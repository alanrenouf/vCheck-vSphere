# Start of Settings
# List of VMs for which the EVC mode does not match the Host/Cluster, do not report on any VMs who are defined here
$ExcludeVMs = "Guest Introspection|ExcludeMe"
# End of Settings

# For Each Host
ForEach ($EVCHost in $VMH) {
		## Get cluster EVC mode
		$myHostEVCMode = $EVCHost.Parent.EVCMode

		## Get cluster name
		$myHostEVCCluster = $EVCHost.Parent.Name

		## Get VMs on current host | Filter by Powered On and VM EVC not equal to host EVC | Select VM, Host and Cluster information and concatenate into array 
		Get-VM -Location $EVCHost | Where-Object {$_.Name -in $VM.Name} | Where-Object {$_.Name -notmatch $ExcludeVMs} | Where-Object {($_.PowerState -eq "PoweredOn") -and ($_.ExtensionData.Summary.Runtime.MinRequiredEVCModeKey -ne $myHostEVCMode)} | Select-Object Name,@{Name='VM EVC';Expression = {$_.ExtensionData.Summary.Runtime.MinRequiredEVCModeKey}},@{Name='Host';Expression = {$EVCHost.Name}},@{Name='Host EVC';Expression = {$myHostEVCMode}},@{Name='Cluster';Expression = {$myHostEVCCluster}}
}

$PluginCategory = "vSphere"
$Title = "EVC Mismatch"
$Header = "EVC Mismatch"
$Comments = "List of VMs for which the EVC mode does not match the Host/Cluster. This can negatively impact performance."
$Display = "Table"
$Author = "Bill Wall"
$PluginVersion = 1.1

# ChangeLog
## 1.1 : Added VM exclusion option because some silly companies (like VMware) can't seem to get their EAM appliances to match current EVC.
