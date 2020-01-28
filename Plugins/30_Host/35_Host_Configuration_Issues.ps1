$Title = "Host Configuration Issues"
$Header = "Host(s) Config Issue(s): [count]"
$Comments = "The following configuration issues have been registered against Hosts in vCenter"
$Display = "Table"
$Author = "Alan Renouf, Dan Barr"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

$hostcialarms = @()
foreach ($HostsView in $HostsViews | Where-Object {$_.Summary.Runtime.ConnectionState -eq 'connected'}) {
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

$hostcialarms | Sort-Object name

# Changelog
## 1.2 : Only check Connected hosts since Disconnected and Not Responding hosts produce an error
