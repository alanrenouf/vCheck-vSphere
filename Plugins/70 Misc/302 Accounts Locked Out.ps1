

# Start of Settings 
# End of Settings 

Search-ADAccount -LockedOut -server $ADWebServer

$Title = "Locked Out Accounts"
$Header =  "Locked Out Accounts"
$Comments = "List locked out accounts"
$Display = "Table"
$Author = "Eric Shanks"
$Version = 1.0
$PluginCategory = "Active Directory"