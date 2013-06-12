# Start of Settings 
# Set the number of days to show VMs created for
$VMsNewRemovedAge =5
# User exception for Snapshot created/removed
$snapshotUserException =" s-veeam"
# End of Settings


Get-VIEvent -maxsamples $MaxSampleVIEvent -Start (Get-Date).AddDays(-$VMsNewRemovedAge) | where {($_.fullFormattedMessage -match "Remove snapshot") -and ($_.userName -notmatch $snapshotUserException)}| Select createdTime, @{N="User";E={$_.userName}}, @{N="VM Name";E={$_.vm.name}}

$Title = "Snapshot removed"
$Header =  "Snapshot removed (Last $VMsNewRemovedAge Day(s)) (with user exception $snapshotUserException)"
$Comments = ""
$Display = "Table"
$Author = "Raphael Schitz, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
