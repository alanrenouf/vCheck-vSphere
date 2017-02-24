$Title = "Snapshot activity"
$Header = "Snapshot activity "
$Display = "Table"
$Author = "Chris Monahan, but is a minor mod of two plugins by Raphael Schitz and Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# Set the number of days to show Snapshots for
$VMsNewRemovedAge = 5
# User exception for Snapshot removed
$snapshotUserException = "s-veeam"
# End of Settings

# Update settings where there is an override
$VMsNewRemovedAge = Get-vCheckSetting $Title "VMsNewRemovedAge" $VMsNewRemovedAge
$snapshotUserException = Get-vCheckSetting $Title "snapshotUserException" $snapshotUserException

Get-VIEventPlus -Start ((get-date).adddays(- $VMsNewRemovedAge)) -EventType "TaskEvent" | ? { $_.FullFormattedMessage -match "snapshot" -and $_.userName -notmatch $snapshotUserException } | Select-Object @{ N = "Created Time"; E = { ($_.createdTime).ToLocalTime() } }, @{ N = "User"; E = { $_.userName } }, @{ N = "VM Name"; E = { $_.vm.name } }, @{ N = "Description"; E = { $_.FullFormattedMessage } } | Sort-Object "VM Name", "Created Time"

$Comments = ("Last {0} Day(s) with user exception {1}" -f $VMsNewRemovedAge, $snapshotUserException)

# This is a consolidation of "65 Snapshot Created.ps1" and "63 Snapshot Removed.ps1", by both Raphael Schitz and Frederic Martin.
# Shows snapshot activity by listing any task with the word "snapshot" in it, sorting by VM name then time of task creation.

# Change Log
## 1.1 : Added Get-vCheckSetting