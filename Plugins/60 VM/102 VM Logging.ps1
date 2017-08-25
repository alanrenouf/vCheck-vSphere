$Title = "VM Logging"
$Header = "VMs with improper logging settings: [count]"
$Display = "Table"
$Author = "Bob Cote"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# The number of logs to keep for each VM
$KeepOld = 10
# The size logs can reach before rotating to a new log (bytes)
$RotateSize = 1000000
# End of Settings

# Update settings where there is an override
$KeepOld = Get-vCheckSetting $Title "KeepOld" $KeepOld
$RotateSize = Get-vCheckSetting $Title "RotateSize" $RotateSize

$VM | Foreach-Object {
   $VMKeepOld = $_.ExtensionData.Config.ExtraConfig | Where-Object {$_.Key -eq "log.keepold"} | Select-Object -ExpandProperty Value
   $VMRotateSize = $_.ExtensionData.Config.ExtraConfig | Where-Object {$_.Key -eq "log.rotatesize"} | Select-Object -ExpandProperty Value

   If ($VMKeepOld -ne $KeepOld -Or $VMRotateSize -ne $RotateSize) {
      New-Object -TypeName PSObject -Property @{
         Name = $_.Name
         KeepOld = $VMKeepOld
         RotateSize = $VMRotateSize
      }
   }
}

$Comments = ("The following virtual machines are not configured to rotate logs at $RotateSize bytes and/or to store {0} logs." -f $KeepOld)

# Change Log
## 1.0 : Initial Release
## 1.1 : Added Get-vCheckSetting, code refactor