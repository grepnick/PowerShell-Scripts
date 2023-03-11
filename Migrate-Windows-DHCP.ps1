# All in one script to export the dhcp configuration on a Windows server, 
# stop and disable the service, then transfer the export to a new server,
# import the configuration, and start the service on the new server.

# Define the source and destination servers
$sourceServer = "SourceServer"
$destinationServer = "DestinationServer"

# Define the paths for the export and import files
$exportFilePath = "C:\dhcp_export.xml"
$importFilePath = "C:\dhcp_import.xml"

# Export the DHCP configuration on the source server
Export-DhcpServer -ComputerName $sourceServer -File $exportFilePath -Force

# Stop and disable the DHCP service on the source server
Stop-Service -Name dhcpserver -ComputerName $sourceServer
Set-Service -Name dhcpserver -StartupType Disabled -ComputerName $sourceServer

# Copy the export file to the destination server
Copy-Item -Path $exportFilePath -Destination "\\$destinationServer\c$\" -Force

# Import the DHCP configuration on the destination server
Import-DhcpServer -ComputerName $destinationServer -File $importFilePath -Force

# Start and enable the DHCP service on the destination server
Set-Service -Name dhcpserver -StartupType Automatic -ComputerName $destinationServer
Start-Service -Name dhcpserver -ComputerName $destinationServer
