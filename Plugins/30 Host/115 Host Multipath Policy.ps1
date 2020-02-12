$Title = "Host Multipath Policy"
$Comments = "See the Storage/SAN section of the <a href='https://www.vmware.com/resources/compatibility/search.php?deviceCategory=san' target='_blank'>VMware Compatibility Guide</a> or your array/storage vendor's documentation for the supported/recommended policy."
$Display = "Table"
$Author = "Doug Taliaferro, Bill Wall"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# The Multipath Policy (PSP Plugin) your hosts should be configured to use
$MultipathPolicy = "VMW_PSP_RR"
# End of Settings

# Update settings where there is an override
$MultipathPolicy = Get-vCheckSetting $Title "MultipathPolicy" $MultipathPolicy

$lunResults = @()
Foreach ($esxhost in ($HostsViews | Where-Object {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {
    $esxhost | ForEach-Object {$_.config.storageDevice.multipathInfo.lun} | Where-Object {$_.path.count -gt 1 } | Where-Object {$_.policy.policy -notmatch $MultipathPolicy} | ForEach-Object {
        $myObj = "" | Select-Object VMHost, LunID, Policy
        $myObj.VMHost = $esxhost.Name
        $myObj.LunID = $_.ID
        $myObj.Policy = $_.Policy.policy
        $lunResults += $myObj
    }
}

$lunResults

$Header = "Hosts/LUNs not using Multipath Policy '$($MultipathPolicy)' : [count]"


# Changelog
## 1.1 : Added check for Maintenance mode VMHs.
