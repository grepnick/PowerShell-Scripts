$role = (Get-WmiObject Win32_ComputerSystem).DomainRole

if ($role -eq 4 -or $role -eq 5) {
    Write-Host "This system is a Domain Controller. Running DC-specific code..."

    $Username = "ITadmin"
    $Password = ConvertTo-SecureString "asdfasdf" -AsPlainText -Force
    $FullName = "IT Domain Admin"
    $Group = "Domain Admins"
    if (Get-ADUser -Filter {SamAccountName -eq $Username}) {
        Write-Output "User $Username already exists. Exiting."
        exit
    } else {
        New-ADUser -Name $FullName -SamAccountName $Username -AccountPassword $Password -Enabled $true -PasswordNeverExpires $true -PassThru
        Add-ADGroupMember -Identity $Group -Members $Username    
        Write-Output "User $Username has been created and added to the Domain Admins group."
    }
} else {
    Write-Host "This system is NOT a Domain Controller. Running member code..."

    $Username = "ITadmin"
    $Password = "asdfasdf"
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    $User = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
    if ($User) {
        Write-Host "User '$Username' already exists. Exiting."
        exit
    } else {
        New-LocalUser -Name $Username -Password $SecurePassword -PasswordNeverExpires -FullName "IT Local Admin" -Description "Local admin account created via RMM"
        Add-LocalGroupMember -Group "Administrators" -Member $Username
        Write-Host "Local administrator account '$Username' has been created successfully."}
} 
