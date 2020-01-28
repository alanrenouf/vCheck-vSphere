$Title = "Host Service Status"
$Header = "Host Service Status"
$Comments = "Check if the Hosts Services works as expected"
$Display = "Table"
$Author = "Felix Longardt"
$PluginVersion = 0.1
$PluginCategory = "vSphere"
# End of Settings

Get-VMHost | Get-VMHostService | Where-Object {($_.Required -match "True" -and $_.Running -notmatch "True") -or ($_.Required -match "False" -and $_.Running -match "True" -and $_.Key -notmatch "vpxa|DCUI|TSM-SSH|lbtd|ntpd|sfcbd-watchdog|TSM|snmpd|vmware-fdm")} | Select VMHost,Key,Label,Policy,Running,Required 
