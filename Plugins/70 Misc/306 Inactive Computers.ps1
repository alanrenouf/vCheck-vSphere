# Start of Settings 
# End of Settings 

$days = (get-date).addDays(0-$inactive)

get-adcomputer -filter 'Passwordlastset -lt $days' -properties *| Select name,passwordlastset

$Title = "Inactive Computers"
$Header =  "Computers inactive"
$Comments = "List Computers inactive for $days"
$Display = "Table"
$Author = "Eric Shanks"
$Version = 1.0
$PluginCategory = "Active Directory"