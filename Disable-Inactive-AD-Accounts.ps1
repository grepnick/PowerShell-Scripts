$inactiveThreshold = (Get-Date).AddDays(-90)

Get-ADUser -Filter { LastLogonTimeStamp -lt $inactiveThreshold } -Properties LastLogonTimeStamp | 
ForEach-Object { 
  Set-ADUser $_.DistinguishedName -Enabled $false 
  Write-Host "Account for user '$($_.Name)' has been disabled." 
}
