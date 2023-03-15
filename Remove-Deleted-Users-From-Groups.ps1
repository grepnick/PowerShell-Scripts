# Scan Active Directory groups for deleted user account references and remove them

$groups = Get-ADGroup -Filter *
foreach ($group in $groups) {
  $members = Get-ADGroupMember $group | where {$_.objectClass -eq "user"}
  foreach ($member in $members) {
    $user = Get-ADUser -Identity $member.SamAccountName -Properties SID
    if ($user -eq $null) {
      Write-Host "Removing $($member.SamAccountName) from $($group.Name)"
      Remove-ADGroupMember $group -Members $member -Confirm:$false
    }
  }
}
