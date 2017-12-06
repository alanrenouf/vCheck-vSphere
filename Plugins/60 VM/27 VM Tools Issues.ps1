$Title = "VM Tools Issues"
$Header = "VM Tools Issues: [count]"
$Comments = "The following VMs have issues with VMTools, these should be checked and reinstalled if necessary"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# VM Tools Issues, do not report on any VMs who are defined here
$VMTDoNotInclude = ""
# End of Settings

# Update settings where there is an override
$VMTDoNotInclude = Get-vCheckSetting $Title "VMTDoNotInclude" $VMTDoNotInclude

$FullVM | Where-Object {$_.Name -notmatch $VMTDoNotInclude -and $_.Guest.GuestState -eq "Running" -And ($_.Guest.GuestFullName -eq $NULL -or $_.Guest.IPAddress -eq $NULL -or $_.Guest.HostName -eq $NULL -or $_.Guest.Disk -eq $NULL -or $_.Guest.Net -eq $NULL)} | Select-Object Name, @{N="IPAddress";E={$_.Guest.IPAddress[0]}},@{n="OSFullName";E={$_.Guest.GuestFullName}},@{n="HostName";e={$_.guest.hostname}},@{N="NetworkLabel";E={$_.guest.Net[0].Network}} -ErrorAction SilentlyContinue | Sort-Object Name

# Change Log
## 1.2 : Added Get-vCheckSetting