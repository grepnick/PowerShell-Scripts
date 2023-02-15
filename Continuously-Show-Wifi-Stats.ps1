# It's like of like the Linux watch command, but for monitoring Windows wifi.

function CountdownTimer {
    param([int]$countdownSeconds = 8)
    Write-Host -NoNewline "Refreshing in: "
    while ($countdownSeconds -gt 0) {
        Write-Host -NoNewline "$countdownSeconds "
        Start-Sleep -Seconds 1
        $countdownSeconds--
        Write-Host -NoNewline "`b`b"
    }
}

if ($args) {
    $countdownSeconds = [int]$args[0]
} else {
    do {
        $countdownSeconds = Read-Host "Enter the number of seconds for the countdown timer"
        if (-not $countdownSeconds) {
            Write-Error -Message "Please enter a valid number." -Category InvalidArgument
        } elseif ($countdownSeconds -lt 3) {
            Write-Error -Message "Please enter a number greater than or equal to 3." -Category LimitsExceeded
        }
    } until ($countdownSeconds -ge 3)
}

while($true) {
    cls
    netsh wlan show interfaces
    Write-Host "Press CTRL+C to terminate.`n"
    CountdownTimer $countdownSeconds
}
