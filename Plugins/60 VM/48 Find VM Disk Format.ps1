# Start of Settings 
# Report on disk formats that are not "thin" or "thick", which format is not allowed?
$diskformat = "thick"
# Specify Datastores to filter from report
$DatastoreIgnore = "local"
# End of Settings

$vmdiskformat = $VM | Get-HardDisk | where {($_.storageformat -match $diskformat) -and ($_.Filename -notmatch $DatastoreIgnore)} | select @{N="VM";E={$_.parent.name}}, @{N="DiskName";E={$_.name}}, @{N="Format";E={$_.storageformat}}, @{N="FileName";E={$_.filename}}
$vmdiskformat

$Title = "Find VMs with thick or thin provisioned vmdk"
$Header = "VMs with $diskformat provisioned vmdk(s): $(@($vmdiskformat).count)"
$Comments = "The following VMs have have $diskformat provisioned vmdk(s)"
$Display = "Table"
$Author = "David Chung"
$PluginVersion = 1.2

$PluginCategory = "vSphere"
