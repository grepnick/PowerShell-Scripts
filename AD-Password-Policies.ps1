Import-Module ActiveDirectory

# Check for supported OS
$OS = Get-WmiObject Win32_OperatingSystem

if (
    $OS.Version -like "5.*" -or
    $OS.Version -like "6.0*" -or
    $OS.Version -like "6.1*"
) {
    Write-Warning "EOL server OS detected. No changes were made."
    exit 1
}

# Verify this computer is a Domain Controller
$ComputerSystem = Get-CimInstance Win32_ComputerSystem

if ($ComputerSystem.DomainRole -notin 4,5) {
    Write-Warning "This computer is not a Domain Controller. No changes were made."
    exit 1
}

Write-Host "Domain Controller detected: $env:COMPUTERNAME"

$Domain = (Get-ADDomain).DNSRoot

# Check for Fine-Grained Password Policies
$FGPP = Get-ADFineGrainedPasswordPolicy -Filter *

if ($FGPP) {
    Write-Warning "Fine-Grained Password Policies exist in this domain."

    $FGPP | Select-Object `
        Name,
        Precedence,
        MinPasswordLength,
        MaxPasswordAge,
        ComplexityEnabled
}
else {
    Write-Host "No Fine-Grained Password Policies found."
}

# Set the default domain password policy
Set-ADDefaultDomainPasswordPolicy `
    -Identity $Domain `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -MinPasswordLength 12 `
    -ComplexityEnabled $true

Write-Host "`nDefault password policy updated for $Domain"

# Display resulting policy
Get-ADDefaultDomainPasswordPolicy |
    Select-Object `
        MaxPasswordAge,
        MinPasswordLength,
        ComplexityEnabled
