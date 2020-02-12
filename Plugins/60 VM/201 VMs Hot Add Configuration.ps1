$Title = "VMs Memory/CPU Hot Add configuration"
$Header = "VMs Memory/CPU Hot Add configuration"
$Display = "Table"
$Author = "Marc Bouchard"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# Should CPU hot plug be enabled
$CPUHotAdd = $true
# Should Memory hot add be enabled
$MEMHotAdd = $true
# End of Settings

# Update settings where there is an override
$CPUHotAdd = Get-vCheckSetting $Title "CPUHotAdd" $CPUHotAdd
$MEMHotAdd = Get-vCheckSetting $Title "MEMHotAdd" $MEMHotAdd

$VMs | Select-Object Name, @{N="CPU Hot Plug Enabled"; E={$_.ExtensionData.config.CpuHotAddEnabled}}, @{N="Memory Hot Add Enabled"; E={$_.ExtensionData.config.MemoryHotAddEnabled}} | Where-Object {$_."CPU Hot Plug Enabled" -ne $CPUHotAdd -or $_."Memory Hot Add Enabled" -ne $MEMHotAdd}

# Create variables with unexpected values, for use in the plugin comment
$CPUNotExpected = if ($CPUHotAdd) { "disabled" } else { "enabled" }
$MEMNotExpected = if ($MEMHotAdd) { "disabled" } else { "enabled" }

$Comments = ("The following lists all VMs with CPU hot plug {0} or Memory hot add {1}" -f $CPUNotExpected, $MEMNotExpected)

# Change Log
## 1.2 : Added Get-vCheckSetting