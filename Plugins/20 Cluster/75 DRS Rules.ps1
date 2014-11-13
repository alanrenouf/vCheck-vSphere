# Start of Settings 
# Display VM affinity rules?
$ShowVMAffinity = $true
# Display VM anti-affinity rules?
$ShowVMAntiAffinity = $true
# Display HOSTaffinity rules?
$ShowHostAffinity = $true
# End of Settings

# Changelog
## 1.0 : Initial Version

# Add pretty icons
Add-ReportResource -cid "Error" -Type "SystemIcons" -ResourceData "Error"
Add-ReportResource -cid "OK" -Type "base64" -ResourceData "png|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"

#Compile an array of rule types to return
$Types = @()
if ($ShowVMAffinity)     { $Types += "VMAffinity"}
if ($ShowVMAntiAffinity) { $Types += "VMAntiAffinity"}
if ($ShowHostAffinity)   { $Types += "VMHostAffinity"}

$Clusters | Foreach {
	Get-DrsRule -Cluster $_ -Type $Types |
	Select Cluster, Enabled, Name, Type, @{N="VM";E={(Get-View $_.VMIDS | Select -ExpandProperty Name) -join "<br />"}},
	  @{N="Rule Host";E={(Get-View $_.AffineHostIds | Select -ExpandProperty Name) -join "<br />" }},
	  @{N="Running on";E={(Get-View (Get-View $_.VMIDS | %{$_.Runtime.Host}) | Select -ExpandProperty Name) -join "<br />"}}
}

$Title = "DRS Rules"
$Header = "DRS Rules"
$Comments = ("Contains all DRS rules defined in this vCenter - {0}" -f ($types -join ","))
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Table formatting rules 
$TableFormat = @{"Enabled" = @(@{ "-eq `$true"     = "Cell,cid|OK|16x16"; },
                               @{ "-eq `$false"    = "Cell,cid|Error|16x16" })
                 }
