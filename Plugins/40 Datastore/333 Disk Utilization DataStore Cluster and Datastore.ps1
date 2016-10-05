# Start of Settings 
# Set the warning threshold for Datastore % Free Space
$WarningDatastorePercentFree = 20
# Set the critical threshold for Datastore % Free Space
$CriticalDatastorePercentFree = 10
# Do not report on any Datastores that are defined here (Datastore Free Space Plugin)
$DatastoreIgnore = "local"
# End of Settings

# ChangeLog
# 1.1 - Changed Table Formating setup for Expandable/Collapsible blocks
# 1.2 - Changed how it finds the Datastores for each Cluster and VMs for each Datastore

$DatastoreClustersCapicity = @(Get-DatastoreCluster | Where-Object {$_.Name -notmatch $DatastoreIgnore} | Sort-Object Name)

$OutputDatastoreSpaceUtilization = @()
ForEach ($Cluster in $DatastoreClustersCapicity){
    $ClusterObj = "" | Select Cluster, DataStore, VMGuest, CapacityGB, FreeSpaceGB, PercentFree
    $ClusterObj.Cluster = $Cluster.Name
    $ClusterObj.DataStore = $null
    $ClusterObj.VMGuest = $null
    $ClusterObj.CapacityGB = [math]::Round($Cluster.CapacityGB, 2)
    $ClusterObj.FreeSpaceGB = [math]::Round($Cluster.FreeSpaceGB, 2)
    $ClusterObj.PercentFree = [math]::Round(($Cluster.FreeSpaceGB / $Cluster.CapacityGB) * 100, 2)

	$OutputDatastoreSpaceUtilization += $ClusterObj

    ForEach ($eachDs in $Cluster.ExtensionData.ChildEntity) {
        $DSID = $eachDs.Type + '-' + $eachDs.Value
        $DataStoreObj = "" | Select Cluster, DataStore, VMGuest, CapacityGB, FreeSpaceGB, PercentFree
        $DatastoreObj.Cluster = $null
        $DatastoreObj.DataStore = $Datastores[$DSIDHash[$DSID]].Name
        $DatastoreObj.VMGuest = $null
        $DatastoreObj.CapacityGB = [math]::Round($Datastores[$DSIDHash[$DSID]].CapacityGB, 2)
        $DatastoreObj.FreeSpaceGB = [math]::Round($Datastores[$DSIDHash[$DSID]].FreeSpaceGB, 2)
        $DatastoreObj.PercentFree = [math]::Round(($Datastores[$DSIDHash[$DSID]].FreeSpaceGB / $Datastores[$DSIDHash[$DSID]].CapacityGB) * 100, 2)
        
		$OutputDatastoreSpaceUtilization += $DatastoreObj

        ForEach ($eachVM in $Datastores[$DSIDHash[$DSID]].ExtensionData.Vm) {
            $VMID = $eachVM.Type + '-' + $eachVM.Value
            $VMGuestObj = "" | Select Cluster, DataStore, VMGuest, CapacityGB, FreeSpaceGB, PercentFree
            $VMGuestObj.Cluster = $null
            $VMGuestObj.DataStore = $null
            $VMGuestObj.VMGuest = $VM[$VMIDHash[$VMID]].Name
            $VMGuestObj.CapacityGB = [math]::Round($VM[$VMIDHash[$VMID]].ProvisionedSpaceGB, 2)
            $VMGuestObj.FreeSpaceGB = [math]::Round(($VM[$VMIDHash[$VMID]].ProvisionedSpaceGB - $VM[$VMIDHash[$VMID]].UsedSpaceGB), 2)
            $VMGuestObj.PercentFree = "NA"

    		$OutputDatastoreSpaceUtilization += $VMGuestObj
	    }
	}
}

$OutputDatastoreSpaceUtilization

$Title = "Datastore Disk Utilization Information"
$Header = "Datastore Disk Utilization Information"
$Comments = "Datastores which run out of space will cause impact on the virtual machines held on these datastore"
$Display = "Table"
$Author = "Dan Rowe"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

$TableFormat = @{"DataStore"   = @(@{ "-like '[A-Za-z]*'"                 = "BegintbodyBlock,a|href|#Block|a|onclick|showHideBlock('UID')|id|UID|style|background-color: lightgray;display: none"});
                 "Cluster"     = @(@{ "-like '[A-Za-z]*'"                 = "EndtbodyBlock,style|display: "});
                 "PercentFree" = @(@{ "-le $CriticalDatastorePercentFree" = "Row,class|critical"; },
		 		  			       @{ "-le $WarningDatastorePercentFree"  = "Row,class|warning" });
                }
