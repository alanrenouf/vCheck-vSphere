$Title = "VSAN Configuration Maximum Hosts Per VSAN Cluster Report"
$Header =  "VSAN Config Max - Hosts Per VSAN Cluster"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# Percentage threshold to warn?
$vsanWarningThreshold = 45
# End of Settings

# Update settings where there is an override
$vsanWarningThreshold = Get-vCheckSetting $Title "vsanWarningThreshold" $vsanWarningThreshold

# This config maximum is different for each version of VSAN, 32 for 5.5
$vsanTotalHostMaximum = 32

foreach ($cluster in $clusviews) {
   if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
      $totalHosts = ($cluster.Host | Measure-Object).count
      $checkValue = [int]($totalHosts/$vsanTotalHostMaximum * 100)

      if($checkValue -gt $vsanWarningThreshold) {
         New-Object -TypeName PSObject -Property @{
            "Cluster" = $cluster.Name
            "TotalHostCount" = $totalHosts }
      }
   }
}

$Comments = ("VSAN hosts approaching {0}% limit of {1} hosts per VSAN Cluster. For more information about enabling 16+ VSAN Host per VSAN Cluster please refer to William Lam's article <a href='http://www.virtuallyghetto.com/2014/03/required-esxi-advanced-setting-to-support-16-node-vsan-cluster.htmlhttp://cormachogan.com/2013/09/04/vsan-part-4-understanding-objects-and-components/' target='_blank'>Required ESXi advanced setting to support 16+ node VSAN Cluster</a>" -f $vsanWarningThreshold,  $vsanTotalHostMaximum)

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
## 1.2 :  Add Get-vCheckSetting