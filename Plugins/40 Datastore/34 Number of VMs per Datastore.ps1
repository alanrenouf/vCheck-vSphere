# Start of Settings 
# Max number of VMs per Datastore
$NumVMsPerDatastore = 5
# Exclude these datastores from report
$ExcludedDatastores = "ExcludeMe"
# End of Settings

# Changelog
## 1.1 : Using managed objects collections in order to avoid using Get-VM cmdlet for performance matter

$Result = @($StorageViews | Where-Object { $_.Name -notmatch $ExcludedDatastores } | Select Name, @{N="NumVM";E={($_.vm).Count}} | Where { $_.NumVM -gt $NumVMsPerDatastore} | Sort NumVM -Descending)
$Result

$Title = "Number of VMs per Datastore"
$Header = "Number of VMs per Datastore over $($NumVMsPerDatastore) : $(@($Result).Count)"
$Comments = "The Maximum number of VMs per datastore is 256, the following VMs are above the defined $NumVMsPerDatastore and may cause performance issues"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
