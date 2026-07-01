# Get Windows Patch Status - Last 30 Days with Intelligent Failure Detection
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$HistoryCount = $Searcher.GetTotalHistoryCount()
$AllUpdates = $Searcher.QueryHistory(0, $HistoryCount)
$OS = (Get-CimInstance Win32_OperatingSystem).Caption

if ($OS -match 'Windows 7|Windows 10|Windows Server 2008|Windows Server 2012') {
    Write-Warning "Unsupported operating system. Exiting."
    exit 0
}

$ResultMap = @{
    0 = "Unknown"
    1 = "In Progress"
    2 = "Succeeded"
    3 = "Succeeded w/ Errors"
    4 = "Failed"
    5 = "Aborted"
}

# Filter to last 30 days AND only KB articles
$CutoffDate = (Get-Date).AddDays(-30)
$RecentUpdates = $AllUpdates | Where-Object { $_.Date -ge $CutoffDate -and $_.Title -match 'KB\d+' }

if (-not $RecentUpdates) {
    Write-Host "`nNo KB updates found in the last 30 days." -ForegroundColor Yellow
    exit 0
}

# Display all KB patches in the last 30 days
Write-Host "`n===== Windows KB Patches - Last 30 Days =====" -ForegroundColor Cyan
$RecentUpdates | Sort-Object Date -Descending | ForEach-Object {
    [PSCustomObject]@{
        Date   = $_.Date.ToString("yyyy-MM-dd HH:mm")
        KB     = if ($_.Title -match '(KB\d+)') { $matches[1] } else { "N/A" }
        Status = $ResultMap[[int]$_.ResultCode]
        Title  = $_.Title.Substring(0, [Math]::Min(70, $_.Title.Length))
    }
} | Format-Table -AutoSize

# --- Intelligent Failure Detection ---
$GroupedByKB = $RecentUpdates | Group-Object {
    if ($_.Title -match '(KB\d+)') { $matches[1] } else { $_.Title }
}

$UnresolvedFailures = @()
$ResolvedFailures   = @()

foreach ($group in $GroupedByKB) {
    $attempts = $group.Group | Sort-Object Date

    $hasFailure = $attempts | Where-Object { $_.ResultCode -in @(4, 5) }

    if (-not $hasFailure) { continue }

    $latestAttempt = $attempts | Select-Object -Last 1

    if ($latestAttempt.ResultCode -eq 2) {
        $ResolvedFailures += [PSCustomObject]@{
            KB         = $group.Name
            Failures   = ($hasFailure | Measure-Object).Count
            ResolvedOn = $latestAttempt.Date.ToString("yyyy-MM-dd HH:mm")
            Title      = $latestAttempt.Title.Substring(0, [Math]::Min(70, $latestAttempt.Title.Length))
        }
    } else {
        $UnresolvedFailures += [PSCustomObject]@{
            KB          = $group.Name
            LastAttempt = $latestAttempt.Date.ToString("yyyy-MM-dd HH:mm")
            Status      = $ResultMap[[int]$latestAttempt.ResultCode]
            Attempts    = ($attempts | Measure-Object).Count
            Title       = $latestAttempt.Title.Substring(0, [Math]::Min(70, $latestAttempt.Title.Length))
        }
    }
}

if ($ResolvedFailures) {
    Write-Host "===== Previously Failed - Now Resolved (Ignored) =====" -ForegroundColor DarkYellow
    $ResolvedFailures | Format-Table -AutoSize
}

if ($UnresolvedFailures) {
    Write-Host "===== Unresolved Patch Failures =====" -ForegroundColor Red
    $UnresolvedFailures | Format-Table -AutoSize
    Write-Host "$($UnresolvedFailures.Count) unresolved patch failure(s) detected. Exiting with code 1." -ForegroundColor Red
    exit 1
} else {
    Write-Host "No unresolved KB patch failures in the last 30 days." -ForegroundColor Green
    exit 0
}
