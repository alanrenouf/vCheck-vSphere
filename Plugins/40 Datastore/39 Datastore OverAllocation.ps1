# Start of Settings 
# Datastore OverAllocation %
$OverAllocation = 50
# Exclude these datastores from report
$ExcludedDatastores = "ExcludeMe"
# End of Settings

$filteredstorageviews = $storageviews | Where-Object { $_.Name -notmatch $ExcludedDatastores }
$voverallocation = @()
foreach ($storage in $filteredstorageviews)
{
	if ($storage.Summary.Uncommitted -gt "0")
	{
		$Details = "" | Select-Object Datastore, Overallocation
		$Details.Datastore = $storage.name
		$Details.overallocation = [math]::round(((($storage.Summary.Capacity - $storage.Summary.FreeSpace) + $storage.Summary.Uncommitted)*100)/$storage.Summary.Capacity,0)
			if ($Details.overallocation -gt $OverAllocation)
			{
				$voverallocation += $Details
			}
	}
}

$voverallocation	

$Title = "Datastore OverAllocation"
$Header = "Datastore OverAllocation Over $OverAllocation%: $(@($voverallocation).Count)"
$Comments = "The following datastores may be overcommitted (over-provisioned) and could run out of space. It is strongly suggested you check these below. You can start an sVMotion to see the Capacity vs. Provisioned space for datastores."
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.4
$PluginCategory = "vSphere"
# 20150223 monahancj - Added datastore filtering
