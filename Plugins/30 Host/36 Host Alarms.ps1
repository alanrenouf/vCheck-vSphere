$Title = "Host Alarms"
$Header = "Host(s) Alarm(s): [count]"
$Comments = "The following alarms have been registered against hosts in vCenter"
$Display = "Table"
$Author = "Alan Renouf, John Sneddon"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

foreach ($HostsView in ($HostsViews | Where-Object {$_.TriggeredAlarmState} | Sort-Object Name)){
   Foreach ($hostsTriggeredAlarm in $HostsView.TriggeredAlarmState){
      New-Object PSObject -Property @{
         "Object" = $HostsView.name;
         "Alarm" = ($valarms | Where-Object {$_.value -eq ($hostsTriggeredAlarm.alarm.value)}).name;
         "Status" = $hostsTriggeredAlarm.OverallStatus;
         "Time" = $hostsTriggeredAlarm.time.ToLocalTime()
      } | Select-Object Object, Alarm, Status, Time
   }
}

$TableFormat = @{"Status" = @(@{ "-eq 'yellow'"  = "Row,class|warning"; },
                              @{ "-eq 'red'"     = "Row,class|critical" })}
