$services = Get-Service | Where-Object { $_.Name -like "*asdf*" -or $_.DisplayName -like "*asdf*" }

if ($services) {
    Write-Host "Found the followig services:"
    $services | Select-Object Name, DisplayName, Status | Format-Table -AutoSize
    exit 1
} else {
    Write-Host "No WebLogic-related services found."
    exit 0
}
