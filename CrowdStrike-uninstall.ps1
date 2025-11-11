$url = "https://asdf.com/CsUninstallTool.exe"
$output = "$env:TEMP\CsUninstallTool.exe"
$os = Get-CimInstance Win32_OperatingSystem

$csInstalled = Get-ItemProperty `
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" ,
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "*CrowdStrike*" }

if ($csInstalled) {
    Write-Host "CrowdStrike Falcon appears to be installed."
    $csInstalled | ForEach-Object {
        Write-Host (" - " + $_.DisplayName + " | Version: " + $_.DisplayVersion)
    }
} else {
    Write-Host "CrowdStrike Falcon NOT found in the installed programs list."
    exit 0
}

$uptime = (Get-Date) - $os.LastBootUpTime
if ($uptime.TotalHours -lt 24) {
    Write-Host "Host has recently rebooted ($([math]::Round($uptime.TotalHours,2)) hours ago). Running uninstaller."
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process -FilePath $output -ArgumentList '/quiet' -Wait
} else {
    # Display alert on Windows workstations
  if ($os.ProductType -eq 1) {
      Write-Host "This is a workstation OS. Sending alert..."
      msg * "Message from BlueAlly: Your workstation will reboot in 2 minutes to begin the transition out process from Aimbridge. Please save your work."
  }
  # wait 2 min and reboot
  sleep 120
  Write-Host "Rebooting..."
  Restart-Computer -Force
}
