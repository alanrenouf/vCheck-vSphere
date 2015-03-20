# Start of Settings
# End of Settings

# Changelog
## 1.0 : Initial Version

# BusSharingMode - Physical and Virtual
$Result = @(ForEach ($vm in $FullVM){
    $scsi = $vm.Config.Hardware.Device | where {$_ -is [VMware.Vim.VirtualSCSIController] -and ($_.SharedBus -eq "physicalSharing" -or $_.SharedBus -eq "virtualSharing")}
    if ($scsi){
        $scsi | Select @{N="VM";E={$vm.Name}},
            @{N="Controller";E={$_.DeviceInfo.Label}},
            @{N="BusSharingMode";E={$_.SharedBus}}
    }
})
$Result

$Title = "BusSharingMode - Physical and Virtual"
$Header = "BusSharingMode - Physical and Virtual: $(@($Result).Count)"
$Comments = "The following VMs have physical and/or virtual bus sharing. A problem will occur in case of svMotion without reconfiguration of the applications which are using these virtual disks and also change of the VM configuration concerned."
$Display = "Table"
$Author = "Petar Enchev, Luc Dekens"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
