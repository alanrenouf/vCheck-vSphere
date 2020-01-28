$Title = "Snapshots Oversize"
$Header = "Snapshots Oversize"
$Comments = "VMware snapshots which are kept for a long period of time may cause issues, filling up datastores and also may impact performance of the virtual machine."
$Display = "Table"
$Author = "Raphael Schitz, Shawn Masterson"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$snapp = @()
Foreach ($vmg in ($VM | Where-Object {$_.ExtensionData.Snapshot})) {
   $hddsize = ($vmg | Get-HardDisk | Measure-Object -sum CapacityGB).sum
   $snapInfo = $vmg | Get-Snapshot | Measure-Object -Sum SizeGB

   $oversize = [math]::round((((($snapInfo.Sum + $hddsize)*100)/$hddsize)-100), 2)
   if ($hddsize -eq 0) { 
      $overSize = "Linked Clone" 
   }
   
   New-Object -TypeName PSObject -Property ([ordered]@{
      VM = $vmg.Name
      vmdkSizeGB = [math]::round($hddsize,2)
      SnapSizeGB = [math]::round($snapInfo.Sum, 2)
      SnapCount = $snapInfo.count 
      "OverSize %" = $oversize
   })
 }

$snapp | Select-Object VM, vmdkSizeGB, SnapSizeGB, SnapCount, @{N="OverSize %";E={$_.OverSize}} | Sort-Object "OverSize %" -Descending

# Changelog
## 1.3 : Rewritten to cleanup and compare vmdk size to only snapshot size
## 1.4 : Code refactor