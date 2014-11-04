<<<<<<< HEAD
# Start of Settings 
$DatastoreIgnore = "BED-QA-SSD-001"
=======
# Start of Settings
$DatastoreIgnore = "local"
>>>>>>> 16438312dd5a2961d90c052893683cabeb8d8c71
# End of Settings 

$VMFolder = @()
Foreach ($CHKVM in $FullVM){
	$Details = "" |Select-Object VM,Path
	$Folder = ((($CHKVM.Summary.Config.VmPathName).Split(']')[1]).Split('/'))[0].TrimStart(' ')
	$Path = ($CHKVM.Summary.Config.VmPathName).Split('/')[0]
	If (($CHKVM.Name-ne $Folder) -and ($Path -notmatch $DatastoreIgnore)){
		$Details.VM= $CHKVM.Name
		$Details.Path= $Path
		$VMFolder += $Details}
}
$VMFolder

$Title = "VMs in inconsistent folders"
$Header = "VMs in Inconsistent folders $(@($VMFolder).Count), excluding those on datastores @($DatastoreIgnore)"
$Comments = "The following VMs are not stored in folders consistent to their names, this may cause issues when trying to locate them from the datastore manually"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
# Datastore filtering added by monahancj
