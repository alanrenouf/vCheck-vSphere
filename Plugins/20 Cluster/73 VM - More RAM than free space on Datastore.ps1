$Title = "More RAM than free space on Datastore"
$Header = "More RAM than free space on Datastore: [count]"
$Comments = "The following VMs can't vMotion because they have more RAM than free space on datastore"
$Display = "Table"
$Author = "Olivier TABUT, Bob Cote"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$VM | Where-Object {$_.PowerState -eq "PoweredOn"} | 
   Select-Object Name, MemoryMB, @{"Name"="FreeSpaceMB";e={($Datastores | Where-Object {$_.Name -eq (($Machine.ExtensionData.Config.Files.VmPathName).Split('[')[1]).Split(']')[0]}).FreeSpaceMB}} | 
   Where-Object {($_.FreeSpaceMB -ne $null) -and ($_.MemoryMB -gt $_.FreeSpaceMB)} | Sort-Object Name