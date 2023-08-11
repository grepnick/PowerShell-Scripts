$regKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regValueName = "InactivityTimeoutSecs"
$newValue = 900

if (Test-Path $regKeyPath) {
    Set-ItemProperty -Path $regKeyPath -Name $regValueName -Value $newValue
    Write-Host "Registry value updated successfully."
} else {
    New-Item -Path $regKeyPath -Force | Out-Null
    Set-ItemProperty -Path $regKeyPath -Name $regValueName -Value $newValue
    Write-Host "Registry key and value created successfully."
}
