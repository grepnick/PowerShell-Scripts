$ActivationStatus = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" |
    Where-Object { $_.PartialProductKey } |
    Select-Object -First 1 -Property LicenseStatus

$LicenseResult = switch($ActivationStatus.LicenseStatus) {
    0 {"Unlicensed"}
    1 {"Licensed"}
    2 {"OOBGrace"}
    3 {"OOTGrace"}
    4 {"NonGenuineGrace"}
    5 {"Not Activated"}
    6 {"ExtendedGrace"}
    default {"Unknown"}
}

# Output the result
$LicenseResult

# Exit with code 1 if not Licensed (LicenseStatus != 1)
if ($ActivationStatus.LicenseStatus -ne 1) {
    Write-Output "Windows is not properly licensed or activated."
    exit 1
} else {
  Write-Output "Windows is licensed and activated."
}
