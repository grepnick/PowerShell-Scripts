param (
    [Parameter(Mandatory = $true)]
    [string]$SearchTerm
)

$WarningDays = 30
$Now = Get-Date

# Get matching certificates
$certs = Get-ChildItem Cert:\LocalMachine -Recurse |
Where-Object {
    $_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and
    (
        ($_.Subject -and $_.Subject -match $SearchTerm) -or
        ($_.FriendlyName -and $_.FriendlyName -match $SearchTerm)
    )
}

if (-not $certs) {
    Write-Host "No certificates found matching '$SearchTerm'"
    exit 1
}

# Sort by expiration date (newest first)
$sortedCerts = $certs | Sort-Object NotAfter -Descending

# Select newest certificate
$newestCert = $sortedCerts | Select-Object -First 1

# Display all matching certs
Write-Host "Matching certificates (sorted by expiration date):`n"
$sortedCerts |
Select-Object PSParentPath, Subject, FriendlyName, Thumbprint, NotAfter |
Format-List

# Check expiration status
$daysRemaining = ($newestCert.NotAfter - $Now).Days

Write-Host "`nNewest certificate:"
$newestCert |
Select-Object Subject, FriendlyName, Thumbprint, NotAfter |
Format-List

if ($newestCert.NotAfter -lt $Now) {
    Write-Host "Newest certificate is EXPIRED!"
    exit 2
}
elseif ($daysRemaining -le $WarningDays) {
    Write-Host "Newest certificate expires in $daysRemaining days!"
    exit 3
}
else {
    Write-Host "Newest certificate is valid. Expires in $daysRemaining days."
    exit 0
}
