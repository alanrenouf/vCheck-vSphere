# Start of Settings
# HA VM restart day(s) number
$HAVMrestartold = 5
# End of Settings

@(Get-VIEventPlus -EventType "com.vmware.vc.ha.VmRestartedByHAEvent" -Start (Get-Date).AddDays(-$HAVMrestartold) | Select-Object CreatedTime, FullFormattedMessage | Sort-Object CreatedTime -Descending)

$Title = "HA VMs restarted"
$Header = ("HA: VM restart (Last {0} Day(s)) : [count]" -f $HAVMrestartold)
$Comments = "The following VMs have been restarted by HA in the last $HAVMresetold days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
