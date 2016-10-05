# Start of Settings 
# VMs not to report on
$IgnoredVMs = "Windows7*"
# End of Settings

$DecommedVMs = @($VM |
  Where-Object {$_.ExtensionData.Config.ManagedBy.ExtensionKey -ne 'com.vmware.vcDr' -and $_.PowerState -eq "PoweredOff" -and $_.Name -notmatch $IgnoredVMs} |
  Select-Object -Property Name, LastPoweredOffDate, Folder, Notes |
  Sort-Object -Property LastPoweredOffDate)
$DecommedVMs

$Title = "Powered Off VMs"
$Header = "VMs Powered Off - Number of Days"
$Comments = "May want to consider deleting VMs that have been powered off for more than 30 days"
$Display = "Table"
$Author = "Adam Schwartzberg"
$PluginVersion = 1.3
$PluginCategory = "vSphere"
