$Title = "sDRS VM Behavior not Default"
$Header = "VMs overriding Datastore Cluster automation level: [count]"
$Comments = "The following VMs are overriding the Datastore Cluster sDRS automation level"
$Display = "Table"
$Author = "Shawn Masterson"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# Exclude these VMs from report
$ExcludedVMs = ""
# End of Settings

# Update settings where there is an override
$ExcludedVMs = Get-vCheckSetting $Title "ExcludedVMs" $ExcludedVMs

$DatastoreClustersView | Foreach {$_.PodStorageDrsEntry.StorageDrsConfig.VMConfig} | `
   Where {$_.Enabled -eq $false -or $_.Behavior -ne $null} | `
   Select @{N="VM";E={Get-View $_.Vm | Select -ExpandProperty Name}}, Enabled, Behavior,@{N="Datastore Cluster";E={$dc.Name}} | Where { $_.VM -notmatch $ExcludedVMs }

# Changelog
## 1.0 : Initial Version
## 1.1 : Code refactor and filtering