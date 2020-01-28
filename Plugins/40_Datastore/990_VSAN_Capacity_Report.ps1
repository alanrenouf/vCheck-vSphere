$Title = "VSAN Datastore Capacity"
$Comments = "VSAN Datastore Capacity Report - Modified version from Alan Renouf & Jonathan Medd's Datastore Report"
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# Set the warning threshold for VSAN Datastore % Free Space
$DatastoreSpace = 15
# End of Settings

# Update settings where there is an override
$DatastoreSpace = Get-vCheckSetting $Title "DatastoreSpace" $DatastoreSpace

$Datastores | Where-Object {$_.Type -match 'vsan'} | Select-Object Name, Type, 
   @{N="CapacityGB";E={[math]::Round($_.CapacityGB,2)}},
   @{N="ProvisionedGB";E={([math]::Round($_.CapacityGB,2) - [math]::Round($_.FreeSpaceGB,2))}},
   @{N="FreeSpaceGB";E={[math]::Round($_.FreeSpaceGB,2)}}, PercentFree| Sort-Object PercentFree| Where-Object { $_.PercentFree -lt $DatastoreSpace }

$Header = "VSAN Datastores (Less than $DatastoreSpace% Free) : [count]"

$TableFormat = @{"PercentFree" = @(@{ "-le 15"     = "Row,class|warning"; },
                                   @{ "-le 10"     = "Row,class|critical" });
                 "CapacityGB"  = @(@{ "-lt 499.75" = "Cell,style|background-color: #FFDDDD"})
                }
                
# Change Log
## 1.0 : Initial version
## 1.1 : Code refactor