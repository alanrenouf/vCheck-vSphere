# Start of Settings 
# End of Settings 

$HostsVer = @()
foreach ($clusview in $clusviews) {
	$HostsVerMiss = $HostsViews | ?{ $_.Parent -match $clusview.MoRef} | select @{N="FullName";E={$_.Config.Product.FullName}} -Unique
	if (($HostsVerMiss | Measure-Object).Count -gt 1) {
		$allVer = ""
		foreach ($Ver in $HostsVerMiss) { $allVer = $allVer + $Ver.FullName + ";" }
		$Details = "" | Select-Object Cluster, Ver
		$Details.Cluster = $clusview.name
		$Details.Ver = "*mismatch* " + $allVer.Substring(0, $allVer.Length-1)
		$HostsVer += $Details
	} elseif (($HostsVerMiss | Measure-Object).Count -eq 1) {
		$Details = "" | Select-Object Cluster, Ver
		$Details.Cluster = $clusview.name
		$Details.Ver = $HostsVerMiss.FullName
		$HostsVer += $Details
	}
}

$HostsVer | Sort Cluster

$Title = "Cluster Node version"
$Header = "Cluster Node version"
$Comments = "Display per cluster nodes version if unique or mismatch"
$Display = "Table"
$Author = "Raphael Schitz, Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
