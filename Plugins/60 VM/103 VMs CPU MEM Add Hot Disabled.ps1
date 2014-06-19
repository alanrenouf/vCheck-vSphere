# Start of Settings
# End of Settings

$ListCPUMemDisabled = @()
foreach ($vmguest in $FullVM) {
		$myObj = "" | select Name,OS,CPU,MEM
		$myObj.Name = $vmguest.name 
		$myObj.OS = $vmguest.Config.GuestFullName
		$myObj.CPU = $vmguest.Config.cpuhotaddenabled
 		$myObj.MEM = $vmguest.Config.memoryhotaddenabled
 		$ListCPUMemDisabled += $myObj
}
$ListCPUMemDisabled | where {$_.CPU -match $false -or $_.Mem -match $false}  | Sort Name

$Title = "CPU/Mem HotPlug"
$Header = "CPU/Mem HotPlug Disabled found"
$Comments = "VMs needs to be shutdown to modify CPU/Mem HotPlug in case this settings is disabled."
$Display = "Table"
$Author = "Eric Lannier"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
