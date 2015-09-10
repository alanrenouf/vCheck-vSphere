# Start of Settings 
# Do not report on any VMs defined here, such as backup proxy hosts
$VMIgnore = "ExcludeMe"
# End of Settings
# v1.2 Added VMIgnore feature and updated Comments for clarity -Greg Hatch

$OutputPhantomSnapshots = @()

foreach ($theVM in $VM){
	if($theVM -notmatch $VMIgnore){
		# Inventory of VM HardDisks
		$theVMdisks = $theVM | Get-HardDisk
	
		foreach ($theVMdisk in $theVMdisks){
	
			# Find VM's where active VMDK is a Delta VMDK
			if ($theVMdisk.Filename -match "-\d{6}.vmdk"){
				
				# Find VM's which don't have normal Snapshots registered 
				if (!(Get-Snapshot $theVM))	{
					$Details = New-object PSObject
					$Details | Add-Member -Name "VM Name" -Value $theVM.name -Membertype NoteProperty
					$Details | Add-Member -Name "VMDK Path" -Value $theVMdisk.Filename -Membertype NoteProperty
					$OutputPhantomSnapshots += $Details
				}
			}
		}
	}
}

$OutputPhantomSnapshots

$Title = "Find Phantom Snapshots"
$Header = "VM's with Phantom Snapshots : $(@($OutputPhantomSnapshots).count)"
$Comments = "The following VM's have Phantom Snapshots and are using '-######.vmdk' files for their primary disks."
$Display = "Table"
$Author = "Mads Fog Albrechtslund"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
