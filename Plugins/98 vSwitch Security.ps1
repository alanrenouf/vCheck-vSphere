# Start of Settings
# Enable Checking of vSwitch security settings?
$vSwitchSecurityCheck = $true
# End of Settings

# Changelog
## 1.0 : Initial Release

$results = @()
$results = "" | Select-Object Host,Type,vSwitch,Portgroup,Policy,Setting

foreach ($VMHost in $VMH | ?{$_.ConnectionState -eq "Connected"}) {
	foreach ($VSWITCH in Get-VirtualSwitch -Standard) {
		if ($VSWITCH.ExtensionData.Spec.Policy.Security.AllowPromiscuous) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Type += "Standard vSwitch<br/>"
			$results.Portgroup += "N/A<br/>"
			$results.Policy += "Promiscuous Mode<br/>"
			$results.Setting += "Accept<br/>"# Start of Settings# Enable Checking of vSwitch security settings?$vSwitchSecurityCheck = $true# End of Settings# Changelog## 1.0 : Initial Releaseif ($vSwitchSecurityCheck) {$results = @()foreach ($VMHost in $VMH | ?{$_.ConnectionState -eq "Connected"}) {	foreach ($VSWITCH in Get-VirtualSwitch -Standard -VMHost $VMHost) {		if ($VSWITCH.ExtensionData.Spec.Policy.Security.AllowPromiscuous) {			$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting			$details.Host += $VMHost.Name + "<br/>"			$details.vSwitch += $VSWITCH.name + "<br/>"			$details.Type += "Standard vSwitch<br/>"			$details.Portgroup += "N/A<br/>"			$details.Policy += "Promiscuous Mode<br/>"			$details.Setting += "Accept<br/>"			$results += $details		}		if ($VSWITCH.ExtensionData.Spec.Policy.Security.ForgedTransmits) {			$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting			$details.Host += $VMHost.Name + "<br/>"			$details.vSwitch += $VSWITCH.name + "<br/>"			$details.Type += "Standard vSwitch<br/>"			$details.Portgroup += "N/A<br/>"			$details.Policy += "Forged Transmits<br/>"			$details.Setting += "Accept<br/>"			$results += $details		}		if ($VSWITCH.ExtensionData.Spec.Policy.Security.MacChanges) {			$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting			$details.Host += $VMHost.Name + "<br/>"			$details.vSwitch += $VSWITCH.name + "<br/>"			$details.Type += "Standard vSwitch<br/>"			$details.Portgroup += "N/A<br/>"			$details.Policy += "MAC Changes<br/>"			$details.Setting += "Accept<br/>"			$results += $details		}			foreach ($portgroup in ($VMHost.ExtensionData.Config.Network.Portgroup | where {$_.Vswitch -eq $vSwitch.Key})) {			if (($portgroup.Spec.Policy.Security.AllowPromiscuous) -or ($portgroup.Spec.Policy.Security.AllowPromiscuous -eq $null)) {				$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting				$details.Host += $VMHost.Name + "<br/>"				$details.vSwitch += $VSWITCH.name + "<br/>"				$details.Type += "Standard vSwitch portgroup<br/>"				$details.Portgroup += $portgroup.Spec.Name + "<br/>"				$details.Policy += "Promiscuous Mode<br/>"				$details.Setting += "Accept<br/>"				$results += $details			}			if (($portgroup.Spec.Policy.Security.ForgedTransmits) -or ($portgroup.Spec.Policy.Security.ForgedTransmits -eq $null)) {				$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting				$details.Host += $VMHost.Name + "<br/>"				$details.vSwitch += $VSWITCH.name + "<br/>"				$details.Type += "Standard vSwitch portgroup<br/>"				$details.Portgroup += $portgroup.Spec.Name + "<br/>"				$details.Policy += "Forged Transmits<br/>"				$details.Setting += "Accept<br/>"				$results += $details			}			if (($portgroup.Spec.Policy.Security.MacChanges) -or ($portgroup.Spec.Policy.Security.MacChanges -eq $null)) {				$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting				$details.Host += $VMHost.Name + "<br/>"				$details.Type += "Standard vSwitch portgroup<br/>"				$details.vSwitch += $VSWITCH.name + "<br/>"				$details.Portgroup += $portgroup.Spec.Name + "<br/>"				$details.Policy += "MAC Changes<br/>"				$details.Setting += "Accept<br/>"				$results += $details			}		}	}	foreach ($VSWITCH in Get-VirtualSwitch -Distributed -VMHost $VMHost) {		if ($VSWITCH.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value) {			$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting			$details.Host += $VMHost.Name + "<br/>"			$details.vSwitch += $VSWITCH.name + "<br/>"			$details.Type += "Standard vSwitch portgroup<br/>"			$details.Portgroup += $portgroup.Spec.Name + "<br/>"			$details.Policy += "Promiscuous Mode<br/>"			$details.Setting += "Accept<br/>"			$results += $details		}		if ($VSWITCH.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value) {			$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting			$details.Host += $VMHost.Name + "<br/>"			$details.vSwitch += $VSWITCH.name + "<br/>"			$details.Type += "Standard vSwitch portgroup<br/>"			$details.Portgroup += $portgroup.Spec.Name + "<br/>"			$details.Policy += "Forged Transmits<br/>"			$details.Setting += "Accept<br/>"			$results += $details		}		if ($VSWITCH.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value) {			$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting			$details.Host += $VMHost.Name + "<br/>"			$details.vSwitch += $VSWITCH.name + "<br/>"			$details.Type += "Standard vSwitch portgroup<br/>"			$details.Portgroup += $portgroup.Spec.Name + "<br/>"			$details.Policy += "MAC Changes<br/>"			$details.Setting += "Accept<br/>"			$results += $details		}		foreach($portgroup in (Get-VirtualPortGroup -Distributed -VirtualSwitch $vSwitch)){			if (($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value) -or ($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value -eq $null)) {				$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting				$details.Host += $VMHost.Name + "<br/>"				$details.vSwitch += $VSWITCH.name + "<br/>"				$details.Type += "Distributed vSwitch Portgroup<br/>"				$details.Portgroup += $portgroup.name + "<br/>"				$details.Policy += "Promiscuous Mode<br/>"				$details.Setting += "Accept<br/>"				$results += $details			}			if (($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value) -or ($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value)) {				$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting				$details.Host += $VMHost.Name + "<br/>"				$details.vSwitch += $VSWITCH.name + "<br/>"				$details.Type += "Distributed vSwitch Portgroup<br/>"				$details.Portgroup += $portgroup.name + "<br/>"				$details.Policy += "Forged Transmits<br/>"				$details.Setting += "Accept<br/>"				$results += $details			}			if (($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value) -or ($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value)) {				$details = "" |Select Host,Type,vSwitch,Portgroup,Policy,Setting				$details.Host += $VMHost.Name + "<br/>"				$details.vSwitch += $VSWITCH.name + "<br/>"				$details.Type += "Distributed vSwitch Portgroup<br/>"				$details.Portgroup += $portgroup.name + "<br/>"				$details.Policy += "MAC Changes<br/>"				$details.Setting += "Accept<br/>"				$results += $details			}		}	}}$results}#if ($results.Host) { $results }$Title = "vSwitch Security"$Header =  "vSwitch and portgroup security settings"$Comments = "All security options for standard vSwitches should be set to REJECT.  Distributed vSwitches may require <em>ForgedTrasmits</em> in the default portgroup but should be disabled in other VM Network portgroups unless expressly required."$Display = "Table"$Author = "Justin Mercier"$PluginVersion = 1.0$PluginCategory = "vSphere"
?
		}
		if ($VSWITCH.ExtensionData.Spec.Policy.Security.ForgedTransmits) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Type += "Standard vSwitch<br/>"
			$results.Portgroup += "N/A<br/>"
			$results.Policy += "Forged Transmits<br/>"
			$results.Setting += "Accept<br/>"
		}
		if ($VSWITCH.ExtensionData.Spec.Policy.Security.MacChanges) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Type += "Standard vSwitch<br/>"
			$results.Portgroup += "N/A<br/>"
			$results.Policy += "MAC Changes<br/>"
			$results.Setting += "Accept<br/>"
		}
	}
	foreach ($portgroup in ($VMHost.ExtensionData.Config.Network.Portgroup | where {$_.Vswitch -eq $vSwitch.Key})) {
		if (($portgroup.Spec.Policy.Security.AllowPromiscuous) -or ($portgroup.Spec.Policy.Security.AllowPromiscuous -eq $null)) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Type += "Standard vSwitch portgroup<br/>"
			$results.Portgroup += $portgroup.Spec.Name + "<br/>"
			$results.Policy += "Promiscuous Mode<br/>"
			$results.Setting += "Accept<br/>"
		}
		if (($portgroup.Spec.Policy.Security.ForgedTransmits) -or ($portgroup.Spec.Policy.Security.ForgedTransmits -eq $null)) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Type += "Standard vSwitch portgroup<br/>"
			$results.Portgroup += $portgroup.Spec.Name + "<br/>"
			$results.Policy += "Forged Transmits<br/>"
			$results.Setting += "Accept<br/>"
		}
		if (($portgroup.Spec.Policy.Security.MacChanges) -or ($portgroup.Spec.Policy.Security.MacChanges -eq $null)) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.Type += "Standard vSwitch portgroup<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Portgroup += $portgroup.Spec.Name + "<br/>"
			$results.Policy += "MAC Changes<br/>"
			$results.Setting += "Accept<br/>"
		}
	}

	foreach ($VSWITCH in Get-VirtualSwitch -Distributed) {
		if ($VSWITCH.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Type += "Standard vSwitch portgroup<br/>"
			$results.Portgroup += $portgroup.Spec.Name + "<br/>"
			$results.Policy += "Promiscuous Mode<br/>"
			$results.Setting += "Accept<br/>"
		}
		if ($VSWITCH.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Type += "Standard vSwitch portgroup<br/>"
			$results.Portgroup += $portgroup.Spec.Name + "<br/>"
			$results.Policy += "Forged Transmits<br/>"
			$results.Setting += "Accept<br/>"
		}
		if ($VSWITCH.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value) {
			$results.Host += $VMHost.Name + "<br/>"
			$results.vSwitch += $VSWITCH.name + "<br/>"
			$results.Type += "Standard vSwitch portgroup<br/>"
			$results.Portgroup += $portgroup.Spec.Name + "<br/>"
			$results.Policy += "MAC Changes<br/>"
			$results.Setting += "Accept<br/>"
		}
		foreach($portgroup in (Get-VirtualPortGroup -Distributed -VirtualSwitch $vSwitch)){
			if (($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value) -or ($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value -eq $null)) {
				$results.Host += $VMHost.Name + "<br/>"
				$results.vSwitch += $VSWITCH.name + "<br/>"
				$results.Type += "Distributed vSwitch Portgroup<br/>"
				$results.Portgroup += $portgroup.name + "<br/>"
				$results.Policy += "Promiscuous Mode<br/>"
				$results.Setting += "Accept<br/>"
			}
			if (($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value) -or ($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value)) {
				$results.Host += $VMHost.Name + "<br/>"
				$results.vSwitch += $VSWITCH.name + "<br/>"
				$results.Type += "Distributed vSwitch Portgroup<br/>"
				$results.Portgroup += $portgroup.name + "<br/>"
				$results.Policy += "Forged Transmits<br/>"
				$results.Setting += "Accept<br/>"
			}
			if (($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value) -or ($portgroup.Extensiondata.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value)) {
				$results.Host += $VMHost.Name + "<br/>"
				$results.vSwitch += $VSWITCH.name + "<br/>"
				$results.Type += "Distributed vSwitch Portgroup<br/>"
				$results.Portgroup += $portgroup.name + "<br/>"
				$results.Policy += "MAC Changes<br/>"
				$results.Setting += "Accept<br/>"
			}
		}
	}
}

if ($results.Host) { $results }


$Title = "vSwitch Security"
$Header =  "vSwitch and portgroup security settings"
$Comments = "All security options for standard vSwitches should be set to REJECT.  Distributed vSwitches may require <em>ForgedTrasmits</em> in the default portgroup but should be disabled in other VM Network portgroups unless expressly required."
$Display = "Table"
$Author = "Justin Mercier"
$PluginVersion = 1.0
$PluginCategory = "vSphere"