# Start of Settings 
# End of Settings 

# Using enterpriseadmins.org modified code
$HostOSVers = @{}
$HostsViews | % {
	$HostOSVer = $_.Summary.Config.product.fullName
	$HostOSVers.$HostOSVer++
}

$myCol = @()
foreach ( $hosname in $HostOSVers.Keys | sort) {
	$MyDetails = "" | select OS, Count
	$MyDetails.OS = $hosname
	$MyDetails.Count = $HostOSVers.$hosname
	$myCol += $MyDetails
}

$myCol | sort Count -desc

$Title = "Host Build versions in use"
$Header = "Host Build versions in use"
$Comments = "The following host builds are in use in this vCenter"
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
