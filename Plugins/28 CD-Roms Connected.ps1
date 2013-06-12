# Start of Settings 
# VMs with CD drives not to report on
$CDFloppyConnectedOK ="APP*"
# End of Settings

$Result = @($VM | Where { $_ | Get-CDDrive | Where { $_.ConnectionState.Connected -eq $true } } | Where { $_.Name -notmatch $CDFloppyConnectedOK } | Select Name, VMHost)
$Result

$Title = "CD-Roms Connected"
$Header =  "VM: CD-ROM Connected - VMotion Violation: $(@($Result).Count)"
$Comments = "The following VMs have a CD-ROM connected, this may cause issues if this machine needs to be migrated to a different host"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
