# Start of Settings 
# End of Settings 

$FullVM | Where {$_.Runtime.ConnectionState -eq "invalid" -or $_.Runtime.ConnectionState -eq "inaccessible"} | Sort Name | `
    Select Name, @{Name="ConnectionState";e={$_.Runtime.ConnectionState}}, @{Name="PowerState";e={$_.Runtime.PowerState}}, @{Name="IP_Address";e={$_.Guest.IpAddress}}

$Title = "Invalid or inaccessible VM"
$Header = "VM invalid or inaccessible: [count]]"
$Comments = "The following VMs are marked as inaccessible or invalid"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
