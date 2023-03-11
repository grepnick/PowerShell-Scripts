# Script to take a CSV file with a list of AD Groups and sync them directly to an office 365 group.
# Have not tested yet.

# Check if the required modules are installed and install them if necessary
$modules = @("AzureAD","ActiveDirectory")
foreach ($module in $modules) {
    if (-not(Get-Module $module)) {
        Write-Host "Installing $module module..."
        Install-Module -Name $module -Force
    }
}

# Set the Office 365 credentials
$username = "your_username_here"
$password = "your_password_here" | ConvertTo-SecureString -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($username, $password)

# Import the modules and connect to Office 365
Import-Module AzureAD
Import-Module ActiveDirectory
Connect-AzureAD -Credential $creds

# Read the CSV file
$csv = Import-Csv -Path C:\path\to\file.csv

# CSV Format:
# DestinationGroup1,SourceGroup1,SourceGroup2,etc.
# DestinationGroup2,SourceGroup3,SourceGroup4,etc.
# DestinationGroup3,SourceGroup4,SourceGroup5,etc.

# Loop through each row in the CSV file
foreach ($row in $csv) {

    # Get the destination group
    $destinationGroup = Get-UnifiedGroup -Identity $row.DestinationGroup

    # Get the source groups
    $sourceGroups = $row | Select-Object -Skip 1 | Get-ADGroup

    # Add the members from the source groups to the destination group
    foreach ($sourceGroup in $sourceGroups) {
        $membersToAdd = Get-ADGroupMember -Identity $sourceGroup | Where-Object {$_.objectClass -eq 'user'}
        foreach ($member in $membersToAdd) {
            Add-UnifiedGroupLinks -Identity $destinationGroup -LinkType Members -Links $member.distinguishedName
            Write-Host "Added user $($member.DisplayName) to group $($destinationGroup.DisplayName)."
        }
    }

    # Check for any members in the destination group that are no longer in the source groups and remove them
    $currentMembers = Get-UnifiedGroupLinks -Identity $destinationGroup -LinkType Members
    foreach ($currentMember in $currentMembers) {
        $memberExists = $false
        foreach ($sourceGroup in $sourceGroups) {
            $members = Get-ADGroupMember -Identity $sourceGroup | Where-Object {$_.objectClass -eq 'user'}
            foreach ($member in $members) {
                if ($member.distinguishedName -eq $currentMember) {
                    $memberExists = $true
                }
            }
        }
        if (!$memberExists) {
            Remove-UnifiedGroupLinks -Identity $destinationGroup -LinkType Members -Links $currentMember
            $removedUser = Get-ADUser -Identity $currentMember
            Write-Host "Removed user $($removedUser.DisplayName) from group $($destinationGroup.DisplayName)."
        }
    }
}

# NICE!
# Disconnect from Office 365
Disconnect-AzureAD
