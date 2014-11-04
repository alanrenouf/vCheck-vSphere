# Start of Settings 
# Set the number of days to show reset VMs
$VMsResetAge = 1
# End of Settings

@(Get-VIEventPlus -Start ((get-date).adddays(-$VMsResetAge)) -EventType "VmResettingEvent" | Select createdTime, UserName, fullFormattedMessage)

$Title = "Reset VMs"
$Header = "VMs Reset (Last $VMsResetAge Day(s)) : [count]"
$Comments = "The following VMs have been reset over the last $($VMsResetAge) days"
$Display = "Table"
$Author = "James Scholefield"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
