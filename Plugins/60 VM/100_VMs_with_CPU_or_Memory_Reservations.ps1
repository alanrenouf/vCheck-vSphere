$Title = "VMs with CPU or Memory Reservations Configured"
$Header = "VMs with CPU or Memory Reservations Configured: [count]"
$Comments = "The following VMs have a CPU or Memory Reservation configured which may impact the performance of the VM. Note: -1 indicates no reservation"
$Display = "Table"
$Author = "Dan Jellesma"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# Do not report on any VMs who are defined here
$MCRDoNotInclude = ""
# End of Settings

# Update settings where there is an override
$MCRDoNotInclude = Get-vCheckSetting $Title "MCRDoNotInclude" $MCRDoNotInclude

$FullVM | Where-Object {$_.Name -notmatch $MCRDoNotInclude -and ($_.config.cpuallocation.Reservation -ne "0" -or $_.config.memoryallocation.Reservation -ne "0")} | Select-Object Name, @{Name="CPUReservationMhz";E={$_.config.cpuallocation.Reservation}}, @{Name="MemReservationMB";E={$_.config.memoryallocation.Reservation}}

# Change Log
## 1.0 : Initial Release
## 1.1 : Added Get-vCheckSetting