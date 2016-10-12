$Title = "vCenter License Report"
$Header = "License Report"
$Comments = "The following displays licenses registered with this server and usage."
$Display = "Table"
$Author = "Justin Mercier"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

$vSphereLicInfo = @()

Foreach ($LicenseMan in Get-View ($ServiceInstance | Select -First 1).Content.LicenseManager) 
{
   ($LicenseMan | Select -ExpandProperty Licenses) | Select @{Name="VC";e={([Uri]$LicenseMan.Client.ServiceUrl).Host}}, `
      Name, LicenseKey, Total, Used, @{Name="Information";e={$_.Labels | Select -ExpandProperty Value}}, `
      @{"Name"="ExpirationDate";e={$_.Properties | Where { $_.key -eq "expirationDate" } | Select -ExpandProperty Value}}
}

# Changelog
## 1.0 : Initial Release
## 1.1 : Code refactor