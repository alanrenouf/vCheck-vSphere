# Start of Settings 
# What is the name of the Server Running Active Directory Web Services?
$ADWebServer = "ADserver.domain.local"
# How many days should a computer go without logging in to the Domain before being considered Inactive?
$Inactive = "90"
# End of Settings

if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "Module exists"
} else {
    Import-Module ActiveDirectory
}

$Title = "Initialize AD Plugin"
$Header =  "Initialize AD Plugin"
$Comments = "Set AD variables and import module"
$Display = "List"
$Author = "Eric Shanks"
$Version = 1.0
$PluginCategory = "Active Directory"
