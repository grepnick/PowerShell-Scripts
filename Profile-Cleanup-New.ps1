param(
    [int]$CutoffMonths = 6,
    [string]$UsersRoot = 'C:\Users',
    [switch]$Delete
)

$cutoff = (Get-Date).AddMonths(-$CutoffMonths)
$excludedProfiles = @('Public','Default','Default User','All Users','DefaultAppPool','desktop.ini','WDAGUtilityAccount','Administrator','itadmin')

function Get-LatestEntryInPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $null }
    $maxTime = $null
    $maxPath = $null
    try {
        Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            if ($maxTime -eq $null -or $_.LastWriteTime -gt $maxTime) {
                $maxTime = $_.LastWriteTime
                $maxPath = $_.FullName
            }
        }
        if ($maxTime) { return @{Time=$maxTime; Path=$maxPath} }
        else {
            $it = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
            if ($it) { return @{Time=$it.LastWriteTime; Path=$it.FullName} }
        }
    } catch { return $null }
}

$report = @()

Get-ChildItem -Path $UsersRoot -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -notin $excludedProfiles } | ForEach-Object {

    $profilePath = $_.FullName
    $user = $_.Name

    $artifactList = @(
        @{Path = Join-Path $profilePath 'AppData\Roaming\Microsoft\Windows\Recent'; Type='Recent'},
        @{Path = Join-Path $profilePath 'AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations'; Type='JumpLists'},
        @{Path = Join-Path $profilePath 'AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations'; Type='JumpLists'},
        @{Path = Join-Path $profilePath 'Desktop'; Type='Desktop'},
        @{Path = Join-Path $profilePath 'Downloads'; Type='Downloads'},
        @{Path = Join-Path $profilePath 'Documents'; Type='Documents'},
        @{Path = Join-Path $profilePath 'Pictures'; Type='Pictures'}
    )

    $latestTime = $null
    $latestSource = ''
    foreach ($a in $artifactList) {
        if (Test-Path $a.Path) {
            if ((Get-Item $a.Path).PSIsContainer) {
                $res = Get-LatestEntryInPath -Path $a.Path
            } else {
                $it = Get-Item -LiteralPath $a.Path -ErrorAction SilentlyContinue
                if ($it) { $res = @{Time=$it.LastWriteTime; Path=$it.FullName} }
            }
            if ($res -and ($latestTime -eq $null -or $res.Time -gt $latestTime)) {
                $latestTime = $res.Time
                $latestSource = $a.Type
            }
        }
    }

    $report += [PSCustomObject]@{
        User         = $user
        ProfilePath  = $profilePath
        LastActivity = $latestTime
        Source       = $latestSource
    }
}

#Write-Host ""
#Write-Host "Profiles found (cutoff: $cutoff)" -ForegroundColor Cyan
#$report | Sort-Object LastActivity -Descending | Format-Table -AutoSize

Write-Host ""
Write-Host "Profiles with NO activity or activity OLDER than cutoff:" -ForegroundColor Yellow
$stale = $report | Where-Object { -not $_.LastActivity -or $_.LastActivity -lt $cutoff }
if ($stale) {
    $stale | Sort-Object LastActivity | Format-Table -AutoSize
} else {
    Write-Host "None found."
}

if ($Delete) {
    Write-Host "`n*** Deleting stale profiles ***" -ForegroundColor Red
    foreach ($p in $stale) {
        Write-Host "Deleting profile: $($p.User) at $($p.ProfilePath)"
        # To really delete, uncomment:
        $wmi = Get-CimInstance Win32_UserProfile | Where-Object { $_.LocalPath -eq $p.ProfilePath }
        if ($wmi) { $wmi | Remove-CimInstance }
    }
} else {
    Write-Host "`nDry run complete – nothing was deleted."
}
