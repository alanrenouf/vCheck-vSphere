$Title = "VM Alarms"
$Header = "VM Alarm(s): [count]"
$Comments = "The following alarms have been registered against VMs in vCenter"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$vmsalarms = @()
foreach ($VMView in ($FullVM | Where-Object {$_.TriggeredAlarmState})){
   Foreach ($VMsTriggeredAlarm in $VMView.TriggeredAlarmState){
      New-Object -TypeName PSObject -Property @{
         Object = $VMView.name
         Alarm = ($valarms |Where-Object {$_.value -eq ($VMsTriggeredAlarm.alarm.value)}).name
         Status = $VMsTriggeredAlarm.OverallStatus
         Time = $VMsTriggeredAlarm.time
      }
   }
}

# Change Log
## 1.3 : Code refactor