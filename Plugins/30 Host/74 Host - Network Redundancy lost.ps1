$Title = "Network redundancy lost"
$Header = "Network redundancy lost: [count]"
$Comments = "The following Hosts have lost network redundancy"
$Display = "Table"
$Author = "Olivier TABUT"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

$vsList = Get-VirtualSwitch -Standard
foreach ($VMHost in $VMH) {
   foreach($pnic in $VMHost.ExtensionData.Config.Network.Pnic){
      $vSw = $vsList | Where-Object {($_.VMHost -eq $VMHost) -and ($_.Nic -contains $pNic.Device)}
      $pnic | Select-Object @{N="ESXname";E={$VMHost.Name}},@{N="pNic";E={$pnic.Device}},@{N="vSwitch";E={$vSw.Name}},@{N="Status";E={if($pnic.LinkSpeed -ne $null){"up"}else{"down"}}} | Where-Object {($_.Status -eq "down") -and ($_.vSwitch -notlike $null)}
   }
}

## ChangeLog
## 1.3 - Filter out NICs not connected to a vSwitch
## 1.4 - Fixed warning message about VDS objects. Added -Standard option to suppress it, anyway this plugin only works with vSwitch.

