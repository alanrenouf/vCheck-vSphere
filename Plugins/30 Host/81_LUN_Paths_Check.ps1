$Title = "Check LUNS have the recommended number of paths"
$Comments = "Not enough storage paths can effect storage availability in a FC SAN environment"
$Display = "Table"
$Author = "Craig Smith"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings 
# Set the Recommended number of paths per LUN
$RecLUNPaths = 2
# End of Settings

# Update settings where there is an override
$RecLUNPaths = Get-vCheckSetting $Title "RecLUNPaths" $RecLUNPaths

$missingpaths = @() 
foreach ($esxhost in ($HostsViews | Where-Object {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {
  #Write-Host $esxhost.Name
   $lun_array = @() # 2D array - LUN Name & Path Count
   $esxhost | Foreach-Object {$_.config.storageDevice.multipathInfo.lun} | Foreach-Object {$_.path} | Where-Object {$_.name -like "fc.*"} | Foreach-Object {
      $short_path_array = $_.name.split('-')
      $short_path = $short_path_array[2]
      $found = $false
      foreach ($lun in $lun_array) {
         if ($lun[0] -eq $short_path) {
            $found = $true
            $lun[1]++
         }
      }
      if (!($found)) {
         $lun_array +=(,($short_path,1))
      }
   }

   #Create report for ESX host
   foreach ($lun in $lun_array) {
      if ($lun[1] -lt $RecLUNPaths) {
         #Write-Host "Alerting due to lack of paths (" $lun[1] "looking for" $RecLUNPaths "), for LUN: " $lun[0]
         New-Object PSObject -Property @{
            ESXHost = $esxhost.Name
            LUN = $lun[0]
            Paths = $lun[1]
         }
      }
   }
}

$Header = ("LUNs not having the recommended number of paths ({0}): [count]" -f $RecLUNPaths)
