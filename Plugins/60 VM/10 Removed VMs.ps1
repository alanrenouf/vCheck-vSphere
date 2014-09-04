# Start of Settings 
# Set the number of days to show VMs removed for
$VMsNewRemovedAge = 5
# End of Settings

$OutputRemovedVMs = @(Get-VIEventPlus -Start ((get-date).adddays(-$VMsNewRemovedAge)) -EventType "VmRemovedEvent" | Select CreatedTime, UserName, fullFormattedMessage)
$OutputRemovedVMs

$Title = "Removed VMs"
$Header = ("VMs Removed (Last {0} Day(s)): {1}" -f $VMsNewRemovedAge,$OutputRemovedVMs.count)
$Comments = ("The following VMs have been removed/deleted over the last {0} days" -f $VMsNewRemovedAge)
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
