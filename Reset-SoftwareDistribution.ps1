# ============================================================
# Windows Update Cache Reset
#
# - Skips if successfully run within the last $MaxAge days
# - Stores state in HKLM registry
# - Stops Windows Update-related services
# - Renames SoftwareDistribution and catroot2
# - Attempts to delete renamed folders while services are stopped
# - Retries transient access/locking failures
# - Restarts services even if an error occurs
# - Only records LastSuccess if the reset completes successfully
# ============================================================

$RegPath = 'HKLM:\SOFTWARE\grepnick\Remediation'
$RegName = 'SoftwareDistributionCleanup'
$MaxAge  = 30
$Action  = 'Software Distribution cleanup'

$Services = @(
    'bits',
    'wuauserv',
    'cryptsvc'
)

$RenameAttempts = 5
$RenameRetrySeconds = 5

$DeleteAttempts = 3
$DeleteRetrySeconds = 5


# ============================================================
# Registry setup
# ============================================================

if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}


# ============================================================
# Check last successful cleanup
# ============================================================

$LastRunValue = Get-ItemPropertyValue `
    -Path $RegPath `
    -Name $RegName `
    -ErrorAction SilentlyContinue

if ($LastRunValue) {
    try {
        $LastRun = [datetimeoffset]::Parse($LastRunValue)
        $DaysOld = [math]::Floor(
            (([datetimeoffset]::Now) - $LastRun).TotalDays
        )

        if ($DaysOld -lt $MaxAge) {
            Write-Host "$Action already successfully performed $DaysOld days ago. Skipping."
            exit 0
        }
    }
    catch {
        Write-Warning "Existing cleanup timestamp is invalid. Cleanup will proceed."
    }
}


# ============================================================
# Record attempt
# ============================================================

New-ItemProperty `
    -Path $RegPath `
    -Name 'SoftwareDistributionCleanupLastAttempt' `
    -Value ([datetimeoffset]::Now.ToString('o')) `
    -PropertyType String `
    -Force | Out-Null


# ============================================================
# Function: Stop and verify required services
# ============================================================

function Stop-UpdateServices {

    foreach ($ServiceName in $Services) {

        try {
            $Service = Get-Service -Name $ServiceName -ErrorAction Stop

            if ($Service.Status -ne 'Stopped') {

                Write-Host "Stopping $ServiceName..."

                Stop-Service `
                    -Name $ServiceName `
                    -Force `
                    -ErrorAction Stop
            }

            $Service = Get-Service -Name $ServiceName -ErrorAction Stop

            $Service.WaitForStatus(
                [System.ServiceProcess.ServiceControllerStatus]::Stopped,
                [TimeSpan]::FromSeconds(30)
            )

            $Service.Refresh()

            if ($Service.Status -ne 'Stopped') {
                throw "$ServiceName did not reach the Stopped state."
            }

            Write-Host "$ServiceName is stopped."
        }
        catch {
            throw "Unable to stop ${ServiceName}: $($_.Exception.Message)"
        }
    }
}


# ============================================================
# Function: Rename folder with retry
# ============================================================

function Rename-UpdateFolder {

    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (-not (Test-Path $Path)) {
        Write-Host "$Path does not exist. Nothing to rename."
        return $true
    }

    for ($Attempt = 1; $Attempt -le $RenameAttempts; $Attempt++) {

        try {

            # Make sure something hasn't restarted the services
            # between attempts.
            Stop-UpdateServices

            Write-Host "Renaming $Path - attempt $Attempt of $RenameAttempts..."

            Rename-Item `
                -Path $Path `
                -NewName (Split-Path $Destination -Leaf) `
                -ErrorAction Stop

            Write-Host "Successfully renamed:"
            Write-Host "  $Path"
            Write-Host "  -> $Destination"

            return $true
        }
        catch {

            Write-Warning "Rename attempt $Attempt failed for ${Path}: $($_.Exception.Message)"

            if ($Attempt -lt $RenameAttempts) {
                Start-Sleep -Seconds $RenameRetrySeconds
            }
        }
    }

    return $false
}


# ============================================================
# Function: Delete old folder
#
# Failure here is NOT considered a failed Windows Update reset.
# The important operation is successfully renaming the live folder.
# ============================================================

function Remove-OldUpdateFolder {

    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return $true
    }

    for ($Attempt = 1; $Attempt -le $DeleteAttempts; $Attempt++) {

        try {

            Write-Host "Removing $Path - attempt $Attempt of $DeleteAttempts..."

            Remove-Item `
                -Path $Path `
                -Recurse `
                -Force `
                -ErrorAction Stop

            Write-Host "Removed $Path"

            return $true
        }
        catch {

            Write-Warning "Delete attempt $Attempt failed for ${Path}: $($_.Exception.Message)"

            if ($Attempt -lt $DeleteAttempts) {
                Start-Sleep -Seconds $DeleteRetrySeconds
            }
        }
    }

    Write-Warning "Windows Update reset succeeded, but old folder could not be removed:"
    Write-Warning $Path

    return $false
}


# ============================================================
# Main cleanup
# ============================================================

$Suffix = Get-Date -Format 'yyyyMMdd-HHmmss'

$SDPath  = 'C:\Windows\SoftwareDistribution'
$SDOld   = "C:\Windows\SoftwareDistribution.$Suffix"

$CatPath = 'C:\Windows\System32\catroot2'
$CatOld  = "C:\Windows\System32\catroot2.$Suffix"

$ResetSuccessful = $false
$ServicesRestarted = $true


try {

    Write-Host "Starting $Action..."
    Write-Host ""

    # --------------------------------------------------------
    # Stop services
    # --------------------------------------------------------

    Stop-UpdateServices

    # Small delay to allow released handles to clear
    Start-Sleep -Seconds 3


    # --------------------------------------------------------
    # Rename SoftwareDistribution
    # --------------------------------------------------------

    $SDRenamed = Rename-UpdateFolder `
        -Path $SDPath `
        -Destination $SDOld


    # --------------------------------------------------------
    # Rename catroot2
    # --------------------------------------------------------

    $CatRenamed = Rename-UpdateFolder `
        -Path $CatPath `
        -Destination $CatOld


    # --------------------------------------------------------
    # Determine whether reset succeeded
    # --------------------------------------------------------

    if (-not $SDRenamed) {
        throw "Unable to rename $SDPath."
    }

    if (-not $CatRenamed) {
        throw "Unable to rename $CatPath."
    }


    # --------------------------------------------------------
    # Both directories successfully reset
    # --------------------------------------------------------

    $ResetSuccessful = $true

    Write-Host ""
    Write-Host "Windows Update cache folders successfully reset."


    # --------------------------------------------------------
    # Remove renamed folders while services are STILL stopped
    #
    # Cleanup failures are warnings only.
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Attempting cleanup of old folders..."

    if (Test-Path $SDOld) {
        $null = Remove-OldUpdateFolder -Path $SDOld
    }

    if (Test-Path $CatOld) {
        $null = Remove-OldUpdateFolder -Path $CatOld
    }
}
catch {

    Write-Error "$Action failed: $($_.Exception.Message)"
    $ResetSuccessful = $false
}
finally {

    # ========================================================
    # Always restart services
    # ========================================================

    Write-Host ""
    Write-Host "Restarting Windows Update services..."

    foreach ($ServiceName in $Services) {

        try {

            Start-Service `
                -Name $ServiceName `
                -ErrorAction Stop

            Write-Host "Started $ServiceName."
        }
        catch {

            Write-Warning "Unable to start ${ServiceName}: $($_.Exception.Message)"
            $ServicesRestarted = $false
        }
    }
}


# ============================================================
# Record result
# ============================================================

if ($ResetSuccessful -and $ServicesRestarted) {

    $Timestamp = [datetimeoffset]::Now.ToString('o')

    New-ItemProperty `
        -Path $RegPath `
        -Name $RegName `
        -Value $Timestamp `
        -PropertyType String `
        -Force | Out-Null

    New-ItemProperty `
        -Path $RegPath `
        -Name 'SoftwareDistributionCleanupLastResult' `
        -Value 'Success' `
        -PropertyType String `
        -Force | Out-Null

    Write-Host ""
    Write-Host "============================================"
    Write-Host "Windows Update cleanup completed successfully."
    Write-Host "Timestamp: $Timestamp"
    Write-Host "============================================"

    exit 0
}
else {

    New-ItemProperty `
        -Path $RegPath `
        -Name 'SoftwareDistributionCleanupLastResult' `
        -Value 'Failed' `
        -PropertyType String `
        -Force | Out-Null

    Write-Error "Windows Update cleanup did not complete successfully."

    exit 1
}
