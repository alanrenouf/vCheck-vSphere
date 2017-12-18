$Title = "Missing ESX(i) updates and patches"
$Header = "Missing ESX(i) updates and patches: [count]"
$Comments = "The following updates and/or patches are not applied."
$Display = "Table"
$Author = "Luc Dekens"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

# Note: This plugin needs the vCenter Update Manager PowerCLI snap-in installed
# https://communities.vmware.com/community/vmtn/automationtools/powercli/updatemanager
# (Current version 5.1 locks up in PowerShell v3; use "-version 2" when launching.)

If (Get-PSSnapin Vmware.VumAutomation -ErrorAction SilentlyContinue) {
   foreach($esx in $VMH){
      foreach($baseline in (Get-Compliance -Entity $esx -Detailed | Where-Object {$_.Status -eq "NotCompliant"})){
         $baseline.NotCompliantPatches |
         Select-Object @{N="Host";E={$esx.Name}},
         @{N="Baseline";E={$baseline.Baseline.Name}},Name,ReleaseDate,IdByVendor,
         @{N="KB";E={(Select-String "(?<url>http://[\w|\.|/]*\w{1})" -InputObject $_.Description).Matches[0].Groups['url'].Value}}
      }
   }
}
