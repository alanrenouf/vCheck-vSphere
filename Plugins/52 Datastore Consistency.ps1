# Start of Settings
# Do not report on any Datastores that are defined here (Datastore Consistency Plugin)
$DSDoNotInclude ="local*|datastore*"
# End of Settings

$problemDatastores = @() 

if ($Clusters -ne $null) {
                
  ForEach ($Cluster in ($Clusters)) {

                $VMHosts = $VMH | ?{ $Cluster.ExtensionData.host -contains $_.id }

                $CluDatastores = $VMHosts | Get-Datastore

                $problemDatastoresObject = $VMHosts | ForEach {Compare-Object $CluDatastores ($_ | Get-Datastore)} | ForEach {$_.InputObject} | Sort Name | Select @{N="Datastore";E={$_.Name}},@{N="Cluster";E={$Cluster.Name}} -Unique

                $problemDatastores += $problemDatastoresObject

  }
}

@($problemDatastores  | Where { $_.Datastore -notmatch $DSDoNotInclude })

$Title = "Datastore Consistency"
$Header =  "Datastores not connected to every host in cluster"
$Comments = "Virtual Machines residing on these datastores will not be able to run on all hosts in the cluster"
$Display = "Table"
$Author = "Robert Sexstone"
$PluginVersion = 1.4
$PluginCategory = "vSphere"
