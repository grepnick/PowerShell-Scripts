# Import the Active Directory module
Import-Module ActiveDirectory

# Set the path to the target OU
$OU = "OU=Users,DC=example,DC=com"

# Get a list of all users in the target OU
$users = Get-ADUser -SearchBase $OU -Filter *

# Create an array to store the output data
$output = @()

# Loop over the list of users
foreach ($user in $users) {
  # Get the user's full name, username, last login, and last password change
  $full_name = $user.Name
  $username = $user.SamAccountName
  $last_login = $user.LastLogonDate
  $last_pwd_change = $user.PasswordLastSet

  # Create a custom object to store the user information
  $obj = New-Object PSObject
  $obj | Add-Member -MemberType NoteProperty -Name "Full Name" -Value $full_name
  $obj | Add-Member -MemberType NoteProperty -Name "Username" -Value $username
  $obj | Add-Member -MemberType NoteProperty -Name "Last Login" -Value $last_login
  $obj | Add-Member -MemberType NoteProperty -Name "Last Password Change" -Value $last_pwd_change

  # Add the custom object to the output array
  $output += $obj
}

# Save the output data to a CSV file
$output | Export-Csv -Path "user_info.csv" -NoTypeInformation
