# Start of Settings
# Enable VSAN Config Max VMs Per VSAN Cluster Reporting?
$vsanConfigMaxReport = $true
# Percentage threshold to warn?
$warning = 50
# End of Settings

# Changelog
## 1.0 : Initial Release
$vsanMaxConfigInfo = @()
$vsanTotalVMsPerClusterMaximum = 3200

if($vsanConfigMaxReport) {
    foreach ($cluster in $clusviews) {
        if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
            $totalVMs = (Get-View -ViewType VirtualMachine -SearchRoot $cluster.MoRef -Property Name).Count
            $checkValue = [int]($totalVMs/$vsanTotalVMsPerClusterMaximum * 100)

            if($checkValue -gt $warning) {
                $Details = "" |Select Cluster, TotalVMCount
                $Details.Cluster = $cluster.Name
                $Details.TotalVMCount = $totalVMs
                $vsanMaxConfigInfo += $Details	
            }
        }
    }
}

$vsanMaxConfigInfo

$Title = "VSAN Configuration Maximum VMs Per VSAN Cluster Report"
$Header =  "VSAN Config Max - VMs Per VSAN Cluster"
$Comments = "VSAN hosts approaching " + $warning + "% limit of " + $vsanTotalVMsPerClusterMaximum + " VMs per VSAN Cluster"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
