# Start of Settings 
# VMs with Floppy drives not to report on
$CDFloppyConnectedOK ="APP*"
# End of Settings

$Result = @($VM | Where { $_ | Get-FloppyDrive | Where { $_.ConnectionState.Connected -eq $true } } | Where { $_.Name -notmatch $CDFloppyConnectedOK } | Select Name, Host)
$Result

$Title = "Floppys Connected"
$Header =  "VM: Floppy Drive Connected - VMotion Violation: $(@($Result).Count)"
$Comments = "The following VMs have a floppy disk connected, this may cause issues if this machine needs to be migrated to a different host"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
