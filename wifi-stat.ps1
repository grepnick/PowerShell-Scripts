# It's kind of like iostat, but for wifi... and for Windows.

Write-Host "`n`nWireless statistics (press CTRL+C to stop):`n`n"

while ($true) {
    $signalStrength = (netsh wlan show interfaces) -Match '^\s+Signal' -Replace '^\s+Signal\s+:\s+',''
    $wirelessBand = (netsh wlan show interfaces) -Match '^\s+Band' -Replace '^\s+Band\s+:\s+',''
    $wirelessChannel = (netsh wlan show interfaces) -Match '^\s+Channel' -Replace '^\s+Channel\s+:\s+',''
    $receiveRate = (netsh wlan show interfaces) -Match '^\s+Receive' -Replace '^\s+Receive\s+rate\s+\(Mbps\)\s+:\s+',''
    $transmitRate = (netsh wlan show interfaces) -Match '^\s+Transmit' -Replace '^\s+Transmit\s+rate\s+\(Mbps\)\s+:\s+',''
    $wirelessBSSID = (netsh wlan show interfaces) -Match '^\s+BSSID' -Replace '^\s+BSSID\s+:\s+',''
    Write-Host "Signal Strength: $signalStrength | Transmit Rate: $transmitRate Mbps | Receive Rate: $receiveRate Mbps | Wireless Band: $wirelessBand | Channel: $wirelessChannel | AP: $wirelessBSSID"
    Start-Sleep -Seconds 1
}
