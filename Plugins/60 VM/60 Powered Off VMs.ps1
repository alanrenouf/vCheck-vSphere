# Start of Settings 
# VMs not to report on
$IgnoredVMs = "Windows7*"
# Secondary filter accounts for a case like internal self-service VMs that autodelete.  They are not deleted until X days after power off so they aren't breaking policy until then.
$SecondaryFilter = $true
$ExcludeCluster = "Bed-QADev-UCS-06|Bed-QADev-UCS-07"
  # AND
$ExcludeDaysOlderThan = 15
# End of Settings

$DecommedVMs = @($VM |
  Where-Object {$_.ExtensionData.Config.ManagedBy.ExtensionKey -ne 'com.vmware.vcDr' -and $_.PowerState -eq "PoweredOff" -and $_.Name -notmatch $IgnoredVMs} |
  Select-Object -Property Name, LastPoweredOffDate, @{n='DaysPoweredOff';e={((Get-Date) - ($_).LastPoweredOffDate).Days}}, Folder, @{n='Cluster';e={$_.VMHost.Parent.Name}}, Notes, CustomFields |
  Sort-Object -Property LastPoweredOffDate)

If ($SecondaryFilter) {
	$ExcludedVMs = $DecommedVMs | Where-Object { ($_.Cluster -match $ExcludeCluster ) -and ( ($_.DaysPoweredOff -lt $ExcludeDaysOlderThan) -and ($_.DaysPoweredOff -ne $null) ) }
	$DecommedVMs = $DecommedVMs | ? { $ExcludedVMs -notcontains $_ }
}

$DecommedVMs

$Title = "Powered Off VMs"
$Header = "VMs Powered Off - Number of Days"
$Comments = "May want to consider deleting VMs that have been powered off for more than 30 days"
$Display = "Table"
$Author = "Adam Schwartzberg"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# 20150623 monahancj- Added more output fields so there will be fewer times going to vCenter to look up VM background information.  Added additional filtering for powered off VMs that are within a policy.
