# Start of Settings 
# Local Stored VMs, do not report on any VMs who are defined here
$LVMDoNotInclude = "Template_*|VDI*"
# End of Settings

$unSharedDatastore = $storageviews | ?{-Not $_.summary.multiplehostaccess} | Select Name

$Result = $FullVM | ?{$_.Name -notmatch $LVMDoNotInclude} | ?{$_.Runtime.ConnectionState -notmatch "invalid|orphaned"} | %{$_.layoutex.file} | ?{$_.type -ne "log" -and $_.name -notmatch ".vswp$" -And $unSharedDatastore -contains $_.name.Split(']')[0].Split('[')[1]} | Select Name
$Result

$Title = "Single Storage VMs"
$Header =  "VMs stored on non shared datastores: $(@($Result).Count)"
$Comments = "The following VMs are located on storage which is only accesible by 1 host, these will not be compatible with VMotion and may be disconnected in the event of host failure"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
