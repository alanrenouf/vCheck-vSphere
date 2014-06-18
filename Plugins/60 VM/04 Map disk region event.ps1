# Start of Settings 
# End of Settings 

$MapDiskRegionEvents = @($VIEvent | Where {$_.FullFormattedMessage -match "Map disk region"} | Foreach {$_.vm}|select name |Sort-Object -unique)
$MapDiskRegionEvents

$Title = "Map disk region event"
$Header = "Map disk region event (Last $VMsNewRemovedAge Day(s)) : $(@($MapDiskRegionEvents).count)"
$Comments = "These may occur due to VCB issues, check <a href='http://kb.vmware.com/kb/1007331' target='_blank'>this article</a> for more details"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
