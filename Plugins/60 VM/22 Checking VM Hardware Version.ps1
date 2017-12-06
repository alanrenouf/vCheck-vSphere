$Title = "Checking VM Hardware Version"
$Header = "VMs with old hardware: [count]"
$Comments = "The following VMs are not at the latest hardware version, you may gain performance enhancements if you convert them to the latest version"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# Hardware Version to check for at least
$HWVers = 8
# Adding filter for dsvas, vShield appliances or any other vms that will remain on a lower HW version
$vmIgnore = "vShield*|dsva*"
# End of Settings

# Update settings where there is an override
$HWVers = Get-vCheckSetting $Title "HWVers" $HWVers
$vmIgnore = Get-vCheckSetting $Title "vmIgnore" $vmIgnore

$VM | Where-Object {$_.Name -notmatch $vmIgnore -and [INT]($_.HWVersion)-lt $HWVers} | Select-Object Name, HWVersion

# Change Log
## 1.3 : Added Get-vCheckSetting