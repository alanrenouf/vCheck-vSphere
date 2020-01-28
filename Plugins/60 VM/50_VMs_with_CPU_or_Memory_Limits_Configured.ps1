$Title = "VMs with CPU or Memory Limits Configured"
$Header = "VMs with CPU or Memory Limits Configured: [count]"
$Comments = "The following VMs have a CPU or memory limit configured which may impact the performance of the VM. Note: -1 indicates no limit"
$Display = "Table"
$Author = "Jonathan Medd"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings

$FullVM | Where-Object {$_.config.cpuallocation.limit -ne "-1" -or $_.config.memoryallocation.limit -ne "-1"} | Select-Object Name, @{Name="CpuLimitMhz";E={$_.config.cpuallocation.limit}}, @{Name="MemLimitMB";E={$_.config.memoryallocation.limit}}