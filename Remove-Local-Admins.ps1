$computerName = $env:COMPUTERNAME
$excludedAccounts = "Administrator", "itadmin" # Add accounts to exclude, comma-separated

$localAdmins = Get-LocalGroupMember -Name "Administrators"

foreach ($user in $localAdmins) {
    if ($user.ObjectClass -eq "User" -and $excludedAccounts -notcontains $user.Name) {
        try {
            Remove-LocalGroupMember -Group "Administrators" -Member $user.Name -ErrorAction Stop
            Write-Host "Removed user ${$user.Name} from local administrators group on $computerName"
        } catch {
            Write-Warning "Failed to remove user ${$user.Name} from local administrators group on $computerName: ${$_.Exception.Message}"
        }
    }
}
