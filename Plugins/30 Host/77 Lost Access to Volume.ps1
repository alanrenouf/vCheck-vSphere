$Title = "Lost Access to Volume"
$Header = "Lost Access to Volume: [count]"
$Comments = "The following hosts have lost access to a volume. This may indicate a problem with your storage solution."
$Display = "Table"
$Author = "Robert van den Nieuwendijk, Jonathan Medd"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# Set the number of days of Lost Action Volume to report and count on
$LostAccessVolumeAge = 1
# End of Settings

# Update settings where there is an override
$LostAccessVolumeAge = Get-vCheckSetting $Title "LostAccessVolumeAge" $LostAccessVolumeAge

Get-VIEventPlus -Start ($Date).AddDays(-$LostAccessVolumeAge) -EventType "esx.problem.vmfs.heartbeat.unrecoverable","esx.problem.vmfs.heartbeat.timedout","esx.problem.vmfs.heartbeat.corruptondisk" | Where-Object {$_.GetType().Name -eq "EventEx" } | Select-Object -Property @{Name="VMHost";Expression={$_.Host.Name}},CreatedTime,FullFormattedMessage | Sort-Object -Property VMHost,CreatedTime

# Changelog
## 1.1 : Correctly formatted the Start / End Settings and used $MaxSampleVIEvent which is defined in plugin 00
## 1.2 : Update to use Get-VIEventPlus
