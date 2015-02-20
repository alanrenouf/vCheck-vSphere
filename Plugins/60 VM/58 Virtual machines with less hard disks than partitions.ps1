# Start of Settings
# End of Settings

$Result = @($FullVM |
	Where-Object {$_.Config.ManagedBy.ExtensionKey -ne 'com.vmware.vcDr'} |
	Select-Object -Property Name,@{N="NrOfHardDisks";E={($_.Layout.Disk|measure).count}},@{N="NrOfGuestDisks";E={($_.Guest.Disk|measure).count}},@{N="GuestFamily";E={$_.Guest.GuestFamily}} |
	Where-Object {$_.GuestFamily -eq "windowsGuest" -and $_.NrOfHardDisks -lt $_.NrOfGuestDisks}
 )
$Result

$Title = "Virtual machines with less hard disks than partitions"
$Header = "Virtual machines with less hard disks than partitions : $(@($Result).count)"
$Comments = "Virtual machines with less hard disks than partitions. Probably they have more than one partition on a hard disk."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
