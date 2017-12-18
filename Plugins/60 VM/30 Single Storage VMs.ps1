$Title = "Single Storage VMs"
$Header = "VMs stored on non shared datastores: [count]"
$Comments = "The following VMs are located on storage which is only accessible by 1 host, these will not be compatible with vMotion and may be disconnected in the event of host failure"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# Local Stored VMs, do not report on any VMs who are defined here
$LVMDoNotInclude = "Template_*|VDI*"
# End of Settings

# Update settings where there is an override
$LVMDoNotInclude = Get-vCheckSetting $Title "LVMDoNotInclude" $LVMDoNotInclude

$unSharedDatastore = $storageviews | Where-Object {-Not $_.summary.multiplehostaccess} | Select-Object -Expand Name

$FullVM | Where-Object {$_.Name -notmatch $LVMDoNotInclude} | Where-Object {$_.Runtime.ConnectionState -notmatch "invalid|orphaned"} | Foreach-Object {$_.layoutex.file} | Where-Object {$_.type -ne "log" -and $_.name -notmatch ".vswp$" -And $unSharedDatastore -contains $_.name.Split(']')[0].Split('[')[1]} | Select-Object Name

# Change Log
## 1.4 : Added Get-vCheckSetting