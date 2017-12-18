$Title = "vSwitch Security"
$Header = "vSwitch and portgroup security settings"
$Comments = "All security options for standard vSwitches should be set to REJECT.  Distributed vSwitches may require <em>ForgedTrasmits</em> in the default portgroup but should be disabled in other VM Network portgroups unless expressly required."
$Display = "Table"
$Author = "Justin Mercier, Sam McGeown, John Sneddon"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings
# Enable Checking of vSwitch security settings?
$vSwitchSecurityCheck = $true
# Warn for AllowPromiscuous enabled?
$AllowPromiscuousPolicy = $true
# Warn for ForgedTransmits enabled?
$ForgedTransmitsPolicy = $true
# Warn for MacChanges enabled?
$MacChangesPolicy = $true
# End of Settings

# Update settings where there is an override
$vSwitchSecurityCheck = Get-vCheckSetting $Title "vSwitchSecurityCheck" $vSwitchSecurityCheck
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
        if(!(Get-Module -Name VMware.VimAutomation.Vds -ErrorAction SilentlyContinue)) {
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

   Get-VirtualSwitch | % {
      $Output = "" | Select-Object Host,Type,vSwitch,Portgroup,AllowPromiscuous,ForgedTransmits,MacChanges
      if($_.ExtensionData.Summary -ne $null) {
         $Output.Type = "vDS"
         $Output.Host = "*"
      } else {
         $Output.Type = "vSS"
         $Output.Host = $_.VMHost
      }
      $Output.vSwitch = $_.Name
      $Output.Portgroup = "(none)"
      $Output.AllowPromiscuous = ($_.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value -and $_ExtensionData.Spec.Policy.Security.AllowPromiscuous)
      $Output.ForgedTransmits = ($_.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value -and $_ExtensionData.Spec.Policy.Security.AllowPromiscuous)
      $Output.MacChanges = ($_.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value -and $_ExtensionData.Spec.Policy.Security.AllowPromiscuous)
      $results += $Output
   }

   Get-VDPortGroup | % {
      $Output = "" | Select-Object Host,Type,vSwitch,Portgroup,AllowPromiscuous,ForgedTransmits,MacChanges
      $Output.Host = "*"
      $Output.Type = "vDS Port Group"
      $Output.vSwitch = $_.VDSwitch
      $Output.Portgroup = $_.Name
      $Output.AllowPromiscuous = $_.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value
      $Output.ForgedTransmits = $_.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value
      $Output.MacChanges = $_.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value
      $results += $Output
   }

   $VMH | Where-Object { $_.ConnectionState -eq "Connected" } | % {
      $VMHost = $_
      Get-VirtualPortGroup -VMHost $_ -Standard | % {
         $Output = "" | Select-Object Host,Type,vSwitch,Portgroup,AllowPromiscuous,ForgedTransmits,MacChanges
         $Output.Host = $VMHost.Name
         $Output.Type = "vSS Port Group"
         $Output.vSwitch = $_.VirtualSwitch
         $Output.Portgroup = $_.Name
         $Output.AllowPromiscuous = $_.ExtensionData.Spec.Policy.Security.AllowPromiscuous -and ($portgroup.Spec.Policy.Security.MacChanges -eq $null)
         $Output.ForgedTransmits = $_.ExtensionData.Spec.Policy.Security.ForgedTransmits -and ($portgroup.Spec.Policy.Security.MacChanges -eq $null)
         $Output.MacChanges = $_.Spec.ExtensionData.Policy.Security.MacChanges -and ($portgroup.Spec.Policy.Security.MacChanges -eq $null)
         $results += $Output
      }
   }

   if ($results.Host) { $results | Where-Object { ($_.AllowPromiscuous -eq $AllowPromiscuousPolicy) -or ($_.ForgedTransmits -eq $ForgedTransmitsPolicy) -or ($_.MacChanges -eq $MacChangesPolicy) } | Sort-Object vSwitch,PortGroup }
}
else {
   Write-Warning "PowerCLi version installed is lower than 5.1 Release 2"
   New-Object PSObject -Property @{"Message"="PowerCLi version installed is lower than 5.1 Release 2, please update to use this plugin"}
}

# Changelog
## 1.0 : Initial Release
## 1.1 : Re-written for performance improvements
## 1.2 : Added version check (Issue #71)
## 1.3 : Add Get-vCheckSetting
## 1.4 : Fix Version checking for PowerCLI 6.5 - vSphere is no longer in the product name (Issue #514)

