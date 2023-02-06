# PowerShell Script to rename the Windows SoftwareDistribution folder which can help solve update issues.
$oldName = "$env:SystemRoot\SoftwareDistribution"
$newName = "$env:SystemRoot\SoftwareDistribution_Old"

Stop-Service -Name "wuauserv" -Force
Stop-Service -Name "bits" -Force

# Sleep for 15 seconds to allow the services to stop and release the directory
sleep 15

If (Test-Path $oldName) {
  Rename-Item $oldName $newName -Force
  Write-Host "SoftwareDistribution folder renamed to $newName"
}
Else {
  Write-Host "SoftwareDistribution folder not found"
}

Start-Service -Name "wuauserv"
Start-Service -Name "bits"
