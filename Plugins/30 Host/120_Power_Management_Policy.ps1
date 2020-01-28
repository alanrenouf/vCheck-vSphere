$Title = "Host Power Management Policy"
$Comments = "The following hosts are not using the specified power management policy.  Power management may impact performance for latency sensitive workloads.  For details see <a href='https://www.vmware.com/content/dam/digitalmarketing/vmware/en/pdf/techpaper/performance/Perf_Best_Practices_vSphere65.pdf' >Performance Best Practices for VMware vSphere 6.5</a>"
$Display = "Table"
$Author = "Doug Taliaferro"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings
# Which power management policy should your hosts use? For Balanced enter "dynamic" (this is the ESXi default policy), for High Performance enter "static", for Low power enter "low".
$PowerPolicy = "dynamic"
# End of Settings

# Update settings where there is an override
$PowerPolicy = Get-vCheckSetting $Title "PowerPolicy" $PowerPolicy

$hostResults = @()
Foreach ($esxhost in ($HostsViews | Where-Object {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {
    If ($esxhost.config.PowerSystemInfo.CurrentPolicy.ShortName -ne $PowerPolicy) {
        $myObj = "" | Select-Object VMHost, PowerPolicy
        $myObj.VMHost = $esxhost.Name
        $myObj.PowerPolicy = $esxhost.config.PowerSystemInfo.CurrentPolicy.ShortName
        $hostResults += $myObj
    }
}

$hostResults

$Header = "Hosts not using Power Mangement Policy '$($PowerPolicy)' : [count]"