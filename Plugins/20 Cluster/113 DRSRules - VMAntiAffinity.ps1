# Start of Settings 
# End of Settings

# Changelog
## 1.0 : Initial Version

$Clusters | Foreach {
	Get-DrsRule -Cluster $_ -Type VMAntiAffinity |
	Select Cluster, Enabled, Name, @{N="Keep Together";E={"False"}}, @{N="VM";E={Get-View $_.VMIDS | Select -ExpandProperty Name}},
	  @{N="Rule Host";E={Get-View $_.AffineHostIds | Select -ExpandProperty Name}},
	  @{N="Running on";E={Get-View (Get-View $_.VMIDS | %{$_.Runtime.Host}) | Select -ExpandProperty Name}}
}


$Title = "DRSRules - VMAntiAffinity"
$Header = "DRSRules - List of VM Anti Affinity Rules"
$Comments = ""
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
