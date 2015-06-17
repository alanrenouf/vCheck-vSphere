# Start of Settings 
# End of Settings

$HotAdd = @($VM | Select-Object Name, @{N="CPU Hot Plug Enabled"; E={$_.ExtensionData.config.CpuHotAddEnabled}}, @{N="Memory Hot Add Enabled"; E={$_.ExtensionData.config.MemoryHotAddEnabled}})
$HotAdd

$Title = "VMs Memory/CPU Hot Add configuration"
$Header = "VMs Memory/CPU Hot Add configuration"
$Comments = "The following lists all VMs and they Hot Add / Hot Plug feature configuration"

$Display = "Table"
$Author = "Marc Bouchard"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
