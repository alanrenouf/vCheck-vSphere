# Start of Settings 
# End of Settings 

$Result = $FullVM | Where {$_.Guest.GuestState -eq "Running" -And ($_.Guest.GuestFullName -eq $NULL -or $_.Guest.IPAddress -eq $NULL -or $_.Guest.HostName -eq $NULL -or $_.Guest.Disk -eq $NULL -or $_.Guest.Net -eq $NULL)} | select Name, @{N="IPAddress";E={$_.Guest.IPAddress[0]}},@{n="OSFullName";E={$_.Guest.GuestFullName}},@{n="HostName";e={$_.guest.hostname}},@{N="NetworkLabel";E={$_.guest.Net[0].Network}} -ErrorAction SilentlyContinue |sort Name
$Result

$Title = "VM Tools Issues"
$Header =  "VM Tools Issues: $(@($Result).Count)"
$Comments = "The following VMs have issues with VMTools, these should be checked and reinstalled if necessary"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
