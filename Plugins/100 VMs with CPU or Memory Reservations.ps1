$Title = "VMs with CPU or Memory Reservations Configured"
$Header =  "VMs with CPU or Memory Reservations Configured"
$Comments = "The following VMs have a CPU or Memory Reservation configured which may impact the performance of the VM. Note: -1 indicates no reservation"
$Display = "Table"
$Author = "Dan Jellesma"
$PluginVersion = 1.0

# Start of Settings 
# End of Settings
@($VM | Get-VMResourceConfiguration | where {$_.CPUReservationMhz -ne '0' -or $_.MemReservationMB -ne '-1'} | Select-Object VM,CPUReservationMhz,MemReservationMB)
$PluginCategory = "vSphere"
