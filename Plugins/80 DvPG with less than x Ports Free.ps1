# Start of Settings 
# Distributed PortGroup Ports Left
$DvSwitchLeft = 10
# End of Settings

$vdspg = Get-VDSwitch | sort Name | Get-VDPortgroup
$ImpactedDVS = @() 

Foreach ($i in $vdspg | where {$_.IsUplink -ne 'True' -and $_.PortBinding -ne 'Ephemeral'} ) {

$NumPorts = (Get-VDPortgroup $i).NumPorts
$NumVMs = (Get-VDPortgroup $i | Get-VM).Count
$OpenPorts = $NumPorts - $NumVMs

If ($OpenPorts -lt $DvSwitchLeft) {


$myObj = "" | select vDSwitch,Name,OpenPorts
$myObj.vDSwitch = $i.VDSwitch
$myObj.Name = $i.Name
$myObj.OpenPorts = $OpenPorts

$ImpactedDVS += $myObj

}

}

$ImpactedDVS

$Title = "Checking Distributed vSwitch Port Groups for Ports Free"
$Header =  "Distributed vSwitch Port Groups with less than $vSwitchLeft Port(s) Free: $(@($ImpactedDVS).Count)"
$Comments = "The following Distributed vSwitch Port Groups have less than $vSwitchLeft left"
$Display = "Table"
$Author = "Kyle Ruddy"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
