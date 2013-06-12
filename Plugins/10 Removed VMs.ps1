# Start of Settings 
# Set the number of days to show VMs removed for
$VMsNewRemovedAge =5
# End of Settings

$OutputRemovedVMs = @($VIEvent | where {$_.Gettype().Name -eq "VmRemovedEvent"}| Select CreatedTime, UserName, fullFormattedMessage)
$OutputRemovedVMs

$Title = "Removed VMs"
$Header =  "VMs Removed (Last $VMsNewRemovedAge Day(s)) : $(@($OutputRemovedVMs).count)"
$Comments = "The following VMs have been removed/deleted over the last $($VMsNewRemovedAge) days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
