# Windows PowerShell One-Liners

My collection of PowerShell s#!t that is too complicated too remember.

## Security Related

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
Note: Server = the name of any domain controller & Credential = a domain admin

### Add all members of an OU to an AD group
```
Get-ADUser -Filter * -SearchBase "OU=your_OU,DC=your_domain,DC=com" | `
ForEach-Object {Add-ADGroupMember -Identity "your_group_name" -Members $_.DistinguishedName}
```

### List users who have "password never expires
```
Get-ADUser -Filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $true)} -Properties Name, SamAccountName, DistinguishedName
```

## Active Directory

### Import module
```
Import-Module ActiveDirectory
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

### Get information about shared mailboxes
```
Get-Mailbox -Filter {recipienttypedetails -eq "SharedMailbox"} | `
select DisplayName,alias,UserPrincipalName,WhenMailboxCreated,EmailAddresses,`
PrimarySmtpAddress,DeliverToMailboxAndForward,ForwardingAddress,ForwardingSmtpAddress
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
