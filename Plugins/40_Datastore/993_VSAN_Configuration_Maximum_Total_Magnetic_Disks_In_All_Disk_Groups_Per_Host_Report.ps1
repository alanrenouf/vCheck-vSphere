$Title = "VSAN Configuration Maximum Total Magnetic Disks In All Disk Groups Per Host Report"
$Header =  "VSAN Config Max -  Total Magnetic Disks In All Disk Groups Per Host"
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

# This config maximum is different for each version of VSAN, 35 for 5.5
$vsanTotalMDMaximum = 35

foreach ($cluster in $clusviews) {
   if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
      foreach ($vmhost in $cluster.Host |  Sort-Object -Property Name) {
         $totalMDs = 0
         $vmhostView = Get-View $vmhost -Property Name,ConfigManager.VsanSystem
         $vsanSys = Get-View -Id $vmhostView.ConfigManager.VsanSystem
         foreach ($diskMapping in $vsanSys.Config.StorageInfo.DiskMapping) {
            $mds = ($diskMapping.NonSsd | Measure-Object).count
            $totalMDs += $mds
         }
         $checkValue = [int]($totalMDs/$vsanTotalMDMaximum * 100)

         if($checkValue -gt $vsanWarningThreshold) {
            New-Object -TypeName PSObject -Property @{
               "VMhost" = $vmhostView.Name
               "TotalMDCount" = $mds }
         }
      }
   }
}

$Comments = ("VSAN hosts approaching {0}% limit of {1} total magnetic disks in all Disk Groups per host" -f $vsanWarningThreshold, $vsanTotalMDMaximum)

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
## 1.2 : Add Get-vCheckSetting