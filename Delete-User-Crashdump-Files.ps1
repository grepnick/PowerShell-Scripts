$crashDumpTotalSize = 0
$crashDumpFileCount = 0
$deletedFiles = @()

$userDirs = Get-ChildItem "C:\Users" -Directory

foreach ($userDir in $userDirs) {
    $crashDumpPath = Join-Path $userDir.FullName "AppData\Local\CrashDumps"

    if (Test-Path $crashDumpPath) {
        $files = Get-ChildItem $crashDumpPath -File -ErrorAction SilentlyContinue

        foreach ($file in $files) {
            $fileSizeGB = [math]::Round($file.Length / 1GB, 4)
            $crashDumpTotalSize += $file.Length
            $crashDumpFileCount++
            $deletedFiles += "Deleted: $($file.FullName) ($fileSizeGB GB)"
            Remove-Item $file.FullName -Force
        }
    }
}

if ($deletedFiles.Count -gt 0) {
    $deletedFiles | ForEach-Object { Write-Output $_ }
    $totalSizeGB = [math]::Round($crashDumpTotalSize / 1GB, 4)
    Write-Output "`nTotal files deleted: $crashDumpFileCount"
    Write-Output "Total size freed: $totalSizeGB GB"
} else {
    Write-Output "No crash dump files found or deleted."
}
