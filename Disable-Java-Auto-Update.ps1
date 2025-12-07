$javaRegistryPaths = @(
    "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy",
    "HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy"
)

foreach ($path in $javaRegistryPaths) {
    if (Test-Path $path) {
        Write-Host "Found Java Update Policy at: $path"

        # Set values to disable auto-update
        Set-ItemProperty -Path $path -Name "EnableJavaUpdate" -Value 0 -Type DWord
        #Set-ItemProperty -Path $path -Name "NotifyDownload" -Value 0 -Type DWord
        #Set-ItemProperty -Path $path -Name "NotifyInstall" -Value 0 -Type DWord

        Write-Host "Updated: EnableJavaUpdate, NotifyDownload, NotifyInstall to 0"
    }
    else {
        Write-Host "Java Update Policy not found at: $path"
    }
}
