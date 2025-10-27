# Resolves Windows update issues and cleans up disk space used by temporary update files.
$file = "c:\swdistclean.log"
$Days = 30  # Change this value as needed
$type = "Software distribution cleanup"

if (-Not (Test-Path $file)) {
    Get-Date -Format yyyy-MM-dd | Out-File $file
    Write-Host "Log file created with current date."
} else {
    $date = Get-Content $file
    $fileDate = [datetime]$date
    $daysOld = (Get-Date) - $fileDate

    if ($daysOld.Days -le $Days) {
        Write-Host "$type has already been performed within the last $Days days. ($($daysOld.Days) days ago)"
        exit
    } else {
        Write-Host "$type was last performed over $($daysOld.Days) days ago."
        Get-Date -Format yyyy-MM-dd | Out-File $file
    }
}


$services = "wuauserv", "bits", "cryptsvc", "msiserver"
Write-Host "Stopping update services..." -ForegroundColor Cyan
foreach ($svc in $services) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
}

sleep 20

$folder = "$env:SystemRoot\SoftwareDistribution"

Write-Host "Taking ownership of files in $folder..." -ForegroundColor Yellow
takeown /F "$folder" /R /D Y | Out-Null
icacls "$folder" /grant administrators:F /T /C | Out-Null

Write-Host "Deleting contents of $folder..." -ForegroundColor Yellow
Remove-Item -Path "$folder\*" -Recurse -Force -ErrorAction Stop
Write-Host "Successfully deleted SoftwareDistribution contents." -ForegroundColor Green

Write-Host "Restarting services..." -ForegroundColor Cyan
foreach ($svc in $services) {
    Start-Service -Name $svc -ErrorAction SilentlyContinue
}
