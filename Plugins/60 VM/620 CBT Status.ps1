$Title = "VM - Display all VMs with CBT not enabled"
$Header = "VM with CBT disabled: [count]"
$Comments = "List all VMs with CBT status disabled. It's not a good option for backup!"
$Display = "Table"
$Author = "Cyril Epiney"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# Should CBT be enabled (true/false)
$CBTEnabled = $false
# End of Settings

# Update settings where there is an override
$CBTEnabled = Get-vCheckSetting $Title "CBTEnabled" $CBTEnabled

$FullVm | Where-object {$_.Config.ChangeTrackingEnabled -eq $CBTEnabled} | Select-Object Name, @{Name="Change Block Tracking";Expression={if ($_.Config.ChangeTrackingEnabled) { "enabled" } else { "disabled" }}} | Sort-Object Name

# Change Log
## 1.1 : Added Get-vCheckSetting