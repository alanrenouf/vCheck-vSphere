$Title = "Users and Permissions"
# 1.1 - add unique to work with multiple vcenters inside the same sso-domain
$Header = "Users and Permissions"
# End of Settings
$Title = "Users and Permissions"
$Header = "Users and Permissions"
$Display = "Table"
$Author = "Felix Longardt"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

$BlacklistUser = "vsphere-webclient-2571922f-2b1d-sdfsad2-bc1c-e125dba3a11d","vpxd-extension-2571asdfdf2b1d-4402-bc1c-e125dba3a11d","vpxd-2571922f-2b1dfasdf02-bc1c-e125dba3a11d","vpxd-46sdfsadfasd6f608ff-cb37-4d8a-ac3a-68754da88231","vpxd-extension-46660adsf8ff-cb37-4d8a-ac3a-6sdf8754da88231"
# i.e. $BlacklistUser = "vpxd-2222922f-222d-2222-222c","vpxd-extension-2522222f-222d-4222-b222","vsphere-webclient-uzitrz8t"
$BlacklistDomain = ""
# i.e. BlacklistDomain = "VSPHERE.LOCAL"
$BlacklistRole = ""
# i.e. $BlacklistRole = "Admin"
$BlacklistObject = ""
# i.e. $BlacklistObject = "Datacenters"

Get-VIPermission | Select-Object Principal, Role, Propagate, IsGroup, Entity | Where {$_.IsGroup -match "False"} | Select-Object @{N="User";E={($_.Principal.split("\"))[1]}}, @{N="Domain";E={($_.Principal.split("\"))[0]}}, Role,  @{N="Propagate to Child";E={($_.Propagate)}}, @{N="Object";E={($_.Entity)}} -unique | Where {$_.User -notin $BlacklistUser -and $_.Domain -notin $BlacklistDomain -and $_.Role -notin $BlacklistRole -and $_.Object -notin $BlacklistObject} | Sort-Object User 

$Comments = ("The following gives brief about configured Users")

# Change Log
# 1.0 - Initiale Version
# 1.1 - add unique to work with multiple vcenters inside the same sso-domain
