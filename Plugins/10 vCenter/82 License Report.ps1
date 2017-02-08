
# Start of Settings
# Enable License Reporting?
$licenseReport = $true
# Display Eval licenses?
$licenseEvals = $true
# End of Settings

# Changelog
## 1.0 : Initial Release
## 1.1 : Added the ability to exclude evaluation licenses, clean up whitespace (@thebillness)

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
            If ($Details.Name -notmatch "Evaluation") {
                $vSphereLicInfo += $Details
            } elseif ($licenseEvals) {
                $vSphereLicInfo += $Details
            }
        }
    }
    $vSphereLicInfo
}

$Title = "vCenter License Report"
$Header = "License Report"
$Comments = "The following displays licenses registered with this server and usage. Include Evals: $licenseEvals"
$Display = "Table"
$Author = "Justin Mercier, Bill Wall"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
