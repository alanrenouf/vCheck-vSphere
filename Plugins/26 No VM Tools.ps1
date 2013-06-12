# Start of Settings 
# End of Settings 

$Result = @($FullVM | Where {$_.Runtime.Powerstate -eq "poweredOn" -And ($_.Guest.toolsStatus -eq "toolsNotInstalled" -Or $_.Guest.ToolsStatus -eq "toolsNotRunning")} | Select Name, @{N="Status";E={$_.Guest.ToolsStatus}})
$Result

$Title = "NO VM Tools"
$Header =  "NO VM Tools: $(@($Result).Count)"
$Comments = "The following VMs have No VMTools installed, for optimal configuration and performance these should be installed"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
