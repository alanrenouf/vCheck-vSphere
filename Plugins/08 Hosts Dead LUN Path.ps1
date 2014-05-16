# Start of Settings 
# End of Settings 

# Changelog
## 1.1 : Alternate code in order to avoid usage of Get-ScsiLun for performance matter

$deadluns = @()
foreach ($esxhost in ($HostsViews | where {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {
	$esxhost | %{$_.config.storageDevice.multipathInfo.lun} | %{$_.path} | ?{$_.State -eq "Dead"} | %{
		$myObj = "" | Select VMHost, Lunpath, State
		$myObj.VMHost = $esxhost.Name
		$myObj.Lunpath = $_.Name
		$myObj.State = $_.state
		$deadluns += $myObj
	}
}
	
$deadluns

$Title = "Hosts Dead LUN Path"
$Header = "Dead LunPath : $(@($deadluns).count)"
$Comments = "Dead LUN Paths may cause issues with storage performance or be an indication of loss of redundancy"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
