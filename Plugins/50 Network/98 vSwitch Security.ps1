$Title = "vSwitch Security"
$Header = "vSwitch and portgroup security settings"
$Comments = "All security options for standard and distributed switches and port groups should be set to REJECT unless explicitly required, except for ForgedTrasmits which is required on vDS uplink port groups."
$Display = "Table"
$Author = "Justin Mercier, Sam McGeown, John Sneddon, Ben Hocker, Dan Barr"
$PluginVersion = 1.5
$PluginCategory = "vSphere"

# Start of Settings
# Warn for AllowPromiscuous enabled?
$AllowPromiscuousPolicy = $true
# Warn for ForgedTransmits enabled?
$ForgedTransmitsPolicy = $true
# Warn for MacChanges enabled?
$MacChangesPolicy = $true
# End of Settings

# Update settings where there is an override
$AllowPromiscuousPolicy = Get-vCheckSetting $Title "AllowPromiscuousPolicy" $AllowPromiscuousPolicy
$ForgedTransmitsPolicy = Get-vCheckSetting $Title "ForgedTransmitsPolicy" $ForgedTransmitsPolicy
$MacChangesPolicy = Get-vCheckSetting $Title "MacChangesPolicy" $MacChangesPolicy

# Check Power CLI version. Build must be at least 1012425 (5.1 Release 2) to contain Get-VDPortGroup cmdlet
$VersionOK = $false

if (((Get-PowerCLIVersion) -match "VMware.* PowerCLI (.*) build ([0-9]+)")) {

    if ([int]($Matches[2]) -ge 1012425) {
        $VersionOK = $true
        if ([int]($Matches[2]) -ge 2548067) {
            #PowerCLI 6+
            if (!(Get-Module -Name VMware.VimAutomation.Vds -ErrorAction SilentlyContinue)) {
                Import-Module VMware.VimAutomation.Vds
            }
        }
        else {
            # Add required Snap-In
            if (!(Get-PSSnapin -name VMware.VimAutomation.Vds -ErrorAction SilentlyContinue)) {
                Add-PSSnapin VMware.VimAutomation.Vds
            }
        }
    }
}

if ($VersionOK) {
    [array] $results = $null

    Get-VirtualSwitch | ForEach-Object {
        $Output = "" | Select-Object Host, Type, vSwitch, Portgroup, AllowPromiscuous, ForgedTransmits, MacChanges
        if ($_.ExtensionData.Summary -ne $null) {
            $Output.Type = "vDS"
            $Output.Host = "*"
        }
        else {
            $Output.Type = "vSS"
            $Output.Host = $_.VMHost
        }
        $Output.vSwitch = $_.Name
        $Output.Portgroup = "(none)"
        $Output.AllowPromiscuous = ($_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value -or $_.ExtensionData.Spec.Policy.Security.AllowPromiscuous)
        $Output.ForgedTransmits = ($_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value -or $_.ExtensionData.Spec.Policy.Security.ForgedTransmits)
        $Output.MacChanges = ($_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value -or $_.ExtensionData.Spec.Policy.Security.MacChanges)
        $results += $Output
    }

    Get-VDPortGroup | ForEach-Object {
        $Output = "" | Select-Object Host, Type, vSwitch, Portgroup, AllowPromiscuous, ForgedTransmits, MacChanges
        $Output.Host = "*"
        if ($_.ExtensionData.Config.Uplink -eq $true) {
            $Output.Type = "vDS Uplink Port Group"
        }
        else {
            $Output.Type = "vDS Port Group"
        }
        $Output.vSwitch = $_.VDSwitch
        $Output.Portgroup = $_.Name
        $Output.AllowPromiscuous = $_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value
        $Output.ForgedTransmits = $_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value
        $Output.MacChanges = $_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value
        $results += $Output
    }

    $VMH | Where-Object { $_.ConnectionState -eq "Connected" } | ForEach-Object {
        $VMHost = $_
        Get-VirtualPortGroup -VMHost $_ -Standard | ForEach-Object {
            $Output = "" | Select-Object Host, Type, vSwitch, Portgroup, AllowPromiscuous, ForgedTransmits, MacChanges
            $Output.Host = $VMHost.Name
            $Output.Type = "vSS Port Group"
            $Output.vSwitch = $_.VirtualSwitch
            $Output.Portgroup = $_.Name
            $Output.AllowPromiscuous = $_.ExtensionData.Spec.Policy.Security.AllowPromiscuous -and ($_.Spec.Policy.Security.AllowPromiscuous -eq $null)
            $Output.ForgedTransmits = $_.ExtensionData.Spec.Policy.Security.ForgedTransmits -and ($_.Spec.Policy.Security.ForgedTransmits -eq $null)
            $Output.MacChanges = $_.ExtensionData.Spec.Policy.Security.MacChanges -and ($_.Spec.Policy.Security.MacChanges -eq $null)
            $results += $Output
        }
    }

    if ($results.Host) { $results | Where-Object { ($_.AllowPromiscuous -and $AllowPromiscuousPolicy) -or ($_.ForgedTransmits -and $ForgedTransmitsPolicy -and $_.Type -ne "vDS Uplink Port Group") -or ($_.MacChanges -and $MacChangesPolicy) } | Sort-Object vSwitch, PortGroup }
}
else {
    Write-Warning "PowerCLi version installed is lower than 5.1 Release 2"
    New-Object PSObject -Property @{"Message" = "PowerCLi version installed is lower than 5.1 Release 2, please update to use this plugin"}
}

# Changelog
## 1.0 : Initial Release
## 1.1 : Re-written for performance improvements
## 1.2 : Added version check (Issue #71)
## 1.3 : Add Get-vCheckSetting
## 1.4 : Fix Version checking for PowerCLI 6.5 - vSphere is no longer in the product name (Issue #514)
## 1.5 : Ignore ForgedTransmits on vDS Uplink port groups, removed redundant plugin variable block, fixed logic bugs
