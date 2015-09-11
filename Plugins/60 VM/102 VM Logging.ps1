# Start of Settings 
# The number of logs to keep for each VM
$KeepOld = 10
# The size logs can reach before rotating to a new log (bytes)
$RotateSize = 1000000
# Do not report on any vCenters defined here, such as sensitive ones with separately-managed/audited VM log settings.
$SvrIgnore = "vcentername1|vcentername2"
# End of Settings

if($VIServer -notmatch $SvrIgnore){
	$logInfo = @()
	Foreach($Machine in $VM) {
		$Details = "" | Select Name, KeepOld, RotateSize
		$Details.Name = $Machine.Name
		$Details.KeepOld = $Machine.ExtensionData.Config.ExtraConfig | Where {$_.Key -eq "log.keepold"} | Select -ExpandProperty Value
		$Details.RotateSize = $Machine.ExtensionData.Config.ExtraConfig | Where {$_.Key -eq "log.rotatesize"} | Select -ExpandProperty Value
		If ($Details.KeepOld -Or $Details.RotateSize) {
			$logInfo += $Details
		}
	}
	$Result = @($logInfo | Where {$_.KeepOld -ne $KeepOld -or $_.RotateSize -ne $RotateSize} | Sort Name)
$Result
}

$Title = "VM Logging"
$Header = "VMs with improper logging settings: $(@($Result).Count)"
$Comments = "The following virtual machines are not configured to rotate logs at $RotateSize bytes and/or to store $KeepOld logs."
$Display = "Table"
$Author = "Bob Cote"
$PluginVersion = 1.01
$PluginCategory = "vSphere"

#9/10/15 Added vCenters to ignore -Greg Hatch