# Generic script to download an MSI file and run the installer. Should work for EXE too with modifications.

# Update these variables
$msiUrl = "https://asdf.com"
$license = 'If Needed'

$downloadPath = "C:\temp"
$msiFilePath = Join-Path -Path $downloadPath -ChildPath "installer.msi"
$binaryPath = "C:\Program Files\Field Effect\Covalence\bin\covalence-endpoint.exe"

if (Test-Path -Path $binaryPath) {
    Write-Host "Application already installed."
    exit
}

if (-not (Test-Path -Path $downloadPath -PathType Container)) {
    New-Item -Path $downloadPath -ItemType Directory | Out-Null
}

Invoke-WebRequest -Uri $msiUrl -OutFile $msiFilePath

Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiFilePath`" LICENSE=`"$license`" /qn /l*v $downloadPath\InstallerLog.txt" -Wait

Remove-Item -Path $msiFilePath
