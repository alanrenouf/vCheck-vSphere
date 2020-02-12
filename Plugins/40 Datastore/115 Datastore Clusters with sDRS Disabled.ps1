$Title = "Datastore Clusters with sDRS Disabled"
$Header = "Datastore Clusters with sDRS disabled or set to manual: [count]"
$Comments = "The following Datastore Clusters either do not have sDRS enabled or it is set to manual"
$Display = "Table"
$Author = "Shawn Masterson", "Dan Barr"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings
# Datastore Cluster(s) to ignore (regex)
$IgnoreDSCluster = "IgnoreMe"
# End of Settings

# Update settings where there is an override
$IgnoreDSCluster = Get-vCheckSetting $Title "IgnoreDSCluster" $IgnoreDSCluster

$DatastoreClustersView |
   Where-Object {$_.Name -notmatch $IgnoreDSCluster -and ($_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.Enabled -ne $true -or $_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultVmBehavior -ne "automated")} |
   Select-Object Name, @{N="sDRS Enabled";E={$_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.Enabled}}, @{N="sDRS Automation Level";E={$_.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultVmBehavior}}

# Changelog
## 1.0 : Initial Version
## 1.2 : Code refactor
## 1.3 : Add datastore clusters to exclude from report
