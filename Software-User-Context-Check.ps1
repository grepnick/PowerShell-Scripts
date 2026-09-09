# Checks is software is running in the user context.
# Checks is software is running in the user context.
$UninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$SoftwareInstalled = Get-ItemProperty -Path $UninstallPaths -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "*SOFTWARE NAME*" } |
    Select-Object -First 1

if (-not $SoftwareInstalled) {
    Write-Host "IFC8 is not installed. Process check is not applicable."
    exit 0
}

$ValidUsers = @(
    "validusername"
)

$SoftwareProcesses = Get-WmiObject Win32_Process `
    -Filter "Name='PROCESSNAME.exe'" `
    -ErrorAction SilentlyContinue

if (-not $SoftwareProcesses) {
    Write-Host "Software is installed, but is not running."
    exit 0
}

$ValidOwners   = @()
$InvalidOwners = @()
$UnknownPIDs   = @()

foreach ($Process in $SoftwareProcesses) {
    $Owner = $Process.GetOwner()

    if ($Owner.ReturnValue -ne 0) {
        $UnknownPIDs += $Process.ProcessId
        continue
    }

    $FullUserName = "$($Owner.Domain)\$($Owner.User)"

    # SYSTEM processes are expected and are ignored.
    if ($Owner.User -ieq "SYSTEM") {
        continue
    }

    if ($Owner.User -in $ValidUsers) {
        $ValidOwners += $FullUserName
    }
    else {
        $InvalidOwners += $FullUserName
    }
}

$ValidOwners   = $ValidOwners | Select-Object -Unique
$InvalidOwners = $InvalidOwners | Select-Object -Unique

if ($InvalidOwners.Count -gt 0) {
    Write-Host "Software is running under one or more invalid user accounts."
    Write-Host "Invalid user(s): $($InvalidOwners -join ', ')"
    exit 1
}

if ($UnknownPIDs.Count -gt 0) {
    Write-Host "Unable to determine the owner of software PID(s): $($UnknownPIDs -join ', ')"
    exit 1
}

if ($ValidOwners.Count -eq 0) {
    Write-Host "Software is running only as SYSTEM. No invalid user-context process was found."
    exit 0
}

Write-Host "Software is running under a valid user account: $($ValidOwners -join ', ')"
exit 0
