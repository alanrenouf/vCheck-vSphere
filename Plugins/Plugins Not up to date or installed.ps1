# Start of Settings 
# If you use a proxy to access the internet please specify the proxy address here, for example http://127.0.0.1:3128 else use $false 
$proxy ="$false"
# End of Settings

# Changelog
## 1.1 : Adding proxy support for Get-vCheckPlugin cmdlet
## 1.2 : Added support for only vSphere plugins

. $ScriptPath\vcheckutils.ps1 | Out-Null
if ($proxy -eq "$false"){
	$NotInstalled = Get-vCheckPlugin -NotInstalled | Where { $_.Category -eq "vSphere" } | Select Name, version, Status, Description
} else {
	$NotInstalled = Get-vCheckPlugin -NotInstalled -Proxy $proxy | Where { $_.Category -eq "vSphere" } | Select Name, version, Status, Description
}
$NotInstalled

$Title = "Plugins not up to date or not installed"
$Header =  "Plugins not up to date or not installed: $(@($NotInstalled).count)"
$Comments = "The following Plugins are not up to date or not installed"
$Display = "Table"
$Author = "Alan Renouf, Jake Robinson, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vCheck"
