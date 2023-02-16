# Check if the current script is running as an administrator and if not, relaunch as an admin.

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # If the current process is not running as an administrator, relaunch the script as an administrator
    Start-Process powershell.exe "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb runAs
    exit
}

# If we made it this far, the script is running as an administrator and we can do admin things below...
