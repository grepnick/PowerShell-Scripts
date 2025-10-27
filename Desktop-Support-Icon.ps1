$ShortcutName = "Support Portal.lnk"
$ShortcutPath = "C:\Users\Public\Desktop\$ShortcutName"
$TargetPath = "https://support.example.com"
$IconLocation = "C:\Windows\System32\shell32.dll,23"

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetPath
$Shortcut.IconLocation = $IconLocation
$Shortcut.Save()

Write-Output "Shortcut created at $ShortcutPath"
