# Create or update a temporary admin account that expires in 8 hours
# Generates a new random password each time
# Will NOT run on a Domain Controller

# Check if system is a Domain Controller
$role = (Get-CimInstance Win32_ComputerSystem).DomainRole
if ($role -eq 4 -or $role -eq 5) {
    Write-Host "This script cannot be run on a Domain Controller."
    exit 1
}

$userName = "temp.admin"

# Generate random password
$length = 16
$allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{};:,.<>?'
$passwordPlain = -join ((1..$length) | ForEach-Object { $allowedChars[(Get-Random -Maximum $allowedChars.Length)] })
$password = ConvertTo-SecureString $passwordPlain -AsPlainText -Force

$expiryDate = (Get-Date).AddHours(8)

# Check if user exists
$user = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue

if (-not $user) {
    Write-Host "User does not exist. Creating new account..."
    New-LocalUser -Name $userName `
                  -Password $password `
                  -FullName "Temporary Admin" `
                  -Description "Temp admin acct (expires in 8 hrs)"
    
    # Add to Administrators group
    Add-LocalGroupMember -Group "Administrators" -Member $userName

} else {
    Write-Host "User already exists. Updating expiration, password, and enabling account..."

    # Update password
    Set-LocalUser -Name $userName -Password $password

    # Ensure it's enabled
    Enable-LocalUser -Name $userName

    # Ensure it's in the Administrators group
    if (-not (Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.Name -match ("\\?$userName$") })) {
        Add-LocalGroupMember -Group "Administrators" -Member $userName
    }
}

# Set account expiration (works for both new and existing user)
Set-LocalUser -Name $userName -AccountExpires $expiryDate

# Output the generated password securely
Write-Host "User '$userName' is active and will expire at $expiryDate"
Write-Host "Generated password: $passwordPlain"
