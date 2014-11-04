# Start of Settings 
# End of Settings 

# Changelog
## 1.3 : Rewritten to cleanup and compare vmdk size to only snapshot size

$snapp = @()
Foreach ($vmg in $VM) {
	If ($vmg.ExtensionData.Snapshot) {
		$hddsize = 0
		ForEach ($DISK in ($vmg|Get-HardDisk)) { # Loop through VM's harddisks 
				$hddsize = $hddsize+[math]::round($DISK.CapacityKB/1048576, 0)
		}
		$snaps = $vmg | Get-Snapshot
		$snapsize = 0
		ForEach ($snap in $snaps) { # Loop through VM's snapshots 
				$snapsize = $snapsize+[math]::round($snap.SizeGB, 0)
		}
		$oversize = [math]::round((((($snapsize + $hddsize)*100)/$hddsize)-100), 0)
		$snappObj = "" | Select VM,vmdkSizeGB,SnapSizeGB,SnapCount,OverSize
		$snappObj.VM = $vmg.Name
		$snappObj.vmdkSizeGB = $hddsize
		$snappObj.SnapSizeGB = $snapsize
		$snappObj.SnapCount = $snaps.count
		if ($hddsize -eq 0) { 
			$snappObj.OverSize = "Linked Clone" 
		} else {
			$snappObj.OverSize = $oversize
		}
		$snapp += $snappObj
	}
}

$snapp | select VM, vmdkSizeGB, SnapSizeGB, SnapCount, @{N="OverSize %";E={$_.OverSize}} | sort "OverSize %" -Descending




$Title = "Snapshots Oversize"
$Header = "Snapshots Oversize"
$Comments = "VMware snapshots which are kept for a long period of time may cause issues, filling up datastores and also may impact performance of the virtual machine."
$Display = "Table"
$Author = "Raphael Schitz, Shawn Masterson"
$PluginVersion = 1.3
$PluginCategory = "vSphere"