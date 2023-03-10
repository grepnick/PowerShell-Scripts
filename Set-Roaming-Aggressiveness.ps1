# A PowerShell script to set the Roaming Aggressiveness for Windows Wifi Adapters

# Credit: Nick Marsh

# Sets two of the most common roaming settings depending on the card manufacturer:
# RoamAggressiveness = Intel
# RegROAMSensitiveLevel = Realtek

# Note: The script will silently continue if one or the other does not exist.

# Set the $RoamingValue which is the RoamAggressiveness RegistryValue
# Note: The RegistryValue for Roaming is an ordnal number and the DisplayValue is a cardinal number so 0=1, 1=2, etc.
# Valid values:
# 0 = "1. Lowest"
# 1 = "2. Medium-low"
# 2 = "3. Medium"
# 3 = "4. Medium-High"
# 4 = "5. Highest"
$RoamingAggressiveness = 3

# Set $RoamingSensitive which is the RegROAMSensitiveLevel RegistryValue
# Valid values are:
# 127 = Disabled
# 65 = High
# 70 = Middle
# 80 = Low
$RoamingSensitive = 70

$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.MediaType -like '*802.11*' }

try {
    $RoamingAggressivenessValue = Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RoamAggressiveness" -ErrorAction Stop
}
catch {
    Write-Host "RoamAggressiveness advanced property not found on adapter $($adapter.Name)."
    $RoamingAggressivenessValue = $null
}

if ($RoamingAggressivenessValue) {
    if ($RoamingAggressivenessValue.RegistryValue -eq $RoamingAggressiveness) {
        Write-Host "RoamAggressiveness is already set to $RoamingAggressiveness on adapter $($adapter.Name)."
    } else {
        $RoamingAggressivenessValueBefore = $RoamingAggressivenessValue.DisplayValue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RoamAggressiveness" -RegistryValue $RoamingAggressiveness
        $RoamingAggressivenessValueAfter = (Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RoamAggressiveness").DisplayValue
        Write-Host "RoamAggressiveness value before: $($RoamingAggressivenessValueBefore), after: $($RoamingAggressivenessValueAfter)"
    }
}

try {
    $RoamingSensitiveValue = Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RegROAMSensitiveLevel" -ErrorAction Stop
}
catch {
    Write-Host "RegROAMSensitiveLevel advanced property not found on adapter $($adapter.Name)."
    $RoamingSensitiveValue = $null
}

if ($RoamingSensitiveValue) {
    if ($RoamingSensitiveValue.RegistryValue -eq $RoamingSensitive) {
        Write-Host "RegROAMSensitiveLevel is already set to $RoamingSensitive on adapter $($adapter.Name)."
    } else {
        $RoamingSensitiveValueBefore = $RoamingSensitiveValue.Value
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RegROAMSensitiveLevel" -RegistryValue $RoamingSensitive
        $RoamingSensitiveValueAfter = Get-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "RegROAMSensitiveLevel"
        Write-Host "RegROAMSensitiveLevel value before: $($RoamingSensitiveValueBefore), after: $($RoamingSensitiveValueAfter)"
    }
}
