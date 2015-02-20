# Start of Settings 
# Hardware Version to check for at least
$HWVers = 8
#Adding filter for dsvas, vShield appliances or any other vms that will remain on a lower HW version
$vmIgnore = "vShield*|dsva*"
# End of Settings

$HWver = @($VM | Where-Object {$_.Name -notmatch $vmIgnore} | Select-Object Name, HWVersion | Where-Object {[INT]($_.HWVersion).ToString() -lt $HWVers})
$HWVer				

$Title = "Checking VM Hardware Version"
$Header = "VMs with old hardware: $(@($HWVer).Count)"
$Comments = "The following VMs are not at the latest hardware version, you may gain performance enhancements if you convert them to the latest version"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
