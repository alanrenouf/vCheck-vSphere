# Start of Settings
# End of Settings
 
$Result = @( $Clusters | Where-Object {-not $_.HAEnabled} | Select-Object -Property Name,HAEnabled
)
$Result
 
$Title = "Clusters with HA disabled"
$Header =  "Clusters with HA disabled : $(@($Result).Count)"
$Comments = "The following clusters have HA disabled. This will impact your disaster recovery."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
