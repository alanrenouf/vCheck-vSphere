# Start of Settings 
# End of Settings 

$VMFolder = @()
Foreach ($CHKVM in $FullVM){
	$Details = "" |Select-Object VM,Path
	$Folder = ((($CHKVM.Summary.Config.VmPathName).Split(']')[1]).Split('/'))[0].TrimStart(' ')
	$Path = ($CHKVM.Summary.Config.VmPathName).Split('/')[0]
	If ($CHKVM.Name-ne $Folder){
		$Details.VM= $CHKVM.Name
		$Details.Path= $Path
		$VMFolder += $Details}
}
$VMFolder

$Title = "VMs in inconsistent folders"
$Header =  "VMs in Inconsistent folders $(@($VMFolder).Count)"
$Comments = "The Following VM's are not stored in folders consistent to their names, this may cause issues when trying to locate them from the datastore manually"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
