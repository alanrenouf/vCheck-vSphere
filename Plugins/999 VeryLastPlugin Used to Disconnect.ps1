# Start of Settings
# End of Settings
 
# Everything in this script will run at the end of vCheck
If ($VIConnection) {
  $VIConnection | Disconnect-VIServer -Confirm:$false
}

# Unset variables
$vars = @("VM", "VMH", "Clusters", "Datastores", "FullVM", "VMTmpl", "ServiceInstance", "alarmMgr", "HostsViews", "clusviews", "storageviews", "DatastoreClustersView")
$vars | foreach { Remove-Variable $_ }

$Title = "Disconnecting from vCenter"
$Display = "None"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$Header =  "Disconnects from vCenter"
$Comments = "Disconnect plugin"
$Display = "None"

$PluginCategory = "vSphere"
