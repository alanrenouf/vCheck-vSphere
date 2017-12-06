$Title = "Virtual machines with less hard disks than partitions"
$Header = "Virtual machines with less hard disks than partitions: [count]"
$Comments = "Virtual machines with less hard disks than partitions. Probably they have more than one partition on a hard disk."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings
# Do not report on any VMs who are defined here (regex)
$VMTDoNotInclude = "VM1_*|VM2_*"
# End of Settings

# Update settings where there is an override
$VMTDoNotInclude = Get-vCheckSetting $Title "VMTDoNotInclude" $VMTDoNotInclude

$FullVM | Where-Object {$_.Name -notmatch $VMTDoNotInclude} |
   Where-Object {$_.Config.ManagedBy.ExtensionKey -ne 'com.vmware.vcDr'} |
   Select-Object -Property Name,@{N="NrOfHardDisks";E={($_.Layout.Disk|measure).count}},@{N="NrOfGuestDisks";E={($_.Guest.Disk|measure).count}},@{N="GuestFamily";E={$_.Guest.GuestFamily}} |
   Where-Object {$_.GuestFamily -eq "windowsGuest" -and $_.NrOfHardDisks -lt $_.NrOfGuestDisks}

# Change Log
## 1.4 : Added Get-vCheckSetting