$Title = "VMs with CPU or Memory Reservations Configured"
$Header =  "VMs with CPU or Memory Reservations Configured"
$Comments = "The following VMs have a CPU or Memory Reservation configured which may impact the performance of the VM. Note: -1 indicates no reservation"
$Display = "Table"
$Author = "Dan Jellesma"
$PluginVersion = 1.0

# Start of Settings 
# End of Settings
@($FullVM | ?{$_.config.cpuallocation.Reservation -ne "0" -or $_.config.memoryallocation.Reservation -ne "0"} | Select Name, @{Name="CPUReservationMhz";E={$_.config.cpuallocation.Reservation}}, @{Name="MemReservationMB";E={$_.config.memoryallocation.Reservation}})
$PluginCategory = "vSphere"
