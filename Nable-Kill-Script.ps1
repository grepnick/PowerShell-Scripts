$targetPublishers = @(
    "N-able",
    "N-able Technologies",
    "N-able Technologies Ltd."
)

$targetServices = @(
    "SolarWinds.MSP.RpcServerService",
    "Advanced Monitoring Agent",
    "NetworkManagement",
    "Automation Manager Agent"
)

function Stop-ProcessesByName($processNames) {
    foreach ($name in $processNames) {
        $processes = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($processes) {
            Write-Host "Found running processes named '$name'. Stopping them..."
            foreach ($proc in $processes) {
                try {
                    Stop-Process -Id $proc.Id -Force -ErrorAction Stop
                    Write-Host "Stopped process '$name' with ID $($proc.Id)"
                }
                catch {
                    Write-Warning "Failed to stop process '$name' with ID $($proc.Id): $_"
                }
            }
        } else {
            Write-Host "No running processes found with name '$name'."
        }
    }
}


function Get-InstalledSoftware {
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $paths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.Publisher -and ($targetPublishers -contains $_.Publisher) }
    }
}

Write-Host "Checking for hung uninstall-related processes..."

Stop-ProcessesByName @("msiexec", "unins000")
Start-Sleep -Seconds 5

foreach ($serviceName in $targetServices) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq 'Running') {
            Write-Host "Stopping service: $serviceName"
            Stop-Service -Name $serviceName -Force -ErrorAction Stop
            Write-Host "Service stopped: $serviceName"
        }
    } catch {
        Write-Warning "Could not stop service: $serviceName. Error: $_"
    }
}

$softwareList = Get-InstalledSoftware

if ($softwareList.Count -eq 0) {
    Write-Host "No software found from specified publishers."
} else {
    foreach ($app in $softwareList) {
        Write-Host "Uninstalling: $($app.DisplayName) by $($app.Publisher)"
        if ($app.UninstallString) {
            try {
                $uninstallCmd = $app.UninstallString.Trim()

                if ($uninstallCmd -match "msiexec") {
                    if ($uninstallCmd -notmatch "/quiet") {
                        $uninstallCmd += " /quiet /norestart"
                    }
                } else {
                    if ($uninstallCmd -notmatch "/silent") {
                        $uninstallCmd += " /silent"
                    }
                }

                Write-Host "Running: $uninstallCmd"
                Start-Process "cmd.exe" -ArgumentList "/c `"$uninstallCmd`"" -Wait -WindowStyle Hidden

                Write-Host "Successfully triggered uninstall for: $($app.DisplayName)"
            } catch {
                Write-Warning "Failed to uninstall: $($app.DisplayName). Error: $_"
            }
        } else {
            Write-Warning "No uninstall string found for: $($app.DisplayName)"
        }
    }
}
