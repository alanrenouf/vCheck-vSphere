# Start of Settings 
# Datastore OverAllocation %
$OverAllocation =50
# End of Settings

$voverallocation = @()
foreach ($storage in $storageviews)
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
$Header =  "Datastore OverAllocation Over $OverAllocation%: $(@($voverallocation).Count)"
$Comments = "The following datastores may be overcommitted it is strongly suggested you check these"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
