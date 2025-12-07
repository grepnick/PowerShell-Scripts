Write-Host "Starting SecureCRT cleanup process..."

# Step 1: Attempt to uninstall SecureCRT via registry uninstall keys
$programs = Get-CimInstance -ClassName Win32_Product | Where-Object {
    $_.Name -like "*SecureCRT*"
}

if ($programs) {
    foreach ($program in $programs) {
        Write-Host "Found program: $($program.Name)"
        Write-Host "Uninstalling..."
        $result = Invoke-CimMethod -InputObject $program -MethodName Uninstall

        if ($result.ReturnValue -eq 0) {
            Write-Host "Successfully uninstalled: $($program.Name)"
            sleep 10
        } else {
            Write-Host "Failed to uninstall: $($program.Name). Return value: $($result.ReturnValue)"
        }
    }
} else {
    Write-Host "No programs were found."
}

# Step 2: Define directories to remove
$paths = @(
    "C:\Program Files\VanDyke Software",
    "C:\Program Files\SecureCRT",
    "C:\Program Files (x86)\VanDyke Software\",
    "C:\Program Files (x86)\SecureCRT"
)

# Step 3: Delete directories if they exist
foreach ($path in $paths) {
    if (Test-Path $path) {
        try {
            Write-Host "Deleting $path ..."
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            Write-Host "Deleted: $path"
        } catch {
            Write-Host "Failed to delete $path : $_"
        }
    } else {
        Write-Host "Path not found: $path"
    }
}

# Step 4: Delete user registry key for VanDyke
$regPath = "HKCU:\Software\VanDyke"
if (Test-Path $regPath) {
    try {
        Write-Host "Deleting registry key: $regPath"
        Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
        Write-Host "Deleted registry key: $regPath"
    } catch {
        Write-Host "Failed to delete registry key $regPath : $_"
    }
} else {
    Write-Host "Registry key not found: $regPath"
}

Write-Host "SecureCRT cleanup process completed."
