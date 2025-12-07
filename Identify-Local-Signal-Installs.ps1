$SignalFound = $false

$UserProfiles = Get-ChildItem -Path "C:\Users" -Directory | Where-Object {
    Test-Path "$($_.FullName)\AppData\Local"
}

foreach ($User in $UserProfiles) {
    $UserProfile = $User.FullName
    $LocalPath = Join-Path $UserProfile "AppData\Local\Signal"
    $RoamingPath = Join-Path $UserProfile "AppData\Roaming\Signal"

    Write-Host "Checking for Signal in: $UserProfile"

    if (Test-Path $LocalPath) {
        Write-Host "  Found in Local: $LocalPath"
        $SignalFound = $true
    } else {
        Write-Host "  Not found in Local"
    }

    if (Test-Path $RoamingPath) {
        Write-Host "  Found in Roaming: $RoamingPath"
        $SignalFound = $true
    } else {
        Write-Host "  Not found in Roaming"
    }
}


if ($SignalFound) {
    Write-Host "`nSignal was found in at least one user profile."
    exit 1
} else {
    Write-Host "`nSignal was not found in any user profiles."
    exit 0
}
