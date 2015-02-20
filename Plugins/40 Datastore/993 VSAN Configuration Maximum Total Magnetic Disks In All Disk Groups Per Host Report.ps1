# Start of Settings
# Enable VSAN Config Max Total Magnetic Disks In All Disk Groups Per Host Reporting?
$vsanConfigMaxReport = $true
# Percentage threshold to warn?
$warning = 50
# End of Settings

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
$vsanMaxConfigInfo = @()
$vsanTotalMDMaximum = 35

if($vsanConfigMaxReport) {
    foreach ($cluster in $clusviews) {
        if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
            $vmhosts = $cluster.Host
            foreach ($vmhost in $vmhosts |  Sort-Object -Property Name) {
            	$totalMDs = 0
            	$vmhostView = Get-View $vmhost -Property Name,ConfigManager.VsanSystem
            	$vsanSys = Get-View -Id $vmhostView.ConfigManager.VsanSystem
            	foreach ($diskMapping in $vsanSys.Config.StorageInfo.DiskMapping) {
            	    $mds = ($diskMapping.NonSsd | Measure-Object).count
            	    $totalMDs += $mds
            	}
            	$checkValue = [int]($totalMDs/$vsanTotalMDMaximum * 100)

            	if($checkValue -gt $warning) {
            	    $Details = "" |Select VMhost, TotalMDCount
            	    $Details.VMhost = $vmhostView.Name
            	    $Details.TotalMDCount = $mds
            	    $vsanMaxConfigInfo += $Details	
            	}
            }
        }
    }
}

$vsanMaxConfigInfo

$Title = "VSAN Configuration Maximum Total Magnetic Disks In All Disk Groups Per Host Report"
$Header =  "VSAN Config Max -  Total Magnetic Disks In All Disk Groups Per Host"
$Comments = "VSAN hosts approaching " + $warning + "% limit of " + $vsanTotalMDMaximum + " total magnetic disks in all Disk Groups per host"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
