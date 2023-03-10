# A PowerShell script to set the Roaming Aggressiveness for Windows Wifi Adapters

# Credit: Nick Marsh

# Set the $RoamingValue which is the RoamAggressiveness RegistryValue
# Note: The RegistryValue for Roaming is an ordnal number and the DisplayValue is a cardinal number so 0=1, 1=2, etc.
# A RegistryValue of 3 is a DisplayValue of "4. Medium-High"
$RoamingValue = 3

# Find the active wireless adapter
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.MediaType -like '*802.11*' }

if ($adapter) {
    # Check if the Roaming Aggressiveness property exists
    $property = Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RoamAggressiveness" -ErrorAction SilentlyContinue

    if ($property) {
        # Get the current Roaming Aggressiveness property value
        $beforeValue = $property.DisplayValue

        # Check if the Roaming Aggressiveness property value is already set to $RoamingValue
        if ($property.RegistryValue -eq $RoamingValue) {
            Write-Host "Roaming Aggressiveness is already set to $RoamingValue."
            exit
        }
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RoamAggressiveness" -RegistryValue $RoamingValue

        # Get the new Roaming Aggressiveness property value
        $afterValue = (Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RoamAggressiveness").DisplayValue

        # Output the before and after values
        Write-Host "Roaming Agressiveness Before: $($beforeValue)"
        Write-Host "Roaming Agressiveness After: $($afterValue)"
    } else {
        Write-Host "Roaming Aggressiveness property not found."
    }
} else {
    Write-Host "No active wireless adapter found."
}
