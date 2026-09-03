# Checks if autologin is enabled for application servers that run in realtime mode.

$UninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$ApplicationInstalled = Get-ItemProperty -Path $UninstallPaths -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -ieq "SOFTWARE NAME" } |
    Select-Object -First 1

if (-not $ApplicationInstalled) {
    Write-Host "Software is not installed. Autologin check is not applicable."
    exit 0
}

$WinlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$Winlogon = Get-ItemProperty -Path $WinlogonPath -ErrorAction SilentlyContinue
$ValidUserNames = @("username", "variation")

if (
    $Winlogon.AutoAdminLogon -eq "1" -and
    $Winlogon.DefaultUserName -in $ValidUserNames
) {
    Write-Host "Autologin is enabled and configured for $($Winlogon.DefaultUserName)."
    exit 0
}

Write-Host "Software is installed, but autologin is not enabled."
exit 1
