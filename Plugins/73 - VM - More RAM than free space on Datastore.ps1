# Start of Settings 
# End of Settings 

$Result = @($VM | Where {$_.PowerState -eq "PoweredOn"} | Select Name, MemoryMB, @{N="FreeSpaceMB";E={(Get-Datastore -VM $_).FreeSpaceMB}} | Where {($_.FreeSpaceMB -ne $null) -and ($_.MemoryMB -gt $_.FreeSpaceMB)})
$Result

$Title = "More RAM than free space on Datastore"
$Header =  "More RAM than free space on Datastore: $(@($Result).Count)"
$Comments = "The following VMs can't vMotion because they have more RAM than free space on datastore"
$Display = "Table"
$Author = "Olivier TABUT"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
