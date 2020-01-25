$Title = "Checking VI Events"
$Comments = "The following errors were logged in the vCenter Events tab, you may wish to investigate these"
$Display = "Table"
$Author = "Alan Renouf, Felix Longardt"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days of VC Events to check for errors
$VCEventAge = 1
$ExcludeUser = "nagios"
$VIMEventDate = "(Get-Date).AddDays(-1).ToString(MM\/dd\/yyyy hh:mm:ss)"
# End of Settings

Get-VIEvent -Start $VIMEventDate -MaxSamples 10000 -Types error | Where-Object {$_.Username -notmatch $ExcludeUser} | Select-Object @{N="Host";E={$_.host.name}}, createdTime, @{N="User";E={($_.userName.split("\"))[1]}}, fullFormattedMessage

$Header = ("Error Events (Last {0} Day(s)): [count]" -f $VCEventAge)

# 1.3 - works on Powershell core
