$programs = Get-CimInstance -ClassName Win32_Product | Where-Object {
    $_.Name -like "Dell SupportAssist*"
}

if ($programs) {
    foreach ($program in $programs) {
        Write-Host "Found program: $($program.Name)"
        Write-Host "Uninstalling..."
        $result = Invoke-CimMethod -InputObject $program -MethodName Uninstall

        if ($result.ReturnValue -eq 0) {
            Write-Host "Successfully uninstalled: $($program.Name)"
        } else {
            Write-Host "Failed to uninstall: $($program.Name). Return value: $($result.ReturnValue)"
        }
    }
} else {
    Write-Host "No programs starting with 'Dell SupportAssist' were found."
}
