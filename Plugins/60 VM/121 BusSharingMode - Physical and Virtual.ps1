$Title = "BusSharingMode - Physical and Virtual"
$Header = "BusSharingMode - Physical and Virtual: [count]"
$Comments = "The following VMs have physical and/or virtual bus sharing. A problem will occur in case of svMotion without reconfiguration of the applications which are using these virtual disks and also change of the VM configuration concerned."
$Display = "Table"
$Author = "Petar Enchev, Luc Dekens"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

# BusSharingMode - Physical and Virtual
ForEach ($vm in $FullVM){
    $scsi = $vm.Config.Hardware.Device | Where-Object {$_ -is [VMware.Vim.VirtualSCSIController] -and ($_.SharedBus -eq "physicalSharing" -or $_.SharedBus -eq "virtualSharing")}
    if ($scsi){
        $scsi | Select-Object @{N="VM";E={$vm.Name}},
            @{N="Controller";E={$_.DeviceInfo.Label}},
            @{N="BusSharingMode";E={$_.SharedBus}}
    }
}

# Changelog
## 1.0 : Initial Version