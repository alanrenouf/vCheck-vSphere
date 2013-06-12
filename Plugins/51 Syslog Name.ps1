$Title = "Syslog Name"
$Header =  "Syslog Issues"
$Comments = "The following hosts do not have the correct Syslog settings which may cause issues if ESXi hosts experience issues and logs need to be investigated"
$Display = "Table"
$Author = "Jonathan Medd"
$PluginVersion = 1.1

# Start of Settings 
# The Syslog server which should be set on your hosts
$SyslogServer ="syslogserver"
# End of Settings

@($VMH | Where-Object {$_.ExtensionData.Summary.Config.Product.Name -eq 'VMware ESXi'} | Select-Object Name,@{Name='SyslogServer';Expression = {($_ | Get-VMHostSysLogServer).Host}} | Where-Object {$_.SyslogServer -ne $syslogserver})
$PluginCategory = "vSphere"
