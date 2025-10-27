$file = "c:\componentclean.log"
$Days = 30  # Change this value as needed
$type = "Componet store cleanup"

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

Dism.exe /Online /Cleanup-Image /StartComponentCleanup
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
