$users = Get-LocalUser | Where-Object { $_.Enabled -eq $true }

foreach ($user in $users) {
    $userName = $user.Name
    Write-Output "Setting Password Never Expires for: $userName"
    Set-LocalUser -Name $userName -PasswordNeverExpires $true
}
