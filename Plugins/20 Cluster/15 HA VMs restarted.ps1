$Title = "HA VMs restarted"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings
# HA VM restart day(s) number
$HAVMrestartold = 5
# End of Settings

# Update settings where there is an override
$HAVMrestartold = Get-vCheckSetting $Title "HAVMrestartold" $HAVMrestartold

Get-VIEventPlus -EventType "com.vmware.vc.ha.VmRestartedByHAEvent" -Start ($Date).AddDays(-$HAVMrestartold) | Select-Object CreatedTime, FullFormattedMessage | Sort-Object CreatedTime -Descending

$Header = ("HA: VM restart (Last {0} Day(s)) : [count]" -f $HAVMrestartold)
$Comments = ("The following VMs have been restarted by HA in the last {0} days" -f $HAVMresetold)