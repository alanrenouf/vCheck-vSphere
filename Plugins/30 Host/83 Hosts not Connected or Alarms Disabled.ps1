# Start of Settings 
# End of Settings 

$Hosts_notConnected_disabledAlarms = @($VMH | Select-Object Name,PowerState,ConnectionState,@{n='AlarmActionsEnabled';e={$_.ExtensionData.AlarmActionsEnabled}} | Where-Object { ($_.ConnectionState -ne 'Connected') -or ($_.AlarmActionsEnabled -ne 'True') } )
$Hosts_notConnected_disabledAlarms

$Title = "Hosts not Connected or Alarms Disabled"
$Header = "Hosts not Connected or Alarms Disabled : $(@($Hosts_notConnected_disabledAlarms).count)"
$Comments = "Shows hosts not in service and those with alarms disabled."
$Display = "Table"
$Author = "Chris Monahan"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Combines/replaces two plugins, "05 Hosts in Maintenance mode.ps1" and "117 Hosts with Alarm disabled.ps1".