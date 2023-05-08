# A cheap knockoff of vmstat for Windows.
param(
    [int]$seconds = 2,
    [int]$iterations = -1
)

$heading = "Physical Memory Usage (MB)".PadRight(35) + "Available Physical Memory (MB)".PadRight(35) + "Virtual Memory Usage (MB)"
Write-Host $heading
Write-Host ("=" * $heading.Length)

$count = 0
while($true) {
    # Get physical memory usage
    $memory = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory, TotalVirtualMemorySize, FreeVirtualMemory

    # Calculate memory usage in MB
    $memoryUsage = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1KB, 2).ToString("N0")
    $availablePhysicalMemory = [math]::Round($memory.FreePhysicalMemory / 1KB, 2).ToString("N0")
    $virtualMemoryUsage = [math]::Round(($memory.TotalVirtualMemorySize - $memory.FreeVirtualMemory) / 1KB, 2).ToString("N0")

    # Display memory usage values
    Write-Host $memoryUsage.ToString().PadRight(35) $availablePhysicalMemory.ToString().PadRight(35) $virtualMemoryUsage

    $count++

    # Exit loop if we've reached the maximum number of iterations
    if($iterations -ge 0 -and $count -eq $iterations) {
        break
    }

    # Wait for specified number of seconds before checking memory usage again
    Start-Sleep -Seconds $seconds
}
