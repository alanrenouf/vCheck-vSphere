$Title = "Host Build versions in use"
$Header = "Host Build versions in use"
$Comments = "The following host builds are in use in this vCenter"
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$HostsViews | Group-Object {$_.Summary.config.product.fullname} | `
   Select-Object @{Name="Version";Expression={$_.Name}}, Count | Sort-Object Count -Descending