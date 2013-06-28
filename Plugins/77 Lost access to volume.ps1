# Start of Settings
# Set the number of days of Lost Action Volume to report and count on
$LostAccessVolumeAge = 1
# End of Settings

# Changelog
## 1.1 : Correctly formatted the Start / End Settings and used $MaxSampleVIEvent which is defined in plugin 00

$Result = @(Get-VIEvent -Start ($Date).AddDays(-$LostAccessVolumeAge) -MaxSamples $MaxSampleVIEvent | Where-Object {$_.GetType().Name -eq "EventEx" -and $_.EventTypeId -like "esx.problem.vmfs.heartbeat.*"} | Select-Object -Property @{Name="VMHost";Expression={$_.Host.Name}},CreatedTime,FullFormattedMessage | Sort-Object -Property VMHost,CreatedTime)
$Result

$Title = "Lost access to volume"
$Header = "Lost access to volume: $(@($Result | Where-Object {$_.FullFormattedMessage -like "Lost access to volume *"}).Count)"
$Comments = "The following hosts have lost access to a volume. This may indicate a problem with your storage solution."
$Display = "Table"
$Author = "Robert van den Nieuwendijk, Jonathan Medd"
$PluginVersion = 1.1
$PluginCategory = "vSphere" 