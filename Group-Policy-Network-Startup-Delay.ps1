# Sets the GpNetworkStartTimeoutPolicyValue to 60
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$RegistryName = "GpNetworkStartTimeoutPolicyValue"
$RegistryValue = 60

# Check if the registry key exists, create it if not
if (-not (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force
}

# Set the registry value
Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue

Write-Host "GpNetworkStartTimeoutPolicyValue set to $RegistryValue"
