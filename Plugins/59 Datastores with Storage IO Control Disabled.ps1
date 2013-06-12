# Start of Settings
# End of Settings

$Result = @(Get-Datastore | `
  Where-Object {-not $_.StorageIOControlEnabled} | `
  Sort-Object -Property Name | `
  Select-Object -Property Name,StorageIOControlEnabled
)
$Result

$Title = "Datastores with Storage IO Control Disabled"
$Header =  "Datastores with Storage I/O Control Disabled : $(@($Result).Count)"
$Comments = "Datastores with Storage I/O Control Disabled can impact the performance of your virtual machines."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
