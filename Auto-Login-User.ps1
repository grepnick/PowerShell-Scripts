$userName = "user"
$password = "password"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

if (Get-LocalUser -Name $userName -ErrorAction SilentlyContinue) {
    Write-Host "User '$userName' already exists."
    exit
} else {
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $userName -Password $securePassword -PasswordNeverExpires -FullName "Auto Login User" -Description "Auto-login user"
    Write-Host "User '$userName' created successfully."

    # (Optional) Add user to Administrators group
    # Add-LocalGroupMember -Group "Administrators" -Member $userName
}

Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value $userName
Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $password

# (Optional) Specify the default domain name (use computer name if local account)
#$computerName = $env:COMPUTERNAME
#Set-ItemProperty -Path $regPath -Name "DefaultDomainName" -Value $computerName

Write-Host "Autologin configured for user '$userName'."
