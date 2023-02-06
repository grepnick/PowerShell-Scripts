$credential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $Session

$users = Get-MsolUser | Where-Object { $_.BlockCredential -eq $true }

foreach ($user in $users) {
  Write-Host "Processing user: $($user.UserPrincipalName)"
  $licenses = Get-MsolUserLicense -UserPrincipalName $user.UserPrincipalName | Select-Object AccountSkuId

  foreach ($license in $licenses) {
    Write-Host "  Removing license: $($license.AccountSkuId)"
    Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses $license.AccountSkuId
  }
}
