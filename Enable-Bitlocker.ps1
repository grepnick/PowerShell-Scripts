$DriveLetter = "C:"
$EncryptionMethod = "XtsAes128"
$tpm = Get-CimInstance -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm -ErrorAction SilentlyContinue
$bitlockerStatus = Get-BitLockerVolume -MountPoint $DriveLetter
$protectorCount = ($bitlockerStatus.KeyProtector | Measure-Object).Count


# Check BitLocker status
if ($bitlockerStatus.VolumeStatus -eq 'FullyEncrypted') {
    Write-Output "BitLocker is already enabled on $DriveLetter"
    exit
} elseif ($bitlockerStatus.VolumeStatus -eq 'FullyDecrypted'  -and $protectorCount -ge 2) {
    Write-Output "BitLocker already enabled and is pending a reboot to begin encryption."
    exit
}

# Check for TPM
if ($null -eq $tpm) {
    Write-Output "TPM not detected on this system."
    exit 1
} elseif ($tpm.IsEnabled_InitialValue -eq $true -and $tpm.IsActivated_InitialValue -eq $true) {
    Write-Output "TPM is detected and enabled."
} elseif ($tpm.IsEnabled_InitialValue -eq $false) {
    Write-Output "TPM is detected but DISABLED (check BIOS/UEFI settings)."
    exit 1
} else {
    Write-Output "TPM is detected but not fully enabled/activated."
    exit 1
}

# Enable BitLocker with TPM
try {
    Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod -TpmProtector -UsedSpaceOnly -ErrorAction Stop
    Write-Output "BitLocker enabled successfully on $DriveLetter"
}
catch {
    Write-Error "Failed to enable BitLocker on $DriveLetter. Error: $_"
    exit 1
}

# Add Recovery Password Protector
Add-BitLockerKeyProtector -MountPoint $DriveLetter -RecoveryPasswordProtector -Verbose

Write-Output "BitLocker enabled with TPM and Recovery Password on $DriveLetter."
