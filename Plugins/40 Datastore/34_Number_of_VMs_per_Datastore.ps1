$Title = "Number of VMs per Datastore"
$Comments = "The Maximum number of VMs per datastore is 256, the following VMs are above the defined $NumVMsPerDatastore and may cause performance issues"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# Max number of VMs per Datastore
$NumVMsPerDatastore = 5
# Exclude these datastores from report
$ExcludedDatastores = "ExcludeMe"
# End of Settings

# Update settings where there is an override
$NumVMsPerDatastore = Get-vCheckSetting $Title "NumVMsPerDatastore" $NumVMsPerDatastore
$ExcludedDatastores = Get-vCheckSetting $Title "ExcludedDatastores" $ExcludedDatastores

$StorageViews | Where-Object { $_.Name -notmatch $ExcludedDatastores } | Select-Object Name, @{N="NumVM";E={($_.vm).Count}} | Where-Object { $_.NumVM -gt $NumVMsPerDatastore} | Sort-Object NumVM -Descending

$Header = "Number of VMs per Datastore over $($NumVMsPerDatastore) : [count]"


# Changelog
## 1.1 : Using managed objects collections in order to avoid using Get-VM cmdlet for performance matter
## 1.2 : ???
## 1.3 : Add Get-vCheckSetting
