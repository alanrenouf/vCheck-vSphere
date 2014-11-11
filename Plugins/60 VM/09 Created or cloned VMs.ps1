# Start of Settings 
# Set the number of days to show VMs created for
$VMsNewRemovedAge = 5
# End of Settings

@(Get-VIEventPlus -Start ((get-date).adddays(-$VMsNewRemovedAge)) -EventType @("VmCreatedEvent", "VmBeingClonedEvent", "VmBeingDeployedEvent") | Select createdTime, UserName, fullFormattedMessage)

$Title = "Created or cloned VMs"
$Header = ("VMs Created or Cloned (Last {0} Day(s)): [count])" -f $VMsNewRemovedAge)
$Comments = ("The following VMs have been created over the last {0} Days" -f $VMsNewRemovedAge)
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
