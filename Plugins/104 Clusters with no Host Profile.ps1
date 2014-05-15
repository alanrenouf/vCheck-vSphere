# Start of Settings 
# End of Settings

# Get all host profiles and corresponding cluster ID (don't really care about individual hosts at this stage!)
$HostProfiles = Get-VMHostProfile | Select Name, @{Name="ClusterID";Expression={$_.ExtensionData.Entity | ?{ $_.type -eq "ClusterComputeResource" }}}

$clusviews | ?{($HostProfiles | Select -expandProperty ClusterID) -notcontains $_.moref } | Sort-Object Name | Select Name

$Title = "Clusters Without Host Profile attached"
$Header = "Clusters Without Host Profile attached"
$Comments = "The following clusters do not have a host profile attached"
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
