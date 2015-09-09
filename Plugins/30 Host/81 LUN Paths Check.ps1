# Start of Settings 
# Set the Recommended number of paths per LUN
$RecLUNPaths = 4
$HostDoesNotInclude = "hostname"	#In regular expressions $ matches at the end of a line, ^ at the beginning
# End of Settings
# 4/22/14 Added HostDoesNotInclude feature to ignore certain hosts, like Vblock AMP rack servers. -Greg Hatch

$missingpaths = @() 
foreach ($esxhost in ($HostsViews | where {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {
  #Write-Host $esxhost.Name
	$lun_array = @() # 2D array - LUN Name & Path Count
	$esxhost | %{$_.config.storageDevice.multipathInfo.lun} | %{$_.path} | ?{$_.name -like "fc.*"} | %{
		$short_path_array = $_.name.split('-')
		$short_path = $short_path_array[2]
		$found = $false
		foreach ($lun in $lun_array) {
			if ($lun[0] -eq $short_path) {
				$found = $true
				$lun[1]++
			}
		}
		if (!($found)) {
			$lun_array +=(,($short_path,1))
		}
	}

	#Create report for ESX host
	foreach ($lun in $lun_array) {
		if ($lun[1] -lt $RecLUNPaths) {
			#Write-Host "Alerting due to lack of paths (" $lun[1] "looking for" $RecLUNPaths "), for LUN: " $lun[0]
			$myObj = "" | Select ESXHost, LUN , Paths
			$myObj.ESXHost = $esxhost.Name
			$myObj.LUN = $lun[0]
			$myObj.Paths = $lun[1]
			$missingpaths += $myObj
		}
	}
}

$PathReport = @($missingpaths | where { $_.ESXHost -notmatch $HostDoesNotInclude }) | sort ESXHost
if($PathReport -ne $null) {$PathReport}

$Title = "Check LUNS have the recommended number of paths"
$Header =  "LUNs not having the recommended number of paths ($RecLUNPaths): $(@($missingpaths).count)"
$Comments = "Not enough storage paths can effect storage availability in a FC SAN environment"
$Display = "Table"
$Author = "Craig Smith"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
