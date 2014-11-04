# Start of Settings 
# VMs with CD drives not to report on
$CDFloppyConnectedOK = "APP*|ETC*"
# End of Settings

$Result = @($FullVM | ?{$_.runtime.powerState -eq "PoweredOn" -And $_.Name -notmatch $CDFloppyConnectedOK} | ?{$_.config.hardware.device | ?{$_ -is [VMware.Vim.VirtualCdrom] -And $_.connectable.connected}} | Select Name)
$Result

$Title = "CD-ROMs Connected"
$Header = "VM: CD-ROM Connected - vMotion Violation: $(@($Result).Count)"
$Comments = "The following VMs have a CD-ROM connected, this may cause issues if this machine needs to be migrated to a different host"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
