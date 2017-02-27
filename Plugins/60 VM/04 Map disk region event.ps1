$Title = "Map disk region event"
$Comments = "These may occur due to VCB issues, check <a href='http://kb.vmware.com/kb/1007331' target='_blank'>this article</a> for more details"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days to show Map disk region event for
$eventAge = 5
# End of Settings 

# Update settings where there is an override
$eventAge = Get-vCheckSetting $Title "eventAge" $eventAge

Get-VIEventPlus -Start ($Date).AddDays(-$eventAge) -Type Info | Where-Object {$_.FullFormattedMessage -match "Map disk region"} | Foreach-Object {$_.vm}| Select-Object name |Sort-Object -unique

$Header = ("Map disk region event (Last {0} Day(s)): [count]" -f $eventAge)

# Change Log
## 1.2 : Added Get-vCheckSetting and Get-VIEventPlus