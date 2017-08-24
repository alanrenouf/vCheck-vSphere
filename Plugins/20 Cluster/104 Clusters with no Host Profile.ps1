$Title = "Clusters Without Host Profile attached"
$Header = "Clusters Without Host Profile attached"
$Comments = "The following clusters do not have a host profile attached"
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings

# Get all host profiles and corresponding cluster ID (don't really care about individual hosts at this stage!)
$HostProfiles = Get-VMHostProfile | Select-Object Name, @{Name="ClusterID";Expression={$_.ExtensionData.Entity | Where-Object { $_.type -eq "ClusterComputeResource" }}}

$clusviews | Where-Object {($HostProfiles | Select-Object -expandProperty ClusterID) -notcontains $_.moref } | Sort-Object Name | Select-Object Name