$Title = "VMs on Ephemeral Portgroup"
$Header = "VMs on Ephemeral Portgroup: [count]"
$Comments = ""
$Display = "Table"
$Author = "Tim Williams"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings
 
$EphemeralPG = Get-VDSwitch | Get-VDPortgroup | Where-Object {$_.PortBinding -eq "Ephemeral"}
$VM | Get-NetworkAdapter | Where-Object {$_.NetworkName -contains $EphemeralPG} | Select-Object @{Name="VMName"; Expression={$_.parent}}, @{Name="Portgroup"; Expression={$_.NetworkName}}