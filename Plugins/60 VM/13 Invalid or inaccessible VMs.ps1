# Start of Settings 
# End of Settings 

$BlindedVM = $FullVM | Where {$_.Runtime.ConnectionState -eq "invalid" -or $_.Runtime.ConnectionState -eq "inaccessible"} | sort name |select name
$BlindedVM

$Title = "Invalid or inaccessible VM"
$Header = "VM invalid or inaccessible : $(@($BlindedVM).count)"
$Comments = "The following VMs are marked as inaccessible or invalid"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
