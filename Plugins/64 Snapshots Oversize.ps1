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
	
	$vmname | %{
		#Create an array with the vm's directories
		#$VmDirs += $_.Config.Files.VmPathName.split("/")[0]
		$VmDirs += $_.Config.Files.SnapshotDirectory.split("/")[0]
		#$VmDirs += $_.Config.Files.SuspendDirectory.split("/")[0]
		#$VmDirs += $_.Config.Files.LogDirectory.split("/")[0]
		#Add directories of the vm's virtual disk files
		foreach ($disk in $_.Layout.Disk) {
			foreach ($diskfile in $disk.diskfile) {
				$VmDirs += $diskfile.split("/")[0]
			}
		}
		#Only take unique array items
		$VmDirs = $VmDirs | Sort | Get-Unique

		foreach ($dir in $VmDirs){
            $ds = Get-Datastore ($dir.split("[")[1]).split("]")[0]
            $dsb = Get-View (($ds | Get-View).Browser)
			if (($global:DefaultVIServer).Version -cge "5"){$searchSpec = [VMware.Vim.VIConvert]::ToVim50($searchSpec)}
			elseif (($global:DefaultVIServer).Version -cge "4.1"){$searchSpec = [VMware.Vim.VIConvert]::ToVim41($searchSpec)}
			elseif (($global:DefaultVIServer).Version -eq "4.0.0"){$searchSpec = [VMware.Vim.VIConvert]::ToVim4($searchSpec)}
 
			$searchSpec.details.fileOwnerSpecified = $true
 
			if (($global:DefaultVIServer).Version -cge "5"){$dsBrowserMoRef = [VMware.Vim.VIConvert]::ToVim50($dsb.MoRef)}
			elseif (($global:DefaultVIServer).Version -cge "4.1"){$dsBrowserMoRef = [VMware.Vim.VIConvert]::ToVim41($dsb.MoRef)}
            elseif (($global:DefaultVIServer).Version -eq "4.0.0"){$dsBrowserMoRef = [VMware.Vim.VIConvert]::ToVim4($dsb.MoRef)}
 
			$taskMoRef  = $dsb.Client.VimService.SearchDatastoreSubFolders_Task($dsBrowserMoRef, $dir, $searchSpec)
            $task = [VMware.Vim.VIConvert]::ToVim($dsb.WaitForTask([VMware.Vim.VIConvert]::ToVim($taskMoRef))) 
 
            foreach ($result in $task){
                foreach ($file in $result.File){
                    $VmSize += $file.FileSize
                }
            }
		}
    }
    return $VmSize
}

Function Get-Snapshot2 ($objVM) {					
	$rootsnap = $objVM|%{$_.Snapshot.RootSnapshotList}
	$snaplist = @()
	$snaplist += $rootsnap
	$snaplist += get-snapshotlegacy $rootsnap
	return $snaplist
}

Function Get-Snapshotlegacy ($rootsnap) {
	foreach ($snap in ($rootsnap|%{$_.ChildSnapshotList})) {
		$snap
		if ((($snap|%{$_.ChildSnapshotList})|Measure-Object).Count -gt 0) {
			get-snapshotlegacy $snap
		}
	}
}

Function Get-hypersnapshot($FullVM) {
	$snapp = @()
	ForEach ($VMView in $FullVM) {			
		if ($VMView.Snapshot) {
			$vmg = Get-VM -Name $VMView.name
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
$PluginVersion = 1.1
$PluginCategory = "vSphere"
