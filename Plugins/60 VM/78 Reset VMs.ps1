$Title = "Reset VMs"
$Display = "Table"
$Author = "James Scholefield"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days to show reset VMs
$VMsResetAge = 1
# End of Settings

# Update settings where there is an override
$VMsResetAge = Get-vCheckSetting $Title "VMsResetAge" $VMsResetAge

Get-VIEventPlus -Start ((get-date).adddays(-$VMsResetAge)) -EventType "VmResettingEvent" | Select-Object createdTime, UserName, fullFormattedMessage

$Header = ("VMs Reset (Last {0} Day(s)) : [count]" -f $VMsResetAge)
$Comments = ("The following VMs have been reset over the last {0} days" -f $VMsResetAge)

# Change Log
## 1.0 : Initial release
## 1.1 : Added Get-vCheckSetting 