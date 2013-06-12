# Start of Settings 
# End of Settings 

$RespondHosts = @($VMH | where {$_.ConnectionState -ne "Connected" -and $_.ConnectionState -ne "Maintenance"} | Select name, @{N="Connection State";E={$_.ExtensionData.Runtime.ConnectionState}}, @{N="Power State";E={$_.ExtensionData.Runtime.PowerState}})
$RespondHosts

$Title = "Hosts Not responding or Disconnected"
$Header =  "Hosts not responding or disconnected : $(@($RespondHosts).count)"
$Comments = "Hosts which are in a disconnected state will not be running any virtual machine worloads, check the below Hosts are in an expected state"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
