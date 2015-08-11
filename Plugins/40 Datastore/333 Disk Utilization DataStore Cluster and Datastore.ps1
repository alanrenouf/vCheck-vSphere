# Start of Settings 
# Set the warning threshold for Datastore % Free Space
$WarningDatastorePercentFree = 20
# Set the critical threshold for Datastore % Free Space
$CriticalDatastorePercentFree = 10
# Do not report on any Datastores that are defined here (Datastore Free Space Plugin)
$DatastoreIgnore = "local"
# End of Settings

# ChangeLog
# 1.0 - Initial script
# 1.1 - 

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

    $DataStoresCapacity = $Datastores | where {$_.ExtensionData.Parent -eq $Cluster.ExtensionData.MoRef} | Sort-Object Name
    ForEach ($DataStore in $DataStoresCapacity){
        $DataStoreObj = "" | Select Cluster, DataStore, VMGuest, CapacityGB, FreeSpaceGB, PercentFree
        $DatastoreObj.Cluster = $null
        $DatastoreObj.DataStore = $DataStore.Name
        $DatastoreObj.VMGuest = $null
        $DatastoreObj.CapacityGB = [math]::Round($DataStore.CapacityGB, 2)
        $DatastoreObj.FreeSpaceGB = [math]::Round($DataStore.FreeSpaceGB, 2)
        $DatastoreObj.PercentFree = [math]::Round(($DataStore.FreeSpaceGB / $DataStore.CapacityGB) * 100, 2)
        
		$OutputDatastoreSpaceUtilization += $DatastoreObj

        $VMGuestCapacity = $VM | where {$_.DatastoreIdList -eq $DataStore.ExtensionData.MoRef} | Sort-Object Name
        ForEach ($VMGuest in $VMGuestCapacity){
            $VMGuestObj = "" | Select Cluster, DataStore, VMGuest, CapacityGB, FreeSpaceGB, PercentFree
            $VMGuestObj.Cluster = $null
            $VMGuestObj.DataStore = $null
            $VMGuestObj.VMGuest = $VMGuest.Name
            $VMGuestObj.CapacityGB = [math]::Round($VMGuest.ProvisionedSpaceGB, 2)
            $VMGuestObj.FreeSpaceGB = [math]::Round(($VMGuest.ProvisionedSpaceGB - $VMGuest.UsedSpaceGB), 2)
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
$PluginVersion = 1.1
$PluginCategory = "vSphere"

$TableFormat = @{"DataStore"   = @(@{ "-like '[A-Za-z]*'"                 = "BegintbodyBlock,a|href|#Block|a|onclick|showHideBlock('UID')|id|UID|style|display: none"});
                 "Cluster"     = @(@{ "-like '[A-Za-z]*'"                 = "EndtbodyBlock,style|display: "});
                 "PercentFree" = @(@{ "-le $CriticalDatastorePercentFree" = "Row,class|critical"; },
		 		  			       @{ "-le $WarningDatastorePercentFree"  = "Row,class|warning" });
                }
