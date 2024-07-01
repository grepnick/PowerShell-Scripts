# Disable UDP for RDP
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client"
$valueName = "fClientDisableUDP"
$currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

if ($currentValue.$valueName -eq 1) {
    Write-Output "UDP for RDP is already disabled."
    exit 0
} else {
    try { Set-ItemProperty -Path $registryPath -Name $valueName -Value 1 -Type DWord }
    catch { 
            Write-Output "An error has occoured."
            exit 1
    }
}

Write-Output "UDP for RDP has been disabled."
