# PowerShell script template that checks if a registry item exists and changes it, or creates it if it doesn't exist.
$registryPath = "HKEY_LOCAL_MACHINE\SOFTWARE\YourKey"
$registryName = "YourValueName"
$newValue = "YourNewValue"

If (Test-Path $registryPath) {
  Set-ItemProperty -Path $registryPath -Name $registryName -Value $newValue
  Write-Host "Registry item '$registryName' has been updated."
}
Else {
  New-Item -Path $registryPath -Force | Out-Null
  Set-ItemProperty -Path $registryPath -Name $registryName -Value $newValue
  Write-Host "Registry item '$registryName' has been created."
}
