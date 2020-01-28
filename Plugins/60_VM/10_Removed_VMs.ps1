$Title = "Removed VMs"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days to show VMs removed for
$VMsNewRemovedAge = 5
# End of Settings

# Update settings where there is an override
$VMsNewRemovedAge = Get-vCheckSetting $Title "VMsNewRemovedAge" $VMsNewRemovedAge

Get-VIEventPlus -Start ((get-date).adddays(-$VMsNewRemovedAge)) -EventType "VmRemovedEvent" | Select-Object @{Name="VMName";Expression={$_.vm.name}}, CreatedTime, UserName, fullFormattedMessage

$Header = ("VMs Removed (Last {0} Day(s)): [count]" -f $VMsNewRemovedAge)
$Comments = "The following VMs have been removed/deleted over the last {0} days" -f $VMsNewRemovedAge

# Change Log
## 1.4 Added Get-vCheckSetting