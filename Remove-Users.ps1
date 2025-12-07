$usersToCheck = @('admin', 'probe', 'localadmin', 'recovery','toadmin')

foreach ($user in $usersToCheck) {
    $localUser = Get-LocalUser -Name $user -ErrorAction SilentlyContinue

    if ($null -ne $localUser) {
      Remove-LocalUser -Name $user
      Write-Output "User '$user' deleted."
    }
}

Write-Output "### Local Administrators ###"
Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue | Where-Object { $_.ObjectClass -eq 'User' }
