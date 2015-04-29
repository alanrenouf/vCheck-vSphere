# Start of Settings
# Only show NICs that are set to Connect at Startup
$ShowOnlyStartupNICS = $true
# End of Settings

$VMsNetworkNotConnected = @()
# Check only on powered on VMs
foreach ($myVM in $FullVM | ?{$_.runtime.powerState -eq "PoweredOn"}) {
    foreach ($myCard in $myVM.config.hardware.device | ?{$_ -is [VMware.Vim.VirtualEthernetCard]} | ?{-Not $_.connectable.connected}) {
		if ($ShowOnlyStartupNICS -and $myCard.connectable.StartConnected) {      
         # The network card is not connected. Warn user      
         $vmNetworkNotConnected = "" | Select-Object VM, vmNetworkAdapter, State
         $vmNetworkNotConnected.VM = $myVM.Name
         $vmNetworkNotConnected.vmNetworkAdapter = $myCard.deviceInfo.label
         $vmNetworkNotConnected.State = "Disconnected"
         $VMsNetworkNotConnected += $vmNetworkNotConnected
      }
	}
}

$VMsNetworkNotConnected

$Title = "VM - is my network connected?"
$Header = "VM - is my network connected?"
$Comments = "Check if all network cards are connected"
$Display = "Table"
$Author = "Cyril Epiney"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
