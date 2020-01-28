$Title = "ESXi with Technical Support mode or ESXi Shell enabled"
$Header = "ESXi Hosts with Tech Support Mode or ESXi Shell Enabled : [count]"
$Comments = "The following ESXi Hosts have Technical support mode or ESXi Shell enabled, this may not be the best security option, see here for more information: <a href='http://www.yellow-bricks.com/2010/03/01/disable-tech-support-on-esxi/' target='_blank'>Yellow-Bricks Disable Tech Support on ESXi</a>."
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$VMH | Where-Object { ($_.Version -lt 4.1) -and ($_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance") -and ($_.ExtensionData.Summary.Config.Product.Name -match "i")} | Select-Object Name, @{N="TechSuportModeEnabled";E={($_ | Get-AdvancedSetting -Name VMkernel.Boot.techSupportMode).value}} | Where-Object { $_.TechSuportModeEnabled -eq "True" }
$VMH | Where-Object { $_.Version -ge "4.1.0" } | Where-Object {$_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance"} | Select-Object Name, @{N="TechSuportModeEnabled";E={($_ | Get-VMHostService | Where-Object {$_.key -eq "TSM"}).Running}} | Where-Object { $_.TechSuportModeEnabled -eq "True" }