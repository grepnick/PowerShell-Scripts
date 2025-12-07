# Set the path to scan
$path = "C:\ProgramData"

# Find all .dmp files
$dmpFiles = Get-ChildItem -Path $path -Recurse -Filter *.dmp -Force -ErrorAction SilentlyContinue

# Initialize counters
$totalSizeBytes = 0
$fileCount = 0

# Delete files and list them with size
foreach ($file in $dmpFiles) {
    try {
        $sizeGB = [math]::Round($file.Length / 1GB, 4)
        Write-Host "Deleting: $($file.FullName) [$sizeGB GB]"
        $totalSizeBytes += $file.Length
        Remove-Item -Path $file.FullName -Force -ErrorAction Stop
        $fileCount++
    } catch {
        Write-Host "Failed to delete: $($file.FullName) - $_" -ForegroundColor Red
    }
}

# Final totals
$totalSizeGB = [math]::Round($totalSizeBytes / 1GB, 4)
Write-Host "`nDeleted $fileCount .dmp file(s), totaling $totalSizeGB GB." -ForegroundColor Green
