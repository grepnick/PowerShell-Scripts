$volume = "C:"
$bitlockerInfo = Get-BitLockerVolume -MountPoint $volume

if ($bitlockerInfo.ProtectionStatus -eq 'On' -or $bitlockerInfo.VolumeStatus -eq 'FullyEncrypted') {
    # Check if TPM protector exists
    $tpmProtector = $bitlockerInfo.KeyProtector | Where-Object { $_.KeyProtectorType -like "Tpm*" }

    if (-not $tpmProtector) {
        Write-Output "TPM not found in key protectors. Disabling BitLocker on $volume..."
        Disable-BitLocker -MountPoint $volume
    } else {
        Write-Output "TPM protector found. BitLocker will remain enabled on $volume."
    }
} else {
    Write-Output "BitLocker is not enabled on $volume. No action taken."
}
