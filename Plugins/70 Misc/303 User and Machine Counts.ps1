# Start of Settings 
# End of Settings

$useraccount = (get-aduser -filter * -server $ADWebServer |where{$_.enabled}).count
$ComputerAccount = (get-adcomputer -filter * -server $ADWebServer |where{$_.enabled}).count

 $obj = New-Object PSObject -Property @{
  Useraccounts = $useraccount
  computeraccounts = $ComputerAccount
  }
 $obj

$Title = "Active User and Machine Counts"
$Header =  "Active User and Machine Counts"
$Comments = "Count Users and Machines in Active Directory"
$Display = "Table"
$Author = "Eric Shanks"
$Version = 1.0
$PluginCategory = "Active Directory"