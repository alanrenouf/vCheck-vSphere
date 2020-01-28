$Title = "VSAN Configuration Maximum Components Per Host Report"
$Header =  "VSAN Config Max - Components Per Host"
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

# This config maximum is different for each version of VSAN, 3000 for 5.5
$vsanComponentMaximum = 3000

foreach ($cluster in $clusviews) {
   if($cluster.ConfigurationEx.VsanConfigInfo.Enabled) {
      foreach ($vmhost in ($cluster.Host) | Sort-Object -Property Name) {
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

         if($checkValue -gt $vsanWarningThreshold) {
            New-Object -TypeName PSObject -Property @{
               "VMHost" = $vmhostView.Name
               "ComponentCount" = $componentCount }
         }
      }
   }
}

$Comments = ("VSAN hosts approaching {0}% limit of {1} components per host. For more information please refer to Cormac Hogan's article <a href='http://cormachogan.com/2013/09/04/vsan-part-4-understanding-objects-and-components/' target='_blank'>Understanding Objects and Components</a>" -f $vsanWarningThreshold,  $vsanComponentMaximum )

# Changelog
## 1.0 : Initial Release
## 1.1 : Fix indentation + using global $clusviews
## 1.2 : Add Get-vCheckSetting