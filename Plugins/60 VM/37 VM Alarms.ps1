# Start of Settings 
# End of Settings 

$vmsalarms = @()
foreach ($VMView in $FullVM){
	if ($VMView.TriggeredAlarmState){
		$VMsTriggeredAlarms = $VMView.TriggeredAlarmState
		Foreach ($VMsTriggeredAlarm in $VMsTriggeredAlarms){
			$Details = "" | Select-Object Object, Alarm, Status, Time
			$Details.Object = $VMView.name
			$Details.Alarm = ($valarms |?{$_.value -eq ($VMsTriggeredAlarm.alarm.value)}).name
			$Details.Status = $VMsTriggeredAlarm.OverallStatus
			$Details.Time = $VMsTriggeredAlarm.time
			$vmsalarms += $Details
		}
	}
}

$vmsalarms | sort Object

$Title = "VM Alarms"
$Header = "VM(s) Alarm(s): $(@($vmsalarms).Count)"
$Comments = "The following alarms have been registered against VMs in vCenter"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1

$PluginCategory = "vSphere"
