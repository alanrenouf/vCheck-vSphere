# Start of Settings 
# End of Settings 

$MyObj = @()
Foreach ($VMHost in $VMH) {
	$Details = "" | Select Host, TotalMemMB, TotalAssignedMemMB, TotalUsedMB, OverCommitMB
	$Details.Host = $VMHost.Name
	$Details.TotalMemMB = $VMHost.MemoryTotalMB
	if ($VMMem) { Clear-Variable VMMem }
   $VM | ?{$_.Host.Name -eq $VMHost.Name} | Foreach {
		[INT]$VMMem += $_.MemoryMB
	}
	$Details.TotalAssignedMemMB = $VMMem
	$Details.TotalUsedMB = $VMHost.MemoryUsageMB
	If ($Details.TotalAssignedMemMB -gt $VMHost.MemoryTotalMB) {
		$Details.OverCommitMB = ($Details.TotalAssignedMemMB - $VMHost.MemoryTotalMB)
	} Else {
		$Details.OverCommitMB = 0
	}
	$MyObj += $Details
}
$OverCommit = @($MyObj | Where {$_.OverCommitMB -gt 0})
$OverCommit

$Title = "Hosts Overcommit state"
$Header =  "Hosts overcommitting memory : $(@($OverCommit).count)"
$Comments = "Overcommitted hosts may cause issues with performance if memory is not issued when needed, this may cause ballooning and swapping"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
