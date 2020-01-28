$Title = "Created or cloned VMs"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days to show VMs created for
$VMsNewRemovedAge = 5
# End of Settings

# Update settings where there is an override
$VMsNewRemovedAge = Get-vCheckSetting $Title "VMsNewRemovedAge" $VMsNewRemovedAge

Get-VIEventPlus -Start ((get-date).adddays(-$VMsNewRemovedAge)) -EventType @("VmCreatedEvent", "VmBeingClonedEvent", "VmBeingDeployedEvent") | Select-Object createdTime, UserName, fullFormattedMessage

$Header = ("VMs Created or Cloned (Last {0} Day(s)): [count])" -f $VMsNewRemovedAge)
$Comments = ("The following VMs have been created over the last {0} Days" -f $VMsNewRemovedAge)

# Change Log 
## 1.3 : Added Get-vCheckSetting