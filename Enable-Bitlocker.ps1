[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$DriveLetter = 'C:'
$EncryptionMethod = 'XtsAes128'

function Exit-Script {
    param(
        [Parameter(Mandatory)]
        [int]$Code,

        [Parameter(Mandatory)]
        [string]$Message
    )

    if ($Code -eq 0) {
        Write-Output "SUCCESS: $Message"
    }
    else {
        Write-Error "FAILURE: $Message"
    }

    exit $Code
}

function Get-CurrentBitLockerState {
    try {
        return Get-BitLockerVolume -MountPoint $DriveLetter -ErrorAction Stop
    }
    catch {
        Exit-Script -Code 3 -Message "Unable to query BitLocker status for $DriveLetter. $($_.Exception.Message)"
    }
}

function Test-KeyProtector {
    param(
        [Parameter(Mandatory)]
        $BitLockerVolume,

        [Parameter(Mandatory)]
        [string]$ProtectorType
    )

    return [bool](
        $BitLockerVolume.KeyProtector |
            Where-Object { $_.KeyProtectorType -eq $ProtectorType }
    )
}

Write-Output "Checking TPM status..."

# Verify TPM availability and readiness
try {
    $tpm = Get-Tpm -ErrorAction Stop
}
catch {
    Exit-Script -Code 4 -Message "Unable to query the TPM. $($_.Exception.Message)"
}

if (-not $tpm.TpmPresent) {
    Exit-Script -Code 4 -Message 'No compatible TPM was found.'
}

if (-not $tpm.TpmReady) {
    Exit-Script -Code 5 -Message 'The TPM is present but is not ready for use.'
}

Write-Output 'TPM is present and ready.'
Write-Output "Checking BitLocker status on $DriveLetter..."

$bitLocker = Get-CurrentBitLockerState

Write-Output "Volume status:       $($bitLocker.VolumeStatus)"
Write-Output "Protection status:   $($bitLocker.ProtectionStatus)"
Write-Output "Encryption percent:  $($bitLocker.EncryptionPercentage)%"

# Enable BitLocker if the drive is completely decrypted
if (
    $bitLocker.VolumeStatus -eq 'FullyDecrypted' -or
    $bitLocker.EncryptionPercentage -eq 0
) {
    Write-Output "BitLocker encryption is not enabled on $DriveLetter."
    Write-Output "Enabling BitLocker with a TPM protector..."

    try {
        Enable-BitLocker `
            -MountPoint $DriveLetter `
            -EncryptionMethod $EncryptionMethod `
            -UsedSpaceOnly `
            -TpmProtector `
            -SkipHardwareTest `
            -ErrorAction Stop | Out-Null
    }
    catch {
        Exit-Script -Code 6 -Message "Failed to enable BitLocker. $($_.Exception.Message)"
    }

    Write-Output 'BitLocker encryption was started.'

    # Refresh status after enabling BitLocker
    $bitLocker = Get-CurrentBitLockerState
}
elseif (
    $bitLocker.VolumeStatus -notin @(
        'FullyEncrypted'
        'EncryptionInProgress'
        'EncryptionPaused'
    )
) {
    Exit-Script -Code 11 -Message "Unexpected BitLocker volume state: $($bitLocker.VolumeStatus)"
}

# Check TPM protector
$hasTpmProtector = Test-KeyProtector `
    -BitLockerVolume $bitLocker `
    -ProtectorType 'Tpm'

if (-not $hasTpmProtector) {
    Write-Output 'TPM protector is missing. Adding it...'

    try {
        Add-BitLockerKeyProtector `
            -MountPoint $DriveLetter `
            -TpmProtector `
            -ErrorAction Stop | Out-Null
    }
    catch {
        Exit-Script -Code 7 -Message "Failed to add the TPM protector. $($_.Exception.Message)"
    }

    Write-Output 'TPM protector added successfully.'
    $bitLocker = Get-CurrentBitLockerState
}
else {
    Write-Output 'TPM protector is already present.'
}

# Check recovery-password protector
$hasRecoveryProtector = Test-KeyProtector `
    -BitLockerVolume $bitLocker `
    -ProtectorType 'RecoveryPassword'

if (-not $hasRecoveryProtector) {
    Write-Output 'Recovery-password protector is missing. Adding it...'

    try {
        $recoveryResult = Add-BitLockerKeyProtector `
            -MountPoint $DriveLetter `
            -RecoveryPasswordProtector `
            -ErrorAction Stop

        $newRecoveryProtector = $recoveryResult.KeyProtector |
            Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' } |
            Select-Object -Last 1

        Write-Output 'Recovery-password protector added successfully.'

        if ($newRecoveryProtector.KeyProtectorId) {
            Write-Output "Recovery protector ID: $($newRecoveryProtector.KeyProtectorId)"
        }
    }
    catch {
        Exit-Script -Code 8 -Message "Failed to add the recovery-password protector. $($_.Exception.Message)"
    }

    $bitLocker = Get-CurrentBitLockerState
}
else {
    Write-Output 'Recovery-password protector is already present.'
}

# Turn protection on if it is currently off
if ($bitLocker.ProtectionStatus -ne 'On') {
    Write-Output 'BitLocker protection is currently off. Turning it on...'

    try {
        Resume-BitLocker `
            -MountPoint $DriveLetter `
            -ErrorAction Stop | Out-Null
    }
    catch {
        Exit-Script -Code 9 -Message "Failed to turn on BitLocker protection. $($_.Exception.Message)"
    }

    Write-Output 'BitLocker protection was turned on.'
}

# Final validation
$bitLocker = Get-CurrentBitLockerState

$hasTpmProtector = Test-KeyProtector `
    -BitLockerVolume $bitLocker `
    -ProtectorType 'Tpm'

$hasRecoveryProtector = Test-KeyProtector `
    -BitLockerVolume $bitLocker `
    -ProtectorType 'RecoveryPassword'

$encryptionEnabled = (
    $bitLocker.VolumeStatus -in @(
        'FullyEncrypted'
        'EncryptionInProgress'
    )
)

$protectionEnabled = $bitLocker.ProtectionStatus -eq 'On'

Write-Output ''
Write-Output 'Final BitLocker status:'
Write-Output "  Drive:                       $DriveLetter"
Write-Output "  Volume status:               $($bitLocker.VolumeStatus)"
Write-Output "  Protection status:           $($bitLocker.ProtectionStatus)"
Write-Output "  Encryption percentage:       $($bitLocker.EncryptionPercentage)%"
Write-Output "  TPM protector present:       $hasTpmProtector"
Write-Output "  Recovery protector present:  $hasRecoveryProtector"

if (
    -not $encryptionEnabled -or
    -not $protectionEnabled -or
    -not $hasTpmProtector -or
    -not $hasRecoveryProtector
) {
    Exit-Script -Code 10 -Message 'BitLocker failed final validation.'
}

Exit-Script -Code 0 -Message 'BitLocker is enabled and protected with both TPM and recovery-password protectors.'
