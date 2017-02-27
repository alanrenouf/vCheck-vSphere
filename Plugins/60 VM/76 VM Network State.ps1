$Title = "VM Network State"
$Header = "VMs with NIC disconnected: [count]"
$Comments = "Check if all network cards are connected"
$Display = "Table"
$Author = "Cyril Epiney"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings
# Only show NICs that are set to Connect at Startup
$ShowOnlyStartupNICS = $true
# End of Settings

# Update settings where there is an override
$ShowOnlyStartupNICS = Get-vCheckSetting $Title "ShowOnlyStartupNICS" $ShowOnlyStartupNICS

$VMsNetworkNotConnected = @()
# Check only on powered on VMs
foreach ($myVM in $FullVM | Where-Object {$_.runtime.powerState -eq "PoweredOn"}) {
    foreach ($myCard in $myVM.config.hardware.device | Where-Object {$_ -is [VMware.Vim.VirtualEthernetCard] -and -Not $_.connectable.connected}) {
      if ($ShowOnlyStartupNICS -and $myCard.connectable.StartConnected) {
         # The network card is not connected. Warn user
         New-Object -TypeName PSObject -Property @{
            VM = $myVM.Name
            vmNetworkAdapter = $myCard.deviceInfo.label
            State = "Disconnected"
         }
      }
   }
}

# Change Log
## 1.3 : Added Get-vCheckSetting