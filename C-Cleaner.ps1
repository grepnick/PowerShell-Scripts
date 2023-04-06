clear 

# Calculate the date 30 days ago
$MaxAge = 30
$MaxAgeDate = (Get-Date).AddDays(-$($MaxAge))

# Get the free disk space before cleaning
$driveLetter = $env:SystemDrive.TrimEnd(':')
$drive = Get-PSDrive $driveLetter
$freeSpaceBefore = [math]::Round($drive.Free / 1GB, 2)

# Clean Windows Temp Folder
$TempFolder = "$env:SystemRoot\Temp"

# Get all files in the folder that are older than 30 days
$OldTempFiles = Get-ChildItem $TempFolder -Recurse | Where-Object { $_.LastWriteTime -lt $MaxAgeDate -and !$_.PSIsContainer }

# Delete each file
foreach ($file in $OldTempFiles) {
    if (Test-Path $file.FullName -PathType Leaf) {
        Remove-Item $file.FullName -Force
    } else {
        Write-Host "Cannot remove $($file.FullName): Access denied."
    }
}

$TempDeletedFilesCount = ($OldTempFiles | Measure-Object).Count
Write-Host "Deleted $TempDeletedFilesCount files older than $MaxAge days in $($TempFolder)."

# Get a list of all user directories under C:\Users
$userDirectories = Get-ChildItem -Path C:\Users -Directory

# Iterate through each user directory
foreach ($userDirectory in $userDirectories) {
    $tempFolder = Join-Path $userDirectory.FullName "AppData\Local\Temp"

    # Check if the user has a Local\Temp folder
    if (Test-Path $tempFolder) {
        # Get all files in the folder that are older than 30 days
        $oldFiles = Get-ChildItem $tempFolder -Recurse | Where-Object { $_.LastWriteTime -lt $MaxAgeDate -and !$_.PSIsContainer }

        # Delete each file
        foreach ($file in $oldFiles) {
            if (Test-Path $file.FullName -PathType Leaf) {
                Remove-Item $file.FullName -Force
            } else {
                Write-Host "Cannot remove $($file.FullName): Access denied."
            }
        }
        $deletedFilesCount = ($oldFiles | Measure-Object).Count
        Write-Host "Deleted $deletedFilesCount files older than $MaxAge days in $($userDirectory.Name)'s Temp folder."
    }
    else {
        Write-Host "User $($userDirectory.Name) does not have a Temp folder."
    }
}

# Get the free disk space after cleaning
$freeSpaceAfter = [math]::Round($drive.Free / 1GB, 2)

# Calculate the difference
$spaceFreed = [math]::Round($drive.Free / 1MB - $freeSpaceBefore * 1024, 2)

# Display the results
Write-Host "Free disk space before cleanup: $freeSpaceBefore GB"
Write-Host "Free disk space after cleanup: $freeSpaceAfter GB"
Write-Host "Total disk space freed up: $spaceFreed MB"

# NICE
