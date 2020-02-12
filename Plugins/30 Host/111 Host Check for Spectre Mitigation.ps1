# Start of Settings 
# End of Settings 

$vmhosts = Get-View -ViewType HostSystem -Property Name,Config.FeatureCapability

$result = @()
foreach ($vmhost in $vmhosts | Sort-Object -Property Name) {
    $vmhostDisplayName = $vmhost.Name

    $IBRSPass = $false
    $IBPBPass = $false
    $STIBPPass = $false

    $cpuFeatures = $vmhost.Config.FeatureCapability
    foreach ($cpuFeature in $cpuFeatures) {
        if($cpuFeature.key -eq "cpuid.IBRS" -and $cpuFeature.value -eq 1) {
            $IBRSPass = $true
        } elseif($cpuFeature.key -eq "cpuid.IBPB" -and $cpuFeature.value -eq 1) {
            $IBPBPass = $true
        } elseif($cpuFeature.key -eq "cpuid.STIBP" -and $cpuFeature.value -eq 1) {
            $STIBPPass = $true
        }
    }

    $vmhostAffected = $true
    if($IBRSPass -or $IBPBPass -or $STIBPass) {
        $vmhostAffected = $false
    }

    $tmp = [pscustomobject] @{
        VMHost = $vmhostDisplayName;
        IBRPresent = $IBRSPass;
        IBPBPresent = $IBPBPass;
        STIBPresent = $STIBPPass;
        Affected = $vmhostAffected;
    }
    $result+=$tmp
}
$Result

$Title = "ESXi Hosts Exposed to Spectre Vulnerability"
$Header = "ESXi Hosts Exposed to Spectre Vulnerability: $(@($Result).count)"
$Comments = "The following ESXi Hosts require remediation to mitigate the Spectre vulnerability. See the following URLs for more information: <a href='https://kb.vmware.com/s/article/52085' target='_blank'>KB 52085</a>, <a href='https://www.virtuallyghetto.com/2018/01/verify-hypervisor-assisted-guest-mitigation-spectre-patches-using-powercli.html' target='_blank'>Virtually Ghetto</a>."
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
