$Title = "Datastore Information"
$Comments = "Datastores which run out of space will cause impact on the virtual machines held on these datastores"
$Display = "Table"
$Author = "Alan Renouf, Jonathan Medd"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# Set the warning threshold for Datastore % Free Space
$DatastoreSpace = 15
# Do not report on any Datastores that are defined here (Datastore Free Space Plugin)
$DatastoreIgnore = "local"
# End of Settings

# Update settings where there is an override
$DatastoreSpace = Get-vCheckSetting $Title "DatastoreSpace" $DatastoreSpace
$DatastoreIgnore = Get-vCheckSetting $Title "DatastoreIgnore" $DatastoreIgnore

$Datastores | Where-Object {$_.Name -notmatch $DatastoreIgnore} | Select-Object Name, Type, @{N="CapacityGB";E={[math]::Round($_.CapacityGB,2)}}, @{N="FreeSpaceGB";E={[math]::Round($_.FreeSpaceGB,2)}}, PercentFree| Sort-Object PercentFree | Where-Object { $_.PercentFree -lt $DatastoreSpace }

$Header = "Datastores (Less than $DatastoreSpace% Free) : [count]"

$TableFormat = @{"PercentFree" = @(@{ "-le 15"     = "Row,class|warning"; },
                                   @{ "-le 10"     = "Row,class|critical" });
                 "CapacityGB"  = @(@{ "-lt 499.75" = "Cell,style|background-color: #FFDDDD"})
}


# ChangeLog
# 1.2 : Added ability to filter out datastores (e.g. local ones) that you are not concerned about for the report
# 1.3 : Added TableFormat for conditional formatting of output table
# 1.4 : Added Get-vCheckSetting