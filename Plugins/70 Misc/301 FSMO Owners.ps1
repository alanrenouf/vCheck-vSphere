# Start of Settings 
# End of Settings 


Function Get-FSMORoleHolders {            

 $Domain = Get-ADDomain -server $ADWebServer
 $Forest = Get-ADForest -server $ADWebServer            

 $obj = New-Object PSObject -Property @{
  PDC = $domain.PDCEmulator
  RID = $Domain.RIDMaster
  Infrastructure = $Domain.InfrastructureMaster
  Schema = $Forest.SchemaMaster
  DomainNaming = $Forest.DomainNamingMaster
  }
 $obj            

 }
Get-FSMORoleHolders

$Title = "FSMO Owners"
$Header =  "FSMO Owners"
$Comments = "Print Current Flexible Single Master Operator Owners"
$Display = "table"
$Author = "Eric Shanks"
$Version = 1.0
$PluginCategory = "Active Directory"