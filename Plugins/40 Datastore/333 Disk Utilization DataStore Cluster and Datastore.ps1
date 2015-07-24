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

$DatastoreClustersCapicity = @(Get-DatastoreCluster | Sort Name | Where-Object {$_.Name -notmatch $DatastoreIgnore} | Select-Object Name, @{N="CapacityGB";E={[math]::Round($_.CapacityGB, 2)}}, @{N="FreeSpaceGB";E={[math]::Round($_.FreeSpaceGB, 2)}}, @{N="PercentFree";E={[math]::Round(($_.FreeSpaceGB / $_.CapacityGB) * 100, 2)}} | Sort-Object Name)

$OutputDatastoreSpaceUtilization = @()
ForEach ($Cluster in $DatastoreClustersCapicity){
    $ClusterObj = "" | Select Cluster, DataStore, VMGuest, CapacityGB, FreeSpaceGB, PercentFree
    $ClusterObj.Cluster = $Cluster.Name
    $ClusterObj.DataStore = $null
    $ClusterObj.VMGuest = $null
    $ClusterObj.CapacityGB = $Cluster.CapacityGB
    $ClusterObj.FreeSpaceGB = $Cluster.FreeSpaceGB
    $ClusterObj.PercentFree = $Cluster.PercentFree

	$OutputDatastoreSpaceUtilization += $ClusterObj

    $DataStoresCapacity = Get-Datastore -RelatedObject $Cluster.Name | Select-Object Name, @{N="CapacityGB";E={[math]::Round($_.CapacityGB, 2)}}, @{N="FreeSpaceGB";E={[math]::Round($_.FreeSpaceGB, 2)}}, @{N="PercentFree";E={[math]::Round(($_.FreeSpaceGB / $_.CapacityGB) * 100, 2)}} | Sort-Object Name
    ForEach ($DataStore in $DataStoresCapacity){
        $DataStoreObj = "" | Select Cluster, DataStore, VMGuest, CapacityGB, FreeSpaceGB, PercentFree
        $DatastoreObj.Cluster = $null
        $DatastoreObj.DataStore = $DataStore.Name
        $DatastoreObj.VMGuest = $null
        $DatastoreObj.CapacityGB = $DataStore.CapacityGB
        $DatastoreObj.FreeSpaceGB = $DataStore.FreeSpaceGB
        $DatastoreObj.PercentFree = [math]::Round(($DataStore.FreeSpaceGB / $DataStore.CapacityGB) * 100, 2)
        
		$OutputDatastoreSpaceUtilization += $DatastoreObj

        $VMGuestCapacity = Get-VM -Datastore $DataStore.Name | Sort-Object Name
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

$TableFormat = @{"DataStore"   = @(@{ "-like '[A-Za-z]*'"                 = "BeginShowHideBlock,style|display: none"});
                 "Cluster"     = @(@{ "-like '[A-Za-z]*'"                 = "EndShowHideBlock,style|display: "});
                 "PercentFree" = @(@{ "-le $CriticalDatastorePercentFree" = "Row,class|critical"; },
		 		  			       @{ "-le $WarningDatastorePercentFree"  = "Row,class|warning" });
                }
Enter file contents here
