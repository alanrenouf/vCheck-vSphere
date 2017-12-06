$Title = "Hosts with Upcoming Certificate Expiration"
$Comments = "The following hosts have certificates that will expire soon and will need to be replaced."
$Display = "Table"
$Author = ""
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# How many days to warn before cert expiration (Default 60)
$WarningDays = 60
# End of Settings

# Update settings where there is an override
$WarningDays = Get-vCheckSetting $Title "WarningDays" $WarningDays

# Changelog
## 1.1 : Added filter for connected Hosts only

Function Test-WebServerSSL { 
# Function original location: http://en-us.sysadmins.lv/Lists/Posts/Post.aspx?List=332991f0-bfed-4143-9eea-f521167d287c&ID=60 
[CmdletBinding()] 
    param( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)] 
        [string]$URL, 
        [Parameter(Position = 1)] 
        [ValidateRange(1,65535)] 
        [int]$Port = 443, 
        [Parameter(Position = 2)] 
        [Net.WebProxy]$Proxy, 
        [Parameter(Position = 3)] 
        [int]$Timeout = 15000, 
        [switch]$UseUserContext 
    ) 
Add-Type @" 
using System; 
using System.Net; 
using System.Security.Cryptography.X509Certificates; 
namespace PKI { 
    namespace Web { 
        public class WebSSL { 
            public Uri OriginalURi; 
            public Uri ReturnedURi; 
            public X509Certificate2 Certificate; 
            //public X500DistinguishedName Issuer; 
            //public X500DistinguishedName Subject; 
            public string Issuer; 
            public string Subject; 
            public string[] SubjectAlternativeNames; 
            public bool CertificateIsValid; 
            //public X509ChainStatus[] ErrorInformation; 
            public string[] ErrorInformation; 
            public HttpWebResponse Response; 
        } 
    } 
} 
"@ 
    $ConnectString = "https://$url`:$port" 
    $WebRequest = [Net.WebRequest]::Create($ConnectString) 
    $WebRequest.Proxy = $Proxy 
    $WebRequest.Credentials = $null 
    $WebRequest.Timeout = $Timeout 
    $WebRequest.AllowAutoRedirect = $true 
    [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} 
    try {$Response = $WebRequest.GetResponse()} 
    catch {} 
    if ($WebRequest.ServicePoint.Certificate -ne $null) { 
        $Cert = [Security.Cryptography.X509Certificates.X509Certificate2]$WebRequest.ServicePoint.Certificate.Handle
        try {$SAN = ($Cert.Extensions | Where-Object {$_.Oid.Value -eq "2.5.29.17"}).Format(0) -split ", "} 
        catch {$SAN = $null} 
        $chain = New-Object Security.Cryptography.X509Certificates.X509Chain -ArgumentList (!$UseUserContext) 
        [void]$chain.ChainPolicy.ApplicationPolicy.Add("1.3.6.1.5.5.7.3.1") 
        $Status = $chain.Build($Cert) 
        New-Object PKI.Web.WebSSL -Property @{ 
            OriginalUri = $ConnectString; 
            ReturnedUri = $Response.ResponseUri; 
            Certificate = $WebRequest.ServicePoint.Certificate; 
            Issuer = $WebRequest.ServicePoint.Certificate.Issuer; 
            Subject = $WebRequest.ServicePoint.Certificate.Subject; 
            SubjectAlternativeNames = $SAN; 
            CertificateIsValid = $Status; 
            Response = $Response; 
            ErrorInformation = $chain.ChainStatus | ForEach-Object {$_.Status}
        } 
        $chain.Reset() 
        [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
    } else { 
        Write-Error $Error[0] 
    } 
}
# Plugin to report on upcoming host certificate expirations

# Check for Host Certificates 
$VMH | Where-Object {$_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance"} | Foreach-Object { Test-WebServerSSL -URL $_.Name | Select-Object OriginalURi, Issuer, @{N="Expires";E={$_.Certificate.NotAfter} }, @{N="DaysTillExpire";E={(New-TimeSpan -Start (Get-Date) -End ($_.Certificate.NotAfter)).Days} }|? {$_.DaysTillExpire -le $WarningDays}}

$Header = ("Hosts with upcoming Certificate Expirations: {0} Days" -f $WarningDays)