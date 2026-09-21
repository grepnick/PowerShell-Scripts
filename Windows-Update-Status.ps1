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
$MinimumFailures = 3

$GroupedByKB = $RecentUpdates | Group-Object {
    if ($_.Title -match '(KB\d+)') { $matches[1] } else { $_.Title }
}

$UnresolvedFailures = @()

foreach ($group in $GroupedByKB) {
    # Only evaluate installation attempts (Operation 1).
    $attempts = @(
        $group.Group |
            Where-Object { $_.Operation -eq 1 } |
            Sort-Object Date
    )

    if ($attempts.Count -eq 0) { continue }

    $latestAttempt = $attempts[-1]

    # Only alert if the latest installation attempt actually failed.
    # Aborted, successful, and other results do not trigger an alert.
    if ([int]$latestAttempt.ResultCode -ne 4) { continue }

    # Count failures since the last fully successful installation.
    $failureCount = 0

    foreach ($attempt in $attempts) {
        switch ([int]$attempt.ResultCode) {
            2 { $failureCount = 0 }
            4 { $failureCount++ }
        }
    }

    if ($failureCount -ge $MinimumFailures) {
        $UnresolvedFailures += [PSCustomObject]@{
            KB             = $group.Name
            LastAttempt    = $latestAttempt.Date.ToString("yyyy-MM-dd HH:mm")
            Status         = "Failed"
            FailedAttempts = $failureCount
            Title          = $latestAttempt.Title.Substring(
                0, [Math]::Min(70, $latestAttempt.Title.Length)
            )
        }
    }
}

if ($UnresolvedFailures.Count -gt 0) {
    Write-Host "`n===== Patches With 3+ Failed Attempts =====" -ForegroundColor Red
    $UnresolvedFailures | Format-Table -AutoSize

    Write-Host "$($UnresolvedFailures.Count) patch(es) met the failure threshold. Exiting with code 1." -ForegroundColor Red
    exit 1
} else {
    Write-Host "No KB patches meet the 3-failure alert threshold in the last 30 days." -ForegroundColor Green
    exit 0
}
