# Start of Settings 
# Set the number of days to show VMs created for
$VMsNewRemovedAge =5
# End of Settings

$VIEvent = Get-VIEvent -maxsamples $MaxSampleVIEvent -Start ($Date).AddDays(-$VMsNewRemovedAge)
$OutputCreatedVMs = @($VIEvent | where {$_.Gettype().Name -eq "VmCreatedEvent" -or $_.Gettype().Name -eq "VmBeingClonedEvent" -or $_.Gettype().Name -eq "VmBeingDeployedEvent"} | Select createdTime, UserName, fullFormattedMessage)
$OutputCreatedVMs

$Title = "Created or cloned VMs"
$Header =  "VMs Created or Cloned (Last $VMsNewRemovedAge Day(s)): $(@($OutputCreatedVMs).count)"
$Comments = "The following VMs have been created over the last $($VMsNewRemovedAge) Days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
