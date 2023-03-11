# Use this to create an AD group that automatically adds members to a group based on their city.

# Define an array of city names
$cities = @("New York", "Los Angeles", "Chicago")

# Loop through the array of cities and create a group for each one
foreach ($city in $cities) {
    # Get the name of the group that corresponds to the city
    $groupName = "City - $city"
    
    # Check if the group exists, create it if it doesn't
    $group = Get-ADGroup -Filter { Name -eq $groupName } -ErrorAction SilentlyContinue
    if (!$group) {
        $group = New-ADGroup -Name $groupName -GroupCategory Security -GroupScope Global -Path "OU=City Groups,DC=example,DC=com"
    }
    
    # Get a list of all users in Active Directory with the specified city
    $usersInCity = Get-ADUser -Filter { City -eq $city }
    
    # Loop through the users and add them to the group
    foreach ($user in $usersInCity) {
        Add-ADGroupMember -Identity $group.Name -Members $user.SamAccountName
    }
    
    # Loop through the users in the group and remove any that don't belong
    $members = Get-ADGroupMember -Identity $group.Name | Where-Object { $_.objectClass -eq 'user' } | Select-Object -ExpandProperty SamAccountName
    foreach ($member in $members) {
        $user = Get-ADUser -Identity $member
        if ($user.City -ne $city) {
            Remove-ADGroupMember -Identity $group.Name -Members $member
        }
    }
}
