# Start of Settings 
# End of Settings


# Changelog
## 1.0 : Initial Version


$Result = @($DatastoreClustersView | Foreach {$dc = $_;$dc.PodStorageDrsEntry.StorageDrsConfig.VMConfig} | `
	Where {$_.Enabled -eq $false -or $_.Behavior -ne $null} | `
	Select @{N="VM";E={Get-View $_.Vm | Select -ExpandProperty Name}}, Enabled, Behavior,@{N="Datastore Cluster";E={$dc.Name}})
$Result


$Title = "sDRS VM Behavior not Default"
$Header = "VMs overriding Datastore Cluster automation level: $(@($Result).Count)"
$Comments = "The following VMs are overriding the Datastore Cluster sDRS automation level"
$Display = "Table"
$Author = "Shawn Masterson"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
