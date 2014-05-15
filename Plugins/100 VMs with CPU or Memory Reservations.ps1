# Start of Settings
# VMs with CPU or Memory Reservations, do not report on any VMs who are defined here
$MCRDoNotInclude = "VM1_*|VM2_*"
# End of Settings
@($FullVM | Where {$_.Name -notmatch $MCRDoNotInclude} | Where {$_.config.cpuallocation.Reservation -ne "0" -or $_.config.memoryallocation.Reservation -ne "0"} | Select Name, @{Name="CPUReservationMhz";E={$_.config.cpuallocation.Reservation}}, @{Name="MemReservationMB";E={$_.config.memoryallocation.Reservation}})

$Title = "VMs with CPU or Memory Reservations Configured"
$Header = "VMs with CPU or Memory Reservations Configured"
$Comments = "The following VMs have a CPU or Memory Reservation configured which may impact the performance of the VM. Note: -1 indicates no reservation"
$Display = "Table"
$Author = "Dan Jellesma"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
