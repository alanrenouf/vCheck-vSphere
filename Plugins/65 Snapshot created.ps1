# Start of Settings 
# Set the number of days to show Snapshots created for
$VMsNewRemovedAge = 5
# User exception for Snapshot created
$snapshotUserException = "s-veeam"
# End of Settings

$EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
$EventFilterSpec.Category = "info"
$EventFilterSpec.Time = New-Object VMware.Vim.EventFilterSpecByTime
$EventFilterSpec.Time.beginTime = (get-date).adddays(-$VMsNewRemovedAge)
$EventFilterSpec.eventTypeId = "TaskEvent"
(get-view (get-view ServiceInstance -Property Content.EventManager).Content.EventManager).QueryEvents($EventFilterSpec) | ?{$_.FullFormattedMessage -match "Create virtual machine snapshot" -and $_.userName -notmatch $snapshotUserException} | Select createdTime, @{N="User";E={$_.userName}}, @{N="VM Name";E={$_.vm.name}}

$Title = "Snapshot created"
$Header =  "Snapshot created (Last $VMsNewRemovedAge Day(s)) (with user exception $snapshotUserException)"
$Comments = ""
$Display = "Table"
$Author = "Raphael Schitz, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"
