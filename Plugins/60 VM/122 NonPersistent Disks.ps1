$Title = "NonPersistent Disks"
$Header = "NonPersistent Disks: [count]"
$Comments = "The following server VMs have disks in NonPersistent mode (excludes all desktop VMs). A problem will occur in case of svMotion without reconfiguration of these virtual disks."
$Display = "Table"
$Author = "Petar Enchev, Luc Dekens"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# Exclude all virtual machines from report
$NPExcludeVM = "^DV-|^MLB-"
# End of Settings

# Update settings where there is an override
$NPExcludeVM = Get-vCheckSetting $Title "NPExcludeVM" $NPExcludeVM

# NonPersistent Disks
$diskModes = [VMware.Vim.VirtualDiskMode]::independent_nonpersistent,[VMware.Vim.VirtualDiskMode]::nonpersistent
ForEach($npvm in $FullVM | Where-Object {$_.Name -notmatch $NPExcludeVM}){
   $npvm.Config.Hardware.Device |
   Where-Object {$_ -is [VMware.Vim.VirtualDisk] -and $diskModes -contains $_.Backing.DiskMode} |
   Select-Object @{N="VM";E={$npvm.Name}},
      @{N="Disk";E={$_.DeviceInfo.Label}},
      @{N="Mode";E={$_.Backing.DiskMode}},
      @{N="CapacityGB";E={$_.capacityInKB/1MB}},
      @{N="Filename";E={$_.Backing.FileName}}
}

# Changelog
## 1.0 : Initial Version
## 1.1 : Added Get-vCheckSetting