# Start of Settings 
# End of Settings 

$vsList = Get-VirtualSwitch
foreach ($VMHost in $VMH) {
   foreach($pnic in $VMHost.ExtensionData.Config.Network.Pnic){
      $vSw = $vsList | where {($_.VMHost -eq $VMHost) -and ($_.Nic -contains $pNic.Device)}
      $result = $pnic | Select @{N="ESXname";E={$VMHost.Name}},@{N="pNic";E={$pnic.Device}},@{N="vSwitch";E={$vSw.Name}},@{N="Status";E={if($pnic.LinkSpeed -ne $null){"up"}else{"down"}}}
      if (($result.vSwitch -ne $null) -and ($result.status -eq "down")) {$result}
   }   
}


$Title = "Network redundancy lost"
$Header = "Network redundancy lost: $(@($Result).Count)"
$Comments = "The following Hosts have lost network redundancy"
$Display = "Table"
$Author = "Olivier TABUT"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
