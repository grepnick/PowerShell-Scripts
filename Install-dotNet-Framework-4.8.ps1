[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$releaseKeyPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
$dotNet48Release = 528040  # Minimum release number for .NET Framework 4.8

$installed = $false

if (Test-Path $releaseKeyPath) {
    try {
        $release = Get-ItemPropertyValue -Path $releaseKeyPath -Name Release
        if ($release -ge $dotNet48Release) {
            Write-Host ".NET Framework 4.8 or later is already installed. Release key: $release"
            $installed = $true
        } else {
            Write-Host "Detected older .NET Framework version (Release key: $release)."
        }
    } catch {
        Write-Host "Could not read the Release key. Will attempt installation."
    }
} else {
    Write-Host "No .NET Framework 4.x installation detected."
}

if (-not $installed) {
    $dotNetUrl = "https://go.microsoft.com/fwlink/?LinkId=2085155"
    $installerPath = "$env:TEMP\dotnetfx.exe"

    Write-Host "Downloading .NET Framework 4.8 installer from Microsoft..."
    Invoke-WebRequest -Uri $dotNetUrl -OutFile $installerPath

    Write-Host "Installing .NET Framework 4.8 silently..."
    Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart" -Wait -NoNewWindow

    Write-Host "Installation completed. A system restart may be required."
} else {
    Write-Host "No action needed. .NET Framework 4.8 is already present."
}
