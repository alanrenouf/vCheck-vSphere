$Title = "Disk Max Total Latency"
$Display = "Table"
$Author = "Raphael Schitz, Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# Disk Max Total Latency Settings in Milliseconds
$diskmaxtotallatency = "50"
# Disk Max Total Latency range to inspect (1-24) Hours
$stattotallatency = "24"
# End of Settings

# Update settings where there is an override
$diskmaxtotallatency = Get-vCheckSetting $Title "diskmaxtotallatency" $diskmaxtotallatency
$stattotallatency = Get-vCheckSetting $Title "stattotallatency" $stattotallatency

$HostsDiskLatency = @()
foreach ($VMHost in $VMH | Where-Object {$_.ConnectionState -eq "Connected"}) {
   if ($VMHost.Version -lt 4){continue}# not an esx 4.x host
   $HostDiskLatency = @()
   $VHHMaxLatency = $VMHost | get-stat -stat "disk.maxTotalLatency.latest" -start ($Date).addhours(-$stattotallatency) -finish ($Date)|Where-Object {$_.value -gt $diskmaxtotallatency}| Sort-Object Timestamp -Descending
   if ($VHHMaxLatency.Count -gt 0) {
      $Details = "" | Select-Object Host, Timestamp, milliseconds
      $Details.host = $VMHost.name
      $Details.Timestamp = $VHHMaxLatency[0].Timestamp
      $Details.milliseconds = $VHHMaxLatency[0].Value
      $HostDiskLatency += $Details
      if ($VHHMaxLatency.Count -gt 2)	{
         $vmhlatid = [int]"1"
         while ($vmhlatid -cle $VHHMaxLatency.Count-2) {
            if (($VHHMaxLatency[$vmhlatid].timestamp).addminutes(5) -gt $Details.Timestamp -or ($VHHMaxLatency[$vmhlatid].timestamp).addminutes(-5) -gt $Details.Timestamp) { # keeps only high values strictly <> 5 min to avoid flood period
               $Details = "" | Select-Object Host, Timestamp, milliseconds
               $Details.host = $VMHost.name
               $Details.Timestamp = $VHHMaxLatency[$vmhlatid].Timestamp
               $Details.milliseconds = $VHHMaxLatency[$vmhlatid].Value
               $HostDiskLatency += $Details
            }
            $vmhlatid++
         }
      }
   }
   $HostsDiskLatency += $HostDiskLatency
}

$HostsDiskLatency

$Header = ("Disk Max Total Latency over {0}ms" -f $diskmaxtotallatency)
$Comments = ("Check VM per LUN dispatch and esxtop for very high values over {0}ms" -f $diskmaxtotallatency)