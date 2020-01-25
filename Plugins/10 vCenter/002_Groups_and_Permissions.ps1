$Title = "Groups and Permissions"
# 1.1 - add unique to work with multiple vcenters inside the same sso-domain
$Header = "Groups and Permissions"
# End of Settings
$Title = "Groups and Permissions"
$Header = "Groups and Permissions"
$Display = "Table"
$Author = "Felix Longardt"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

$BlacklistGroup = ""
# i.e. $BlacklistGroup = "Administrators","VMUsers"
$BlacklistDomain = ""
# i.e. BlacklistDomain = "VSPHERE.LOCAL"
$BlacklistRole = ""
# i.e. $BlacklistRole = "Admin"
$BlacklistObject = ""
# i.e. $BlacklistObject = "Datacenters"

Get-VIPermission | Select-Object Principal, Role, Propagate, IsGroup, Entity | Where {$_.IsGroup -match "True"} | Select-Object @{N="Group";E={($_.Principal.split("\"))[1]}}, @{N="Domain";E={($_.Principal.split("\"))[0]}}, Role,  @{N="Propagate to Child";E={($_.Propagate)}}, @{N="Object";E={($_.Entity)}} -unique | Where {$_.Group -notin $BlacklistGroup -and $_.Domain -notin $BlacklistDomain -and $_.Role -notin $BlacklistRole -and $_.Object -notin $BlacklistObject} | Sort-Object Group


$Comments = ("The following gives brief about configured User Groups")

# Change Log
# 1.0 - Initiale Version
# 1.1 - add unique to work with multiple vcenters inside the same sso-domain
