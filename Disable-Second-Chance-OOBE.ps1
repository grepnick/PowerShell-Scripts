# Run a user not system
$Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement'
New-Item -Path $Path -Force | Out-Null
New-ItemProperty -Path $Path -Name 'ScoobeSystemSettingEnabled' `
    -PropertyType DWord -Value 0 -Force | Out-Null

Write-Output "SCOOBE disabled for '$env:USERNAME'."
