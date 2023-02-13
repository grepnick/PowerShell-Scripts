# PowerShell script to disable accounts older than 90 days and move the 

$inactiveThreshold = (Get-Date).AddDays(-90)
$ou = "OU=Disabled Users,DC=yourdomain,DC=com"

Get-ADUser -Filter { LastLogonTimeStamp -lt $inactiveThreshold } -Properties LastLogonTimeStamp | 
ForEach-Object { 
  Set-ADUser $_.DistinguishedName -Enabled $false 
  Move-ADObject $_.DistinguishedName -TargetPath $ou
  Write-Host "Account for user '$($_.Name)' has been disabled and moved to $ou." 
}
