$Title = "NTP Name and Service"
$Header = "NTP Issues: [count]"
$Comments = "The following hosts do not have the correct NTP settings and may cause issues if the time becomes far apart from the vCenter/Domain or other hosts"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# The NTP server which should be set on your hosts (comma-separated)
$ntpserver = "pool.ntp.org,pool2.ntp.org"
# End of Settings

$VMH | Where-Object {$_.Connectionstate -ne "Disconnected"} | Select-Object Name, @{N="NTPServer";E={($_ | Get-VMHostNtpServer) -join ","}}, @{N="ServiceRunning";E={(Get-VmHostService -VMHost $_ | Where-Object {$_.key -eq "ntpd"}).Running}} | Where-Object {$_.ServiceRunning -eq $false -or $_.NTPServer -ne $ntpserver}