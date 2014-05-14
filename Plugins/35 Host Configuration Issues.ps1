# Start of Settings 
# End of Settings 

$hostcialarms = @()
foreach ($HostsView in $HostsViews) {
	if ($HostsView.ConfigIssue) {           
		$HostConfigIssues = $HostsView.ConfigIssue
		Foreach ($HostConfigIssue in $HostConfigIssues) {
			$Details = "" | Select-Object Name, Message
			$Details.Name = $HostsView.name
			$Details.Message = $HostConfigIssue.FullFormattedMessage
			$hostcialarms += $Details
		}
	}
}

$hostcialarms | sort name

$Title = "Host Configuration Issues"
$Header = "Host(s) Config Issue(s): $(@($hostcialarms).Count)"
$Comments = "The following configuration issues have been registered against Hosts in vCenter"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
