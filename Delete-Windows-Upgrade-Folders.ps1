$pathsToDelete = @(
    'C:\$GetCurrent',
    'C:\$WINDOWS.~BT',
    'C:\$SysReset',
    'C:\Windows.old',
    'C:\Windows10Upgrade'
)

foreach ($path in $pathsToDelete) {
    if (Test-Path -Path $path) {
        try {
            Write-Host "Taking ownership of: $path"
            takeown /F "$path" /A /R /D Y | Out-Null

            Write-Host "Granting full access to Administrators for: $path"
            icacls "$path" /grant Administrators:F /T /C | Out-Null

            Write-Host "Removing: $path"
            Remove-Item -Path $path -Force -Recurse
            Write-Host "Successfully removed: $path`n"
        } catch {
            Write-Warning "Failed to process ${path}: $_"
        }
    } else {
        Write-Host "Not found (or no access): $path"
    }
}
