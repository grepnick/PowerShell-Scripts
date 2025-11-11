$role = (Get-WmiObject Win32_ComputerSystem).DomainRole

if ($role -eq 4 -or $role -eq 5) {
    Write-Host "This system is a Domain Controller. Running DC-specific code..."

    $Username = "ITadmin"
    $Password = "asdfasdf"
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    Set-ADAccountPassword -Identity $Username -NewPassword $SecurePassword
    Write-Output "Password changed for $Username."

} else {
    Write-Host "This system is NOT a Domain Controller. Running member code..."

    $Username = "ITadmin"
    $Password = "asdfasdf"
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    Set-LocalUser -Name $Username -Password $SecurePassword
    Write-Output "Password changed for $Username."
} 
