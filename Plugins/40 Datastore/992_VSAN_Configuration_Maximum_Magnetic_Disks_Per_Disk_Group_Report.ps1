$Title = "VSAN Configuration Maximum Magnetic Disks Per Disk Group Report"
$Header =  "VSAN Config Max - Magnetic Disks Per Disk Group"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# Percentage threshold to warn?
$vsanWarningThreshold = 50
# End of Settings

# Update settings where there is an override
$vsanWarningThreshold = Get-vCheckSetting $Title "vsanWarningThreshold" $vsanWarningThreshold

# This config maximum is different for each version of VSAN, 7 for 5.5
$vsanMDMaximum = 7

foreach ($cluster in $clusviews) {
   if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
      foreach ($vmhost in $cluster.Host | Sort-Object -Property Name) {
         $vmhostView = Get-View $vmhost -Property Name,ConfigManager.VsanSystem
         $vsanSys = Get-View -Id $vmhostView.ConfigManager.VsanSystem
         foreach ($diskMapping in $vsanSys.Config.StorageInfo.DiskMapping) {
            $mds = ($diskMapping.NonSsd | Measure-Object).count
            $checkValue = [int]($mds/$vsanMDMaximum * 100)

            if($checkValue -gt $vsanWarningThreshold) {
               New-Object -TypeName PSObject -Property @{
                  "VMHost" = $vmhostView.Name
                  "MDCount" = $mds }
            }
         }
      }
   }
}

$Comments = ("VSAN hosts approaching {0}% limit of {1} magnetic disks per Disk Group" -f $vsanWarningThreshold, $vsanMDMaximum)

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
## 1.2 : Add Get-vCheckSetting, code clean up