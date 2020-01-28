$Title = "Active Directory Authentication"
$Header = "Active Directory Authentication"
$Comments = "Active Directory configuration and status for each host. (Domain: $ADDomainName, Admin Group: $ADAdminGroup, Display all results: $ADDisplayOK)"
$Display = "Table"
$Author = "Bill Wall, Dan Barr"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# Show "OK" results?
$ADDisplayOK = $false
# Expected Domain name
$ADDomainName = "mydomain.local"
# Expected Admin Group
$ADAdminGroup = "ESX Admins"
# End of Settings

#Init arrays
$ADFailedHosts = @()
$ADOKHosts = @()

ForEach ($ADHost in $VMH | Where-Object {$_.Connectionstate -eq "Connected"}) {
	# Get authetication settings
	$myADAuth = $ADHost | Get-VMHostAuthentication
	# Get Admin Group settings
	$myADGroup = ($ADHost | Get-AdvancedSetting -Name "Config.HostAgent.plugins.hostsvc.esxAdminsGroup").Value
	# Build array item
	$myADHost = $ADHost | Select-Object Name,@{Name='Domain';Expression = {$myADAuth.Domain}},@{Name='MembershipStatus';Expression = {$myADAuth.DomainMembershipStatus}},@{Name='AdminGroup';Expression = {$myADGroup}}
	# Iterate tests, a single failure constitues a failure for the unit
	If ($myADAuth.Domain -ne $ADDomainName) {$ADFailedHosts += $myADHost } #Configured domain does not equal expected
	ElseIf ($myADGroup -ne $ADAdminGroup) {$ADFailedHosts += $myADHost} #Configured Admin Group does not equal expected
	ElseIf ($myADAuth.DomainMembershipStatus -ne "OK") {$ADFailedHosts += $myADHost} #Domain Memebership is in doubt
	Else {$ADOKHosts += $myADHost} #Configuration passed all tests
}

# If desired, add OK hosts to display after failed hosts
If ($ADDisplayOK) {$ADFailedHosts += $ADOKHosts}

# Provide output
$ADFailedHosts

# Changelog
## 1.2 : Only check Connected hosts since Disconnected and Not Responding produce empty data
