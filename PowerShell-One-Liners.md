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

## Exchange Online

### instlla 
How to Enable Users to Receive Copies of Email They Send to Microsoft 365 Groups
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module ExchangeOnlineManagement
Connect-ExchangeOnline
Get-Mailbox –Resultsize Unlimited | Set-MailboxMessageConfiguration -EchoGroupMessageBackToSubscribedSender $True![image](https://user-images.githubusercontent.com/124594745/224886211-2ca4d2a4-6b47-4d89-88ad-aecccc2278ba.png)




## Random

### Configure TLS 1.2
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```
