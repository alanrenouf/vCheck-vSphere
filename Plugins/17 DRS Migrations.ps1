# Start of Settings 
# Set the number of days of DRS Migrations to report and count on
$DRSMigrateAge =1
# End of Settings
		
$DRSMigrations = @(Get-VIEvent -maxsamples 10000 -Start ($Date).AddDays(-$DRSMigrateAge ) | where {$_.Gettype().Name -eq "DrsVmMigratedEvent"} | select createdTime, fullFormattedMessage)
$DRSMigrations

$Title = "DRS Migrations"
$Header =  "DRS Migrations (Last $DRSMigrateAge Day(s)) : $(@($DRSMigrations).count)"
$Comments = "Multiple DRS Migrations may be an indication of overloaded hosts, check resouce levels of the cluster"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
