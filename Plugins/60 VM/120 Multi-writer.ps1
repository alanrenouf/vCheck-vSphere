# Start of Settings
# End of Settings

# Changelog
## 1.0 : Initial Version
## 1.1 : Change $VM variable to prevent clobbering

# Multi-writer parameter

ForEach ($mwvm in $FullVM){
    $mwvm.Config.ExtraConfig | Where {$_.Key -like "scsi*sharing"} |
    Select @{N="VM";E={$mwvm.Name}},Key,Value
}


$Title = "Multi-writer"
$Header = "[count] VMs with Multi-writer parameter"
$Comments = "The following VMs have multi-writer parameter. A problem will occur in case of svMotion without reconfiguration of the applications which are using these virtual disks and also change of the VM configuration concerned. More information <a href='http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1034165'>here</a>."
$Display = "Table"
$Author = "Petar Enchev, Luc Dekens"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
