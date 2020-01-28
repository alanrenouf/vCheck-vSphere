$Title = "Hosts with reboot required"
$Header = "Hosts with reboot required : [count]"
$Comments = "The following hosts require a reboot."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.1
$PluginCategory = "vSphere"


# Start of Settings
# End of Settings

$VMH | Where-Object {$_.ExtensionData.Summary.RebootRequired} | Select-Object -Property Name, State