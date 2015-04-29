# Start of Settings
# Enable License Reporting?
$licenseReport = $true
# End of Settings

# Changelog
## 1.0 : Initial Release

if ($licenseReport) {

$vSphereLicInfo = @()
$ServiceInstance = Get-View ServiceInstance
Foreach ($LicenseMan in Get-View ($ServiceInstance | Select -First 1).Content.LicenseManager) {
    Foreach ($License in ($LicenseMan | Select -ExpandProperty Licenses)) {
        $Details = "" |Select VC, Name, Key, Total, Used, ExpirationDate , Information
        $Details.VC = ([Uri]$LicenseMan.Client.ServiceUrl).Host
        $Details.Name= $License.Name
        $Details.Key= $License.LicenseKey
        $Details.Total= $License.Total
        $Details.Used= $License.Used
        $Details.Information= $License.Labels | Select -expand Value
        $Details.ExpirationDate = $License.Properties | Where { $_.key -eq "expirationDate" } | Select -ExpandProperty Value
        $vSphereLicInfo += $Details
    }
}

$vSphereLicInfo

}

$Title = "vCenter License Report"
$Header = "License Report"
$Comments = "The following displays licenses registered with this server and usage."
$Display = "Table"
$Author = "Justin Mercier"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
