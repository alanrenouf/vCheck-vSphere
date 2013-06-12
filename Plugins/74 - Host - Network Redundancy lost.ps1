# Start of Settings 
# End of Settings 

foreach ($HostsView in $HostsViews) {
   foreach($pnic in $HostsView.Config.Network.Pnic){
      $vSw = Get-VirtualSwitch -VMHost $HostsView.name | where {$_.Nic -contains $pNic.Device}
      $result = $pnic | Select @{N="ESXname";E={$HostsView.Name}},@{N="pNic";E={$pnic.Device}},@{N="vSwitch";E={$vSw.Name}},@{N="Status";E={if($pnic.LinkSpeed -ne $null){"up"}else{"down"}}}
      if (($result.vSwitch -ne $null) -and ($result.status -eq "down")) {$result}
   }   
}


$Title = "Network redundancy lost"
$Header =  "Network redundancy lost: $(@($Result).Count)"
$Comments = "The following Hosts have lost network redundancy"
$Display = "Table"
$Author = "Olivier TABUT"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

