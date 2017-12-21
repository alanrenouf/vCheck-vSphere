$Title = "Powered Off VMs"
$Header = "VMs Powered Off - Number of Days"
$Display = "Table"
$Author = "Adam Schwartzberg"
$PluginVersion = 1.5
$PluginCategory = "vSphere"

# Start of Settings 
# VMs not to report on
$IgnoredVMs = "Windows7*"
#VmPathName not to report on
$IgnoredVMpath = "-backup-"
# Report VMs powered off over this many days
$PoweredOffDays = 7
# End of Settings

# Update settings where there is an override
$IgnoredVMs = Get-vCheckSetting $Title "IgnoredVMs" $IgnoredVMs
$IgnoredVMpath = Get-vCheckSetting $Title "IgnoredVMpath" $IgnoredVMpath
$PoweredOffDays = Get-vCheckSetting $Title "PoweredOffDays" $PoweredOffDays

$VM | Where-Object {$_.ExtensionData.Config.ManagedBy.ExtensionKey -ne 'com.vmware.vcDr' -and 
                $_.PowerState -eq "PoweredOff" -and 
                $_.LastPoweredOffDate -lt $date.AddDays(-$PoweredOffDays) -and
                $_.Name -notmatch $IgnoredVMs -and 
                $_.ExtensionData.Config.Files.VmPathName -notmatch $IgnoredVMpath} |
  Select-Object -Property Name, LastPoweredOffDate, @{l = 'Folder'; e = {$_.Folder.Name}}, Notes |
  Sort-Object -Property LastPoweredOffDate

$Comments = ("May want to consider deleting VMs that have been powered off for more than {0} days" -f $PoweredOffDays)

# Change Log 
## 1.4 : Added Get-vCheckSetting, $PoweredOffDays 
## 1.5 : Select-Object now returns Folder as a string; Added IgnoredVMpath