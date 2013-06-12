# Start of Settings 
# Hardware Version to check for at least
$HWVers =8
# End of Settings

$HWver = @($VM | Select Name, HWVersion | Where {[INT]($_.HWVersion).ToString() -lt $HWVers})
$HWVer				

$Title = "Checking VM Hardware Version"
$Header =  "VMs with old hardware: $(@($HWVer).Count)"
$Comments = "The following VMs are not at the latest hardware version, you may gain performance enhancements if you convert them to the latest version"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
