# Start of Settings

$StartDate = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-1)
$MaxSamples = [int]::MaxValue

# End of Settings

$Result = @(Get-VIEvent -Start $StartDate -MaxSamples $MaxSamples | Where-Object {$_.GetType().Name -eq "EventEx" -and $_.EventTypeId -like "esx.problem.vmfs.heartbeat.*"} | Select-Object -Property @{Name="VMHost";Expression={$_.Host.Name}},CreatedTime,FullFormattedMessage | Sort-Object -Property VMHost,CreatedTime)
$Result

$Title = "Lost access to volume"
$Header = "Lost access to volume: $(@($Result | Where-Object {$_.FullFormattedMessage -like "Lost access to volume *"}).Count)"
$Comments = "The following hosts have lost access to a volume. This may indicate a problem with your storage solution."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.0
$PluginCategory = "vSphere" 