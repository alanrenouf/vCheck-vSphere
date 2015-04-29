# Start of Settings 
# End of Settings 

if ($VIVersion -ge 5) {
	$MaintDatastores = @($StorageViews | Where {$_.Summary.MaintenanceMode -match "inMaintenance"} | Select Name, @{N="MaintenanceMode";E={$_.Summary.MaintenanceMode}})
	$MaintDatastores
}

$Title = "Datastores in Maintenance Mode"
$Header = "Datastores in Maintenance Mode : $(@($MaintDatastores).count)"
$Comments = "Datastore held in Maintenance mode will not be hosting any virtual machine, check the below Datastore are in an expected state"
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
