# Start of Settings 
# End of Settings 

$vmInfo = @()
Foreach($Machine in $VM | Where {$_.PowerState -eq "PoweredOn"}) {
    $Details = "" | Select Name, MemoryMB, FreeSpaceMB
    $Details.Name = $Machine.Name
    $Details.MemoryMB = $Machine.MemoryMB
    $Details.FreeSpaceMB = ($Datastores|Where {$_.Name -eq (($Machine.ExtensionData.Config.Files.VmPathName).Split('[')[1]).Split(']')[0]}).FreeSpaceMB
    $vmInfo += $Details
}
$Result = @($vmInfo | Where {($_.FreeSpaceMB -ne $null) -and ($_.MemoryMB -gt $_.FreeSpaceMB)} | Sort Name)
$Result

$Title = "More RAM than free space on Datastore"
$Header = "More RAM than free space on Datastore: $(@($Result).Count)"
$Comments = "The following VMs can't vMotion because they have more RAM than free space on datastore"
$Display = "Table"
$Author = "Olivier TABUT, Bob Cote"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
