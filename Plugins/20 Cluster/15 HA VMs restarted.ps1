# Start of Settings 
# HA VM restart day(s) number
$HAVMrestartold = 5
# End of Settings

$EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
$EventFilterSpec.Category = "warning"
$EventFilterSpec.eventTypeId = "com.vmware.vc.ha.VmRestartedByHAEvent"
$EventFilterSpec.Time = New-Object VMware.Vim.EventFilterSpecByTime
$EventFilterSpec.Time.beginTime = (Get-Date).AddDays(-$HAVMrestartold)

$HAVMrestartlist = @((get-view (get-view ServiceInstance -Property Content.EventManager).Content.EventManager).QueryEvents($EventFilterSpec) | select CreatedTime,FullFormattedMessage |sort CreatedTime -Descending)
$HAVMrestartlist

$Title = "HA VMs restarted"
$Header = ("HA: VM restart (Last {0} Day(s)) : {1}" -f $HAVMrestartold, @($HAVMrestartlist).count)
$Comments = "The following VMs have been restarted by HA in the last $HAVMresetold days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

Remove-Variable HAVMrestartlist, EventFilterSpec
