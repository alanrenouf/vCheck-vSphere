# Start of Settings
# End of Settings

$Result = @($VM | Where-Object {$_.Guest.OSFullname -like "*Windows*"} | ForEach-Object {
  $CurrentVm = $_
  $NrOfHardDisks = ($CurrentVm | Get-HardDisk | Measure-Object).Count
  $NrOfGuestDisks = ($CurrentVm.Guest.Disks | Measure-Object).Count
  if ($NrOfHardDisks -lt $NrOfGuestDisks) {
    "" | Select-Object -Property @{N="VM";E={$CurrentVm.Name}},@{N="NrOfHardDisks";E={$NrOfHardDisks}},@{N="NrOfGuestDisks";E={$NrOfGuestDisks}}
  }
 }
)
$Result

$Title = "Virtual machines with less hard disks than partitions"
$Header =  "Virtual machines with less hard disks than partitions : $(@($Result).count)"
$Comments = "Virtual machines with less hard disks than partitions probably have more than one partition on a hard disk."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
