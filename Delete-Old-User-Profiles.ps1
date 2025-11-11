$daysInactive = 90
$cutoffDate = (Get-Date).AddDays(-$daysInactive)

$os = Get-CimInstance Win32_OperatingSystem
if ($os.ProductType -ne 1) {
    Write-Host "This script is not allowed to run on a server. Exiting..."
    exit
}

$excludedUsers = @(
    "Administrator", "Admin", "itadmin", "itsupport"
)

# Get all local admin usernames
$adminUsers = (Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue | Where-Object { $_.ObjectClass -eq "User" }).Name | ForEach-Object { ($_ -split '\\')[-1] }
$excludedUsers += $adminUsers

#$excludedUsers

$profiles = Get-WmiObject Win32_UserProfile | Where-Object {
    -not $_.Special -and $_.LocalPath -like "C:\Users\*" -and 
    ($excludedUsers -notcontains ($_.LocalPath -split '\\')[-1])
}

foreach ($profile in $profiles) {
    $userFolder = $profile.LocalPath
    $username = ($userFolder -split '\\')[-1]

    $ntuserPath = Join-Path $userFolder "ntuser.dat"

    if (Test-Path $ntuserPath) {
        try {
            $lastModified = (Get-Item -Force $ntuserPath).LastWriteTime

            if ($lastModified -lt $cutoffDate) {
                Write-Host "Deleting: $userFolder (ntuser.dat Last modified: $lastModified)" -ForegroundColor Yellow
                $profile.Delete()
            } else {
                Write-Host "Skipping $userFolder — ntuser.dat recently modified ($lastModified)"
            }
        } catch {
            Write-Warning "Failed to process ntuser.dat for ${userFolder}: $_"
        }
    } else {
        Write-Host "ntuser.dat not found in: $userFolder" -ForegroundColor Gray
    }
}
