try {
    # Check for the Hyper-V management service
    $HyperV = Get-Service -Name vmms -ErrorAction SilentlyContinue

    if (-not $HyperV) {
        Write-Output "SKIPPED: Hyper-V management service is not installed."
        exit 0
    }

    if ($HyperV.Status -ne 'Running') {
        Write-Output "ERROR: Hyper-V management service is not running."
        exit 0
    }

    # Verify the Hyper-V PowerShell tools are available
    Import-Module Hyper-V -ErrorAction Stop

    # Check only currently running VMs
    $VMs = @(Get-VM -ErrorAction Stop |
        Where-Object {
            $_.State -eq 'Running' -and
            $_.AutomaticStartAction -ne 'Start'
        })

    if ($VMs.Count -gt 0) {
        Write-Output "WARNING: The following VMs are not configured to automatically start:"
        $VMs |
            Select-Object Name, State, AutomaticStartAction |
            Format-Table -AutoSize

        exit 1
    }

    Write-Output "OK: No running VMs lack the Always Start setting."
    exit 0
}
catch {
    Write-Output "ERROR: Unable to check Hyper-V settings. $($_.Exception.Message)"
    exit 2
}
