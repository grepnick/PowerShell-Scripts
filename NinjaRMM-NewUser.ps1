# Creates a new admin user and sets the password from the parameter prompt in NinjaOne RMM
param (
    [Parameter(Mandatory = $true)]
    [string]$Password
)

$role = (Get-WmiObject Win32_ComputerSystem).DomainRole

# Define the username
$Username = "myadmin"
$FullName = "Admin User"
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

# Check if the user already exists
$User = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
if ($User) {
    Write-Host "User '$Username' already exists. Updating password and ensuring account is enabled..."

    Set-LocalUser -Name $Username -Password $SecurePassword
    Set-LocalUser -Name $Username -PasswordNeverExpires 1
    Enable-LocalUser -Name $Username

    Write-Host "Password for '$Username' has been updated."
    exit
}

# Runs code specific to local workstations or domain controllers.
if ($role -eq 4 -or $role -eq 5) {
    Write-Host "This system is a Domain Controller. Running DC-specific code..."

    $Group = "Domain Admins"
    New-ADUser -Name $FullName -SamAccountName $Username -AccountPassword $SecurePassword -Enabled $true -PasswordNeverExpires $true -PassThru
    Add-ADGroupMember -Identity $Group -Members $Username    

    Write-Output "User $Username has been created and added to the Domain Admins group."
} else {
    Write-Host "This system is NOT a Domain Controller. Running member code..."

    New-LocalUser -Name $Username -Password $SecurePassword -PasswordNeverExpires -FullName $FullName -Description "Local admin account created via RMM"
    Add-LocalGroupMember -Group "Administrators" -Member $Username

    Write-Host "Local administrator account '$Username' has been created successfully."

} 
