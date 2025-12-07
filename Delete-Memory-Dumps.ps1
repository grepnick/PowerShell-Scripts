$dumpLocations = @(
    "$env:SystemRoot\Minidump",
    "$env:SystemRoot\MEMORY.DMP",
    "$env:LocalAppData\CrashDumps"
    "C:\Windows\SysWOW64\config\systemprofile\AppData\Local\CrashDumps"
    "C:\Windows\system32"
)

$deletedCount = 0
$totalFreed = 0

foreach ($location in $dumpLocations) {
    if (Test-Path $location) {
        if (Test-Path $location -PathType Container) {
            $dmpFiles = Get-ChildItem -Path $location -Filter *.dmp -Recurse -ErrorAction SilentlyContinue
        } elseif (Test-Path $location -PathType Leaf) {
            $dmpFiles = Get-Item -Path $location -ErrorAction SilentlyContinue
        }

        foreach ($file in $dmpFiles) {
            try {
                $fileSize = $file.Length
                Remove-Item $file.FullName -Force -ErrorAction Stop
                $deletedCount++
                $totalFreed += $fileSize
                Write-Host "Deleted: $($file.FullName) - $([math]::Round($fileSize / 1MB, 2)) MB"
            } catch {
                Write-Warning "Failed to delete: $($file.FullName) - $_"
            }
        }
    }
}

Write-Host "`nTotal files deleted: $deletedCount"
Write-Host "Total space freed: $([math]::Round($totalFreed / 1MB, 2)) MB"
