# Start of Settings
# Do not report on any Datastores that are defined here (Storage IO Control disabled Plugin)
$DatastoreIgnore = "local"
# End of Settings

$Result = @($Datastores | `
  Where-Object {$_.Name -notmatch $DatastoreIgnore} | `
  Where-Object {-not $_.StorageIOControlEnabled} | `
  Sort-Object -Property Name | `
  Select-Object -Property Name,StorageIOControlEnabled
)
$Result

$Title = "Datastores with Storage IO Control Disabled"
$Header = "Datastores with Storage I/O Control Disabled : $(@($Result).Count) (with user exception $DatastoreIgnore)"
$Comments = "Datastores with Storage I/O Control Disabled can impact the performance of your virtual machines."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
