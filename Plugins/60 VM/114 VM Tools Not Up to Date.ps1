# Start of Settings
# Do not report on any VMs who are defined here (regex)
$VMTDoNotInclude = "VM1_*|VM2_*"
# Maximum number of VMs shown
$VMTMaxReturn = 30
# End of Settings


# Changelog
## 1.0 : Initial Version


$Result = @($FullVM | Where {$_.Name -notmatch $VMTDoNotInclude} | Where {$_.Runtime.Powerstate -eq "poweredOn" -And $_.Guest.toolsStatus -eq "toolsOld"} | `
	Select Name, @{N="Version";E={$_.Guest.ToolsVersion}}, @{N="Status";E={$_.Guest.ToolsStatus}})
$Return = $Result | Sort Name | Select -First $VMTMaxReturn
$Return


$Title = "VM Tools Not Up to Date"
$Header = "VM Tools Not Up to Date: $(@($Result).Count)"
$Comments = "The following VMs are running an older version of Tools than is available on its Host (Max Shown: $VMTMaxReturn Exceptions: $VMTDoNotInclude)"
$Display = "Table"
$Author = "Alan Renouf, Shawn Masterson"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
