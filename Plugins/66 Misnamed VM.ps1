# Start of Settings 
# End of Settings 

$misnamed = @()
foreach ($vmguest in ($FullVM | where { $_.Guest.HostName -ne $NULL -AND $_.Guest.HostName -notmatch $_.Name })) {
	$myObj = "" | select VMName,GuestName
	$myObj.VMName = $vmguest.name
	$myObj.GuestName = $vmguest.Guest.HostName
	$misnamed += $myObj
}

$misnamed

$Title = "Mis-named virtual machines"
$Header =  "Mis-named virtual machines"
$Comments = "The following guest names do not match the name inside of the guest."
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
