$Title = "Eval License Keys"
$Comments = "The following hosts are using an evaluation key that will expire, causing them to disconnect from vCenter."
$Display = "Table"
$Author = "Doug Taliaferro"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

$hostResults = @()
foreach ($esxhost in ($VMH | where {$_.ConnectionState -match "Connected|Maintenance"})) {
    if ($esxhost.LicenseKey -eq "00000-00000-00000-00000-00000") {
        $myObj = "" | Select VMHost, LicenseKey
        $myObj.VMHost = $esxhost.Name
        $myObj.LicenseKey = $esxhost.LicenseKey
        $hostResults += $myObj
	}
}
$hostResults

$Header = "Hosts using an Evaluation Key : [count]"