# Display alert on Windows workstations
$os = Get-CimInstance Win32_OperatingSystem
if ($os.ProductType -eq 1) {
    Write-Host "This is a workstation OS. Sending alert..."
    msg * "Message from IT: Scheduled routine maintenance is about to begin at your location. This process can take up to 1 hour. Please save your work immediately."
}

# Skip excluded Servers
$hostname = $env:COMPUTERNAME
$PmsServers = @(
    "Server1",
    "Server2",
    "Server3"
)

if ($PmsServers -contains $hostname) {
    Write-Host "Host '$hostname' is a excluded server, exiting."
    exit 0
}

# Skip reboot on Hyper-V guests because we will reboot the host system.
$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
if ($computerSystem.Manufacturer -match "Microsoft Corporation" -and
    $computerSystem.Model -match "Virtual Machine") {
    Write-Host "This system appears to be a Hyper-V virtual machine, exiting."
    exit 0
}

# Skip Hyper-V Hosts
#try {
#    $hv = Get-WindowsFeature -Name Hyper-V -ErrorAction Stop
#    if ($hv -and $hv.Installed) {
#        Write-Host "Hyper-V role is installed. Exiting without reboot."
#        exit 0
#    }
#}
#catch {
#    Write-Host "Could not query Windows Features (likely not Server OS). Skipping Hyper-V check."
#}

# Skip reboot if the host has been up for less than two days
$uptime = (Get-Date) - $os.LastBootUpTime
if ($uptime.TotalHours -lt 48) {
    Write-Host "Host has recently rebooted ($([math]::Round($uptime.TotalHours,2)) hours ago). Exiting without reboot."
    exit 0
}

# wait 2 min and reboot
Start-Sleep -Seconds 120
Write-Host "Rebooting..."
Restart-Computer -Force
