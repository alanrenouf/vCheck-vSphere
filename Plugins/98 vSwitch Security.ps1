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

# Changelog
## 1.0 : Initial Release
## 1.1 : Re-written for performance improvements

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

if ($results.Host) { $results | where { ($_.AllowPromiscuous -eq $AllowPromiscuousPolicy) -or ($_.ForgedTransmits -eq $ForgedTransmitsPolicy) -or ($_.MacChanges -eq $MacChangesPolicy) } | Sort-Object vSwitch,PortGroup }


$Title = "vSwitch Security"
$Header =  "vSwitch and portgroup security settings"
$Comments = "All security options for standard vSwitches should be set to REJECT.  Distributed vSwitches may require <em>ForgedTrasmits</em> in the default portgroup but should be disabled in other VM Network portgroups unless expressly required."
$Display = "Table"
$Author = "Justin Mercier, Sam McGeown"
$PluginVersion = 1.1
$PluginCategory = "vSphere"