$Title = "VMs on Ephemeral Portgroup"
$Header = "VMs on Ephemeral Portgroup: [count]"
$Comments = ""
$Display = "Table"
$Author = "Tim Williams"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

$EphemeralPG = Get-VDSwitch | Get-VDPortgroup | Where-Object {$_.PortBinding -eq "Ephemeral"}
$VM | Get-NetworkAdapter | Where-Object {$_.NetworkName -in $EphemeralPG.Name} | Select-Object @{Name="VMName"; Expression={$_.parent}}, @{Name="Portgroup"; Expression={$_.NetworkName}}

# Change Log
## 1.0 : Initial release
## 1.1 : Modified Where-Object filter to retreive result when there are more then one $EphemeralPG object
