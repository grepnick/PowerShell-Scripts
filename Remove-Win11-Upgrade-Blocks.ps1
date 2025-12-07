# Ensure the script is running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "This script must be run as Administrator." -ForegroundColor Red
    Exit 1
}

# Define registry path
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# Define values to delete
$valuesToDelete = @("ProductVersion", "TargetReleaseVersion", "TargetReleaseVersionInfo")

foreach ($value in $valuesToDelete) {
    try {
        Remove-ItemProperty -Path $regPath -Name $value -ErrorAction Stop
        Write-Host "Deleted value: $value"
    } catch {
        Write-Host "Failed to delete $value or it does not exist." -ForegroundColor Yellow
    }
}

# Force Group Policy update silently
Start-Process "gpupdate.exe" -ArgumentList "/force" -WindowStyle Hidden -NoNewWindow
