$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath | Out-Null
}

New-ItemProperty `
    -Path $regPath `
    -Name "InactivityTimeoutSecs" `
    -PropertyType DWord `
    -Value 600 `
    -Force
