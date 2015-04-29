# Start of Settings 
# End of Settings

$OutputPhantomSnapshots = @()

ForEach ($theVM in $VM){
	# Inventory of VM HardDisks
    $theVMdisks = $theVM | Get-HardDisk

    
    ForEach ($theVMdisk in $theVMdisks){

    
    	# Find VM's where active VMDK is a Delta VMDK
    	if ($theVMdisk.Filename -match "-\d{6}.vmdk"){
    		
    		# Find VM's which don't have normal Snapshots registered 
    		if (!(Get-Snapshot $theVM))
{
    			$Details = New-object PSObject

	    		$Details | Add-Member -Name "VM Name" -Value $theVM.name -Membertype NoteProperty

    			$Details | Add-Member -Name "VMDK Path" -Value $theVMdisk.Filename -Membertype NoteProperty

    			$OutputPhantomSnapshots += $Details

    		}
        }
    }
}

$OutputPhantomSnapshots

$Title = "Find Phantom Snapshots"
$Header = "VM's with Phantom Snapshots : $(@($OutputPhantomSnapshots).count)"
$Comments = "The following VM's have Phantom Snapshots"
$Display = "Table"
$Author = "Mads Fog Albrechtslund"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
