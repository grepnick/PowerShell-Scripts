# PowerShell Script to rename the Windows SoftwareDistribution folder, which can help solve many Windows update issues.
$oldName = "$env:SystemRoot\SoftwareDistribution"
$newName = "$env:SystemRoot\SoftwareDistribution_Old"

Stop-Service -Name "wuauserv" -Force
Stop-Service -Name "bits" -Force

sleep 20

If (Test-Path $oldName) {
  if (Test-Path $newName) {
    Remove-Item $newName -Recurse -Force
  }
  Rename-Item $oldName $newName -Force
  Write-Host "SoftwareDistribution folder renamed to $newName"
}
Else {
  Write-Host "SoftwareDistribution folder not found"
}

Start-Service -Name "wuauserv"
Start-Service -Name "bits"
