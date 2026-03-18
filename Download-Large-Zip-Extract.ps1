# Step 1: Ensure C:\Temp exists
$TempPath = "C:\Temp"
if (-not (Test-Path $TempPath)) {
    New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
}

$DownloadUrl = "https://asdf.zip"
$ExtractPath = "C:\Temp\asdf"
$ZipPath = "C:\Temp\asdf.zip"

# Step 2: Download the ZIP file
$maxRetries = 3
for ($i = 1; $i -le $maxRetries; $i++) {
    try {
        Start-BitsTransfer -Source $DownloadUrl -Destination $ZipPath -ErrorAction Stop
        break
    }
    catch {
        if ($i -eq $maxRetries) { throw }
        Start-Sleep -Seconds 30
    }
}

# Step 3: Extract files (overwrite if exists)
if (Test-Path $ExtractPath) {
    Remove-Item $ExtractPath -Recurse -Force
}

Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

# Step 4: Clean-up
# Remove-Item $ExtractPath -Recurse -Force
Remove-Item $ZipPath -Force
