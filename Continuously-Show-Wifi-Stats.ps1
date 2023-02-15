# Useful for walking a site and monitoring wifi connections as you roam.

while($true) {
    cls
    netsh wlan show interfaces
    Start-Sleep -Seconds 5
}
