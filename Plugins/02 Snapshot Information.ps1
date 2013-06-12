# Start of Settings 
# Set the warning threshold for snapshots in days old
$SnapshotAge =14
# End of Settings

Function Find-Username ($username){
	if ($username -ne $null)
	{
		$root = [ADSI]""
		$filter = ("(&(objectCategory=user)(samAccountName=$Username))")
		$ds = new-object  system.DirectoryServices.DirectorySearcher($root,$filter)
		$ds.PageSize = 1000
		$UN = $ds.FindOne()
		If ($UN -eq $null){
			Return $username
		}
		Else {
			Return $UN
		}
	}
}

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

			$mySnaps | Select VM, Name, @{N="DaysOld";E={((Get-Date) - $_.Created).Days}}, @{N="Creator";E={(Find-Username (($_.Creator.split("\"))[1])).Properties.displayname}}, SizeMB, Created, Description -ErrorAction SilentlyContinue | Sort DaysOld

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
	$tasknumber = 999		# Windowsize of the Task collector
	$taskMgr = Get-View TaskManager
	
	# Create hash table. Each entry is a create snapshot task
	$report = @{}
	
	$filter = New-Object VMware.Vim.TaskFilterSpec
	$filter.Time = New-Object VMware.Vim.TaskFilterSpecByTime
	$filter.Time.beginTime = (($snap.Created).AddDays(-5))
	$filter.Time.timeType = "startedTime"
	
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
		$key = $_.vm.Name + "&" + ($_.Created.ToString())
		if($report.ContainsKey($key)){
			$_ | Add-Member -MemberType NoteProperty -Name Creator -Value $report[$key].User
		}
		$_
	}
	$snapshotsExtra
}

$Snapshots = @($VM | Get-Snapshot | Where {$_.Created -lt (($Date).AddDays(-$SnapshotAge))} | Get-SnapshotSummary)
$Snapshots

$Title = "Snapshot Information"
$Header =  "Snapshots (Over $SnapshotAge Days Old) : $(@($snapshots).count)"
$Comments = "VMware snapshots which are kept for a long period of time may cause issues, filling up datastores and also may impact performance of the virtual machine."
$Display = "Table"
$Author = "Alan Renouf, Raphael Schitz"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
