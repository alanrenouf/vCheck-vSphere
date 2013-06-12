# Start of Settings 
# Number of slots available in a cluster
$numslots =10
# End of Settings
		
If ($vSphere){
	$SlotInfo = @()
	Foreach ($Cluster in ($Clusters)){
		If ($Cluster.ExtensionData.Configuration.DasConfig.Enabled -eq $true){
			$SlotDetails = $Cluster.ExtensionData.RetrieveDasAdvancedRuntimeInfo()
			$Details = "" | Select Cluster, TotalSlots, UsedSlots, AvailableSlots
			$Details.Cluster = $Cluster.Name
			$Details.TotalSlots =  $SlotDetails.TotalSlots
			$Details.UsedSlots = $SlotDetails.UsedSlots
			$Details.AvailableSlots = $SlotDetails.UnreservedSlots
			$SlotInfo += $Details
		}
	}
	$SlotCHK = @($SlotInfo | Where { $_.AvailableSlots -lt $numslots})
}

$SlotCHK

$Title = "Cluster Slot Sizes"
$Header =  "Clusters with less than $numslots Slot Sizes : $(@($SlotCHK).count)"
$Comments = "Slot sizes in the below cluster are less than is specified, this may cause issues with creating new VMs, for more information click here: <a href='http://www.yellow-bricks.com/vmware-high-availability-deepdiv/' target='_blank'>Yellow-Bricks HA Deep Dive</a>"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
