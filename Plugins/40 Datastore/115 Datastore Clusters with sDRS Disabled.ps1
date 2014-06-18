# Start of Settings 
# End of Settings

# Changelog
## 1.0 : Initial Version


$Result = @($DatastoreClustersView | `
	Where {$_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.Enabled -ne $true -or $_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultVmBehavior -ne "automated"} | `
	Select Name, @{N="sDRS Enabled";E={$_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.Enabled}}, @{N="sDRS Automation Level";E={$_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultVmBehavior}})
$Result


$Title = "Datastore Clusters with sDRS Disabled"
$Header = "Datastore Clusters with sDRS disabled or set to manual: $(@($Result).Count)"
$Comments = "The following Datastore Clusters either do not have sDRS enabled or it is set to manual"
$Display = "Table"
$Author = "Shawn Masterson"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
