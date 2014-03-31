# Start of Settings
# Return results in GB or MB?
$Units ="GB"
# End of Settings

$MyObj = @()
If ($Units -eq "MB") {
	Foreach ($VMHost in $VMH) {
		$Details = "" | Select Host, TotalMemMB, TotalAssignedMemMB, TotalUsedMB, OverCommitMB
		$Details.Host = $VMHost.Name
		$Details.TotalMemMB = [Math]::Round($VMHost.MemoryTotalMB,0)
		if ($VMMem) { Clear-Variable VMMem }
	   $VM | ?{$_.Host.Name -eq $VMHost.Name} | Foreach {
			[INT]$VMMem += $_.MemoryMB
		}
		$Details.TotalAssignedMemMB = $VMMem
		$Details.TotalUsedMB = [Math]::Round($VMHost.MemoryUsageMB,0)
		If ($Details.TotalAssignedMemMB -ge $Details.TotalMemMB) {
			$Details.OverCommitMB = ($Details.TotalAssignedMemMB - $Details.TotalMemMB)
		} Else {
			$Details.OverCommitMB = -1
		}
		$MyObj += $Details
	}
	$OverCommit = @($MyObj | Where {$_.OverCommitMB -ge 0})
} Else {
	Foreach ($VMHost in $VMH) {
		$Details = "" | Select Host, TotalMemGB, TotalAssignedMemGB, TotalUsedGB, OverCommitGB
		$Details.Host = $VMHost.Name
		$Details.TotalMemGB = [Math]::Round($VMHost.MemoryTotalGB,0)
		if ($VMMem) { Clear-Variable VMMem }
	   $VM | ?{$_.Host.Name -eq $VMHost.Name} | Foreach {
			[INT]$VMMem += $_.MemoryGB
		}
		$Details.TotalAssignedMemGB = $VMMem
		$Details.TotalUsedGB = [Math]::Round($VMHost.MemoryUsageGB,0)
		If ($Details.TotalAssignedMemGB -ge $Details.TotalMemGB) {
			$Details.OverCommitGB = ($Details.TotalAssignedMemGB - $Details.TotalMemGB)
		} Else {
			$Details.OverCommitGB = -1
		}
		$MyObj += $Details
	}
	$OverCommit = @($MyObj | Where {$_.OverCommitGB -ge 0})
}	
	
$OverCommit

$Title = "Hosts Overcommit state"
$Header =  "Hosts overcommitting memory : $(@($OverCommit).count)"
$Comments = "Overcommitted hosts may cause issues with performance if memory is not issued when needed, this may cause ballooning and swapping"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"
