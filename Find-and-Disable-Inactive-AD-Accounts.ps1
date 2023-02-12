Import-Module ActiveDirectory

$Time = (Get-Date).AddDays(-30)
$SearchBase = "OU=<OU_DistinguishedName>,DC=<DomainName>,DC=<TLD>"
$Users = Get-ADUser -Filter {LastLogonDate -lt $Time} -Properties LastLogonDate -SearchBase $SearchBase

foreach ($User in $Users) {
  Write-Output "Disabling account: $($User.Name)"
  Disable-ADAccount -Identity $User
}
