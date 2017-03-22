# Start of Settings 
# End of Settings 

get-aduser -filter {PasswordNeverExpires -eq $True -AND Enabled -eq $True} -server $ADWebServer | Select name

$Title = "Passwords that don't Expire"
$Header =  "Passwords that don't Expire"
$Comments = "List accounts with non-expiring passwords"
$Display = "Table"
$Author = "Eric Shanks"
$Version = 1.0
$PluginCategory = "Active Directory"

