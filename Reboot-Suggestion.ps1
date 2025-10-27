Add-Type -AssemblyName System.Windows.Forms

$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$uptimeDays = [int]$uptime.TotalDays

if ($uptimeDays -gt 7) {
    $message = "Your system has been up for $uptimeDays days.`nIt is recommended to reboot.`nWould you like to reboot now?"
    $caption = "Reboot Recommended by IT"
    $buttons = [System.Windows.Forms.MessageBoxButtons]::YesNo
    $icon = [System.Windows.Forms.MessageBoxIcon]::Warning

    $result = [System.Windows.Forms.MessageBox]::Show($message, $caption, $buttons, $icon)

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        Restart-Computer -Force
    }
}
