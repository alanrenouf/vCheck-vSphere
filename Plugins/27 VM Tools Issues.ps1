# Start of Settings 
# End of Settings 

$Result = $VM | Where {$_.Guest.State -eq "Running" -And ($_.Guest.OSFullName -eq $NULL -or $_.Guest.IPAddress -eq $NULL -or $_.Guest.HostName -eq $NULL -or $_.Guest.Disks -eq $NULL -or $_.Guest.Nics -eq $NULL)} |select -ExpandProperty Guest |select VMName , @{N= "IPAddress";E={$_.IPAddress[0]}},OSFullName,HostName,@{N="NetworkLabel";E={$_.nics[0].NetworkName}} -ErrorAction SilentlyContinue|sort VmName
$Result

$Title = "VM Tools Issues"
$Header =  "VM Tools Issues: $(@($Result).Count)"
$Comments = "The following VMs have issues with VMTools, these should be checked and reinstalled if necessary"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
