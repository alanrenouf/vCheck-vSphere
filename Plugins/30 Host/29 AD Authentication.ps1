# Start of Settings
# End of Settings

@($VMH | Where-Object {$_.ExtensionData.Summary.Config.Product.Name -eq 'VMware ESXi'} | Select-Object Name,@{Name='Domain';Expression = {($_ | Get-VMHostAuthentication).Domain}},@{Name='MembershipStatus';Expression = {($_ | Get-VMHostAuthentication).DomainMembershipStatus}},@{Name='AdminGroup';Expression = {($_ | Get-AdvancedSetting -Name "Config.HostAgent.plugins.hostsvc.esxAdminsGroup").Value}})

$PluginCategory = "vSphere"
$Title = "Active Directory Authentication"
$Header = "Active Directory Authentication"
$Comments = "Active Directory configuration and status for each host."
$Display = "Table"
$Author = "Bill Wall"
$PluginVersion = 1.0
