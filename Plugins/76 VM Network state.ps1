# Start of Settings 
# End of Settings

$VMsNetworkNotConnected = @()
foreach ($myVM in $VM) {
    # Check only on powered on VMs
    if ($myVM.PowerState -eq "PoweredOn") {
        foreach ($myCard in $myVM | Get-NetworkAdapter) {
            # The network card is not connected. Warn user
            if (! $myCard.ConnectionState.Connected) {
            	$vmNetworkNotConnected = "" | Select-Object VM, vmNetworkAdapter, State
                $vmNetworkNotConnected.VM = $myVM.Name
                $vmNetworkNotConnected.vmNetworkAdapter = $myCard.Name
                $vmNetworkNotConnected.State = "Disconnected"
            	$VMsNetworkNotConnected += $vmNetworkNotConnected
            }
        }
    }
}

$VMsNetworkNotConnected

$Title = "VM - is my network connected ?"
$Header =  "VM - is my network connected ?"
$Comments = "Check if all network cards are connected"
$Display = "Table"
$Author = "Cyril Epiney"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
