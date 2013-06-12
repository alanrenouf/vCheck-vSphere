# Start of Settings 
# HA VM reset day(s) number due to Guest OS error
$HAVMresetold =5
# End of Settings

$HAVMresetlist = @(Get-VIEvent -maxsamples 100000 -Start ($Date).AddDays(-$HAVMresetold) -type info | Where {$_.FullFormattedMessage -match "reset due to a guest OS error"} |select CreatedTime,FullFormattedMessage |sort CreatedTime -Descending)
$HAVMresetlist

$Title = "VMs restarted due to Guest OS Error"
$Header =  "HA: VM restarted due to Guest OS Error (Last $HAVMresetold Day(s)) : $(@($HAVMresetlist).count)"
$Comments = "The following VMs have been restarted by HA in the last $HAVMresetold days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
