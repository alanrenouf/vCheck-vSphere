$Title = "Checking VI Events"
$Comments = "The following errors were logged in the vCenter Events tab, you may wish to investigate these"
$Display = "Table"
$Author = "Alan Renouf, Felix Longardt"
$PluginVersion = 1.5
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days of VC Events to check for errors
$VCEventAge = 1
$ExcludeUser = ""
$ExcludeEvent = ""
$VIMEventDate = (Get-Date).AddDays(-$VCEventAge).ToString("MM\/dd\/yyyy hh:mm:ss")
# End of Settings

if($PSEdition -eq "core"){
Get-VIEvent -Start $VIMEventDate -MaxSamples 10000 -Types error | Where-Object {$_.Username -notmatch $ExcludeUser -and $_.fullFormattedMessage -notmatch $ExcludeEvent} | Select-Object @{N="Host";E={$_.host.name}}, createdTime, @{N="User";E={($_.userName.split("\"))[1]}}, fullFormattedMessage
}
else
{
Get-VIEventPlus -Start ($Date).AddDays(-$VCEventAge ) -EventType Error | Select-Object @{N="Host";E={$_.host.name}}, createdTime, @{N="User";E={($_.userName.split("\"))[1]}}, fullFormattedMessage
}
$Header = ("Error Events (Last {0} Day(s)): [count]" -f $VCEventAge)

# 1.3 - works on Powershell core
# 1.4 - added Exclude event
# 1.5 - add Switch for Different PSEditions
