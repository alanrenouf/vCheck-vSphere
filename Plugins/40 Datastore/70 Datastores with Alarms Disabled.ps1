$Title = "Datastores with Alarms Disabled"
$Header = "Datastores with Alarms Disabled : [count]"
$Comments = "The datastores will not generate alarms which may highlight problems with the datastore"
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$Datastores | where {!$_.ExtensionData.AlarmActionsEnabled} | Select Name, @{n='AlarmActionsEnabled'; e={$_.ExtensionData.AlarmActionsEnabled}}

# Change Log
## 1.0 : Initial version
## 1.1 : Code refactor