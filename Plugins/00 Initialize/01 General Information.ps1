$Title = "General Information"
$Header =  "General Information"
$Comments = "General details on the infrastructure"
$Display = "List"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days of DRS Migrations to report and count on
$DRSMigrateAge = 1
# Set the number of days of Storage DRS Migrations to report and count on
$SDRSMigrateAge = 1
# End of Settings

# Update settings where there is an override
$DRSMigrateAge = Get-vCheckSetting $Title "DRSMigrateAge" $DRSMigrateAge
$SDRSMigrateAge = Get-vCheckSetting $Title "SDRSMigrateAge" $SDRSMigrateAge

if ($VIVersion -lt 5) {
   $DRSMigrations = Get-VIEventPlus -Start $Date.AddDays(-$DRSMigrateAge) -EventType 'DrsVmMigratedEvent' | Select-Object CreatedTime, FullFormattedMessage
}
else {
   $DRSMigrations = Get-VIEventPlus -Start $Date.AddDays(-$DRSMigrateAge) -EventType 'DrsVmMigratedEvent' | Select-Object CreatedTime, FullFormattedMessage
   $StorageDRSQuery = Get-VIEventPlus -Start $Date.AddDays(-$SDRSMigrateAge) -EventType 'com.vmware.vc.sdrs.StorageDrsStoragePlacementEvent'
   $SDRSMigrations = ForEach ($Event in $StorageDRSQuery) {
      New-Object -TypeName PSObject -Property @{
         'CreatedTime' = $Event.CreatedTime
         'FullFormattedMessage' = "SDRS migrated $($Event.Arguments.Value[0]) to $($Event.Arguments.Value[2]) in datastore cluster $($Event.ObjectName)."
      }
   }
}

$Info = New-Object -TypeName PSObject -Property ([ordered]@{
   "Number of Hosts" = (@($VMH).Count)
   "Number of VMs" = (@($VM).Count)
   "Number of Templates" = (@($VMTmpl).Count)
   "Number of Clusters" = (@($Clusters).Count)
   "Number of Datastores" = (@($Datastores).Count)
   "Active VMs" = (@($FullVM | Where-Object { $_.Runtime.PowerState -eq "poweredOn" }).Count) 
   "In-active VMs" = (@($FullVM | Where-Object { $_.Runtime.PowerState -eq "poweredOff" }).Count)
})

# Don't display DRS line if 0 days are set
if ($DRSMigrateAge -gt 0) {
   $Info | Add-Member Noteproperty "DRS Migrations for last $($DRSMigrateAge) Days" (@($DRSMigrations).Count)
}

# Adding vSphere 5 informations
if ($VIVersion -ge 5) {
   $Info | Add-Member Noteproperty "Number of Datastore Clusters" $(@($DatastoreClustersView).Count)
   if (($SDRSMigrations) -and ($SDRSMigrateAge -gt 0)) {
      $Info | Add-Member Noteproperty "Storage DRS Migrations for last $($SDRSMigrateAge) Days" (@($SDRSMigrations).Count)
   }
}

$Info

# Changelog
## 1.1 : Adding some vSphere5 features (Storage Pod, StorageDRS migration)
## 1.2 : Generalised the DRS Event Log Queries for use here and Plugin 17, potentially more efficient if $DRSMigrateAge and $SDRSMigrateAge are equal
## 1.3 : Add Get-vCheckSetting calls
## 1.4 : Changed DRS and SDRS Event Log Queries to be more efficient. Issue #695
