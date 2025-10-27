# Resets the search index file if it is larger than 5GB.
$files = @(
    "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb",
    "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.db"
)

$limitGB = 5
$limitBytes = $limitGB * 1GB
$resetNeeded = $false

foreach ($file in $files) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        $name = Split-Path $file -Leaf
        Write-Host "$name size: $([math]::Round($size / 1GB, 2)) GB"

        if ($size -gt $limitBytes) {
            Write-Warning "$name exceeds $limitGB GB. Marked for deletion."
            $resetNeeded = $true
        } else {
            Write-Host "$name is within size limits." -ForegroundColor Yellow
        }
    } else {
        Write-Host "File not found: $file" -ForegroundColor Red
    }
}

if ($resetNeeded) {
    Write-Host "Resetting Windows Search..." -ForegroundColor Cyan
    try {
        Stop-Service -Name "WSearch" -Force -ErrorAction Stop
        Write-Host "Service stopped." -ForegroundColor Green
        Start-Sleep -Seconds 30

        foreach ($file in $files) {
            if (Test-Path $file) {
                try {
                    Remove-Item $file -Force -ErrorAction Stop
                    Write-Host "Deleted: $(Split-Path $file -Leaf)" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to delete ${file}: $_"
                }
            }
        }

        Start-Service -Name "WSearch" -ErrorAction Stop
        Write-Host "Service restarted." -ForegroundColor Green
    } catch {
        Write-Host "Error during reset: $_"
    }
} else {
    Write-Host "No oversized files found. No reset needed." -ForegroundColor Cyan
}
