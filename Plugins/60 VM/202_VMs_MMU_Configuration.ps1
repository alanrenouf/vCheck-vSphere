$Title = "Hardware CPU/MMU virtualization configuration"
$Header = "Hardware CPU/MMU virtualization configuration"
$Comments = "The following lists all VMs and their hardware CPU/MMU virtualization configuration"
$Display = "Table"
$Author = "Marc Bouchard"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings

$VM | Select-Object Name, @{N="Virtual Exec"; E={$_.ExtensionData.Config.Flags.VirtualExecUsage}}, @{N="Virtual MMU"; E={$_.ExtensionData.Config.Flags.VirtualMmuUsage}}

# Change Log
## 1.0 : Initial release
## 1.1 : Remove Get-VM