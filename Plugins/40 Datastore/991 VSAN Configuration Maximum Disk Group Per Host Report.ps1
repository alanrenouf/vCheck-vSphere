# Start of Settings
# Enable VSAN Config Max Disk Group Per Host Reporting?
$vsanConfigMaxReport = $true
# Percentage threshold to warn?
$warning = 80
# End of Settings

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
$vsanMaxConfigInfo = @()
$vsanDiskGroupMaximum = 5

if($vsanConfigMaxReport) {
    foreach ($cluster in $clusviews) {
        if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
            $vmhosts = $cluster.Host
            foreach ($vmhost in $vmhosts | Sort-Object -Property Name) {
            	$vmhostView = Get-View $vmhost -Property Name,ConfigManager.VsanSystem
            	$vsanSys = Get-View -Id $vmhostView.ConfigManager.VsanSystem
            	# Number of DG's per Host
            	$diskGroups = ($vsanSys.Config.StorageInfo.DiskMapping | Measure-Object).count
            	$checkValue = [int]($diskGroups/$vsanDiskGroupMaximum * 100)

            	if($checkValue -gt $warning) {
            	    $Details = "" |Select VMHost, DiskGroupCount
            	    $Details.VMHost = $vmhostView.Name
            	    $Details.DiskGroupCount = $diskGroups
            	    $vsanMaxConfigInfo += $Details
            	}
            }
        }
    }
}

$vsanMaxConfigInfo

$Title = "VSAN Configuration Maximum Disk Group Per Host Report"
$Header =  "VSAN Configuration Maximum - Disk Group Per Host"
$Comments = "VSAN hosts approaching " + $warning + "% limit of " + $vsanDiskGroupMaximum + " Disk Groups per host"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
