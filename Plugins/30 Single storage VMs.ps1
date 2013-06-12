# Start of Settings 
# Local Stored VMs, do not report on any VMs who are defined here
$LVMDoNotInclude ="Template_*|VDI*"
# End of Settings

$Report = @()
Foreach ($datastore in $Datastores){
	If ($datastore.Extensiondata.summary.multiplehostaccess -eq $false){
		ForEach ($VirtM in (get-vm -datastore $Datastore )){
			$SAHost = "" | Select VM, Datastore
			$SAHost.VM = $VirtM.Name 
			$SAHost.Datastore = $Datastore.Name
			$Report += $SAHost
		}
	}
}

$Result = @($Report | Where { $_.VM -notmatch $LVMDoNotInclude }) 
$Result

$Title = "Single Storage VMs"
$Header =  "VMs stored on non shared datastores: $(@($Result).Count)"
$Comments = "The following VMs are located on storage which is only accesible by 1 host, these will not be compatible with VMotion and may be disconnected in the event of host failure"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
