$Shortcuts = @{
   "Link 1" = "https://example.com"
   "Link 2" = "https://example.com"
   "Link 3" = "https://example.com"
}

$DesktopPath = "C:\Users\Public\Desktop"

foreach ($Name in $Shortcuts.Keys) {
   $Url = $Shortcuts[$Name]
   $ShortcutFile = "$DesktopPath\$Name.url"
   # Create the .url file
   $Content = @"
[InternetShortcut]
URL=$Url
IconIndex=0
"@

   $Content | Set-Content -Path $ShortcutFile -Encoding ASCII
}
Write-Host "Shortcuts created successfully for all users."
