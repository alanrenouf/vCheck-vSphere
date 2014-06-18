# Start of Settings 
# End of Settings
#@($VM | Get-VMResourceConfiguration | Where-Object {$_.CpuLimitMHZ -ne '-1' -or $_.MemLimitMB -ne '-1'} | Select-Object VM,CpuLimitMhz,MemLimitMB)

@($FullVM | ?{$_.config.cpuallocation.limit -ne "-1" -or $_.config.memoryallocation.limit -ne "-1"} | Select Name, @{Name="CpuLimitMhz";E={$_.config.cpuallocation.limit}}, @{Name="MemLimitMB";E={$_.config.memoryallocation.limit}})
$PluginCategory = "vSphere"

$Title = "VMs with CPU or Memory Limits Configured"
$Header = "VMs with CPU or Memory Limits Configured"
$Comments = "The following VMs have a CPU or memory limit configured which may impact the performance of the VM. Note: -1 indicates no limit"
$Display = "Table"
$Author = "Jonathan Medd"
$PluginVersion = 1.1
