
$cutoffDate = (Get-Date).AddDays(-30)

# Get list of user profile directories
$userDirs = Get-ChildItem "C:\Users" -Directory | Where-Object {
    $_.Name -notin @("All Users", "Default", "Default User", "Public")
}

foreach ($userDir in $userDirs) {
    $tempPath = Join-Path -Path $userDir.FullName -ChildPath "AppData\Local\Temp"
    
    if (Test-Path $tempPath) {
        Write-Output "Cleaning temp files for: $($userDir.Name)"

        # Remove files older than 30 days
        Get-ChildItem -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoffDate } |
        ForEach-Object {
            try {
                #Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
                Write-Output "Deleted: $($_.FullName)"
            } catch {
                Write-Warning "Could not delete: $($_.FullName) - $($_.Exception.Message)"
            }
        }
    } else {
        Write-Output "Temp path does not exist for: $($userDir.Name)"
    }
}
