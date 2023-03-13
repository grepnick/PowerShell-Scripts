# Windows PowerShell Oneliners

My collection of PowerShell ish that is too complicated too remember.

## Display the most recent user login failures
Get-EventLog -LogName Security -InstanceId 4625 -Newest 50 | Where-Object {$_.Message -like "*failure*"} | Select-Object TimeGenerated, MachineName, @{Name="UserName";Expression={$_.ReplacementStrings[5]}} 




