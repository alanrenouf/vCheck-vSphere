# Start of Settings
# VMs with incorrect OS Configuration, do not report on any VMs who are defined here
$VMTDoNotInclude = "VM1_*|VM2_*"
# End of Settings
 
$Result = @( $FullVM | Where {$_.Name -notmatch $VMTDoNotInclude} |`
  Where-Object {$_.Guest.GuestId -and $_.Guest.GuestId -ne $_.Config.GuestId} | `
  Select-Object -Property Name,@{N="GuestId";E={$_.Guest.GuestId}},
    @{N="Installed Guest OS";E={$_.Guest.GuestFullName}},
    @{N="Configured GuestId";E={$_.Config.GuestId}},
    @{N="Configured Guest OS";E={$_.Config.GuestFullName}}
)
$Result
 
$Title = "Virtual machines with incorrect OS configuration"
$Header = "Virtual machines with incorrect OS configuration : $(@($Result).Count)"
$Comments = "The following virtual machines have an installed OS that is different from the configured OS. This can impact the performance of the virtual machine."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
