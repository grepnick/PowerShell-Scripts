# Define the username and password
$Username = "myadmin"
$Password = "secure_password"
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

# Check if the user already exists
$User = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
if ($User) {
    Write-Host "User '$Username' already exists. Exiting."
    exit
}

# Create the local user account
New-LocalUser -Name $Username -Password $SecurePassword -PasswordNeverExpires -FullName "My Admin" -Description "Local admin account created via RMM"

# Add the user to the Administrators group
Add-LocalGroupMember -Group "Administrators" -Member $Username

Write-Host "Local administrator account '$Username' has been created successfully."
