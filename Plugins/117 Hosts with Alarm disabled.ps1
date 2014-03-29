# Start of Settings
# Include Hosts in Maintenance mode
$IncludeMaintenance = $false
# End of Settings

$AlarmActionsEnabled =	$VMH | Where { (-not $_.ExtensionData.AlarmActionsEnabled)} | 
									Select @{Name="Host"; Expression={$_.Name}}, @{"Name"="InMaintenanceMode";Expression={$_.ExtensionData.Runtime.InMaintenanceMode}}, @{"Name"="AlarmActionsEnabled"; Expression={$_.ExtensionData.AlarmActionsEnabled}} |
									Sort-Object Host

if ($IncludeMaintenance -eq $false) {
	$AlarmActionsEnabled = $AlarmActionsEnabled | Where {-not $_.InMaintenanceMode}
}
$AlarmActionsEnabled

$Title = "Hosts with Alarm disabled"
$Header =  "Hosts with Alarms disabled : $(@($AlarmActionsEnabled).Count)"
$Comments = "The following Hosts have Alarm disabled. This may impact the Alarming of your infrastrucure."
$Display = "Table"
$Author = "Denis Gauthier"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
