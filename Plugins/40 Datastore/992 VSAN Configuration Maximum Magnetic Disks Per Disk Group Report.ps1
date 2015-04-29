# Start of Settings
# Enable VSAN Config Max Magnetic Disks Per Disk Group Reporting?
$vsanConfigMaxReport = $true
# Percentage threshold to warn?
$warning = 50
# End of Settings

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
$vsanMaxConfigInfo = @()
$vsanMDMaximum = 7

if($vsanConfigMaxReport) {
    foreach ($cluster in $clusviews) {
        if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
            $vmhosts = $cluster.Host
            foreach ($vmhost in $vmhosts | Sort-Object -Property Name) {
            	$vmhostView = Get-View $vmhost -Property Name,ConfigManager.VsanSystem
            	$vsanSys = Get-View -Id $vmhostView.ConfigManager.VsanSystem
            	foreach ($diskMapping in $vsanSys.Config.StorageInfo.DiskMapping) {
            	    $mds = ($diskMapping.NonSsd | Measure-Object).count
            	    $checkValue = [int]($mds/$vsanMDMaximum * 100)

            	    if($checkValue -gt $warning) {
            	    	$Details = "" |Select VMHost, MDCount
            	    	$Details.VMHost = $vmhostView.Name
            	    	$Details.MDCount = $mds
            	    	$vsanMaxConfigInfo += $Details
            	    }	
            	}
            }
        }
    }
}

$vsanMaxConfigInfo

$Title = "VSAN Configuration Maximum Magnetic Disks Per Disk Group Report"
$Header =  "VSAN Config Max - Magnetic Disks Per Disk Group"
$Comments = "VSAN hosts approaching " + $warning + "% limit of " + $vsanMDMaximum + " magnetic disks per Disk Group"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
