$Title = "Syslog Name"
$Header = "Syslog Issues"
$Comments = "The following hosts do not have the correct Syslog settings which may cause issues if ESXi hosts experience issues and logs need to be investigated"
$Display = "Table"
$Author = "Jonathan Medd, Dan Barr"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# The Syslog server(s) which should be set on your hosts (comma-separated)
$SyslogServer = "udp://syslogserver"
# End of Settings

# Update settings where there is an override
$SyslogServer = Get-vCheckSetting $Title "SyslogServer" $SyslogServer

@($VMH | Where-Object {($_.ExtensionData.Summary.Config.Product.Name -eq 'VMware ESXi') -and ($_.ConnectionState -eq 'Connected')} | Select-Object Name,@{Name='SyslogServer';Expression = {($_ | Get-VMHostSysLogServer).Host}},@{Name='SyslogSetting';Expression = {($_ | Get-AdvancedSetting -Name Syslog.Local.DatastorePath).Value| Where-Object {$_ -ne $NULL}}} | Where-Object {($_.SyslogServer -join ',') -ne $SyslogServer -and $_.SyslogSetting -ne $SyslogServer})

# Change Log
## 1.2 : Added support for multiple (comma-delimited) syslog servers; only report on connected hosts