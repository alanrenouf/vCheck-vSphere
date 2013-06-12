# Start of Settings 
# VMs not to report on
$IgnoredVMs ="Windows7*"
# End of Settings

$DecommedVMs = ($VM | Where { $_.PowerState -eq "PoweredOff"} | Where {$_.Name -notmatch $IgnoredVMs} | Select Name, LastPoweredOffDate) | Sort-Object -Property LastPoweredOffDate
$DecommedVMs

$Title = "Powered Off VMs"
$Header =  "VMs Powered Off - Number Of Days"
$Comments = "May want to consider deleting VMs that have been powered off for more than 30 days"
$Display = "Table"
$Author = "Adam Schwartzberg"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
