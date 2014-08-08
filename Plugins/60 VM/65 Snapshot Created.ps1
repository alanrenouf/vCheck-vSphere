# Start of Settings 
# Set the number of days to show Snapshots created for
$VMsNewRemovedAge = 5
# User exception for Snapshot created
$snapshotUserException = "s-veeam"
# End of Settings

Get-VIEventPlus -Start ((get-date).adddays(-$VMsNewRemovedAge)) -EventType "TaskEvent" | ?{$_.FullFormattedMessage -match "Create virtual machine snapshot" -and $_.userName -notmatch $snapshotUserException} | Select @{N="Created Time";E={($_.createdTime).ToLocalTime()}}, @{N="User";E={$_.userName}}, @{N="VM Name";E={$_.vm.name}}

$Title = "Snapshot created"
$Header = "Snapshot created (Last $VMsNewRemovedAge Day(s)) (with user exception $snapshotUserException)"
$Comments = ""
$Display = "Table"
$Author = "Raphael Schitz, Frederic Martin"
$PluginVersion = 1.4
$PluginCategory = "vSphere"
