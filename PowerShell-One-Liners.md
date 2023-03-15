- [Active Directory Commands](#active-directory)
- [Azure Active Directory](#azure-active-directory)
- [Exchange Online](#exchange-online)
- [Windows](#windows)
- [Random](#random)

# PowerShell One-Liners for Windows Admins

My collection of PowerShell s#!t that is too complicated too remember.

**Note:** For some reason multi-line commands don't work if your past by right clicking into PowerShell, but they willwork if you press <CTRL +V>.

## Active Directory

### Install RSAT
Install all RSAT Tools
```
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
```

Install Group Policy Only
```
Get-WindowsCapability -Name RSAT.GroupPolicy* -Online | Add-WindowsCapability -Online
```

Install AD Only
```
Get-WindowsCapability -Name RSAT.ActiveDirectory* -Online | Add-WindowsCapability -Online
```

### Check RSAT Installation Status ###
```
Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property Name, State
```

### Import AD
```
Import-Module ActiveDirectory
```

### Audit basic user password best practices
Hard Coded AD password settings + last reset and login
```
get-aduser -filter * -SearchBase "OU=Staff,OU=Accounts,DC=domain,DC=local" `
-properties Name, passwordlastset, CannotChangePassword, PasswordNeverExpires, `
lastlogon |  Export-csv c:\temp\UserPasswordAudit.csv -NoTypeInformation
```

Default Domain Password Group Polcy Settings
```
Get-ADDefaultDomainPasswordPolicy
```

Fine Grained Password Policy
```
Get-ADFineGrainedPasswordPolicy -filter *
```

List users who have "password never expires" enabled
```
Get-ADUser -Filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $true)} `
-Properties Name, SamAccountName, DistinguishedName `
|  Export-csv c:\temp\PasswordNeverExpires.csv -NoTypeInformation
```

### Show all DCs and their OS
```
Get-ADDomainController -filter * | select hostname, operatingsystem
```

### Finding Users

Get all users
```
Get-ADUser -Filter *
```
Wildcard name search
```
get-Aduser -Filter {name -like "*robert*"}
```

Limit Get-ADUser to a specific OU
```
Get-ADUser -Filter  * -SearchBase "OU=Staff,OU=Accounts,DC=domain,DC=local"
```

### Display the most recent user login failures
```
Get-EventLog -LogName Security -InstanceId 4625 -Newest 50 | `
Where-Object {$_.Message -like "*failure*"} | `
Select-Object TimeGenerated, MachineName, @{Name="UserName";Expression={$_.ReplacementStrings[5]}}
```

### Restore a workstation's trust relationship
```
Reset-ComputerMachinePassword -Server DomainController -Credential DomainAdmin
```
**Note**: Server = the name of any domain controller & Credential = a domain admin

### Add all members of an OU to an AD group
```
Get-ADUser -Filter * -SearchBase "OU=your_OU,DC=your_domain,DC=com" | `
ForEach-Object {Add-ADGroupMember -Identity "your_group_name" -Members $_.DistinguishedName}
```

### Clear an AD user attribute
```
Get-ADUser -filter * | Set-ADUser -Clear scriptPath
```

### Find locked accounts
```
Search-ADAccount -LockedOut
```

### Remove disabled user accounts from groups
```
Get-ADUser -Filter 'Enabled -eq $false' -Properties MemberOf | `
ForEach-Object {Set-ADObject -Identity $_.DistinguishedName -Remove @{MemberOf= $_.MemberOf}}
```

## Azure Active Directory

### Get MFA Status
```
Get-MsolUser -all | select DisplayName,UserPrincipalName,@{N="MFA Status";`
E={ if( $_.StrongAuthenticationMethods.IsDefault -eq $true) `
{($_.StrongAuthenticationMethods | Where IsDefault -eq $True).MethodType} `
else { "Disabled"}}}
```

## Exchange Online

### Install Exchange Online Management
```
Install-Module ExchangeOnlineManagement
```
### Import & Connect
```
Import-Module ExchangeOnlineManagement ; Connect-ExchangeOnline
```

### Enable Users to Receive Copies of Email Sent to Microsoft 365 Groups
```
Get-Mailbox –Resultsize Unlimited | Set-MailboxMessageConfiguration -EchoGroupMessageBackToSubscribedSender $True
```

### Enable Native External Sender Callouts in Outlook
```
Set-ExternalInOutlook -Enabled $true
```

### Disable Focused Inbox
```
Set-OrganizationConfig -FocusedInboxOn $false
```

### Get information about shared mailboxes
```
Get-Mailbox -Filter {recipienttypedetails -eq "SharedMailbox"} | `
select DisplayName,alias,UserPrincipalName,WhenMailboxCreated,EmailAddresses,`
PrimarySmtpAddress,DeliverToMailboxAndForward,ForwardingAddress,ForwardingSmtpAddress
```
## Windows

### Get Uptime
```
systeminfo | find "System Boot Time"
```
or
```
(Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
```
**Attention M$FT:** Come on bruh, can we not have an easier uptime command? Get-Uptime?!? Seriously.

### Get a list of users logged into a DC
Hey it's like the "who" for \*nix systems - -except unnecissairly complex.
```
Get-WmiObject -Class Win32_LogonSession -ComputerName YourDomainControllerHostnameOrIPAddress | `
Where-Object {$_.LogonType -eq 2 -or $_.LogonType -eq 10} | `
ForEach-Object { (Get-WmiObject -Class Win32_LoggedOnUser -Filter "Dependent='Win32_LogonSession.LogonId=$_'") }
```
or
```
qwinsta /server:YourDomainControllerHostnameOrIPAddress
```

## Random

### Configure TLS 1.2
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```
### Export to CSV with no type info
```
|  Export-csv c:\temp\asdf.csv -NoTypeInformation
```
