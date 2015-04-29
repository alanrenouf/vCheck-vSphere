# Start of Settings 
# End of Settings

$CPUMMU = @(Get-VM | Sort -Property Name | Select-Object Name, @{N="Virtual Exec"; E={$_.ExtensionData.Config.Flags.VirtualExecUsage}}, @{N="Virtual MMU"; E={$_.ExtensionData.Config.Flags.VirtualMmuUsage}})
$CPUMMU

$Title = "Hardware CPU/MMU virtualization configuration"
$Header = "Hardware CPU/MMU virtualization configuration"
$Comments = "The following lists all VMs and their hardware CPU/MMU virtualization configuration"

$Display = "Table"
$Author = "Marc Bouchard"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
