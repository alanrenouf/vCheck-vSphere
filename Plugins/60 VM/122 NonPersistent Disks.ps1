# Start of Settings
# Exclude all desktop virtual machines
$NPExcludeVM = "^DV-|^MLB-"
# End of Settings

# Changelog
## 1.0 : Initial Version

# NonPersistent Disks
$diskModes = [VMware.Vim.VirtualDiskMode]::independent_nonpersistent,[VMware.Vim.VirtualDiskMode]::nonpersistent
$Result = @(ForEach($vm in $FullVM | Where {$_.Name -notmatch $NPExcludeVM}){
	$vm.Config.Hardware.Device |
	Where {$_ -is [VMware.Vim.VirtualDisk] -and $diskModes -contains $_.Backing.DiskMode} |
	Select @{N="VM";E={$vm.Name}},
		@{N="Disk";E={$_.DeviceInfo.Label}},
		@{N="Mode";E={$_.Backing.DiskMode}},
		@{N="CapacityGB";E={$_.capacityInKB/1MB}},
		@{N="Filename";E={$_.Backing.FileName}}
})
$Result

$Title = "NonPersistent Disks"
$Header = "NonPersistent Disks: $(@($Result).Count)"
$Comments = "The following server VMs have disks in NonPersistent mode (excludes all desktop VMs). A problem will occur in case of svMotion without reconfiguration of these virtual disks."
$Display = "Table"
$Author = "Petar Enchev, Luc Dekens"
$PluginVersion = 1.0
$PluginCategory = "vSphere"