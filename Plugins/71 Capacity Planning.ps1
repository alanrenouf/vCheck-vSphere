# Start of Settings 
# Max CPU usage for non HA cluster
$limitResourceCPUClusNonHA = 0.6 
# Max MEM usage for non HA cluster
$limitResourceMEMClusNonHA = 0.6 
# End of Settings

$capacityinfo = @()
foreach ($cluv in ($clusviews | Sort Name)) {
		$clucapacity = "" |Select ClusterName, "Estimated Num VM Left (CPU)", "Estimated Num VM Left (MEM)", "vCPU/pCPU ratio", "VM/VMHost ratio"
		if ( $cluv.Configuration.DasConfig.Enabled -eq $true ) {
			$DasRealCpuCapacity = $cluv.Summary.EffectiveCpu - (($cluv.Summary.EffectiveCpu * $cluv.Configuration.DasConfig.FailoverLevel)/$cluv.Summary.NumHosts)
			$DasRealMemCapacity = $cluv.Summary.EffectiveMemory - (($cluv.Summary.EffectiveMemory * $cluv.Configuration.DasConfig.FailoverLevel)/$cluv.Summary.NumHosts)
		} else {
			$DasRealCpuCapacity = $cluv.Summary.EffectiveCpu * $limitResourceCPUClusNonHA
			$DasRealMemCapacity = $cluv.Summary.EffectiveMemory * $limitResourceMEMClusNonHA
		}
		
		$cluvmlist = (Get-Cluster $cluv.name|Get-VM)
		
		#CPU
			$CluCpuUsage = (get-view $cluv.ResourcePool).Summary.runtime.cpu.OverallUsage
		$CluCpuUsageAvg = $CluCpuUsage
		if ($cluvmlist -and $cluv.host -and $CluCpuUsageAvg -gt 0){
			$VmCpuAverage = $CluCpuUsageAvg/(Get-Cluster $cluv.name|Get-VM).count
			$CpuVmLeft = [math]::round(($DasRealCpuCapacity-$CluCpuUsageAvg)/$VmCpuAverage,0)
		}
		elseif ($CluCpuUsageAvg -eq 0) {$CpuVmLeft = "N/A"}
		else {$CpuVmLeft = 0}
		
	
		#MEM
			$CluMemUsage = (get-view $cluv.ResourcePool).Summary.runtime.memory.OverallUsage
		$CluMemUsageAvg = $CluMemUsage/1MB
		if ($cluvmlist -and $cluv.host -and $CluMemUsageAvg -gt 100){
			$VmMemAverage = $CluMemUsageAvg/(Get-Cluster $cluv.name|Get-VM).count
			$MemVmLeft = [math]::round(($DasRealMemCapacity-$CluMemUsageAvg)/$VmMemAverage,0)
		}
		elseif ($CluMemUsageAvg -lt 100) {$CluMemUsageAvg = "N/A"}
		else{$MemVmLeft = 0}
	
		$clucapacity.ClusterName = $cluv.name
		$clucapacity."Estimated Num VM Left (CPU)" = $CpuVmLeft
		$clucapacity."Estimated Num VM Left (MEM)" = $MemVmLeft
		if ($cluvmlist){
			$vCPUpCPUratio = [math]::round(($cluvmlist|Measure-Object -Sum -Property NumCpu).sum / $cluv.summary.NumCpuThreads,0)
			$clucapacity."vCPU/pCPU ratio" = $vCPUpCPUratio
		}
		else {$clucapacity."vCPU/pCPU ratio" = "0 (vCPU < pCPU)"}
		if ($cluvmlist){
			$clucapacity."VM/VMHost ratio" = [math]::round(($cluvmlist).count/$cluv.Summary.NumHosts,0)
		}
		else {$clucapacity."VM/VMHost ratio" = 0}

		$capacityinfo += $clucapacity
}

$capacityinfo | Sort ClusterName

$Title = "QuickStats Capacity Planning"
$Header =  "QuickStats Capacity Planning"
$Comments = "The following gives brief capacity information for each cluster based on QuickStats CPU/Mem usage and counting for HA failover requirements"
$Display = "Table"
$Author = "Raphael Schitz, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"
