# Start of Settings 
# Set the warning threshold for snapshots in days old
$SnapshotAge = 14
# Set snapshot name exception (regex)
$excludeName = "ExcludeMe"
# Set snapshot description exception (regex)
$excludeDesc = "ExcludeMe"
# Set snapshot creator exception (regex)
$excludeCreator = "ExcludeMe"
# End of Settings

# Changelog
## 1.3 : Cleanup - Fixed Creator - Changed Size to GB
## 1.4 : Decode URL-encoded snapshot name (i.e. the %xx caharacters)

Add-Type -AssemblyName System.Web

function Get-SnapshotSummary {
	param(
		$InputObject = $null
	)

	PROCESS {
		if ($InputObject -and $_) {
			throw 'ParameterBinderStrings\AmbiguousParameterSet'
			break
		} elseif ($InputObject) {
			$InputObject
		} elseif ($_) {

			$mySnaps = @()
			foreach ($snap in $_){
				$SnapshotInfo = Get-SnapshotExtra $snap
				$mySnaps += $SnapshotInfo
			}

			$mySnaps | Select VM, @{N="SnapName";E={[System.Web.HttpUtility]::UrlDecode($_.Name)}}, @{N="DaysOld";E={((Get-Date) - $_.Created).Days}}, Creator, @{N="SizeGB";E={$_.SizeGB -as [int]}}, Created, Description -ErrorAction SilentlyContinue | Sort DaysOld

		} else {
			throw 'ParameterBinderStrings\InputObjectNotBound'
		}
	}
}

function Get-SnapshotTree{
	param($tree, $target)

	$found = $null
	foreach($elem in $tree){
		if($elem.Snapshot.Value -eq $target.Value){
			$found = $elem
			continue
		}
	}
	if($found -eq $null -and $elem.ChildSnapshotList -ne $null){
		$found = Get-SnapshotTree $elem.ChildSnapshotList $target
	}

	return $found
}

function Get-SnapshotExtra ($snap){
	$guestName = $snap.VM	# The name of the guest
	$tasknumber = 999		# Window size of the Task collector
	$taskMgr = Get-View TaskManager

	# Create hash table. Each entry is a create snapshot task
	$report = @{}

	$filter = New-Object VMware.Vim.TaskFilterSpec
	$filter.Time = New-Object VMware.Vim.TaskFilterSpecByTime
	$filter.Time.beginTime = (($snap.Created).AddDays(-5))
	$filter.Time.timeType = "startedTime"
	# Added filter to only view for the selected VM entity. Massive speed up.
	# Entity name check could be removed in line 91.
	$filter.Entity = New-Object VMware.Vim.TaskFilterSpecByEntity
    	$filter.Entity.Entity = $snap.VM.ExtensionData.MoRef

	$collectionImpl = Get-View ($taskMgr.CreateCollectorForTasks($filter))

	$dummy = $collectionImpl.RewindCollector
	$collection = $collectionImpl.ReadNextTasks($tasknumber)
	while($collection -ne $null){
		$collection | where {$_.DescriptionId -eq "VirtualMachine.createSnapshot" -and $_.State -eq "success" -and $_.EntityName -eq $guestName} | %{
			$row = New-Object PsObject
			$row | Add-Member -MemberType NoteProperty -Name User -Value $_.Reason.UserName
			$vm = Get-View $_.Entity
			if($vm -ne $null){ 
				$snapshot = Get-SnapshotTree $vm.Snapshot.RootSnapshotList $_.Result
				if($snapshot -ne $null){
					$key = $_.EntityName + "&" + ($snapshot.CreateTime.ToString())
					$report[$key] = $row
				}
			}
		}
		$collection = $collectionImpl.ReadNextTasks($tasknumber)
	}
	$collectionImpl.DestroyCollector()

	# Get the guest's snapshots and add the user
	$snapshotsExtra = $snap | % {
		$key = $_.vm.Name + "&" + ($_.Created.ToUniversalTime().ToString())
		$str = $report | Out-String
		if($report.ContainsKey($key)){
			$_ | Add-Member -MemberType NoteProperty -Name Creator -Value $report[$key].User
		}
		$_
	}
	$snapshotsExtra
}

$Snapshots = @($VM | Get-Snapshot | Where {$_.Created -lt (($Date).AddDays(-$SnapshotAge))} | Get-SnapshotSummary | Where {$_.SnapName -notmatch $excludeName -and $_.Description -notmatch $excludeDesc -and $_.Creator -notmatch $excludeCreator})
$Snapshots

$Title = "Snapshot Information"
$Header =  "Snapshots (Over $SnapshotAge Days Old) : $(@($snapshots).count)"
$Comments = "VMware snapshots which are kept for a long period of time may cause issues, filling up datastores and also may impact performance of the virtual machine."
$Display = "Table"
$Author = "Alan Renouf, Raphael Schitz"
$PluginVersion = 1.4
$PluginCategory = "vSphere"
