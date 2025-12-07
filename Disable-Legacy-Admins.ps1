$usersToCheck = @('user1', 'user2', 'user3')

foreach ($user in $usersToCheck) {
    $localUser = Get-LocalUser -Name $user -ErrorAction SilentlyContinue

    if ($null -ne $localUser) {
        if (-not $localUser.Enabled) {
            Write-Output "User '$user' already disabled."
        } else {
            Disable-LocalUser -Name $user
            Write-Output "User '$user' found and disabled."
        }
    } else {
        Write-Output "User '$user' does not exist."
    }
}
