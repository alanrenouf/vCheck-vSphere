# Start of Settings
# End of Settings
 
$Result = @( $Clusters | Where-Object {-not $_.DRSEnabled} | Select-Object -Property Name,DRSEnabled
)
$Result
 
$Title = "Clusters with DRS disabled"
$Header =  "Clusters with DRS disabled : $(@($Result).Count)"
$Comments = "The following clusters have DRS disabled. This may impact the performance of your cluster."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
