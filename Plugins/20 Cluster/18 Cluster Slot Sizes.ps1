$Title = "Cluster Slot Sizes"
$Header = "Clusters with less than $numslots Slot Sizes : [count]"
$Comments = "Available slots in the below cluster are less than is specified, this may cause issues with creating new VMs, for more information click here: <a href='http://www.yellow-bricks.com/vmware-high-availability-deepdiv/' target='_blank'>Yellow-Bricks HA Deep Dive</a>"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# Minimum number of slots available in a cluster
$numslots = 10
# End of Settings

# Update settings where there is an override
$numslots = Get-vCheckSetting $Title "numslots" $numslots

If ($vSphere){
   Foreach ($Cluster in ($Clusters)){
      If ($Cluster.ExtensionData.Configuration.DasConfig.Enabled -eq $true -and 
          $Cluster.ExtensionData.Configuration.DasConfig.AdmissionControlPolicy.getType() -eq [VMware.Vim.ClusterFailoverLevelAdmissionControlPolicy]){
         $SlotDetails = $Cluster.ExtensionData.RetrieveDasAdvancedRuntimeInfo()
         
         if ($SlotDetails.UnreservedSlots -lt $numslots) {
            [PSCustomObject] @{
               Cluster = $Cluster.Name
               TotalSlots = $SlotDetails.TotalSlots
               UsedSlots = $SlotDetails.UsedSlots
               AvailableSlots = $SlotDetails.UnreservedSlots
            }
         }
      }
   }
}