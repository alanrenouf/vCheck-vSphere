# Start of Settings 
# HA VM restart day(s) number
$HAVMrestartold =5
# End of Settings

$EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
$EventFilterSpec.Category = "info"
$EventFilterSpec.Time = New-Object VMware.Vim.EventFilterSpecByTime
$EventFilterSpec.Time.beginTime = (get-date).adddays(-$HAVMrestartold)
$EventFilterSpec.eventTypeId = "TaskEvent"
$HAVMrestartlist = @((get-view (get-view ServiceInstance -Property Content.EventManager).Content.EventManager).QueryEvents($EventFilterSpec) | ?{$_.FullFormattedMessage -match "was restarted"} |select CreatedTime,FullFormattedMessage |sort CreatedTime -Descending)
$HAVMrestartlist

$Title = "HA VMs restarted"
$Header =  "HA: VM restart (Last $HAVMrestartold Day(s)) : $(@($HAVMrestartlist).count)"
$Comments = "The following VMs have been restarted by HA in the last $HAVMresetold days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
