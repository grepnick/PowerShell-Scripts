function Get-FreeSpace {
    $drive = Get-PSDrive -Name C
    return [math]::Round($drive.Free / 1GB, 2)
}

$freeBefore = Get-FreeSpace
Write-Output "Free Disk Space Before Cleanup: $freeBefore GB"

$BrowsersToKill = @("chrome", "msedge", "firefox", "island", "islandhelper", "islandchashahndler", "islandchashahndler64")
foreach ($proc in $BrowsersToKill) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}


$users = Get-ChildItem "C:\Users" | Where-Object {
    $_.PSIsContainer -and $_.Name -notin @("Public", "Default", "Default User", "All Users")
}

foreach ($user in $users) {
    $userProfile = "C:\Users\$($user.Name)"
    Write-Output "Processing user profile: $userProfile"

     $paths = @(
        # Google Chrome
        Join-Path $userProfile "\AppData\Local\Google\Chrome\User Data\Default\Cache"
        Join-Path $userProfile "\AppData\Local\Google\Chrome\User Data\Default\Code Cache"
        Join-Path $userProfile "\AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage"

        # Microsoft Edge
        Join-Path $userProfile "\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
        Join-Path $userProfile "\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache"
        Join-Path $userProfile "\AppData\Local\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage"

        # Island Browser
        Join-Path $userProfile "\AppData\Local\Island\Island\User Data\Default\Cache"
        Join-Path $userProfile "\AppData\Local\Island\Island\User Data\Default\Code Cache"
        Join-Path $userProfile "\AppData\Local\Island\Island\User Data\Default\Service Worker\CacheStorage"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            try {
                Write-Output "Clearing cache: $path"
                Remove-Item -Path $path -Recurse -Force #-ErrorAction SilentlyContinue
            } catch {
                Write-Output "Failed to remove: $path"
            }
        }
    }

    Write-Output ""
}

$freeAfter = Get-FreeSpace
$spaceFreed = [math]::Round(($freeAfter - $freeBefore), 2)

Write-Output "Free Disk Space After Cleanup: $freeAfter GB"
Write-Output "Total Space Freed: $spaceFreed GB"
Write-Output "Cache cleanup process completed."
