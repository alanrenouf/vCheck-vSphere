# Start of Settings 
# End of Settings 

$wrongOS = @()
foreach ($vmguest in ($FullVM | where ({ $_.Guest.GuestFullname -ne $NULL -AND $_.Guest.GuestFullname -ne $_.Summary.Config.GuestFullName}))) {
	$myObj = "" | select Name,InstalledOS,SelectedOS
	$myObj.Name = $vmguest.name
	$myObj.InstalledOS = $vmguest.Guest.GuestFullName
	$myObj.SelectedOS = $vmguest.Summary.Config.GuestFullName
	$wrongOS += $myObj
}

$wrongOS | Sort Name

$Title = "Guests with wrong OS"
$Header =  "Guests with wrong OS"
$Comments = "The following virtual machines contain operating systems other than the ones selected in the VM configuration."
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
