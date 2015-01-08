# Start of Settings
# Enter maximum vCenter session length in hours
$MaxvCenterSessionAge = 48
# Do not report on usernames that are defined here (regex)
$vCenterSessionsDoNotInclude = "DOMAIN\\user1|DOMAIN\\user2"
# End of Settings

# Changelog
## 1.0 : Initial Release

# Retreive vCenter sessions and report any sessions that exceed the maximum session age
if ($VIConnection.IsConnected) {
 $Result = @(
  $ServiceInstance = Get-View ServiceInstance
  $SessionManager = Get-View $ServiceInstance.Content.SessionManager
  $SessionManager.SessionList | ?{$_.LoginTime -lt (Get-Date).AddHours(-$MaxvCenterSessionAge) -AND $_.UserName -notmatch $vCenterSessionsDoNotInclude} | select LoginTime, UserName, FullName, @{N="IdleMinutes";e={([Math]::Round(((Get-Date)-($_.lastActiveTime).ToLocalTime()).TotalMinutes))}}
 )
 $Return = $Result | Sort LoginTime
 $Return
}
else {
	Write-Error $pLang.connError
}

$Title = "vCenter Sessions Age"
$Header = "vCenter Sessions Age Report"
$Comments = "The following displays vCenter sessions that exceed the maximum session age ($MaxvCenterSessionAge Hour(s))."
$Display = "Table"
$Author = "Rudolf Kleijwegt"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
