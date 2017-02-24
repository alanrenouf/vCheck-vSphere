$Title = "No VM Tools"
$Header = "No VM Tools: [count]"
$Comments = "The following VMs have No VMTools installed, for optimal configuration and performance these should be installed"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# Do not report on any VMs who are defined here (regex)
$VMTDoNotInclude = ""
# End of Settings

# Update settings where there is an override
$VMTDoNotInclude = Get-vCheckSetting $Title "VMTDoNotInclude" $VMTDoNotInclude

$FullVM | Where-Object {$_.Name -notmatch $VMTDoNotInclude -and $_.Runtime.Powerstate -eq "poweredOn" -And ($_.Guest.toolsStatus -eq "toolsNotInstalled" -Or $_.Guest.ToolsStatus -eq "toolsNotRunning")} | Select-Object Name, @{N="Status";E={$_.Guest.ToolsStatus}}

# Change Log
## 1.2 : Added Get-vCheckSetting