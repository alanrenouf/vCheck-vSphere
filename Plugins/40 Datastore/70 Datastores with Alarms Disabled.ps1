# Start of Settings 
# End of Settings 

$Datastores | where {!$_.ExtensionData.AlarmActionsEnabled} | Select Name, @{n='AlarmActionsEnabled'; e={$_.ExtensionData.AlarmActionsEnabled}}

$Title = "Datastores with Alarms Disabled"
$Header = "Datastores with Alarms Disabled"
$Comments = "Datastores with Alarms Disabled"
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
