$Title = "Checking VI Events"
$Comments = "The following errors were logged in the vCenter Events tab, you may wish to investigate these"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days of VC Events to check for errors
$VCEventAge = 1
# End of Settings 

Get-VIEventPlus -Start ($Date).AddDays(-$VCEventAge ) -EventType Error | Select-Object @{N="Host";E={$_.host.name}}, createdTime, @{N="User";E={($_.userName.split("\"))[1]}}, fullFormattedMessage

$Header = ("Error Events (Last {0} Day(s)): [count]" -f $VCEventAge)