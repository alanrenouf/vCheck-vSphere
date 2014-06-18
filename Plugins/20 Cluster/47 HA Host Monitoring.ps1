# Start of Settings 
# End of Settings

$HAmonitor = $clusviews | where {$_.Configuration.DasConfig.HostMonitoring -eq "disabled"} | sort name | select Name, @{N="Host_Monitor";E={$_.Configuration.DasConfig.HostMonitoring}}
$HAmonitor

$Title = "Find clusters that have HA host monitoring disabled"
$Header = "Clusters with HA host monitoring disabled: $(@($HAmonitor).count)"
$Comments = "The following clusters have HA host monitoring disabled"
$Display = "Table"
$Author = "David Chung"
$PluginVersion = 1.1
	
$PluginCategory = "vSphere"
