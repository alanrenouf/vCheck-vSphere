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

# SIG # Begin signature block
# MIIaIgYJKoZIhvcNAQcCoIIaEzCCGg8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrOnNsQNAGlubkcaDeVDfZQ9V
# VoOgghTdMIIG3jCCBMagAwIBAgITLAAACIZKKD9KFQrLmwAAAAAIhjANBgkqhkiG
# 9w0BAQ0FADBlMRMwEQYKCZImiZPyLGQBGRYDY29tMR0wGwYKCZImiZPyLGQBGRYN
# Y29ybmVyc3RvbmVudzEYMBYGCgmSJomT8ixkARkWCGludGVybmFsMRUwEwYDVQQD
# EwxDU05XIFJvb3QgQ0EwHhcNMjEwNTAzMjI0MDA1WhcNMjIwNTAzMjI0MDA1WjB7
# MRMwEQYKCZImiZPyLGQBGRYDY29tMR0wGwYKCZImiZPyLGQBGRYNY29ybmVyc3Rv
# bmVudzEYMBYGCgmSJomT8ixkARkWCGludGVybmFsMREwDwYDVQQLDAhPVV91c2Vy
# czEYMBYGA1UEAxMPVGhvbWFzLkZyZWFyc29uMFkwEwYHKoZIzj0CAQYIKoZIzj0D
# AQcDQgAE/PoIlU91LMGtwMi0ry9sKeeRq0TyOzWDZSW7N1XrLa+6mAdgUDciVp8J
# 1fqcyWMHFh4kRnuNq2+/zb92wWL99aOCAzowggM2MDwGCSsGAQQBgjcVBwQvMC0G
# JSsGAQQBgjcVCIX31ziG/ox0htmRD4bVkEqCuvg/XYfyuz+is2ECAWQCAQgwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsGCSsGAQQBgjcVCgQO
# MAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFKguBJKXvZckUGfMS1UGRjg1A8EQMB8G
# A1UdIwQYMBaAFFNLHk1vGE692PjWZ1QEcop+y1wOMIIBsQYDVR0fBIIBqDCCAaQw
# ggGgoIIBnKCCAZiGRWh0dHA6Ly9kYzEuaW50ZXJuYWwuY29ybmVyc3RvbmVudy5j
# b20vQ2VydEVucm9sbC9DU05XJTIwUm9vdCUyMENBLmNybIaBxWxkYXA6Ly8vQ049
# Q1NOVyUyMFJvb3QlMjBDQSxDTj1kYzEsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUy
# MFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9aW50ZXJu
# YWwsREM9Y29ybmVyc3RvbmVudyxEQz1jb20/Y2VydGlmaWNhdGVSZXZvY2F0aW9u
# TGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50hkdmaWxl
# Oi8vLy9kYzEuaW50ZXJuYWwuY29ybmVyc3RvbmVudy5jb20vQ2VydEVucm9sbC9D
# U05XJTIwUm9vdCUyMENBLmNybIY+aHR0cDovL3BraS5pbnRlcm5hbC5jb3JuZXJz
# dG9uZW53LmNvbS9wa2kvQ1NOVyUyMFJvb3QlMjBDQS5jcmwwgYAGCCsGAQUFBwEB
# BHQwcjBwBggrBgEFBQcwAYZkaHR0cDovL2RjMS5pbnRlcm5hbC5jb3JuZXJzdG9u
# ZW53LmNvbS9DZXJ0RW5yb2xsL2RjMS5pbnRlcm5hbC5jb3JuZXJzdG9uZW53LmNv
# bV9DU05XJTIwUm9vdCUyMENBLmNydDA8BgNVHREENTAzoDEGCisGAQQBgjcUAgOg
# IwwhdGhvbWFzLmZyZWFyc29uQGNvcm5lcnN0b25lbncuY29tMA0GCSqGSIb3DQEB
# DQUAA4ICAQBZn8FwZAJPkVZXMRL0gRu0HZmeBwXA/6B+RxABPMwdlPpm844MNCeg
# DF4C5Bu0LeePT5Ab1i0NtGecog58xF69Dbd6uvw72QdVbc9vndF1vqSmY3wJsqY/
# HCFaC0sJmvZf+HWxY+vI9ji96juPGJnQekpoChtQP5Ne/7AlGhYC6Vk4x6GIMmsI
# NvIK533hT7JYmivCmG0EupVJkzKnOe1HtDmFXFTIjznXB6lmU/f9ODSkGc8/3kN9
# 9QsL9hBoAtpltPYZ51raqGh8HDBK26BzvAFR46uM/r+Bn5tadrNph7zjC15Y4TpT
# dx4/zKXC98lcdXcWHez4yM8qB/lQmdb1QSlEErD2Jg3hWI31t9J29bnK5fKFS+4B
# lg+EIDPkniEOILPfDXX2ctsDebwsYGLvdI0fVg52ApaWjCTwt0K22CH26pvTMQsL
# KDnQFyZy5c8xqmPGgxtTzGY/80DKhO3u65TF9ouPr07tjcwejyJjt/4uj8O/pVML
# +bRU/m1krkIZ6cDkezT/xb36N9psESlQuhnaRaF8u1OxmvzR98yzI1mox/6vT6EJ
# ttw0pGF7hN0LT5vPNTcJOTlouWLgKBv/tdV1watycAvx84HOvreWIhE5ulhnQHdN
# u/vGgZUHyTnE4ohwTl3rnRUA4CNs+Y+AaUKnNx94O8PHKjMxZLV8EjCCBuwwggTU
# oAMCAQICEDAPb6zdZph0fKlGNqd4LbkwDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0
# eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VS
# VHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE5MDUwMjAwMDAw
# MFoXDTM4MDExODIzNTk1OVowfTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0
# ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSUwIwYDVQQDExxTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIENB
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyBsBr9ksfoiZfQGYPyCQ
# vZyAIVSTuc+gPlPvs1rAdtYaBKXOR4O168TMSTTL80VlufmnZBYmCfvVMlJ5Lslj
# whObtoY/AQWSZm8hq9VxEHmH9EYqzcRaydvXXUlNclYP3MnjU5g6Kh78zlhJ07/z
# Obu5pCNCrNAVw3+eolzXOPEWsnDTo8Tfs8VyrC4Kd/wNlFK3/B+VcyQ9ASi8Dw1P
# s5EBjm6dJ3VV0Rc7NCF7lwGUr3+Az9ERCleEyX9W4L1GnIK+lJ2/tCCwYH64TfUN
# P9vQ6oWMilZx0S2UTMiMPNMUopy9Jv/TUyDHYGmbWApU9AXn/TGs+ciFF8e4KRmk
# KS9G493bkV+fPzY+DjBnK0a3Na+WvtpMYMyou58NFNQYxDCYdIIhz2JWtSFzEh79
# qsoIWId3pBXrGVX/0DlULSbuRRo6b83XhPDX8CjFT2SDAtT74t7xvAIo9G3aJ4oG
# 0paH3uhrDvBbfel2aZMgHEqXLHcZK5OVmJyXnuuOwXhWxkQl3wYSmgYtnwNe/YOi
# U2fKsfqNoWTJiJJZy6hGwMnypv99V9sSdvqKQSTUG/xypRSi1K1DHKRJi0E5FAMe
# KfobpSKupcNNgtCN2mu32/cYQFdz8HGj+0p9RTbB942C+rnJDVOAffq2OVgy728Y
# UInXT50zvRq1naHelUF6p4MCAwEAAaOCAVowggFWMB8GA1UdIwQYMBaAFFN5v1qq
# K0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBQaofhhGSAPw0F3RSiO0TVfBhIEVTAO
# BgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggr
# BgEFBQcDCDARBgNVHSAECjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0
# cDovL2NybC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25B
# dXRob3JpdHkuY3JsMHYGCCsGAQUFBwEBBGowaDA/BggrBgEFBQcwAoYzaHR0cDov
# L2NydC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUG
# CCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEB
# DAUAA4ICAQBtVIGlM10W4bVTgZF13wN6MgstJYQRsrDbKn0qBfW8Oyf0WqC5SVmQ
# KWxhy7VQ2+J9+Z8A70DDrdPi5Fb5WEHP8ULlEH3/sHQfj8ZcCfkzXuqgHCZYXPO0
# EQ/V1cPivNVYeL9IduFEZ22PsEMQD43k+ThivxMBxYWjTMXMslMwlaTW9JZWCLjN
# XH8Blr5yUmo7Qjd8Fng5k5OUm7Hcsm1BbWfNyW+QPX9FcsEbI9bCVYRm5LPFZgb2
# 89ZLXq2jK0KKIZL+qG9aJXBigXNjXqC72NzXStM9r4MGOBIdJIct5PwC1j53BLwE
# NrXnd8ucLo0jGLmjwkcd8F3WoXNXBWiap8k3ZR2+6rzYQoNDBaWLpgn/0aGUpk6q
# PQn1BWy30mRa2Coiwkud8TleTN5IPZs0lpoJX47997FSkc4/ifYcobWpdR9xv1tD
# XWU9UIFuq/DQ0/yysx+2mZYm9Dx5i1xkzM3uJ5rloMAMcofBbk1a0x7q8ETmMm8c
# 6xdOlMN4ZSA7D0GqH+mhQZ3+sbigZSo04N6o+TzmwTC7wKBjLPxcFgCo0MR/6hGd
# HgbGpm0yXbQ4CStJB6r97DDa8acvz7f9+tCjhNknnvsBZne5VhDhIG7GrrH5trrI
# NV0zdo7xfCAMKneutaIChrop7rRaALGMq+P5CslUXdS5anSevUiumDCCBwcwggTv
# oAMCAQICEQCMd6AAj/TRsMY9nzpIg41rMA0GCSqGSIb3DQEBDAUAMH0xCzAJBgNV
# BAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1Nh
# bGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGln
# byBSU0EgVGltZSBTdGFtcGluZyBDQTAeFw0yMDEwMjMwMDAwMDBaFw0zMjAxMjIy
# MzU5NTlaMIGEMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVz
# dGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQx
# LDAqBgNVBAMMI1NlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgU2lnbmVyICMyMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkYdLLIvB8R6gntMHxgHKUrC+
# eXldCWYGLS81fbvA+yfaQmpZGyVM6u9A1pp+MshqgX20XD5WEIE1OiI2jPv4ICmH
# rHTQG2K8P2SHAl/vxYDvBhzcXk6Th7ia3kwHToXMcMUNe+zD2eOX6csZ21ZFbO5L
# IGzJPmz98JvxKPiRmar8WsGagiA6t+/n1rglScI5G4eBOcvDtzrNn1AEHxqZpIAC
# TR0FqFXTbVKAg+ZuSKVfwYlYYIrv8azNh2MYjnTLhIdBaWOBvPYfqnzXwUHOrat2
# iyCA1C2VB43H9QsXHprl1plpUcdOpp0pb+d5kw0yY1OuzMYpiiDBYMbyAizE+cgi
# 3/kngqGDUcK8yYIaIYSyl7zUr0QcloIilSqFVK7x/T5JdHT8jq4/pXL0w1oBqlCl
# i3aVG2br79rflC7ZGutMJ31MBff4I13EV8gmBXr8gSNfVAk4KmLVqsrf7c9Tqx/2
# RJzVmVnFVmRb945SD2b8mD9EBhNkbunhFWBQpbHsz7joyQu+xYT33Qqd2rwpbD1W
# 7b94Z7ZbyF4UHLmvhC13ovc5lTdvTn8cxjwE1jHFfu896FF+ca0kdBss3Pl8qu/C
# dkloYtWL9QPfvn2ODzZ1RluTdsSD7oK+LK43EvG8VsPkrUPDt2aWXpQy+qD2q4lQ
# +s6g8wiBGtFEp8z3uDECAwEAAaOCAXgwggF0MB8GA1UdIwQYMBaAFBqh+GEZIA/D
# QXdFKI7RNV8GEgRVMB0GA1UdDgQWBBRpdTd7u501Qk6/V9Oa258B0a7e0DAOBgNV
# HQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDBABgNVHSAEOTA3MDUGDCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRw
# czovL3NlY3RpZ28uY29tL0NQUzBEBgNVHR8EPTA7MDmgN6A1hjNodHRwOi8vY3Js
# LnNlY3RpZ28uY29tL1NlY3RpZ29SU0FUaW1lU3RhbXBpbmdDQS5jcmwwdAYIKwYB
# BQUHAQEEaDBmMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29SU0FUaW1lU3RhbXBpbmdDQS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQBKA3iQQjPsexqDCTYz
# mFW7nUAGMGtFavGUDhlQ/1slXjvhOcRbuumVkDc3vd/7ZOzlgreVzFdVcEtO9KiH
# 3SKFple7uCEn1KAqMZSKByGeir2nGvUCFctEUJmM7D66A3emggKQwi6Tqb4hNHVj
# ueAtD88BN8uNovq4WpquoXqeE5MZVY8JkC7f6ogXFutp1uElvUUIl4DXVCAoT8p7
# s7Ol0gCwYDRlxOPFw6XkuoWqemnbdaQ+eWiaNotDrjbUYXI8DoViDaBecNtkLwHH
# waHHJJSjsjxusl6i0Pqo0bglHBbmwNV/aBrEZSk1Ki2IvOqudNaC58CIuOFPePBc
# ysBAXMKf1TIcLNo8rDb3BlKao0AwF7ApFpnJqreISffoCyUztT9tr59fClbfErHD
# 7s6Rd+ggE+lcJMfqRAtK5hOEHE3rDbW4hqAwp4uhn7QszMAWI8mR5UIDS4DO5E3m
# KgE+wF6FoCShF0DV29vnmBCk8eoZG4BU+keJ6JiBqXXADt/QaJR5oaCejra3QmbL
# 2dlrL03Y3j4yHiDk7JxNQo2dxzOZgjdE1CYpJkCOeC+57vov8fGP/lC4eN0Ult4c
# DnCwKoVqsWxo6SrkECtuIf3TfJ035CoG1sPx12jjTwd5gQgT/rJkXumxPObQeCOy
# CSziJmK/O6mXUczHRDKBsq/P3zGCBK8wggSrAgEBMHwwZTETMBEGCgmSJomT8ixk
# ARkWA2NvbTEdMBsGCgmSJomT8ixkARkWDWNvcm5lcnN0b25lbncxGDAWBgoJkiaJ
# k/IsZAEZFghpbnRlcm5hbDEVMBMGA1UEAxMMQ1NOVyBSb290IENBAhMsAAAIhkoo
# P0oVCsubAAAAAAiGMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSm5qqMM6oiZz8GDWXErf5ckmgK
# 3TALBgcqhkjOPQIBBQAERjBEAiBkc13I2RPMoECdLanikEbLOt+NHwUyv1u3HnXN
# +od1SQIgD4tUknnfoIjvuyvzBKpaD/o7ewjFy2LdOSRPBY4kL5qhggNMMIIDSAYJ
# KoZIhvcNAQkGMYIDOTCCAzUCAQEwgZIwfTELMAkGA1UEBhMCR0IxGzAZBgNVBAgT
# EkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMP
# U2VjdGlnbyBMaW1pdGVkMSUwIwYDVQQDExxTZWN0aWdvIFJTQSBUaW1lIFN0YW1w
# aW5nIENBAhEAjHegAI/00bDGPZ86SIONazANBglghkgBZQMEAgIFAKB5MBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMDYwNDIzNTcx
# MFowPwYJKoZIhvcNAQkEMTIEMBnZW7VAXwIt0CkTpG3mSEXZEKKsxSFpRcAEObRQ
# o/0lId5kFil2iNFziqlrEKk+IDANBgkqhkiG9w0BAQEFAASCAgALyd+FCGc9+3e0
# Ccz6HcvG4j8d880/QbVcWKtDcCScAAs/Ej3IMQHIJ/o2++qgH1Q/zRjVM/6r3M5K
# YAkpRMJrxV7zoHqKr1G8ipt+qJdqGyFJik3n0Z7sdrrbEfmh9DmiHdyvn1lCqS/U
# IqpgGdXb84MXwXFUJpecWavah9VAPOLVpHgmaRA0Q/AUb98uQDRwyTrMMbs87IGj
# uOOaPW1zB+Sox769YUEtR0MBKzPCDDb9DZXvtheFQjJaqNHUWTxD04H3RvqjomTH
# qdnKorkttd/e7fmuTy0als8DNwHdTVw0ZoJACV8W16UCRvz0jhtlPAaNUUl81XwT
# kAl7sFmQIywnthUtItCsgEwuwI0glIzLy70PeI8WMi99pnG6P4G2VDOJnArzeV94
# XqLwr81YS9LTfNAUfSEKbt3K5KX77jdTLJzgQ2guOkZxBWh8sg+CE2Pwt7/yNQ0L
# A7BG9hZOI0biv1fZjqY7szQMPYAFHX/Fqiz+6JlTTQG2ugbPBKcPKbFmi6PswGYj
# sXw+TIXHzdNpINw2RibN2xsWAX5boykIdIn+YVshCRKZ6HdTF51v6JfWyENkJ22r
# F0Z10VUzA0vQ6otuiTk/dmGaqaR8WoBVFbNNcNFSuw7U1WMtn41llNe0/qqrtrlj
# WR0FaaVOW+PZDAaqKk6xAflGapXLrw==
# SIG # End signature block
