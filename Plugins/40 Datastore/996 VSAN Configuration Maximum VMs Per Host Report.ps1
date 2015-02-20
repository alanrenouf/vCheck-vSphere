# Start of Settings
# Enable VSAN Config Max VMs Per Host Reporting?
$vsanConfigMaxReport = $true
# Percentage threshold to warn?
$warning = 50
# End of Settings

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
$vsanMaxConfigInfo = @()
$vsanTotalVMsHostMaximum = 100

if($vsanConfigMaxReport) {
    foreach ($cluster in $clusviews) {
        if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
            $vmhosts = $cluster.Host
            foreach ($vmhost in $vmhosts | Sort-Object -Property Name) {
                $vmhostView = Get-View $vmhost -Property Name,Vm
                $totalVMs = ($vmhostView.Vm | Measure-Object).count
                $checkValue = [int]($totalVMs/$vsanTotalVMsHostMaximum * 100)

                if($checkValue -gt $warning) {
                    $Details = "" |Select VMHost, VMCount
                    $Details.VMHost = $vmhostView.Name
                    $Details.VMCount = $totalVMs
                    $vsanMaxConfigInfo += $Details
                }
            }
        }
    }
}

$vsanMaxConfigInfo

$Title = "VSAN Configuration Maximum VMs Per Host Report"
$Header =  "VSAN Config Max - VMs Per Host"
$Comments = "VSAN hosts approaching " + $warning + "% limit of " + $vsanTotalVMsHostMaximum + " VMs per host"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
