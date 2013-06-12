# Start of Settings
# End of Settings
 
$Result = @( $VM | `
  Where-Object {$_.Guest.GuestId -and $_.Guest.GuestId -ne $_.ExtensionData.Config.GuestId} | `
  Select-Object -Property Name,@{N="GuestId";E={$_.Guest.GuestId}},
    @{N="Guest OS";E={$_.Guest.OSFullName}},
    @{N="Configured GuestId";E={$_.ExtensionData.Config.GuestId}},
    @{N="Configured Guest OS";E={$_.ExtensionData.Config.GuestFullName}}
)
$Result
 
$Title = "Virtual machines with incorrect OS configuration"
$Header =  "Virtual machines with incorrect OS configuration : $(@($Result).Count)"
$Comments = "The following virtual machines have an installed OS that is different from the configured OS. This can impact the performance of the virtual machine."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
