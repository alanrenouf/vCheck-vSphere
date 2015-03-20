# Start of Settings
# End of Settings

# Changelog
## 1.0 : Initial Version

# Multi-writer parameter

$Result = @(ForEach ($vm in $FullVM){
    $vm.Config.ExtraConfig | Where {$_.Key -like "scsi*sharing"} |
    Select @{N="VM";E={$vm.Name}},Key,Value
})
$Result

$Title = "Multi-writer"
$Header = "Multi-writer: $(@($Result).Count)"
$Comments = "The following VMs have multi-writer parameter. A problem will occur in case of svMotion without reconfiguration of the applications which are using these virtual disks and also change of the VM configuration concerned. More information <a href='http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1034165'>here</a>."
$Display = "Table"
$Author = "Petar Enchev, Luc Dekens"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
