# Start of Settings 
# End of Settings

$CBTEnabled = $false

$VMsCBTStatus = @($FullVm | Where-object {$_.Config.ChangeTrackingEnabled -eq $CBTEnabled} | Select-Object Name, @{Name="Change Block Tracking";Expression={if ($_.Config.ChangeTrackingEnabled) { "enabled" } else { "disabled" }}} | Sort Name)
$VMsCBTStatus

$Title = "VM - Display all VMs with CBT not enabled"
$Header = "VM with CBT disabled : $(@($VMsCBTStatus).Count)"
$Comments = "List all VMs with CBT status disabled. It's not a good option for backup!"
$Display = "Table"
$Author = "Cyril Epiney"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
