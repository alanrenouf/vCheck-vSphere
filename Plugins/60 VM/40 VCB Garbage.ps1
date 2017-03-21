$Title = "VCB/Veeam/NetBackup Garbage"
$Header = "VCB/Veeam/Netbackup Garbage: [count]"
$Comments = "The following snapshots have been left over from using VCB/Veeam or Netbackup, you may wish to investigate if these are still needed"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"


# Start of Settings 
# End of Settings 

$FullVM | Where-Object {$_.snapshot | Foreach-Object {$_.rootsnapshotlist | Where-Object {$_.name -contains "VCB|Consolidate|veeam|NBU_SNAPSHOT"}}} | Sort-Object Name | Select-Object Name