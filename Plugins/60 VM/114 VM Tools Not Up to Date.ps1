$Title = "VM Tools Not Up to Date"
$Header = "VM Tools Not Up to Date: [count]"
$Display = "Table"
$Author = "Alan Renouf, Shawn Masterson"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# Do not report on any VMs who are defined here (regex)
$VMTDoNotInclude = ""
# Maximum number of VMs shown
$VMTMaxReturn = 30
# End of Settings

# Update settings where there is an override
$VMTDoNotInclude = Get-vCheckSetting $Title "VMTDoNotInclude" $VMTDoNotInclude
$VMTMaxReturn = Get-vCheckSetting $Title "VMTMaxReturn" $VMTMaxReturn

$FullVM | Where-Object {$_.Name -notmatch $VMTDoNotInclude -and ($_.Runtime.Powerstate -eq "poweredOn" -And $_.Guest.toolsStatus -eq "toolsOld")} | `
   Select-Object Name, @{N="Version";E={$_.Guest.ToolsVersion}}, @{N="Status";E={$_.Guest.ToolsStatus}} | Sort-Object Name | Select-Object -First $VMTMaxReturn

$Comments = ("The following VMs are running an older version of Tools than is available on its Host (Max Shown: {0} Exceptions: {1})" -f $VMTMaxReturn, $VMTDoNotInclude)

# Changelog
## 1.0 : Initial Version
## 1.1 : Added Get-vCheckSetting