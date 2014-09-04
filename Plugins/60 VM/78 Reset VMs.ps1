# Start of Settings 
# Set the number of days to show VMs reset for
$VMsResetAge = 1
# End of Settings

$OutputResetVMs = @(Get-VIEventPlus -Start ((get-date).adddays(-$VMsResetAge)) -EventType "VmResettingEvent" | Select createdTime, UserName, fullFormattedMessage)
$OutputResetVMs

$Title = "Reset VMs"
$Header = ("VMs Reset (Last {0} Day(s)): {1}" -f $VMsResetAge,$OutputResetVMs.count)
$Comments = ("The following VMs have been reset over the last {0} days" -f $VMsResetAge)
$Display = "Table"
$Author = "James Scholefield"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
