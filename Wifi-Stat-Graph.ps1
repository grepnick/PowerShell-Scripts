# Hide the cursor
[Console]::CursorVisible = $false
clear

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

function Show-SignalStrengthBarGraph {
    param(
        [int]$signalStrength
    )

    $maxSignalStrength = 100
    $numBars = 20
    $numFilledBars = [math]::Round(($signalStrength / $maxSignalStrength) * $numBars)
    $numEmptyBars = $numBars - $numFilledBars

    # Color scale from red to yellow to green
    $colorRed = [System.ConsoleColor]::Red
    $colorYellow = [System.ConsoleColor]::Yellow
    $colorGreen = [System.ConsoleColor]::Green

    # Determine the color of the filled bars based on the signal strength
    if ($signalStrength -lt 33) {
        $filledBarColor = $colorRed
    } elseif ($signalStrength -lt 67) {
        $filledBarColor = $colorYellow
    } else {
        $filledBarColor = $colorGreen
    }

    # Set the console foreground color to the color of the filled bars
    Write-Host -NoNewline "Signal ["
    [Console]::ForegroundColor = $filledBarColor
    Write-Host -NoNewline ("#" * $numFilledBars)

    # Set the console foreground color back to the default color
    [Console]::ResetColor()
    Write-Host -NoNewline ("-" * $numEmptyBars)

    Write-Host -NoNewline "] $signalStrength%"
} #NICE!

Write-Host "`n`nWireless statistics (press CTRL+C to stop):`n`n"

while ($true) {
    Clear-Host
    $output = netsh wlan show interfaces
    $name = $output | Select-String "Name" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $description = $output | Select-String "Description" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $guid = $output | Select-String "GUID" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $physical_address = $output | Select-String "Physical address" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $state = $output | Select-String "State" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    $ssid = $output  -NotLike "*BSSID*" |Select-String "SSID" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
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
    $signalStrength = $output | Select-String "Signal" | ForEach-Object { $_.ToString().Split(":")[1].Trim().TrimEnd('%') }
    $ipAddress = Get-NetIPAddress -InterfaceAlias $name | Where-Object {$_.AddressFamily -eq "IPv4"} | Select-Object -ExpandProperty IPAddress


    
    Write-Host "SSID: $ssid $bssid"
    Write-Host "Band: $wirelessBand"
    Write-Host "Channel: $wirelessChannel"
    Write-Host "TX Rate: $transmitRate Mbps"
    Write-Host "RX Rate: $receiveRate Mbps"
    Write-Host "IP Address: $ipAddress`n"

    Show-SignalStrengthBarGraph -signalStrength $signalStrength
    #Start-Sleep -Seconds 5
    Write-Host "`n`nPress CTRL+C to terminate.`n"
    CountdownTimer $countdownSeconds
}
