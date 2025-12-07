$serviceName = "winlogbeat"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service) {
    Write-Host "Stopping service: $serviceName"
    Stop-Service -Name $serviceName -Force
    Write-Host "Waiting for the service to stop..."
    $service.WaitForStatus('Stopped', '00:00:10')
} else {
    Write-Host "Service '$serviceName' not found. Skipping step."
}

Write-Host "Searching for installed products matching '*winlogbeat*'..."

$products = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "(?i)winlogbeat" }

if ($products) {
    foreach ($product in $products) {
        Write-Host "Uninstalling: $($product.Name)"
        $product.Uninstall() | Out-Null
    }
    Write-Host "Uninstallation complete."
} else {
    Write-Host "No installed products matching '*winlogbeat*' were found."
}
