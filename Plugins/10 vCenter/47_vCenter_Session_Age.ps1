$Title = "vCenter Sessions Age"
$Header = "vCenter Sessions Age Report"
$Display = "Table"
$Author = "Rudolf Kleijwegt"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings
# Enter maximum vCenter session length in hours
$MaxvCenterSessionAge = 48
# Enter minimum vCenter session length in minutes (IdleMinutes)
$MinvCenterSessionAge = 10
# Do not report on usernames that are defined here (regex)
$vCenterSessionsDoNotInclude = "DOMAIN\\user1|DOMAIN\\user2"
# End of Settings

# Update settings where there is an override
$MaxvCenterSessionAge = Get-vCheckSetting $Title "MaxvCenterSessionAge" $MaxvCenterSessionAge
$MinvCenterSessionAge = Get-vCheckSetting $Title "MinvCenterSessionAge" $MinvCenterSessionAge
$vCenterSessionsDoNotInclude = Get-vCheckSetting $Title "vCenterSessionsDoNotInclude" $vCenterSessionsDoNotInclude

# Retrieve vCenter sessions and report any sessions that exceed the maximum session age

(Get-View $ServiceInstance.Content.SessionManager).SessionList | `
   Where-Object {$_.LoginTime -lt (Get-Date).AddHours(-$MaxvCenterSessionAge) -AND `
   $_.UserName -notmatch $vCenterSessionsDoNotInclude} | `
   Select-Object LoginTime, UserName, FullName, @{N="IdleMinutes";e={([Math]::Round(((Get-Date)-($_.lastActiveTime).ToLocalTime()).TotalMinutes))}} | ` 
   Where-Object {$_.IdleMinutes -ge $MinvCenterSessionAge}

$Comments = "The following displays vCenter sessions that exceed the maximum session age ($MaxvCenterSessionAge Hour(s))."

# Changelog
## 1.0 : Initial Release
## 1.1 : Modified the plug-in to not report active sessions, only report sessions that have been inactive for more than $MinvCenterSessionAge minutes
## 1.2 : Updated to use Get-vCheckSetting