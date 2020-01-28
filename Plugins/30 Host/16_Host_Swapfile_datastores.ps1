$Title = "Host Swapfile datastores"
$Header = "Host Swapfile datastores not set : [count]"
$Comments = "The following hosts are in a cluster which is set to store the swap file in the datastore specified by the host but no location has been set on the host"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

foreach ($clusview in $clusviews) {
   if ($clusview.ConfigurationEx.VmSwapPlacement -eq "hostLocal") {
      $CluNodes = $VMH | Where-Object {$clusview.Host -contains $_.Id }
      foreach ($CluNode in $CluNodes) {
         if ($CluNode.VMSwapfileDatastore.Name -eq $null){
            if ($CluNode.ExtensionData.Config.LocalSwapDatastore.Value) {
               New-Object PSObject -Property @{
                  Cluster = $clusview.name
                  Host = $CluNode.name
                  Message = "Swap file location NOT SET"
               }
            }
         }
      }
   }
}