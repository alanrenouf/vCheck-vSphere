# Start of Settings
# Enable VSAN Config Max Hosts Per VSAN Cluster Reporting?
$vsanConfigMaxReport = $true
# Percentage threshold to warn?
$warning = 45
# End of Settings

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
$vsanMaxConfigInfo = @()
$vsanTotalHostMaximum = 32

if($vsanConfigMaxReport) {
    foreach ($cluster in $clusviews) {
        if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
            $vmhosts = $cluster.Host
            $totalHosts = ($vmhosts | Measure-Object).count
            $checkValue = [int]($totalHosts/$vsanTotalHostMaximum * 100)

            if($checkValue -gt $warning) {
                $Details = "" |Select Cluster, TotalHostCount
                $Details.Cluster = $cluster.Name
                $Details.TotalHostCount = $totalHosts
                $vsanMaxConfigInfo += $Details	
            }
        }
    }
}

$vsanMaxConfigInfo

$Title = "VSAN Configuration Maximum Hosts Per VSAN Cluster Report"
$Header =  "VSAN Config Max - Hosts Per VSAN Cluster"
$Comments = "VSAN hosts approaching " + $warning + "% limit of " + $vsanTotalHostMaximum + " hosts per VSAN Cluster. For more information about enabling 16+ VSAN Host per VSAN Cluster please refer to William Lam's article <a href='http://www.virtuallyghetto.com/2014/03/required-esxi-advanced-setting-to-support-16-node-vsan-cluster.htmlhttp://cormachogan.com/2013/09/04/vsan-part-4-understanding-objects-and-components/' target='_blank'>Required ESXi advanced setting to support 16+ node VSAN Cluster</a>"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
