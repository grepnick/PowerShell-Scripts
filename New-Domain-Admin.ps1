$Username = "Myadmin"
$Password = ConvertTo-SecureString "password" -AsPlainText -Force
$FullName = "My Admin"
$Group = "Domain Admins"

#Import-Module ActiveDirectory

if (Get-ADUser -Filter {SamAccountName -eq $Username}) {
    Write-Output "User $Username already exists. Exiting."
} else {

    New-ADUser -Name $FullName -SamAccountName $Username -AccountPassword $Password -Enabled $true -PasswordNeverExpires $true -PassThru
    Add-ADGroupMember -Identity $Group -Members $Username    
    Write-Output "User $Username has been created and added to the Domain Admins group."
}
