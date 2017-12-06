$Title = "Single Storage VMs"
$Header = "VMs stored on non shared datastores: [count]"
$Comments = "The following VMs are located on storage which is only accessible by 1 host, these will not be compatible with vMotion and may be disconnected in the event of host failure"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin, Dan Barr"
$PluginVersion = 1.5
$PluginCategory = "vSphere"

# Start of Settings 
# Local Stored VMs, do not report on any VMs who are defined here
$LVMDoNotInclude = "Template_*|VDI*"
# Local Datastores, do not report on any VMs within these datastores
$LDSDoNotInclude = "Local|datastore1"
# End of Settings

# Update settings where there is an override
$LVMDoNotInclude = Get-vCheckSetting $Title "LVMDoNotInclude" $LVMDoNotInclude
$LDSDoNotInclude = Get-vCheckSetting $Title "LDSDoNotInclude" $LDSDoNotInclude

$unSharedDatastore = $storageviews | Where-Object {$_.Name -notmatch $LDSDoNotInclude -and -not $_.summary.multiplehostaccess} | Select-Object -Expand Name

$FullVM | Where-Object {$_.Name -notmatch $LVMDoNotInclude} | Where-Object {$_.Runtime.ConnectionState -notmatch "invalid|orphaned"} | Foreach-Object {$_.layoutex.file} | Where-Object {$_.type -ne "log" -and $_.name -notmatch ".vswp$" -And $unSharedDatastore -contains $_.name.Split(']')[0].Split('[')[1]} | Select-Object Name

# Change Log
## 1.4 : Added Get-vCheckSetting
## 1.5 : Added setting for datastores to exclude in addition to VM names