# Start of Settings
# Display Eval licenses?
$licenseEvals = $true
# End of Settings

Foreach ($LicenseMan in Get-View ($ServiceInstance | Select-Object -First 1).Content.LicenseManager)
{
    $vSphereLicInfo = @()
    foreach ($License in ($LicenseMan | Select-Object -ExpandProperty Licenses | Where-Object {$licenseEvals -or $_.Name -notmatch "Evaluation" })) {
        $ExpirationDate = $License.Properties | Where-Object { $_.key -eq "expirationDate"} | Select-Object -ExpandProperty Value
        $inObj = [ordered] @{
            'vCenter Server' = ([URI]$LicenseMan.Client.ServiceUrl).Host
            'Product' = $License.Name
            'License Key' = $License.LicenseKey
            'Capacity' = $License.Total
            'Usage' = $License.Used
            'Information' = $License.Labels
            'Expiration Date' = Switch ([string]::IsNullOrEmpty($ExpirationDate)) {
                $true {'Never'}
                $false {$ExpirationDate.ToShortDateString()}
                default {'Unknown'}
            }
        }

        $vSphereLicInfo += [pscustomobject]$inobj

    }
}

$vSphereLicInfo

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
## 1.3 : Added the ability to detect never expiring licenses
