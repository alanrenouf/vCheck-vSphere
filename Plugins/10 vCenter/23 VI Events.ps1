# Start of Settings 
# End of Settings 

$Result = @(Get-VIEvent -maxsamples $MaxSampleVIEvent -Start ($Date).AddDays(-$VCEventAge ) -Type Error | Select @{N="Host";E={$_.host.name}}, createdTime, @{N="User";E={($_.userName.split("\"))[1]}}, fullFormattedMessage)
$Result

$Title = "Checking VI Events"
$Header = "Error Events (Last $VCEventAge Day(s)): $(@($Result).Count)"
$Comments = "The following errors were logged in the vCenter Events tab, you may wish to investigate these"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
