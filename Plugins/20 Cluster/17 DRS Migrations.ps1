$Title = "DRS & SDRS Migrations"
$Comments = "Multiple DRS Migrations may be an indication of overloaded hosts, check resource levels of the cluster"
$Display = "Table"
$Author = "Alan Renouf, Jonathan Medd"
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

if (-not $DRSMigrations) {
   $DRSMigrations = Get-VIEventPlus -Start $Date.AddDays(-$DRSMigrateAge) -EventType 'DrsVmMigratedEvent' | Select-Object CreatedTime, FullFormattedMessage
}
if ($VIVersion -ge 5 -and -not $SDRSMigrations) {
   $StorageDRSQuery = Get-VIEventPlus -Start $Date.AddDays(-$SDRSMigrateAge) -EventType 'com.vmware.vc.sdrs.StorageDrsStoragePlacementEvent'
   $SDRSMigrations = ForEach ($Event in $StorageDRSQuery) {
      New-Object -TypeName PSObject -Property @{
         'CreatedTime' = $Event.CreatedTime
         'FullFormattedMessage' = "SDRS migrated $($Event.Arguments.Value[0]) to $($Event.Arguments.Value[2]) in datastore cluster $($Event.ObjectName)."
      }
   }
}

$DRSMigrations
$SDRSMigrations

if ($VIVersion -ge 5) {
    $HeaderText = "DRS Migrations (Last $DRSMigrateAge Day(s)) : $(@($DRSMigrations).count); SDRS Migrations (Last $SDRSMigrateAge Day(s)) : $(@($SDRSMigrations).count)"
}
else {
    $HeaderText = "DRS Migrations (Last $DRSMigrateAge Day(s)) : $(@($DRSMigrations).count)"
}

$Header = $HeaderText

# Changelog
## 1.2 : Removed setting $DRSMigrateAge since already specified in Plugin 01. Also added Storage DRS info
## 1.3 : Added $MigrationQuery# section in case General Info plugin is disabled. Issue #285
## 1.4 : Changed DRS and SDRS Event Log Queries to be more efficient. Issue #695