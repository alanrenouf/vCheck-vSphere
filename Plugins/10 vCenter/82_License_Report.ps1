# Start of Settings
# Display Eval licenses?
$licenseEvals = $true
# End of Settings

$vSphereLicInfo = @()

Foreach ($LicenseMan in Get-View ($ServiceInstance | Select-Object -First 1).Content.LicenseManager) 
{
   ($LicenseMan | Select-Object -ExpandProperty Licenses) | Where {$licenseEvals -or $_.Name -notmatch "Evaluation" } | Select-Object  @{Name="VC";e={([Uri]$LicenseMan.Client.ServiceUrl).Host}}, `
      Name, LicenseKey, Total, Used, @{Name="Information";e={$_.Labels | Select-Object -ExpandProperty Value}}, `
      @{"Name"="ExpirationDate";e={$_.Properties | Where-Object { $_.key -eq "expirationDate" } | Select-Object -ExpandProperty Value}} 
}

$Title = "vCenter License Report"
$Header = "License Report"
$Comments = "The following displays licenses registered with this server and usage. Include Evals: $licenseEvals"
$Display = "Table"
$Author = "Justin Mercier, Bill Wall"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Changelog
## 1.0 : Initial Release
## 1.1 : Code refactor
## 1.2 : Added the ability to exclude evaluation licenses, clean up whitespace (@thebillness)
