$Title = "Hosts Dead LUN Path"
$Header = "Dead LunPath : [count]"
$Comments = "Dead LUN Paths may cause issues with storage performance or be an indication of loss of redundancy"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

foreach ($esxhost in ($HostsViews | Where-Object {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {
   $esxhost | Foreach-Object {$_.config.storageDevice.multipathInfo.lun} | Foreach-Object {$_.path} | Where-Object {$_.State -eq "Dead"} | Foreach-Object {
      New-Object PSObject -Property @{
         VMHost = $esxhost.Name
         Lunpath = $_.Name
         State = $_.state
      }
   }
}

# Changelog
## 1.1 : Alternate code in order to avoid usage of Get-ScsiLun for performance matter
## 1.2 : Code refactor