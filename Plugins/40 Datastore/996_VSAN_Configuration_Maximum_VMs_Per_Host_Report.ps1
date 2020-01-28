$Title = "VSAN Configuration Maximum VMs Per Host Report"
$Header =  "VSAN Config Max - VMs Per Host"
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

# This config maximum is different for each version of VSAN, 100 for 5.5
$vsanTotalVMsHostMaximum = 100

foreach ($cluster in $clusviews) {
   if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
      foreach ($vmhost in $cluster.Host | Sort-Object -Property Name) {
         $vmhostView = Get-View $vmhost -Property Name,Vm
         $totalVMs = ($vmhostView.Vm | Measure-Object).count
         $checkValue = [int]($totalVMs/$vsanTotalVMsHostMaximum * 100)

         if($checkValue -gt $vsanWarningThreshold) {
            New-Object -TypeName PSObject -Property @{
            "VMHost" = $vmhostView.Name
            "VMCount" = $totalVMs }
         }
      }
   }
}

$Comments = ("VSAN hosts approaching {0}% limit of {1} VMs per host" -f $vsanWarningThreshold, $vsanTotalVMsHostMaximum)

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
## 1.2 : Add Get-vCheckSetting