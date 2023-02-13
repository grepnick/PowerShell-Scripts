# PowerShell script template that checks if a registry item exists and changes it, or creates it if it doesn't exist.

$registryPath = "HKEY_LOCAL_MACHINE\SOFTWARE\YourKey"
$registryName = "YourValueName"
$newValue = "YourNewValue"

# Valid value types: String, ExpandString, Binary, DWord, MultiString, Qword, Unknown
$valueType = "DWORD"

function UpdateRegistry {
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $newValue -Type $valueType
}

If (Test-Path $registryPath) {
  UpdateRegistry
  Write-Host "Registry item '$registryName' has been updated."
}
Else {
  New-Item -Path $registryPath -Force | Out-Null
  UpdateRegistry
  Write-Host "Registry item '$registryName' has been created."
}
