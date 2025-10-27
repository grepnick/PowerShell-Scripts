Write-Host "Searching for Zscaler-related products..." -ForegroundColor Cyan

try {
    $zscalerApps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Zscaler*" }

    if ($zscalerApps.Count -eq 0) {
        Write-Host "No Zscaler-related products found." -ForegroundColor Yellow
        exit 0
    }

    foreach ($app in $zscalerApps) {
        Write-Host "Attempting to uninstall: $($app.Name)" -ForegroundColor Cyan
        try {
            $result = $app.Uninstall()
            if ($result.ReturnValue -eq 0) {
                Write-Host "Successfully uninstalled: $($app.Name)" -ForegroundColor Green
            } else {
                Write-Warning "Failed to uninstall $($app.Name). Return code: $($result.ReturnValue)"
            }
        } catch {
            Write-Error "Exception occurred while uninstalling $($app.Name): $_"
        }
    }
} catch {
    Write-Error "Error querying installed programs: $_"
}
