# It's kind of like the Linux watch command, but for monitoring Windows wifi.

function CountdownTimer {
    param([int]$countdownSeconds = 5)
    Write-Host -NoNewline "Refreshing in: "
    while ($countdownSeconds -gt 0) {
        Write-Host -NoNewline "$countdownSeconds "
        Start-Sleep -Seconds 1
        if ( $countdownSeconds -ge 10) {
            Write-Host -NoNewline "`b`b`b"
        } else {
            Write-Host -NoNewline "`b`b"
        }
        $countdownSeconds--
    }
}

if (($args) -and ($args[0] -ge 3) -and ($args[0] -le 99)) {
    $countdownSeconds = [int]$args[0]
} else {
    do {
        [int]$countdownSeconds = Read-Host "Enter the number of seconds (3-99) for the countdown timer"
        if ( -not $countdownSeconds) {
            Write-Error -Message "Please enter a valid number." -Category InvalidArgument
        } elseif ($countdownSeconds -lt 3) {
            Write-Error -Message "Please enter a number greater than or equal to 3." -Category LimitsExceeded
        } elseif ($countdownSeconds -gt 99) {
            Write-Error -Message "Please enter a number less than or equal to 99." -Category LimitsExceeded
        }
    } until (($countdownSeconds -ge 3) -and ($countdownSeconds -le 99))
}

while($true) {
    cls
    netsh wlan show interfaces
    Write-Host "Press CTRL+C to terminate.`n"
    CountdownTimer $countdownSeconds
}
