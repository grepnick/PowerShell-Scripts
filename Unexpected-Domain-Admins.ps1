$role = (Get-WmiObject Win32_ComputerSystem).DomainRole

$ver = [Environment]::OSVersion.Version
if ($ver.Major -eq 6 -and ($ver.Minor -eq 0 -or $ver.Minor -eq 1)) {
    Write-Host "This is Windows Server 2008 or 2008 R2"
    exit 0
}

if ($role -eq 4 -or $role -eq 5) {
    Write-Host "This system is a Domain Controller."

    $allowed = @("administrator", "itadmin")

    $admins = Get-ADGroupMember -Identity "Domain Admins" -Recursive |
    Where-Object { $_.ObjectClass -eq "user" } |
    Get-ADUser -Properties Enabled, LastLogonDate |
    Select-Object Name, SamAccountName, Enabled, LastLogonDate

    $unexpected = $admins | Where-Object { $allowed -notcontains $_.SamAccountName.ToLower() }

    if ($unexpected) {
        Write-Warning "Unexpected Domain Admin accounts detected!"
        $unexpected | Format-Table -AutoSize
        exit 1
    } else {
        Write-Host "No unapproved Domain Admin accounts found."
        exit 0
   }
}
