# Start of Settings 
# End of Settings 

$Results = $VM |where { (Get-Snapshot -VM $_).name -contains "VCB|Consolidate|veeam|NBU_SNAPSHOT" } |sort name |select name
$Results

$Title = "VCB/Veeam/NetBackup Garbage"
$Header =  "VCB/Veeam/Netbackup Garbage: $(@($Results).Count)"
$Comments = "The following snapshots have been left over from using VCB/Veeam or Netbackup, you may wish to investigate if these are still needed"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
