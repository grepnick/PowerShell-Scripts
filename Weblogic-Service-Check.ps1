# Check if any service contains "weblogic" in its name or display name
$services = Get-Service | Where-Object { $_.Name -like "*weblogic*" -or $_.DisplayName -like "*weblogic*" }

if ($services) {
    Write-Host "Found the following WebLogic-related services:"
    $services | Select-Object Name, DisplayName, Status | Format-Table -AutoSize
    exit 1
} else {
    Write-Host "No WebLogic-related services found."
    exit 0
}
