# Start of Settings
# Do not report on any Datastores that are defined here (Datastore Consistency Plugin)
$DSDoNotInclude = "local*|datastore*"
# End of Settings

$problemDatastores = @() 

if ($Clusters -ne $null) {              
   ForEach ($Cluster in ($Clusters)) {
      $problemDatastores += $Cluster.ExtensionData.Host | %{ $h = $_; $Datastores | Where {$_.ExtensionData.Host.key -contains $h}} | 
                              Where {$_.Name -notmatch $DSDoNotInclude } | Group-Object Name | Where { $_.Count -ne $cluster.ExtensionData.Host.count } | 
                              Select @{Name="Name"; Expression={$_.Group.name}}, @{Name="Cluster";Expression={$Cluster.Name}}
   }
}

$problemDatastores

$Title = "Datastore Consistency"
$Header = "Datastores not connected to every host in cluster"
$Comments = "Virtual Machines residing on these datastores will not be able to run on all hosts in the cluster"
$Display = "Table"
$Author = "Robert Sexstone"
$PluginVersion = 1.5
$PluginCategory = "vSphere"
