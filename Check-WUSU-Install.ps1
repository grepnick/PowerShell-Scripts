if (Get-WindowsFeature -Name UpdateServices | Where-Object Installed) {
    "WSUS is installed"
    exit 1
} else {
    "WSUS is not installed"
    exit 0
}
