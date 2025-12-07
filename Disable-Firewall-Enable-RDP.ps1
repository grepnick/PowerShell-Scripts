Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
