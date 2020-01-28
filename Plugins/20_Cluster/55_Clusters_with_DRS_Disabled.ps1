$Title = "Clusters with DRS disabled"
$Header = "Clusters with DRS disabled : [count]"
$Comments = "The following clusters have DRS disabled. This may impact the performance of your cluster."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings
# Clusters with DRS Disabled, do not report on any Clusters that are defined here
$ClustersDoNotInclude = "VM1_*|VM2_*"
# End of Settings

# Update settings where there is an override
$ClustersDoNotInclude = Get-vCheckSetting $Title "ClustersDoNotInclude" $ClustersDoNotInclude

@( $Clusters |
   Where-Object {$_.Name -notmatch $ClustersDoNotInclude -and -not $_.DRSEnabled} |
   Select-Object -Property Name,DRSEnabled
)