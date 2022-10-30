# Start of Settings
# End of Settings

$result = @()
foreach ($vmobj in $FullVM | Sort-Object -Property Name) {
    # Only check VMs that are powered on
    if($vmobj.Runtime.PowerState -eq "poweredOn") {
        $vmDisplayName = $vmobj.Name
        $vmvHW = $vmobj.Config.Version

        $vHWPass = $false
        if($vmvHW -eq "vmx-04" -or $vmvHW -eq "vmx-06" -or $vmvHW -eq "vmx-07" -or $vmvHW -eq "vmx-08") {
            $vHWPass = "N/A"
        } elseif($vmvHW -eq "vmx-09" -or $vmvHW -eq "vmx-10" -or $vmvHW -eq "vmx-11" -or $vmvHW -eq "vmx-12" -or $vmvHW -eq "vmx-13") {
            $vHWPass = $true
        }

        $IBRSPass = $false
        $IBPBPass = $false
        $STIBPPass = $false

        $cpuFeatures = $vmobj.Runtime.FeatureRequirement
        foreach ($cpuFeature in $cpuFeatures) {
            if($cpuFeature.key -eq "cpuid.IBRS") {
                $IBRSPass = $true
            } elseif($cpuFeature.key -eq "cpuid.IBPB") {
                $IBPBPass = $true
            } elseif($cpuFeature.key -eq "cpuid.STIBP") {
                $STIBPPass = $true
            }
        }

        $vmAffected = $true
        if( ($IBRSPass -eq $true -or $IBPBPass -eq $true -or $STIBPPass -eq $true) -and $vHWPass -eq $true) {
            $vmAffected = $false
        } elseif($vHWPass -eq "N/A") {
            $vmAffected = $vHWPass
        }

        $tmp = [pscustomobject] @{
            VM = $vmDisplayName;
            IBRPresent = $IBRSPass;
            IBPBPresent = $IBPBPass;
            STIBPresent = $STIBPPass;
            vHW = $vmvHW;
            Affected = $vmAffected;
        }
        $result+=$tmp
    }
}
$Result

$Title = "VMs Exposed to Spectre Vulnerability"
$Header = "Virtual Machines Exposed to Spectre Vulnerability: $(@($Result).Count)"
$Comments = "The following VMs require remediation to mitigate the Spectre vulnerability. See the following URLs for more information: <a href='https://kb.vmware.com/s/article/52085' target='_blank'>KB 52085</a>, <a href='https://www.virtuallyghetto.com/2018/01/verify-hypervisor-assisted-guest-mitigation-spectre-patches-using-powercli.html' target='_blank'>Virtually Ghetto</a>."
$Display = "Table"
$Author = "William Lam"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


# Changelog
## 1.0 : Initial version.
## 1.2 : The variable $vm has been changed to $vmobj because $vm is defined globally. This modification allows subsequent plugins to run without problems.

