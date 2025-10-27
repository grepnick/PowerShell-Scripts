$bitlockerVolume = Get-BitLockerVolume -MountPoint "C:"

if ($bitlockerVolume.VolumeStatus -eq 'FullyEncrypted') {
    Write-Host "BitLocker is enabled on drive C:."

    $recoveryKey = $bitlockerVolume.KeyProtector | Where-Object {
        $_.KeyProtectorType -eq 'RecoveryPassword'
    }

    if ($recoveryKey) {
        Write-Host "BitLocker recovery key exists for drive C:."
        Write-Host "Recovery Key ID: $($recoveryKey.KeyProtectorId)"
    } else {
        Write-Host "No BitLocker recovery key found for drive C:. Creating..."
        Add-BitLockerKeyProtector -MountPoint C: -RecoveryPasswordProtector -Verbose
    }
} else {
    Write-Host "BitLocker is not enabled on drive C:."
}
