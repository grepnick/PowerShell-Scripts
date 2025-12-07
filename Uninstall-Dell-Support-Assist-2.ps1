$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $registryPaths) {
    $apps = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -like "Dell SupportAssist*"
    }

    foreach ($app in $apps) {
        Write-Host "Found: $($app.DisplayName)"

        if ($app.UninstallString) {
            $uninstallCmd = $app.UninstallString

            Write-Host "Running: $uninstallCmd"
            
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$uninstallCmd`"" -Wait -NoNewWindow

            Write-Host "Uninstall command executed for: $($app.DisplayName)"
            Start-Sleep -Seconds 10 
        } else {
            Write-Host "No uninstall string found for: $($app.DisplayName)"
        }
    }
}
