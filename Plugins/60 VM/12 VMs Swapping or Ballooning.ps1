# Start of Settings 
# End of Settings 

# Changelog
## 1.1 : Using quick stats property in order to avoid using Get-Stat cmdlet for performance matter

$bs = $FullVM | Where {$_.runtime.PowerState -eq "PoweredOn" }| Select Name, @{N="SwapMB";E={$_.Summary.QuickStats.SwappedMemory}}, @{N="MemBalloonMB";E={$_.Summary.QuickStats.BalloonedMemory}} | Where { ($_.MemBalloonMB -gt 0) -Or ($_.SwapMB -gt 0)}
$bs

$Title = "VMs Ballooning or Swapping"
$Header = "VMs Ballooning or Swapping : $(@($bs).count)"
$Comments = "Ballooning and swapping may indicate a lack of memory or a limit on a VM, this may be an indication of not enough memory in a host or a limit held on a VM, <a href='http://www.virtualinsanity.com/index.php/2010/02/19/performance-troubleshooting-vmware-vsphere-memory/' target='_blank'>further information is available here</a>."
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
