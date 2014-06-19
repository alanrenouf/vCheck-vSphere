# Start of Settings
# End of Settings

$Result = @($VMH | Where-Object {$_.ExtensionData.Summary.RebootRequired} | Select-Object -Property Name, State)
$Result

$Title = "Hosts with reboot required"
$Header = "Hosts with reboot required : $(@($Result).count)"
$Comments = "The following hosts require a reboot."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
