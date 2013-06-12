# Start of Settings
# End of Settings
 
# Everything in this script will run at the end of vCheck
If ($VIConnection) {
  $VIConnection | Disconnect-VIServer -Confirm:$false
}

$Title = "Disconnecting from vCenter"
$Display = "None"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$Header =  "Disconnects from vCenter"
$Comments = "Disconnect plugin"
$Display = "None"

$PluginCategory = "vSphere"
