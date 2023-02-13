Import-Module ActiveDirectory
Import-Module MSOnline

# Variables
$sharedMailboxName = "Deleted User Account"
$retentionPolicyTagName = "RetentionHold"

# Prompt for userPrincipalName
$userPrincipalName = Read-Host "Enter the userPrincipalName of the account to be deleted and restored"

# Confirm before executing the remaining tasks
$confirm = Read-Host "Are you sure you want to delete and restore the user account with userPrincipalName '$userPrincipalName'? (Y/N)"
if ($confirm -ne "Y") {
    Write-Host "Operation cancelled."
    return
}

# Delete the user from Active Directory
Get-ADUser -Filter "UserPrincipalName -eq '$userPrincipalName'" | Remove-ADUser

# Restore the deleted user in Microsoft 365
Get-MsolUser -ReturnDeletedUsers -SearchString $userPrincipalName | Restore-MsolUser

# Convert the user to a shared mailbox
Set-Mailbox -Identity $userPrincipalName -Type Shared

# Rename the shared mailbox
Set-Mailbox -Identity $userPrincipalName -DisplayName $sharedMailboxName

# Apply the retention hold to the shared mailbox
$retentionPolicyTag = Get-RetentionPolicyTag | Where-Object { $_.DisplayName -eq $retentionPolicyTagName }
Set-Mailbox -Identity $userPrincipalName -RetentionPolicy $retentionPolicyTag.RetentionPolicy

# Remove all licenses for the user
$licenses = Get-MsolUser -UserPrincipalName $userPrincipalName | Select-Object -ExpandProperty Licenses
$licenses | ForEach-Object { Set-MsolUserLicense -UserPrincipalName $userPrincipalName -RemoveLicenses $_.AccountSkuId }
