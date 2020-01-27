$Title = "Datastore OverAllocation"
$Comments = "The following datastores may be overcommitted, it is strongly suggested you check these"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# Datastore OverAllocation %
$OverAllocation = 50
# Exclude these datastores from report
$ExcludedDatastores = ""
# End of Settings

# Update settings where there is an override
$OverAllocation = Get-vCheckSetting $Title "OverAllocation" $OverAllocation
$ExcludedDatastores = Get-vCheckSetting $Title "ExcludedDatastores" $ExcludedDatastores

$filteredstorageviews = $storageviews | Where-Object { $_.Name -notmatch $ExcludedDatastores }

foreach ($storage in $filteredstorageviews)
{
   if ($storage.Summary.Uncommitted -gt "0")
   {
      $allocation = [math]::round(((($storage.Summary.Capacity - $storage.Summary.FreeSpace) + $storage.Summary.Uncommitted)*100)/$storage.Summary.Capacity,0)
      
      if (($allocation-100) -gt $OverAllocation) {
         New-Object -TypeName PSObject -Property @{
            "Datastore" = $storage.name
            "OverAllocation" = $overAllocation }
      }
   }
}

$Header = ("Datastore OverAllocation Over {0}%: [count]" -f $OverAllocation)

# Change Log
# 1.3 : 20150223 monahancj - Added datastore filtering
# 1.4 : Added Get-vCheckSetting, fixed logic to report over allocation properly
