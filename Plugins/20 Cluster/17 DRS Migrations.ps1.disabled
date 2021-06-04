$Title = "DRS & SDRS Migrations"
$Comments = "Multiple DRS Migrations may be an indication of overloaded hosts, check resource levels of the cluster"
$Display = "Table"
$Author = "Alan Renouf, Jonathan Medd"
$PluginVersion = 1.3
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

if (-not $MigrationQuery1) 
{
   if ($DRSMigrateAge -eq $SDRSMigrateAge)
   {
      $MigrationQuery1 = Get-VIEventPlus -Start ($Date).AddDays(-$DRSMigrateAge) -Type Info
   }
   else {
      if ($VIVersion -ge 5) {
         $MigrationQuery1 = Get-VIEventPlus -Start ($Date).AddDays(-$DRSMigrateAge) -Type Info
         $MigrationQuery2 = Get-VIEventPlus -Start ($Date).AddDays(-$SDRSMigrateAge) -Type Info
      }
      else {
         $MigrationQuery1 = Get-VIEventPlus -Start ($Date).AddDays(-$DRSMigrateAge) -Type Info
      }
   }
}

$DRSMigrations = @($MigrationQuery1 | Where-Object {$_.Gettype().Name -eq "DrsVmMigratedEvent"} | Select-Object createdTime, fullFormattedMessage)
$SDRSMigrations = @($MigrationQuery2 | Where-Object {$_.FullFormattedMessage -imatch "(Storage vMotion){1}.*(DRS){1}"} | Select-Object createdTime, fullFormattedMessage)

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