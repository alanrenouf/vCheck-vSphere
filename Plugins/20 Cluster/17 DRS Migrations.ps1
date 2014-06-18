# Start of Settings 
# End of Settings

# Changelog
## 1.2 : Removed setting $DRSMigrateAge since already specified in Plugin 01. Also added Storage DRS info



$DRSMigrations = @($MigrationQuery1 | Where {$_.Gettype().Name -eq "DrsVmMigratedEvent"} | Select createdTime, fullFormattedMessage)
$SDRSMigrations = @($MigrationQuery2 | Where {$_.FullFormattedMessage -imatch "(Storage vMotion){1}.*(DRS){1}"} | Select createdTime, fullFormattedMessage)

$DRSMigrations
$SDRSMigrations


if ($VIVersion -ge 5) {
    $HeaderText = "DRS Migrations (Last $DRSMigrateAge Day(s)) : $(@($DRSMigrations).count); SDRS Migrations (Last $SDRSMigrateAge Day(s)) : $(@($SDRSMigrations).count)"
}
else {
    $HeaderText = "DRS Migrations (Last $DRSMigrateAge Day(s)) : $(@($DRSMigrations).count)"
}

$Title = "DRS & SDRS Migrations"
$Header = $HeaderText
$Comments = "Multiple DRS Migrations may be an indication of overloaded hosts, check resource levels of the cluster"
$Display = "Table"
$Author = "Alan Renouf, Jonathan Medd"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
