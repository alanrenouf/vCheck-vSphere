$Title = "Missing ESXi patches Summary"
$Header = "Missing ESXi patches Summary"
$Comments = "The following is a summary of non-compliant patches for the hosts."
$Display = "Table"
$Author = "Conrad Ramos(vNoob)"
$PluginVersion = 1
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 


Import-Module vmware.vumautomation -ErrorAction SilentlyContinue

   foreach($esx in $VMH){
      foreach($baseline in (Get-Compliance -Entity $esx -Detailed | Where-Object {$_.Status -eq "NotCompliant"})){
         $baseline |
         Select-Object @{N="Host";E={$esx.Name}},
         @{N="Baseline";E={$baseline.Baseline.name}},
         @{N="Count";E={$_.notcompliantpatches.count}
      }
   }
}
