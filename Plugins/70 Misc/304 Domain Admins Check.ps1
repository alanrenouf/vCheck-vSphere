# Start of Settings 
# End of Settings 

get-adgroupmember -identity "domain admins" -server $ADWebServer | select samaccountname

$Title = "Domain Admins Group"
$Header =  "Domain Admins Group Members"
$Comments = "List Current Domain Admins"
$Display = "Table"
$Author = "Eric Shanks"
$Version = 1.0
$PluginCategory = "Active Directory"