# Get all active network adapters, excluding those with "NDIS" in the name or interface description
$adapters = Get-NetAdapter |
    Where-Object {
        $_.Status -eq 'Up' -and
        $_.Name -notmatch 'NDIS' -and
        $_.InterfaceDescription -notmatch 'NDIS'
    }

# Track if any adapter is below 1 Gbps
$lowSpeedAdapters = @()

foreach ($adapter in $adapters) {
    # Parse speed as Mbps
    $speedMbps = ($adapter.LinkSpeed -replace '[^0-9.]', '') -as [double]
    
    # Convert speed to Mbps based on unit
    if ($adapter.LinkSpeed -like '*Gbps') {
        $speedMbps *= 1000
    }

    if ($speedMbps -lt 1000) {
        $lowSpeedAdapters += $adapter
    }
}

if ($lowSpeedAdapters.Count -gt 0) {
    Write-Host "Warning: One or more active network adapters are connected at less than 1 Gbps."
    $lowSpeedAdapters | Select-Object Name, LinkSpeed | Out-Host
    exit 1
} else {
    Write-Host "All active network adapters are connected at 1 Gbps or higher." -ForegroundColor Green
    exit 0
}
