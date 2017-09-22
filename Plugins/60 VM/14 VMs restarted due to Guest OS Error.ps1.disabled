$Title = "VMs restarted due to Guest OS Error"
$Header = "HA: VM restarted due to Guest OS Error: [count]"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# HA VM reset day(s) number due to Guest OS error
$HAVMresetold = 5
# End of Settings

# Update settings where there is an override
$HAVMresetold = Get-vCheckSetting $Title "HAVMresetold" $HAVMresetold

Get-VIEventPlus -Start ($Date).AddDays(-$HAVMresetold) -EventType "VmDasBeingResetEvent","VmDasBeingResetWithScreenshotEvent" | 
Select-Object CreatedTime,FullFormattedMessage | Sort-Object CreatedTime -Descending

$Comments = ("The following VMs have been restarted by HA in the last {0} days" -f $HAVMresetold)

# Change Log
## 1.4 : Let Get-VIEventPlus search for VmDasBeingResetEvent events
## 1.3 : Add Get-vCheckSetting and switch to Get-VIEventPlus
