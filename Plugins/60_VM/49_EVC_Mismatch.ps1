# Start of Settings
# End of Settings

# For Each Host
ForEach ($EVCHost in $VMH) {
		## Get cluster EVC mode
		$myHostEVCMode = $EVCHost.Parent.EVCMode

		## Get cluster name
		$myHostEVCCluster = $EVCHost.Parent.Name

		## Get VMs on current host | Filter by Powered On and VM EVC not equal to host EVC | Select VM, Host and Cluster information and concatenate into array 
		Get-VM -Location $EVCHost | Where-Object {($_.PowerState -eq "PoweredOn") -and ($_.ExtensionData.Summary.Runtime.MinRequiredEVCModeKey -ne $myHostEVCMode)} | Select-Object Name,@{Name='VM EVC';Expression = {$_.ExtensionData.Summary.Runtime.MinRequiredEVCModeKey}},@{Name='Host';Expression = {$EVCHost.Name}},@{Name='Host EVC';Expression = {$myHostEVCMode}},@{Name='Cluster';Expression = {$myHostEVCCluster}}
}

$PluginCategory = "vSphere"
$Title = "EVC Mismatch"
$Header = "EVC Mismatch"
$Comments = "List of VMs for which the EVC mode does not match the Host/Cluster. This can negatively impact performance."
$Display = "Table"
$Author = "Bill Wall"
$PluginVersion = 1.0
