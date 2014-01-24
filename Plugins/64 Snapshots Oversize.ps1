# Start of Settings 
# End of Settings 

Function Get-VmSize($vmname) {
	# modded version from Arnim van Lieshout http://www.van-lieshout.com/2009/07/how-big-is-my-vm/
   #Initialize variables
   $VmDirs = @()
   $VmSize = 0
	$fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
	$fileQueryFlags.FileSize = $true
	#$fileQueryFlags.FileType = $true
	#$fileQueryFlags.Modification = $true
	$searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
	$searchSpec.details = $fileQueryFlags
	$vmname | ForEach {
		#Create an array with the vm's directories
		$VmDirs += $_.Config.Files.SnapshotDirectory.split("/")[0]
		#Add directories of the vm's virtual disk files
		ForEach ($disk in $_.Layout.Disk) {
			ForEach ($diskfile in $disk.diskfile) {
				$VmDirs += $diskfile.split("/")[0]
			}
		}
		#Only take unique array items
		$VmDirs = $VmDirs | Sort | Get-Unique

		ForEach ($dir in $VmDirs){
            $ds = Get-Datastore ($dir.split("[")[1]).split("]")[0]
            $dsb = Get-View (($ds | Get-View).Browser)
			$vimapiversion = ($defaultviserver.extensiondata.client.version.tostring()).Split("Vim")[-1]
			$searchSpec = [VMware.Vim.VIConvert]::"ToVim$vimapiversion".invoke($searchSpec)
			
			$searchSpec.details.fileOwnerSpecified = $true
 
			$dsBrowserMoRef = [VMware.Vim.VIConvert]::"ToVim$vimapiversion".invoke($dsb.MoRef)
			$taskMoRef  = $dsb.Client.VimService.SearchDatastoreSubFolders_Task($dsBrowserMoRef, $dir, $searchSpec)
            $task = [VMware.Vim.VIConvert]::ToVim($dsb.WaitForTask([VMware.Vim.VIConvert]::ToVim($taskMoRef))) 
 
            ForEach ($result in $task){
                ForEach ($file in $result.File){
                    $VmSize += $file.FileSize
                }
            }
		}
    }
    return $VmSize
}

Function Get-Snapshot2 ($objVM) {					
	$rootsnap = $objVM | Foreach {$_.Snapshot.RootSnapshotList}
	$snaplist = @()
	$snaplist += $rootsnap
	$snaplist += get-snapshotlegacy $rootsnap
	return $snaplist
}

Function Get-Snapshotlegacy ($rootsnap) {
	foreach ($snap in ($rootsnap|%{$_.ChildSnapshotList})) {
		$snap
		if ((($snap | Foreach {$_.ChildSnapshotList})|Measure-Object).Count -gt 0) {
			get-snapshotlegacy $snap
		}
	}
}

Function Get-hypersnapshot($FullVM) {
	$snapp = @()
	ForEach ($VMView in $FullVM) {			
		if ($VMView.Snapshot) {
			$vmg = $VM | ?{$_.Id -eq $VMView.MoRef}
			$vmname = $VMView.name
			$hddsize = 0
			ForEach ($DISK in ($vmg|Get-HardDisk)) { # Loop through VM's harddisks 
				$hddsize = $hddsize+[math]::round($DISK.CapacityKB/1048576, 0)
			}
			$snapcount = (Get-Snapshot2 $VMView|Measure-Object).Count
			$totalsize = Get-VmSize($VMView)
			$totalsize = [math]::round($totalsize/1073741824,0)
			$oversize = [math]::round((($totalsize*100)/$hddsize), 0)
			if ($oversize -gt $limitSnapshotOversizeShow) {
				$snappObj = "" | Select VM,vmdkSize,RealSize,SnapCount,OverSize
				$snappObj.VM = $vmname
				$snappObj.vmdkSize = "$hddsize GB"
				$snappObj.RealSize = "$totalsize GB"
				$snappObj.SnapCount = $snapcount
				if ($hddsize -eq 0) { 
					$snappObj.OverSize = "Linked Clone" 
				} else {
					$snappObj.OverSize = "$oversize%"
				}
				$snapp += $snappObj
			}
		}
	}
	return $snapp
}

Get-hypersnapshot($FullVM) | sort OverSize -Descending

$Title = "Snapshots Oversize"
$Header =  "Snapshots Oversize"
$Comments = ""
$Display = "Table"
$Author = "Raphael Schitz"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
