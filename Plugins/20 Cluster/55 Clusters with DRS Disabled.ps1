# Start of Settings
# Clusters with DRS Disabled, do not report on any Clusters that are defined here
$ClustersDoNotInclude = "VM1_*|VM2_*"
# End of Settings
 
$Result = @( $Clusters |
  Where-Object {$_.Name -notmatch $ClustersDoNotInclude -and -not $_.DRSEnabled} |
  Select-Object -Property Name,DRSEnabled
)
$Result
 
$Title = "Clusters with DRS disabled"
$Header = "Clusters with DRS disabled : $(@($Result).Count)"
$Comments = "The following clusters have DRS disabled. This may impact the performance of your cluster."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
