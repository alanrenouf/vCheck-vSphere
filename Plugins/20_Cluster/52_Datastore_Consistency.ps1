$Title = "Datastore Consistency"
$Header = "Datastores not connected to every host in cluster"
$Comments = "Virtual Machines residing on these datastores will not be able to run on all hosts in the cluster"
$Display = "Table"
$Author = "Robert Sexstone"
$PluginVersion = 1.6
$PluginCategory = "vSphere"

# Start of Settings
# Do not report on any Datastores that are defined here (Datastore Consistency Plugin)
$DSDoNotInclude = "local*|datastore*"
# End of Settings

# Update settings where there is an override
$DSDoNotInclude = Get-vCheckSetting $Title "DSDoNotInclude" $DSDoNotInclude

if ($Clusters -ne $null) 
{
   ForEach ($Cluster in ($Clusters)) 
   {
      $Cluster.ExtensionData.Host | Foreach-Object { $h = $_; $Datastores | Where-Object {$_.ExtensionData.Host.key -contains $h}} | 
         Where-Object {$_.Name -notmatch $DSDoNotInclude } | Group-Object Name | Where-Object { $_.Count -ne $cluster.ExtensionData.Host.count } | 
         Select-Object @{Name="Name"; Expression={$_.Group.name}}, @{Name="Cluster";Expression={$Cluster.Name}}
   }
}