# Start of Settings 
# vSwitch Port Left
$vSwitchLeft =5
# End of Settings

$Result = $VMH | Get-VirtualSwitch -Standard | Sort NumPortsAvailable | Where {$_.NumPortsAvailable -lt $($vSwitchLeft)} | Select VMHost, Name, NumPortsAvailable
$Result

$Title = "Checking Standard vSwitch Ports Free"
$Header =  "Standard vSwitch with less than $vSwitchLeft Port(s) Free: $(@($Result).Count)"
$Comments = "The following standard vSwitches have less than $vSwitchLeft left"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
