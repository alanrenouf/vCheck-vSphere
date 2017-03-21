$Title = "Datastores with Storage IO Control Disabled"
$Header = "Datastores with Storage I/O Control Disabled : [count]"
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings
# Do not report on any Datastores that are defined here (Storage IO Control disabled Plugin)
$DatastoreIgnore = "local"
# End of Settings

# Update settings where there is an override
$DatastoreIgnore = Get-vCheckSetting $Title "DatastoreIgnore" $DatastoreIgnore

$Datastores | Where-Object {$_.Name -notmatch $DatastoreIgnore -and -not $_.StorageIOControlEnabled} | `
   Sort-Object -Property Name | `
   Select-Object -Property Name,StorageIOControlEnabled

$Comments = ("Datastores with Storage I/O Control Disabled can impact the performance of your virtual machines. Excludes {0}" -f $DatastoreIgnore)

# Change Log
## 1.3 : Added Get-vCheckSetting