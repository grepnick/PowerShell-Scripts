$APIKey       = "YOUR_API_KEY"
$BaseURI      = "https://api.itglue.com"

$PasswordName = "Password Name"
$Username     = "username"
$Password     = "password"
$Notes        = "Base template for mass creating passwords to be used with Network Glue."

$Headers = @{
    "x-api-key"    = $APIKey
    "Content-Type" = "application/vnd.api+json"
}

$Organizations = (Invoke-RestMethod `
    -Method Get `
    -Uri "$BaseURI/organizations?page[size]=1000" `
    -Headers $Headers `
    -ErrorAction Stop
).data

Write-Host "Found $($Organizations.Count) organizations."

foreach ($Organization in $Organizations) {

    $OrganizationID   = $Organization.id
    $OrganizationName = $Organization.attributes.name

    $Body = @{
        data = @{
            type = "passwords"
            attributes = @{
                name              = $PasswordName
                username          = $Username
                password          = $Password
                notes             = $Notes
                "organization-id" = $OrganizationID
            }
        }
    } | ConvertTo-Json -Depth 10

    try {

        $Result = Invoke-RestMethod `
            -Method Post `
            -Uri "$BaseURI/passwords" `
            -Headers $Headers `
            -Body $Body `
            -ErrorAction Stop

        Write-Host "SUCCESS: $OrganizationName - $OrganizationID"
    }
    catch {

        Write-Host "FAILED: $OrganizationName - $OrganizationID"
        Write-Host $_.Exception.Message
    }
}
