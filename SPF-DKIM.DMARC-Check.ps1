# Looks up SPF, DKIM, and DMARC records for Google Workspace and Microsoft 365 domains.

# Run as an interactive script or accept the first argument as a domain.
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [string]$DomainName
)

Clear-Host

# Prompt for domain if not specified as an argument
if (-not $DomainName) {
    $DomainName = Read-Host "Enter the domain name to check (e.g. example.com)"
} else {
    Write-Host "Domain: $DomainName"
}

# Find the MX
$mxRecords = (Resolve-DnsName -Type MX -Name $DomainName | Sort-Object Priority).NameExchange
$mxGoogle = $mxRecords | Where-Object {$_ -clike "*google*"}
$mxMicrosoft = $mxRecords | Where-Object {$_ -clike "*outlook*"}

# Lookup DMARC
if ($mxGoogle) {
        $dkimSelector = "google"
    Write-Host "`nGoogle MX detected"
} elseif ($mxMicrosoft) {
        $dkimSelector = "selector1","selector2"
    Write-Host "`nMicrosoft MX detected"
} else {
    Write-Host -ForegroundColor Red "No valid Google Workspace or Microsoft 365 MX records were found for the domain $DomainName."
    exit
}

# Lookup SPF and print results
$sfpRecord = (Resolve-DnsName -Type TXT -ErrorAction SilentlyContinue -Name $DomainName).Strings | Where-Object {$_ -clike "*v=spf1*" }

if ($sfpRecord) {
    Write-Host "`nSPF record detected:"
    Write-Host -ForegroundColor Green "$sfpRecord"
} elseif (!$sfpRecord) {
    Write-Host -ForegroundColor Red  "No SPF record was found for the domain $DomainName."
}

#Lookup DMARC and print results
$dmarcRecord = (Resolve-DnsName -Type TXT -ErrorAction SilentlyContinue -Name "_dmarc.$DomainName").Strings | Where-Object {$_ -clike "v=DMARC1*"}

if ($dmarcRecord) {
    Write-Host  "`nDMARC record detected:"
    Write-Host -ForegroundColor Green "$dmarcRecord"
} elseif (!$dmarcRecord) {
    Write-Host -ForegroundColor Red "`nNo DMARC record was found for the domain $DomainName."
}

# Lookup DKIM and print results
foreach ($selector in $dkimSelector) {
    $dkimRecord = (Resolve-DnsName -Type TXT -ErrorAction SilentlyContinue -Name "$selector._domainkey.$DomainName").Strings | Where-Object {$_ -like "*=DKIM1*"}
    if ($dkimRecord) {
    Write-Host "`nDKIM record detected for $selector._domainkey.${DomainName}:"
    Write-Host  -ForegroundColor Green "$dkimRecord"    
    } else {
    Write-Host  -ForegroundColor Red "`nNo DKIM record was found for selector $selector._domainkey.$DomainName."
    
    }
}


# Nice
