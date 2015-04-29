# Start of Settings 
# Set the number of days of DRS Migrations to report and count on
$DRSMigrateAge = 1
# Set the number of days of Storage DRS Migrations to report and count on
$SDRSMigrateAge = 1
# End of Settings

# Changelog
## 1.1 : Adding some vSphere5 features (Storage Pod, StorageDRS migration)
## 1.2 : Generalised the DRS Event Log Queries for use here and Plugin 17, potentially more efficient if $DRSMigrateAge and $SDRSMigrateAge are equal

if ($DRSMigrateAge -eq $SDRSMigrateAge){
    $MigrationQuery1 = Get-VIEvent -MaxSamples $MaxSampleVIEvent -Start ($Date).AddDays(-$DRSMigrateAge) -Type Info
}

else {
    if ($VIVersion -ge 5) {
        $MigrationQuery1 = Get-VIEvent -MaxSamples $MaxSampleVIEvent -Start ($Date).AddDays(-$DRSMigrateAge) -Type Info
        $MigrationQuery2 = Get-VIEvent -MaxSamples $MaxSampleVIEvent -Start ($Date).AddDays(-$SDRSMigrateAge) -Type Info
    }
    else {
        $MigrationQuery1 = Get-VIEvent -MaxSamples $MaxSampleVIEvent -Start ($Date).AddDays(-$DRSMigrateAge) -Type Info
    }
}

$Info = New-Object -TypeName PSObject -Property @{
	"Number of Hosts" = (@($VMH).Count)
	"Number of VMs" = (@($VM).Count)
	"Number of Templates" = (@($VMTmpl).Count)
	"Number of Clusters" = (@($Clusters).Count)
	"Number of Datastores" = (@($Datastores).Count)
	"Active VMs" = (@($FullVM | Where { $_.Runtime.PowerState -eq "poweredOn" }).Count) 
	"In-active VMs" = (@($FullVM | Where { $_.Runtime.PowerState -eq "poweredOff" }).Count)
}

# Don't display DRS line if 0 days are set
if ($DRSMigrateAge -gt 0) {
	$Info | Add-Member Noteproperty "DRS Migrations for last $($DRSMigrateAge) Days" (@($MigrationQuery1 | Where {$_.GetType().Name -eq "DrsVmMigratedEvent"}).Count)
}

# Adding vSphere 5 informations
if ($VIVersion -ge 5) {
	$Info | Add-Member Noteproperty "Number of Datastore Clusters" $(@($DatastoreClustersView).Count)
	if ($SDRSMigrateAge -gt 0) {
		$Info | Add-Member Noteproperty "Storage DRS Migrations for last $($SDRSMigrateAge) Days" (@($MigrationQuery2 | Where {$_.FullFormattedMessage -imatch "(Storage vMotion){1}.*(DRS){1}"}).Count)
	}
}

$Info

$Title = "General Information"
$Header =  "General Information"
$Comments = "General details on the infrastructure"
$Display = "List"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

