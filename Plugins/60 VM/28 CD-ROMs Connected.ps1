# Start of Settings 
# VMs with CD drives not to report on
$CDFloppyConnectedOK = "APP*|ETC*"
# End of Settings

$Result = @($FullVM |
  Where-Object {$_.runtime.powerState -eq "PoweredOn" -and $_.Name -notmatch $CDFloppyConnectedOK} |
  Where-Object {$_.config.hardware.device | Where-Object {$_ -is [VMware.Vim.VirtualCdrom] -and $_.connectable.connected}} |
  Select-Object -Property Name,
    @{Name='Label';Expression={($_.config.hardware.device | Where-Object {$_ -is [VMware.Vim.VirtualCdrom] -and $_.connectable.connected}).DeviceInfo.Label}},
    @{Name='Summary';Expression={($_.config.hardware.device | Where-Object {$_ -is [VMware.Vim.VirtualCdrom] -and $_.connectable.connected}).DeviceInfo.Summary}})
$Result

$Title = "CD-ROMs Connected"
$Header = "VM: CD-ROM Connected - vMotion Violation: $(@($Result).Count)"
$Comments = "The following VMs have a CD-ROM connected, this may cause issues if this machine needs to be migrated to a different host"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"
