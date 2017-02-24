$Title = "ESXi hosts which do not have Lockdown mode enabled"
$Header = "ESXi Hosts with Lockdown Mode not Enabled: [count]"
$Comments = "The following ESXi Hosts do not have lockdown enabled, think about using lockdown as an extra security feature."
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$VMH | Where-Object {@("Connected","Maintenance") -contains $_.ConnectionState -and 
              $_.ExtensionData.Summary.Config.Product.Name -match "i" -and 
              -not $_.ExtensionData.Config.AdminDisabled} | `
                 Select-Object Name, @{N="LockedMode";E={$_.ExtensionData.Config.AdminDisabled}}