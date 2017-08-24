$Title = "VMs needing snapshot consolidation"
$Header = "VMs needing snapshot consolidation [count]"
$Comments = "The following VMs have snapshots that failed to consolidate. See <a href='http://blogs.vmware.com/vsphere/2011/08/consolidate-snapshots.html' target='_blank'>this article</a> for more details"
$Display = "Table"
$Author = "Luc Dekens, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$htabHostVersion = @{}
$HostsViews | Foreach-Object {$htabHostVersion.Add($_.MoRef,$_.config.product.version)}
$FullVM | Where-Object {$htabHostVersion[$_.runtime.host].Split('.')[0] -ge 5 -and $_.runtime.consolidationNeeded} | Sort-Object -Property Name | Select-Object Name,@{N="Consolidation needed";E={$_.Runtime.consolidationNeeded}}