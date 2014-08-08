# Start of Settings
# Misnamed VMs, do not report on any VMs who are defined here
$MNDoNotInclude = "VM1_*|VM2_*"
# End of Settings

$misnamed = @()
foreach ($vmguest in ($FullVM | Where {$_.Name -notmatch $MNDoNotInclude -AND $_.Guest.HostName -ne "" -AND $_.Guest.HostName -notmatch $_.Name })) {
	$myObj = "" | select VMName,GuestName
	$myObj.VMName = $vmguest.name
	$myObj.GuestName = $vmguest.Guest.HostName
	$misnamed += $myObj
}

$misnamed

$Title = "Mis-named virtual machines"
$Header = "Mis-named virtual machines"
$Comments = "The following guest names do not match the name inside of the guest."
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
