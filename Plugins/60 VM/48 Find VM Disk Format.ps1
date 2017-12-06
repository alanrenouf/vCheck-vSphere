# Start of Settings 
# Report on disk formats that are not "thin" or "thick", which format is not allowed?
$diskformat = "thick"
# Specify Datastores to filter from report
$DatastoreIgnore = "local"
# End of Settings

# Update settings where there is an override
$diskformat = Get-vCheckSetting $Title "diskformat" $diskformat
$DatastoreIgnore = Get-vCheckSetting $Title "DatastoreIgnore" $DatastoreIgnore

$VM | Get-HardDisk | Where-Object {($_.storageformat -match $diskformat) -and ($_.Filename -notmatch $DatastoreIgnore)} | Select-Object @{N="VM";E={$_.parent.name}}, @{N="DiskName";E={$_.name}}, @{N="Format";E={$_.storageformat}}, @{N="FileName";E={$_.filename}}

$Title = "Find VMs with thick or thin provisioned vmdk"
$Header = "VMs with $diskformat provisioned vmdk(s): [count]"
$Comments = "The following VMs have have $diskformat provisioned vmdk(s)"
$Display = "Table"
$Author = "David Chung"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Change Log
## 1.3 : Added Get-vCheckSetting