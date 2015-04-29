# Start of Settings
# Enter maximum vCenter session length in hours
$MaxvCenterSessionAge = 48
# Enter minimum vCenter session length in minutes (IdleMinutes)
$MinvCenterSessionAge = 10
# Do not report on usernames that are defined here (regex)
$vCenterSessionsDoNotInclude = "DOMAIN\\user1|DOMAIN\\user2"
# End of Settings

# Changelog
## 1.0 : Initial Release
## 1.1 : Modified the plug-in to not report active sessions, only report sessions that have been inactive for more than $MinvCenterSessionAge minutes

# Retreive vCenter sessions and report any sessions that exceed the maximum session age
$SessionManager = Get-View $ServiceInstance.Content.SessionManager
$SessionManager.SessionList | `
            Where {$_.LoginTime -lt (Get-Date).AddHours(-$MaxvCenterSessionAge) -AND `
            $_.UserName -notmatch $vCenterSessionsDoNotInclude} | `
            select LoginTime, UserName, FullName, @{N="IdleMinutes";e={([Math]::Round(((Get-Date)-($_.lastActiveTime).ToLocalTime()).TotalMinutes))}} | ` 
            Where {$_.IdleMinutes -ge $MinvCenterSessionAge}

$Title = "vCenter Sessions Age"
$Header = "vCenter Sessions Age Report"
$Comments = "The following displays vCenter sessions that exceed the maximum session age ($MaxvCenterSessionAge Hour(s))."
$Display = "Table"
$Author = "Rudolf Kleijwegt"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
