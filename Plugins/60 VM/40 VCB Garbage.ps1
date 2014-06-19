# Start of Settings 
# End of Settings 

$Results = $FullVM | ?{$_.snapshot | %{$_.rootsnapshotlist | ?{$_.name -contains "VCB|Consolidate|veeam|NBU_SNAPSHOT"}}} | Sort Name | Select Name
$Results

$Title = "VCB/Veeam/NetBackup Garbage"
$Header = "VCB/Veeam/Netbackup Garbage: $(@($Results).Count)"
$Comments = "The following snapshots have been left over from using VCB/Veeam or Netbackup, you may wish to investigate if these are still needed"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
