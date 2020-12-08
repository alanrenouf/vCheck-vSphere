# Start of Settings   
# End of Settings

$Title = "Cluster Overcommitment rate"
$Header = "Cluster Overcommitment rate"
$Comments = "The ratio of the VM-assigned CPU and memory to the actual existing hardware CPU amd memory"
$Author = "Dennis Ploeger"
$PluginVersion = "1.0"
$PluginCategory = "vSphere"
$Display = "Table"

foreach ($cluv in ($clusviews | Where-Object {$_.Summary.NumHosts -gt 0 } | Sort-Object Name)) {
    $cluvmlist = $VM | Where-Object { $cluv.Host -contains $_.VMHost.Id  }

    $totalCpu = $cluv.Summary.NumCpuThreads
    $totalMem = $cluv.Summary.EffectiveMemory/1024

    $committedCpu = ($cluvmlist|Measure-Object -Sum -Property NumCpu).sum
    $committedMem = ($cluvmlist|Measure-Object -Sum -Property MemoryGB).sum

    $clusterInfo = "" | Select-Object Name, TotalCPU, TotalMem, CommittedCPU, CommittedMem, OverCommitmentRateCpu, OverCommitmentRateMem
    $clusterInfo.Name = $cluv.Name
    $clusterInfo.TotalCPU = $totalCpu
    $clusterInfo.TotalMem = [math]::Round($totalMem, 2)
    $clusterInfo.CommittedCPU = $committedCpu
    $clusterInfo.CommittedMem = $committedMem
    $clusterInfo.OverCommitmentRateCpu = [math]::Round($committedCpu / $totalCpu * 100, 2)
    $clusterInfo.OverCommitmentRateMem = [math]::Round($committedMem / $totalMem * 100, 2)
    $clusterInfo
}
