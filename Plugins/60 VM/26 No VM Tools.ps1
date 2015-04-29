# Start of Settings
# Do not report on any VMs who are defined here (regex)
$VMTDoNotInclude = "VM1_*|VM2_*"
# End of Settings

$Result = @($FullVM | Where {$_.Name -notmatch $VMTDoNotInclude} | Where {$_.Runtime.Powerstate -eq "poweredOn" -And ($_.Guest.toolsStatus -eq "toolsNotInstalled" -Or $_.Guest.ToolsStatus -eq "toolsNotRunning")} | Select Name, @{N="Status";E={$_.Guest.ToolsStatus}})
$Result

$Title = "No VM Tools"
$Header = "No VM Tools: $(@($Result).Count)"
$Comments = "The following VMs have No VMTools installed, for optimal configuration and performance these should be installed"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
