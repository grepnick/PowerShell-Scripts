$warningDays = 90
$maxDays = 365
$now = Get-Date

try {
    $tcp = New-Object Net.Sockets.TcpClient("localhost", 443)
    $ssl = New-Object Net.Security.SslStream(
        $tcp.GetStream(),
        $false,
        { $true }
    )

    $ssl.AuthenticateAsClient("localhost")

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 `
        $ssl.RemoteCertificate

    $daysRemaining = ($cert.NotAfter - $now).Days
    $expiredDays   = ($now - $cert.NotAfter).Days

    Write-Host "TLS Certificate Details:"
    Write-Host " Subject      : $($cert.Subject)"
    Write-Host " Issuer       : $($cert.Issuer)"
    Write-Host " Thumbprint   : $($cert.Thumbprint)"
    Write-Host " Expires      : $($cert.NotAfter)"
    Write-Host " Days Left    : $daysRemaining"
    Write-Host ""

    if ($cert.NotAfter -lt $now -and $expiredDays -gt $maxDays) {
        Write-Host "INFO: Certificate expired $expiredDays days ago (> $maxDays). Ignoring."
        exit 0
    }
    elseif ($cert.NotAfter -lt $now) {
        Write-Warning "CRITICAL: TLS certificate expired $expiredDays days ago!"
        exit 2
    }
    elseif ($daysRemaining -le $warningDays) {
        Write-Warning "WARNING: TLS certificate expires in $daysRemaining days."
        exit 1
    }
    else {
        Write-Host "OK: TLS certificate is valid."
        exit 0
    }
}
catch {
    Write-Error "FAILED: Unable to retrieve TLS certificate. $($_.Exception.Message)"
    exit 0
}
finally {
    if ($ssl) { $ssl.Dispose() }
    if ($tcp) { $tcp.Close() }
}
