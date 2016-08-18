# Start of Settings 
# End of Settings 

$valarms = $alarmMgr.GetAlarm($null) | select value, @{N="name";E={(Get-View -Id $_).Info.Name}}

foreach ($HostsView in ($HostsViews | Where {$_.TriggeredAlarmState} | Sort-Object Name)){
   Foreach ($hostsTriggeredAlarm in $HostsView.TriggeredAlarmState){
      New-Object PSObject -Property @{
         "Object" = $HostsView.name;
         "Alarm" = ($valarms | Where {$_.value -eq ($hostsTriggeredAlarm.alarm.value)}).name;
         "Status" = $hostsTriggeredAlarm.OverallStatus;
         "Time" = $hostsTriggeredAlarm.time.ToLocalTime()
      } | Select Object, Alarm, Status, Time
   }
}
    
$Title = "Host Alarms"
$Header = "Host(s) Alarm(s): [count]]"
$Comments = "The following alarms have been registered against hosts in vCenter"
$Display = "Table"
$Author = "Alan Renouf, John Sneddon"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

$TableFormat = @{"Status" = @(@{ "-eq 'yellow'"     = "Row,class|warning"; },
                              @{ "-eq 'red'"     = "Row,class|critical" })}
