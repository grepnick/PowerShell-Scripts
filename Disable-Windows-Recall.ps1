$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'
$valueName = 'AllowRecallEnablement'
$valueData = 0

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}

New-ItemProperty -Path $regPath -Name $valueName -Value $valueData -PropertyType DWORD -Force

Write-Host "Registry value set: $regPath\$valueName = $valueData"
