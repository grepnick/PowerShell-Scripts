# When I wrote this, M365 did not play well with nested groups. With this script, 
# you can create a CSV where the first field is the destination group name, and
# all the subsequent groups are source groups that feed into the destination group.
# Then you can run it via a scheduled task and the ADSync will pick up the changes
# and push them to Office 365. I hope this helps someone.

# Credit: Nick Marsh

# You can also use a PowerAutomate Flow to # Synchronize an Azure AD Group with an 
# Office 365 Group on a recurring basis, which works well with this setup:
# https://powerautomate.microsoft.com/en-us/templates/details/0b51be005f85488c8da4c23b929f771c/synchronize-an-azure-ad-group-with-an-office-365-group-on-a-recurring-basis/

# CSV Format:
# DestinationGroup1,SourceGroup1,SourceGroup2,etc.
# DestinationGroup2,SourceGroup3,SourceGroup4,etc.
# DestinationGroup3,SourceGroup4,SourceGroup5,etc.



# AzureAD now supports dynamic groups with a P1 license -- but sometimes you need 
# something really special for your edge cases ( you don't have P1 licenses).
# See: https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-dynamic-membership

# Get the input CSV file path from the user
#$file = Get-Item Read-Host "Enter the path to the input CSV file"
$file = c:\path_to_your_csv.csv

# Read the CSV file and loop through each row
Import-Csv $file | ForEach-Object {
    # Get the destination group name from the first field of the current row
    $destinationGroup = $_.PSObject.Properties.Value[0]

    # Loop through each subsequent field in the current row and get the source group name
    $sourceGroups = $_.PSObject.Properties.Value[1..$_.PSObject.Properties.Count]

    # Get the current members of the destination group
    $currentMembers = Get-ADGroupMember $destinationGroup | Select-Object -ExpandProperty SamAccountName

    # Loop through each source group and add its members to the destination group
    foreach ($sourceGroup in $sourceGroups) {
        # Get the members of the current source group
        $members = Get-ADGroupMember $sourceGroup | Select-Object -Property SamAccountName, Name

        # Add each member to the destination group
        foreach ($member in $members) {
            if ($currentMembers -notcontains $member.SamAccountName) {
                Add-ADGroupMember -Identity $destinationGroup -Members $member.SamAccountName
                Write-Host "Added $($member.Name) to $($destinationGroup) group"
            }
        }
    }

    # Get the updated members of the destination group
    $updatedMembers = Get-ADGroupMember $destinationGroup | Select-Object -ExpandProperty SamAccountName

    # Check if any members were removed from the destination group
    $removedMembers = Compare-Object $currentMembers $updatedMembers | Where-Object { $_.SideIndicator -eq "<=" } | Select-Object -ExpandProperty InputObject

    # Remove any members that were removed from the source groups
    foreach ($removedMember in $removedMembers) {
        Remove-ADGroupMember -Identity $destinationGroup -Members $removedMember
        $removedUser = Get-ADUser $removedMember
        Write-Host "Removed $($removedUser.Name) from $($destinationGroup) group"
    }
}



# Nice!
