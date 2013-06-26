# Start of Settings 
# VMs with Floppy drives not to report on
$CDFloppyConnectedOK ="APP*"
# End of Settings

$Result = @($FullVM | ?{$_.runtime.powerState -eq "PoweredOn" -And $_.Name -notmatch $CDFloppyConnectedOK} | ?{$_.config.hardware.device | ?{$_ -is [VMware.Vim.VirtualFloppy] -And $_.connectable.connected}} | Select Name)
$Result

$Title = "Floppys Connected"
$Header =  "VM: Floppy Drive Connected - VMotion Violation: $(@($Result).Count)"
$Comments = "The following VMs have a floppy disk connected, this may cause issues if this machine needs to be migrated to a different host"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
