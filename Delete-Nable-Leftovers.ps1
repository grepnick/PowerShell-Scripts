$targetPaths = @(
    "C:\Program Files (x86)\N-able Technologies",
    "C:\Program Files\N-able Technologies"
)

foreach ($targetPath in $targetPaths) {
    if (Test-Path $targetPath) {
        try {
            Write-Host "Taking ownership of: $targetPath"
            takeown.exe /F "$targetPath" /R /D Y | Out-Null

            Write-Host "Granting full control permissions to current user"
            $currentUser = "$($env:USERDOMAIN)\$($env:USERNAME)"
            icacls.exe "$targetPath" /grant "${currentUser}:(OI)(CI)F" /T | Out-Null

            Write-Host "Deleting: $targetPath"
            Remove-Item -Path $targetPath -Recurse -Force -ErrorAction Stop
            Write-Host "Deleted successfully: $targetPath`n"
        } catch {
            Write-Warning "Failed to delete ${targetPath}: $_"
        }
    } else {
        Write-Host "Path does not exist: $targetPath"
    }
}
