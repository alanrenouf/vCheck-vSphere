# Start of Settings 
# End of Settings

# Changelog
## 1.0 : Initial Version

$Clusters | Foreach {
	Get-DrsRule -Cluster $_ -Type VMAffinity |
	Select Cluster, Enabled, Name, @{N="Keep Together";E={"True"}}, @{N="VM";E={Get-View $_.VMIDS | Select -ExpandProperty Name}},
	  @{N="Rule Host";E={Get-View $_.AffineHostIds | Select -ExpandProperty Name}},
	  @{N="Running on";E={Get-View (Get-View $_.VMIDS | %{$_.Runtime.Host}) | Select -ExpandProperty Name}}
}


$Title = "DRSRules - VMAffinity"
$Header = "DRSRules - List of VM Affinity Rules"
$Comments = ""
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
