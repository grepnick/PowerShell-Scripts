# It's kind of like ifstat, but for wifi... and for Windows.

Write-Host "`n`nWireless statistics (press CTRL+C to stop):`n`n"

while ($true) {
    $output = netsh wlan show interfaces
    $name = $output | Select-String "Name" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $description = $output | Select-String "Description" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $guid = $output | Select-String "GUID" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $physical_address = $output | Select-String "Physical address" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $state = $output | Select-String "State" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $ssid = $output | Select-String "SSID" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $bssid = $output | Select-String "BSSID" | ForEach-Object { $_.ToString().Split(":", 2)[1].Trim() -join ":" }
    $network_type = $output | Select-String "Network type" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $radio_type = $output | Select-String "Radio type" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $authentication = $output | Select-String "Authentication" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $cipher = $output | Select-String "Cipher" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $connection_mode = $output | Select-String "Connection mode" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $wirelessBand = $output | Select-String "Band" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $wirelessChannel = $output | Select-String "Channel" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $receiveRate = $output | Select-String "Receive rate" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $transmitRate = $output | Select-String "Transmit rate" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $signalStrength = $output | Select-String "Signal" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    Write-Host "Signal Strength: $signalStrength | TX Rate: $transmitRate Mbps | RX Rate: $receiveRate Mbps | Band: $wirelessBand | Channel: $wirelessChannel | AP: $bssid"
    Start-Sleep -Seconds 1
}
