$Title = "Unwanted virtual hardware found"
$Header = "Unwanted virtual hardware found: [count]"
$Comments = "Certain kinds of hardware are unwanted on virtual machines as they may cause unnecessary vMotion constraints."
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# Find unwanted virtual hardware
$unwantedHardware = "VirtualUSBController|VirtualParallelPort|VirtualSerialPort"
# End of Settings

# Update settings where there is an override
$unwantedHardware = Get-vCheckSetting $Title "unwantedHardware" $unwantedHardware

foreach ($vmguest in $FullVM) {
   $vmguest.Config.Hardware.Device | Where-Object {$_.GetType().Name -match $unwantedHardware} | Foreach-Object {
      New-Object -TypeName PSObject -Property @{
         Name = $vmguest.name 
         Label = $_.DeviceInfo.Label
      }
   }
}

#Thanks to @lucd http://communities.vmware.com/message/1546618

# Change Log
## 1.2 : Added Get-vCheckSetting