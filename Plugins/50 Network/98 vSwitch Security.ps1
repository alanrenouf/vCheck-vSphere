$Title = "vSwitch Security"
$Header = "vSwitch and portgroup security settings"
$Comments = "All security options for standard and distributed switches and port groups should be set to REJECT unless explicitly required, except for ForgedTrasmits which is required on vDS uplink port groups."
$Display = "Table"
$Author = "Justin Mercier, Sam McGeown, John Sneddon, Ben Hocker, Dan Barr"
$PluginVersion = 1.5
$PluginCategory = "vSphere"

# Start of Settings
# Warn for AllowPromiscuous enabled?
$AllowPromiscuousPolicy = $true
# Warn for ForgedTransmits enabled?
$ForgedTransmitsPolicy = $true
# Warn for MacChanges enabled?
$MacChangesPolicy = $true
# End of Settings

# Update settings where there is an override
$AllowPromiscuousPolicy = Get-vCheckSetting $Title "AllowPromiscuousPolicy" $AllowPromiscuousPolicy
$ForgedTransmitsPolicy = Get-vCheckSetting $Title "ForgedTransmitsPolicy" $ForgedTransmitsPolicy
$MacChangesPolicy = Get-vCheckSetting $Title "MacChangesPolicy" $MacChangesPolicy

# Check Power CLI version. Build must be at least 1012425 (5.1 Release 2) to contain Get-VDPortGroup cmdlet
$VersionOK = $false

if (((Get-PowerCLIVersion) -match "VMware.* PowerCLI (.*) build ([0-9]+)")) {

    if ([int]($Matches[2]) -ge 1012425) {
        $VersionOK = $true
        if ([int]($Matches[2]) -ge 2548067) {
            #PowerCLI 6+
            if (!(Get-Module -Name VMware.VimAutomation.Vds -ErrorAction SilentlyContinue)) {
                Import-Module VMware.VimAutomation.Vds
            }
        }
        else {
            # Add required Snap-In
            if (!(Get-PSSnapin -name VMware.VimAutomation.Vds -ErrorAction SilentlyContinue)) {
                Add-PSSnapin VMware.VimAutomation.Vds
            }
        }
    }
}

if ($VersionOK) {
    [array] $results = $null

    Get-VirtualSwitch | ForEach-Object {
        $Output = "" | Select-Object Host, Type, vSwitch, Portgroup, AllowPromiscuous, ForgedTransmits, MacChanges
        if ($_.ExtensionData.Summary -ne $null) {
            $Output.Type = "vDS"
            $Output.Host = "*"
        }
        else {
            $Output.Type = "vSS"
            $Output.Host = $_.VMHost
        }
        $Output.vSwitch = $_.Name
        $Output.Portgroup = "(none)"
        $Output.AllowPromiscuous = ($_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value -or $_.ExtensionData.Spec.Policy.Security.AllowPromiscuous)
        $Output.ForgedTransmits = ($_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value -or $_.ExtensionData.Spec.Policy.Security.ForgedTransmits)
        $Output.MacChanges = ($_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value -or $_.ExtensionData.Spec.Policy.Security.MacChanges)
        $results += $Output
    }

    Get-VDPortGroup | ForEach-Object {
        $Output = "" | Select-Object Host, Type, vSwitch, Portgroup, AllowPromiscuous, ForgedTransmits, MacChanges
        $Output.Host = "*"
        if ($_.ExtensionData.Config.Uplink -eq $true) {
            $Output.Type = "vDS Uplink Port Group"
        }
        else {
            $Output.Type = "vDS Port Group"
        }
        $Output.vSwitch = $_.VDSwitch
        $Output.Portgroup = $_.Name
        $Output.AllowPromiscuous = $_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.AllowPromiscuous.Value
        $Output.ForgedTransmits = $_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.ForgedTransmits.Value
        $Output.MacChanges = $_.ExtensionData.Config.DefaultPortConfig.SecurityPolicy.MacChanges.Value
        $results += $Output
    }

    $VMH | Where-Object { $_.ConnectionState -eq "Connected" } | ForEach-Object {
        $VMHost = $_
        Get-VirtualPortGroup -VMHost $_ -Standard | ForEach-Object {
            $Output = "" | Select-Object Host, Type, vSwitch, Portgroup, AllowPromiscuous, ForgedTransmits, MacChanges
            $Output.Host = $VMHost.Name
            $Output.Type = "vSS Port Group"
            $Output.vSwitch = $_.VirtualSwitch
            $Output.Portgroup = $_.Name
            $Output.AllowPromiscuous = $_.ExtensionData.Spec.Policy.Security.AllowPromiscuous -and ($_.Spec.Policy.Security.AllowPromiscuous -eq $null)
            $Output.ForgedTransmits = $_.ExtensionData.Spec.Policy.Security.ForgedTransmits -and ($_.Spec.Policy.Security.ForgedTransmits -eq $null)
            $Output.MacChanges = $_.ExtensionData.Spec.Policy.Security.MacChanges -and ($_.Spec.Policy.Security.MacChanges -eq $null)
            $results += $Output
        }
    }

    if ($results.Host) { $results | Where-Object { ($_.AllowPromiscuous -and $AllowPromiscuousPolicy) -or ($_.ForgedTransmits -and $ForgedTransmitsPolicy -and $_.Type -ne "vDS Uplink Port Group") -or ($_.MacChanges -and $MacChangesPolicy) } | Sort-Object vSwitch, PortGroup }
}
else {
    Write-Warning "PowerCLi version installed is lower than 5.1 Release 2"
    New-Object PSObject -Property @{"Message" = "PowerCLi version installed is lower than 5.1 Release 2, please update to use this plugin"}
}

# Changelog
## 1.0 : Initial Release
## 1.1 : Re-written for performance improvements
## 1.2 : Added version check (Issue #71)
## 1.3 : Add Get-vCheckSetting
## 1.4 : Fix Version checking for PowerCLI 6.5 - vSphere is no longer in the product name (Issue #514)
## 1.5 : Ignore ForgedTransmits on vDS Uplink port groups, removed redundant plugin variable block, fixed logic bugs

# SIG # Begin signature block
# MIIaIwYJKoZIhvcNAQcCoIIaFDCCGhACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUELLv3hTzfKexo4LivqYqNuGG
# W0ugghTdMIIG3jCCBMagAwIBAgITLAAACIZKKD9KFQrLmwAAAAAIhjANBgkqhkiG
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
# CSziJmK/O6mXUczHRDKBsq/P3zGCBLAwggSsAgEBMHwwZTETMBEGCgmSJomT8ixk
# ARkWA2NvbTEdMBsGCgmSJomT8ixkARkWDWNvcm5lcnN0b25lbncxGDAWBgoJkiaJ
# k/IsZAEZFghpbnRlcm5hbDEVMBMGA1UEAxMMQ1NOVyBSb290IENBAhMsAAAIhkoo
# P0oVCsubAAAAAAiGMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSe/ciH6iR9qtfHnT9XuywtOMhR
# nDALBgcqhkjOPQIBBQAERzBFAiBBPoueeQ0S1NLXfAv52TahoCNdgKsSXGHXnD7r
# /AXZEQIhANQBQdg+/1CMhVwU/nU3dWJQrn16gOdKO8JYHHx4ldc2oYIDTDCCA0gG
# CSqGSIb3DQEJBjGCAzkwggM1AgEBMIGSMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0EgVGltZSBTdGFt
# cGluZyBDQQIRAIx3oACP9NGwxj2fOkiDjWswDQYJYIZIAWUDBAICBQCgeTAYBgkq
# hkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMTA2MDQyMzU4
# MjhaMD8GCSqGSIb3DQEJBDEyBDDWoPYWzxob8ffG+x1LyEHSdBmyenZUpHnLaxNU
# ihOq1oWnKzVVwuVUnyrpoNfGOqgwDQYJKoZIhvcNAQEBBQAEggIAQezqR2g/aosN
# +QDKJQeYKJwMMlTiUV9SBZzcW7kLJZ7GRHfcwtRE6nYLRTPBAvgaauvBjVfJMDjw
# MmAWiRPcOmkRgj5vvplEUi6BO1i9VtDwRJ/ZUpa7mM7YhnkXQ1Mh88iYsIk3ze60
# vK+WjXUIZpcMOeONgz00puZcEUNKoE3B6iccqz0W1xtaNJQgJIKi6SVgiXdxbF+p
# JgEuTYr8gb6fLSNTMmBhiHRwyg/vNi/PIgFv4a5ZLeCaELgH2hZW5ZfQzzbcXbYa
# ucXldmW040pMGOYYRp5atHLba8J3HD947uGzBP2Lt1AWl6ukKFOM/DGmn4/yfcIj
# gUw6S+z4Yboc3GMjGusJd2YmL/SaPeOSwZIXwbS4C1Y8A+QPQsdvCBaw1r7RvywW
# rz5a198t3tWMCyGrYzgxerOtqwTmoZnwql05NNs/IJqGGvnNe3JSNlJXSiOGWYEb
# baTLyImu8risxMk/v3l54PbPS0nydpVRZ4F0Ux1v/QvPINhKpbLSe60mCiueQmq7
# BoiA+4wTz3E55E6SGj4t0qY72BfscwIlBmVZTDCjiiXVhUQUK2GwQFZMcNxcznCf
# HcDQd7skuNJ/hsmR/fNEdbmHuOtI6xyS1dIL6eP1bgGWzh4PqDHKTa8/kUBvSxuY
# hyNxeoFC7zTpVe8vQRMsGrZezwId6co=
# SIG # End signature block
