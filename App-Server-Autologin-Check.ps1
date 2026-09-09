# Checks for shitty Oracle POS software and ensures it is setup to autologin because they don't
# understand how services work apparently.
$UninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$ApplicationInstalled = Get-ItemProperty -Path $UninstallPaths -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -ieq "WIN32 CAL Client" } |
    Select-Object -First 1

if (-not $ApplicationInstalled) {
    Write-Host "WIN32 CAL Client is not installed. Autologin check is not applicable."
    exit 0
}

$WinlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$Winlogon = Get-ItemProperty -Path $WinlogonPath -ErrorAction SilentlyContinue
$ValidUserNames = @("caps.user", "micros")

if (
    $Winlogon.AutoAdminLogon -eq "1" -and
    $Winlogon.DefaultUserName -in $ValidUserNames
) {
    Write-Host "Autologin is enabled and configured for $($Winlogon.DefaultUserName)."
    exit 0
}

Write-Host "CAPS is installed, but autologin is not enabled."
exit 1
