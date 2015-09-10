# Start of Settings
# VMs with CPU or Memory Reservations, do not report on any VMs who are defined here
$MCRDoNotInclude = "VM1_*|VM2_*"
# End of Settings
# 6/18/14 Overhauled to support listing Cluster name -Greg Hatch

$MyCollection = @()
foreach ($CHKVM in $FullVM){
	$Details = "" |Select-Object VM,Cluster,CPUReservationMhz,MemReservationMB
	if($CHKVM.Name -notmatch $MCRDoNotInclude -and ($CHKVM.config.cpuallocation.Reservation -ne "0" -or $CHKVM.config.memoryallocation.Reservation -ne "0")){
		$Details.VM = $CHKVM.Name
		$ClusterTmp = get-cluster -VM $Details.VM | Select Name
		$Details.Cluster = $ClusterTmp.Name
		$Details.CPUReservationMhz = $CHKVM.config.cpuallocation.Reservation
		$Details.MemReservationMB = $CHKVM.config.memoryallocation.Reservation
		$MyCollection += $Details
	}
}

$MyCollection

#@($FullVM | where {$_.Name -notmatch $MCRDoNotInclude} | where {$_.config.cpuallocation.Reservation -ne "0" -or $_.config.memoryallocation.Reservation -ne "0"} | Select Name, @{Name="CPUReservationMhz";E={$_.config.cpuallocation.Reservation}}, @{Name="MemReservationMB";E={$_.config.memoryallocation.Reservation}})

$Title = "VMs with CPU or Memory Reservations Configured"
$Header = "VMs with CPU or Memory Reservations Configured"
$Comments = "The following VMs have a CPU or Memory Reservation configured which may impact the performance of the VM. Note: -1 indicates no reservation"
$Display = "Table"
$Author = "Dan Jellesma"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
