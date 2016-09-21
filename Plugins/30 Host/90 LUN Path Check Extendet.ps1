# Start of Settings 
# Set the maximum number of paths per LUN
$MaxLUNPaths = 4
# End of Settings

$myHosts = $VMH | where {$_.ConnectionState  -eq "Connected" -and $_.PowerState -eq "PoweredOn"}

$Report = @()
foreach ($myHost in $myHosts) {
	$esxcli2 = Get-ESXCLI -VMHost $myHost -V2
	$devices = $esxcli2.storage.core.path.list.invoke() | select Device -Unique

	foreach ($device in $devices) {
		$arguments = $esxcli2.storage.core.path.list.CreateArgs()
		$arguments.device = $device.Device
		$LUNs = $esxcli2.storage.core.path.list.Invoke($arguments)
		[String]$LUNIDs = $LUNs.LUN | Select-Object -Unique
		$LUNReport = [PSCustomObject] @{
			HostName = $myHost.Name
			Device = $device.Device
			LUNPaths = $LUNs.Length
			LUNIDs = $LUNIDs
		}
		$Report += $LUNReport
		}
	}

$Report | where {$_.LUNPaths -gt $MaxLUNPaths -or ($_.LUNIDs | measure).count -gt 1 } 

$Title = "Check LUNS that have to much Paths or Multiple LUN IDs"
$Header = "LUNs not having more than ($MaxLUNPaths) Paths or Multiple LUN IDs: $(@($Report | where {$_.LUNPaths -gt $MaxLUNPaths -or ($_.LUNIDs | measure).count -gt 1 } ).count)"
$Comments = "Multiple LUN IDs are not Supported"
$Display = "Table"
$Author = "Markus Kraus"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
