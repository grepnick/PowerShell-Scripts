$excludedFolders = @('Public', 'Default', 'Default User', 'All Users')

$profiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.LocalPath -like "C:\Users\*" }

$profileNames = $profiles | ForEach-Object {
    Split-Path $_.LocalPath -Leaf
}

$userFolders = Get-ChildItem "C:\Users" -Directory | Where-Object {
    $excludedFolders -notcontains $_.Name
}

$orphanedFolders = $userFolders | Where-Object { $_.Name -notin $profileNames }

if ($orphanedFolders) {
    Write-Host "Deleting orphaned user folders:"
    foreach ($folder in $orphanedFolders) {
        Write-Host " - Removing $($folder.FullName)"
        #Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
    }
    Write-Host "All orphaned folders deleted."
} else {
    Write-Host "No orphaned user folders found."
}
