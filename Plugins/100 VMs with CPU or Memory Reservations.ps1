$Title = "VMs with CPU or Memory Reservations Configured"
$Header =  "VMs with CPU or Memory Reservations Configured"
$Comments = "The following VMs have a CPU or Memory Reservation configured which may impact the performance of the VM. Note: -1 indicates no reservation"
$Display = "Table"
$Author = "Dan Jellesma"
$PluginVersion = 1.0

# Start of Settings 
# End of Settings
@($FullVM | ?{$_.config.cpuallocation.limit -ne "-1" -or $_.config.memoryallocation.limit -ne "-1"} | Select Name, @{Name="CPUReservationMhz";E={$_.config.cpuallocation.limit}}, @{Name="MemReservationMB";E={$_.config.memoryallocation.limit}})
$PluginCategory = "vSphere"
