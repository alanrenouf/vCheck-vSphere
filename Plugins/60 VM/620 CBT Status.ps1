# Start of Settings 
# Should CBT be enabled (true/false)
$CBTEnabled = $false
# End of Settings

# Update settings where there is an override
$CBTEnabled = Get-vCheckSetting $Title "CBTEnabled" $CBTEnabled

$FullVm | Where-object {$_.Config.ChangeTrackingEnabled -ne $CBTEnabled} | Select-Object Name, @{Name="Change Block Tracking";Expression={if ($_.Config.ChangeTrackingEnabled) { "enabled" } else { "disabled" }}} | Sort-Object Name

if ($CBTEnabled)
{
   $Header = "VM with CBT disabled: [count]"
   $Comments = "List all VMs with CBT status disabled. It's not a good option for backup!"
}
else
{
   $Header = "VM with CBT enabled: [count]"
   $Comments = "List all VMs with CBT status enabled."
}

$Title = "VM - Display all VMs with CBT unexpected status"
$Display = "Table"
$Author = "Cyril Epiney"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Change Log
## 1.1 : Added Get-vCheckSetting
