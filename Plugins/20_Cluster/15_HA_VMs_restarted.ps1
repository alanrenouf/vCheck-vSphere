$Title = "HA VMs restarted"
$Display = "Table"
$Author = "Alan Renouf, Felix Longardt"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings
# HA VM restart day(s) number
$HAVMrestartold = 5
$VIMEventDate = (Get-Date).AddDays(-$HAVMrestartold).ToString("MM\/dd\/yyyy hh:mm:ss")
# End of Settings

# Update settings where there is an override
$HAVMrestartold = Get-vCheckSetting $Title "HAVMrestartold" $HAVMrestartold

if($PSEdition -eq "core"){
Get-VIEvent -Start $VIMEventDate -MaxSamples 1000000 -Types warning | Where-Object {$_.fullFormattedMessage -match "vSphere HA restarted a virtual machine"} | Select-Object CreatedTime, @{N="Host";E={$_.host.name}}, @{N="VM";E={$_.vm.name}}, fullFormattedMessage | Sort-Object CreatedTime -Descending
}
else {
Get-VIEventPlus -EventType "com.vmware.vc.ha.VmRestartedByHAEvent" -Start ($Date).AddDays(-$HAVMrestartold) |  Select-Object CreatedTime, @{N="Host";E={$_.host.name}}, @{N="VM";E={$_.vm.name}}, fullFormattedMessage | Sort-Object CreatedTime -Descending
}

$Header = ("HA: VM restart (Last {0} Day(s)) : [count]" -f $HAVMrestartold)
$Comments = ("The following VMs have been restarted by HA in the last {0} days" -f $HAVMresetold)

## Changelog
# 1.4 - Added Switch for PSCore
