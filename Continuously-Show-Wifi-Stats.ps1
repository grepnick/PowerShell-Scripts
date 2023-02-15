function CountdownTimer {
$countdownSeconds = 8
Write-Host -NoNewline "Refreshing in: "
    while ($countdownSeconds -gt 0) {
        Write-Host -NoNewline "$countdownSeconds "
        Start-Sleep -Seconds 1
        $countdownSeconds--
        Write-Host -NoNewline "`b`b"

    }
}

while($true) {
    cls
    netsh wlan show interfaces
    CountdownTimer
}
