# Start of Settings 
# HA VM reset day(s) number due to Guest OS error
$HAVMresetold =5
# End of Settings

$EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
$EventFilterSpec.Category = "info"
$EventFilterSpec.Time = New-Object VMware.Vim.EventFilterSpecByTime
$EventFilterSpec.Time.beginTime = (get-date).adddays(-$HAVMresetold)
$EventFilterSpec.eventTypeId = "TaskEvent"
$HAVMresetlist = @((get-view (get-view ServiceInstance -Property Content.EventManager).Content.EventManager).QueryEvents($EventFilterSpec) | ?{$_.FullFormattedMessage -match "reset due to a guest OS error"} |select CreatedTime,FullFormattedMessage |sort CreatedTime -Descending)
$HAVMresetlist

$Title = "VMs restarted due to Guest OS Error"
$Header =  "HA: VM restarted due to Guest OS Error (Last $HAVMresetold Day(s)) : $(@($HAVMresetlist).count)"
$Comments = "The following VMs have been restarted by HA in the last $HAVMresetold days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
