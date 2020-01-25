$Title = "Raw Device Mappings"
$Comments = ("The following RDMs can prevent the VMs from cloning Operations")
$Header = "Raw Device Mappings: [count]"
# End of Settings
$Title = "Raw Device Mappings"
$Header = "Raw Device Mappings: [count]"
$Comments = "The following RDMs are configured and can prevent VMs from clone operations"
$Display = "Table"
$Author = "Felix Longardt"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Get RDM-Devices
get-vm | Get-RDM | Select-Object VM,VMHost,Datastore,VMDK,HDSizeGB,HDLabel,HDMode,LUNID,DeviceName 

# Changelog
## 1.0 : Initial Version

$Comments = ("The following RDMs can prevent the VMs from cloning Operations")
