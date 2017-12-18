$Title = "VSAN Configuration Maximum Disk Group Per Host Report"
$Header =  "VSAN Configuration Maximum - Disk Group Per Host"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# Percentage threshold to warn?
$vsanWarningThreshold = 80
# End of Settings

# Update settings where there is an override
$vsanWarningThreshold = Get-vCheckSetting $Title "vsanWarningThreshold" $vsanWarningThreshold

# This config maximum is different for each version of VSAN, 5 for 5.5
$vsanDiskGroupMaximum = 5

foreach ($cluster in $clusviews) {
   if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
      $vmhosts = $cluster.Host
      foreach ($vmhost in $vmhosts | Sort-Object -Property Name) {
         $vmhostView = Get-View $vmhost -Property Name,ConfigManager.VsanSystem
         $vsanSys = Get-View -Id $vmhostView.ConfigManager.VsanSystem
         # Number of DG's per Host
         $diskGroups = ($vsanSys.Config.StorageInfo.DiskMapping | Measure-Object).count
         $checkValue = [int]($diskGroups/$vsanDiskGroupMaximum * 100)

         if($checkValue -gt $vsanWarningThreshold) {
            New-Object -TypeName PSObject -Property @{
               "VMHost" = $vmhostView.Name
               "DiskGroupCount" = $diskGroups }
         }
      }
   }
}

$Comments = "VSAN hosts approaching {0}% limit of {1} Disk Groups per host" -f $vsanWarningThreshold, $vsanDiskGroupMaximum

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
## 1.2 : Add Get-vCheckSetting