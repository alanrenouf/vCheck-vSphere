$Title = "Checking Standard vSwitch Ports Free"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# vSwitch Port Left
$vSwitchLeft = 5
# End of Settings

# Update settings where there is an override
$vSwitchLeft = Get-vCheckSetting $Title "vSwitchLeft" $vSwitchLeft

$VMH | Get-VirtualSwitch -Standard | Sort-Object NumPortsAvailable | Where-Object {$_.NumPortsAvailable -lt $($vSwitchLeft)} | Select-Object VMHost, Name, NumPortsAvailable

$Header = "Standard vSwitch with less than $vSwitchLeft Port(s) Free: [count]"
$Comments = "The following standard vSwitches have less than $vSwitchLeft left"