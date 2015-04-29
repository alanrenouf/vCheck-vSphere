# Start of Settings 
# End of Settings 

$ESXiTechMode = @()
$ESXiTechMode += $VMH | Where { ($_.Version -lt 4.1) -and ($_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance") -and ($_.ExtensionData.Summary.Config.Product.Name -match "i")} | Select Name, @{N="TechSuportModeEnabled";E={($_ | Get-AdvancedSetting -Name VMkernel.Boot.techSupportMode).value}}
$ESXiTechMode += $VMH | Where { $_.Version -ge "4.1.0" } | Where {$_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance"} | Select Name, @{N="TechSuportModeEnabled";E={($_ | Get-VMHostService | Where {$_.key -eq "TSM"}).Running}}
$Result = @($ESXiTechMode | Where { $_.TechSuportModeEnabled -eq "True" })
$Result

$Title = "ESXi with Technical Support mode or ESXi Shell enabled"
$Header = "ESXi Hosts with Tech Support Mode or ESXi Shell Enabled : $(@($Result).count)"
$Comments = "The following ESXi Hosts have Technical support mode or ESXi Shell enabled, this may not be the best security option, see here for more information: <a href='http://www.yellow-bricks.com/2010/03/01/disable-tech-support-on-esxi/' target='_blank'>Yellow-Bricks Disable Tech Support on ESXi</a>."
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"
