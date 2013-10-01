# Start of Settings
# Find unwanted virtual hardware
$unwantedHardware ="VirtualUSBController|VirtualParallelPort|VirtualSerialPort"
# End of Settings

#Thanks to @lucd http://communities.vmware.com/message/1546618
$vUnwantedHw = @()
foreach ($vmguest in $FullVM) {
	$vmguest.Config.Hardware.Device | where {$_.GetType().Name -match $unwantedHardware} | %{
		$myObj = "" | select Name,Label
		$myObj.Name = $vmguest.name 
		$myObj.Label = $_.DeviceInfo.Label
		$vUnwantedHw += $myObj
	}
}

$vUnwantedHw | Sort Name

$Title = "Unwanted virtual hardware found"
$Header =  "Unwanted virtual hardware found"
$Comments = "Certain kinds of hardware are unwanted on virtual machines as they may cause unnecessary vMotion constraints."
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
