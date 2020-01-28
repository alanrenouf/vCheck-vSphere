$Title = "Datastore OverAllocation"
$Comments = "The following datastores may be overcommitted, it is strongly suggested you check these"
$Display = "Table"
$Author = "Alan Renouf, Felix Longardt"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# Datastore OverAllocation %
$OverAllocation = 0
# Exclude these datastores from report
$ExcludedDatastores = "MyExcludedDatastore"
# End of Settings

# Update settings where there is an override
#$OverAllocation = Get-vCheckSetting $Title "OverAllocation" $OverAllocation
#$ExcludedDatastores = Get-vCheckSetting $Title "ExcludedDatastores" $ExcludedDatastores

$filteredstorageviews = Get-Datastore | %{$_.ExtensionData} | Where-Object { $_.Name -notmatch $ExcludedDatastores }

foreach ($storage in $filteredstorageviews)
{
   if ($storage.Summary.Uncommitted -gt "0")
   {
      $allocation = [math]::round(((($storage.Summary.Capacity - $storage.Summary.FreeSpace) + $storage.Summary.Uncommitted)*100)/$storage.Summary.Capacity,0)
      $totalspaceGB = [math]::round($storage.Summary.Capacity/1GB,0)
      $usedspaceGB = [math]::round(($storage.Summary.Capacity - $storage.Summary.FreeSpace)/1GB,0)
      $provisionedspaceGB = [math]::round(($storage.Summary.Capacity - $storage.Summary.FreeSpace + $storage.Summary.Uncommitted)/1GB,0)
       
      if (($allocation-100) -gt $OverAllocation) {
         New-Object -TypeName PSObject -Property @{
            "OverAllocation" = "$allocation %"
	    "TotalSpace" = "$totalspaceGB GB"
	    "UsedSpace" = "$usedspaceGB GB"
	    "ProvisionedSpace" = "$provisionedspaceGB GB"
            "Datastore" = $storage.name} | Select Datastore,OverAllocation,TotalSpace,UsedSpace,ProvisionedSpace
      }
   }
}

$Header = ("Datastore OverAllocation Over {0}%: [count]" -f $OverAllocation)

# Change Log
# 1.3 : 20150223 monahancj - Added datastore filtering
# 1.4 : Added Get-vCheckSetting, fixed logic to report over allocation properly
# 1.5 : Added Total/Used and Provisioned Space
