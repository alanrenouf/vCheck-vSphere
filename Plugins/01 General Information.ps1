# Start of Settings 
# Set the number of days of DRS Migrations to report and count on
$DRSMigrateAge = 1
# Set the number of days of Storage DRS Migrations to report and count on
$SDRSMigrateAge = 1
# End of Settings

# Changelog
## 1.1 : Adding some vSphere5 features (Storage Pod, StorageDRS migration)

$Info = New-Object -TypeName PSObject -Property @{
	"Number of Hosts:" = (@($VMH).Count)
	"Number of VMs:" = (@($VM).Count)
	"Number of Templates:" = (@($VMTmpl).Count)
	"Number of Clusters:" = (@($Clusters).Count)
	"Number of Datastores:" = (@($Datastores).Count)
	"Active VMs:" = (@($FullVM | Where { $_.Runtime.PowerState -eq "poweredOn" }).Count) 
	"In-active VMs:" = (@($FullVM | Where { $_.Runtime.PowerState -eq "poweredOff" }).Count)
	"DRS Migrations for last $($DRSMigrateAge) Days:" = (@(Get-VIEvent -maxsamples $MaxSampleVIEvent -Start ($Date).AddDays(-$DRSMigrateAge) -Type Info | Where {$_.GetType().Name -eq "DrsVmMigratedEvent"}).Count)
}

# Adding vSphere 5 informations
if ($VIVersion -ge 5) {
	$Info | Add-Member Noteproperty "Number of Datastore Clusters:" $(@($DatastoreClustersView).Count)
	$Info | Add-Member Noteproperty "Storage DRS Migrations for last $($SDRSMigrateAge) Days:" (@(Get-VIEvent -maxsamples $MaxSampleVIEvent -Start ($Date).AddDays(-$SDRSMigrateAge) -Type Info | Where {$_.FullFormattedMessage -imatch "(Storage vMotion){1}.*(DRS){1}"}).Count)
}

$Info

$Title = "General Information"
$Header =  "General Information"
$Comments = "General details on the infrastructure"
$Display = "List"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
