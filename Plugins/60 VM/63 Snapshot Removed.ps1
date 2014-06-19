# Start of Settings 
# Set the number of days to show Snapshots removed for
$VMsNewRemovedAge = 5
# User exception for Snapshot removed
$snapshotUserException = "s-veeam"
# End of Settings

$EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
$EventFilterSpec.Category = "info"
$EventFilterSpec.Time = New-Object VMware.Vim.EventFilterSpecByTime
$EventFilterSpec.Time.beginTime = ((get-date).adddays(-$VMsNewRemovedAge)).ToUniversalTime()
$EventFilterSpec.eventTypeId = "TaskEvent"
(get-view (get-view ServiceInstance -Property Content.EventManager).Content.EventManager).QueryEvents($EventFilterSpec) | `
	?{($_.FullFormattedMessage -match "Remove snapshot" -or $_.FullFormattedMessage -match "Remove all snapshots") -and $_.userName -notmatch $snapshotUserException} | `
	Select @{N="Removal Time";E={($_.createdTime).ToLocalTime()}}, @{N="User";E={$_.userName}}, @{N="VM Name";E={$_.vm.name}}

$Title = "Snapshot removed"
$Header = "Snapshot removed (Last $VMsNewRemovedAge Day(s)) (with user exception $snapshotUserException)"
$Comments = ""
$Display = "Table"
$Author = "Raphael Schitz, Frederic Martin"
$PluginVersion = 1.4
$PluginCategory = "vSphere"
