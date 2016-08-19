# Start of Settings
# End of Settings
 
$EphemeralPG = Get-VDSwitch | Get-VDPortgroup | where {$_.PortBinding -eq "Ephemeral"}
@($VM | Get-NetworkAdapter | where {$_.NetworkName -contains $EphemeralPG} | Select @{Name="VMName"; Expression={$_.parent}}, @{Name="Portgroup"; Expression={$_.NetworkName}})
 
$Title = "VMs on Ephemeral Portgroup"
$Header = "VMs on Ephemeral Portgroup: [count]"
$Comments = ""
$Display = "Table"
$Author = "Tim Williams"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
