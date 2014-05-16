# Start of Settings 
# End of Settings 

$alarms = $alarmMgr.GetAlarm($null)
$valarms = $alarms | select value, @{N="name";E={(Get-View -Id $_).Info.Name}}
$hostsalarms = @()
foreach ($HostsView in $HostsViews){
	if ($HostsView.TriggeredAlarmState){
		$hostsTriggeredAlarms = $HostsView.TriggeredAlarmState
		Foreach ($hostsTriggeredAlarm in $hostsTriggeredAlarms){
			$Details = "" | Select-Object Object, Alarm, Status, Time
			$Details.Object = $HostsView.name
			$Details.Alarm = ($valarms | Where {$_.value -eq ($hostsTriggeredAlarm.alarm.value)}).name
			$Details.Status = $hostsTriggeredAlarm.OverallStatus
			$Details.Time = $hostsTriggeredAlarm.time
			$hostsalarms += $Details
		}
	}
}

@($hostsalarms |sort Object)
    
$Title = "Host Alarms"
$Header = "Host(s) Alarm(s): $(@($hostsalarms).Count)"
$Comments = "The following alarms have been registered against hosts in vCenter"
$Display = "Table"
$Author = "Alan Renouf, John Sneddon"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

$TableFormat = @{"Status" = @(@{ "-eq 'yellow'"     = "Row,class|warning"; },
							  @{ "-eq 'red'"     = "Row,class|critical" })
				}
