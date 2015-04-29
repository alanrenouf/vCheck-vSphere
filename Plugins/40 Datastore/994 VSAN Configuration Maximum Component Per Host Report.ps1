# Start of Settings
# Enable VSAN Config Max Components Per Host Reporting?
$vsanConfigMaxReport = $true
# Percentage threshold to warn?
$warning = 50
# End of Settings

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
$vsanMaxConfigInfo = @()
$vsanComponentMaximum = 3000

if($vsanConfigMaxReport) {
    foreach ($cluster in $clusviews) {
        if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
            $vmhosts = $cluster.Host
            foreach ($vmhost in $vmhosts | Sort-Object -Property Name) {
                $vmhostView = Get-View $vmhost -Property Name,ConfigManager.VsanSystem,ConfigManager.VsanInternalSystem
                $vsanSys = Get-View -Id $vmhostView.ConfigManager.VsanSystem
                $vsanIntSys = Get-View -Id $vmhostView.ConfigManager.VsanInternalSystem

                $vsanProps = @("lsom_objects_count","owner")
                $results = $vsanIntSys.QueryPhysicalVsanDisks($vsanProps)
                $vsanStatus = $vsanSys.QueryHostStatus()

                $componentCount = 0
                $json = $results | ConvertFrom-Json
                foreach ($line in $json | Get-Member) {
                    # ensure component is owned by ESXi host
        	        if($vsanStatus.NodeUuid -eq $json.$($line.Name).owner) {
        	             $componentCount += $json.$($line.Name).lsom_objects_count
        	        }
       	        }
                $checkValue = [int]($componentCount/$vsanComponentMaximum * 100)

                if($checkValue -gt $warning) {
                    $Details = "" |Select VMHost, ComponentCount
                    $Details.VMHost = $vmhostView.Name
                    $Details.ComponentCount = $componentCount
                    $vsanMaxConfigInfo += $Details
                }
            }
        }
    }
}

$vsanMaxConfigInfo

$Title = "VSAN Configuration Maximum Components Per Host Report"
$Header =  "VSAN Config Max - Components Per Host"
$Comments = "VSAN hosts approaching " + $warning + "% limit of " + $vsanComponentMaximum + " components per host. For more information please refer to Cormac Hogan's article <a href='http://cormachogan.com/2013/09/04/vsan-part-4-understanding-objects-and-components/' target='_blank'>Understanding Objects and Components</a>"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
