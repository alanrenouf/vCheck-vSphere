# Start of Settings 
# Set the warning threshold for VSAN Datastore % Free Space
$DatastoreSpace = 85
# End of Settings

$OutputDatastores = @($Datastores | Where-Object {$_.Type -match 'vsan'} | Select-Object Name, Type, 
@{N="CapacityGB";E={[math]::Round($_.CapacityGB,2)}},
@{N="ProvisionedGB";E={([math]::Round($_.CapacityGB,2) - [math]::Round($_.FreeSpaceGB,2))}},
@{N="FreeSpaceGB";E={[math]::Round($_.FreeSpaceGB,2)}}, PercentFree| Sort-Object PercentFree)| Where-Object { $_.PercentFree -lt $DatastoreSpace }

$OutputDatastores

$Title = "VSAN Datastore Capacity"
$Header = "VSAN Datastores (Less than $DatastoreSpace% Free) : $(@($OutputDatastores).count)"
$Comments = "VSAN Datastore Capacity Report - Modified version from Alan Renouf & Jonathan Medd's Datastore Report"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

$TableFormat = @{"PercentFree" = @(@{ "-le 25"     = "Row,class|warning"; },
								   @{ "-le 15"     = "Row,class|critical" });
				 "CapacityGB"  = @(@{ "-lt 499.75" = "Cell,style|background-color: #FFDDDD"})			   
				}
