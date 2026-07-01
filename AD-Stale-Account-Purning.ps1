$role = (Get-WmiObject Win32_ComputerSystem).DomainRole

if ($role -eq 4 -or $role -eq 5) {
    Write-Host "This system is a Domain Controller. Running DC-specific code..."
} else {
    Write-Host "This system is NOT a Domain Controller. Exiting."
    exit 0
} 

Import-Module ActiveDirectory

$InactiveDays = 180
$CutoffDate = (Get-Date).AddDays(-$InactiveDays)

$ExcludedAccounts = @(
    'Administrator',
    'krbtgt',
    'DefaultAccount',
    'WDAGUtilityAccount'
)

Get-ADUser -Filter 'Enabled -eq $true' `
    -Properties LastLogonDate, ServicePrincipalName, Description |
    Where-Object {
        (
            $_.LastLogonDate -lt $CutoffDate -or
            $null -eq $_.LastLogonDate
        ) -and
        $_.SamAccountName -notin $ExcludedAccounts -and
        -not $_.ServicePrincipalName
    } |
    ForEach-Object {
        $Date = Get-Date -Format 'yyyy-MM-dd'
        $Note = "Disabled on $Date due to inactivity."

        $NewDescription = if ([string]::IsNullOrWhiteSpace($_.Description)) {
            $Note
        }
        else {
            "$($_.Description) | $Note"
        }

        Set-ADUser -Identity $_ -Description $NewDescription
        Disable-ADAccount -Identity $_

        $LastLogon = if ($_.LastLogonDate) {
            $_.LastLogonDate.ToString('yyyy-MM-dd')
        }
        else {
            'Never'
        }

        Write-Host "Disabled $($_.SamAccountName) - Last Logon: $LastLogon" -ForegroundColor Yellow
    }
