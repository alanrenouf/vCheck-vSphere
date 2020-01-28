$Title = "Datastore Clusters with sDRS Disabled"
$Header = "Datastore Clusters with sDRS disabled or set to manual: [count]"
$Comments = "The following Datastore Clusters either do not have sDRS enabled or it is set to manual"
$Display = "Table"
$Author = "Shawn Masterson"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings

$DatastoreClustersView | `
   Where-Object {$_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.Enabled -ne $true -or $_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultVmBehavior -ne "automated"} | `
   Select-Object Name, @{N="sDRS Enabled";E={$_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.Enabled}}, @{N="sDRS Automation Level";E={$_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultVmBehavior}}

# Changelog
## 1.0 : Initial Version
## 1.2 : Code refactor