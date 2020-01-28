$Title = "Datastores in Maintenance Mode"
$Header = "Datastores in Maintenance Mode : [count]"
$Comments = "Datastore held in Maintenance mode will not be hosting any virtual machine, check the below Datastore are in an expected state"
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

if ($VIVersion -ge 5) {
   $StorageViews | Where-Object {$_.Summary.MaintenanceMode -match "inMaintenance"} | Select-Object Name, @{N="MaintenanceMode";E={$_.Summary.MaintenanceMode}}
}

# Change Log
## 1.2 : Code refactor