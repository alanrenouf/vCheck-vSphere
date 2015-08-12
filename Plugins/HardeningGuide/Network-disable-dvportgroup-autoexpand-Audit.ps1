# Start of Settings 
$Display = "Table"
# End of Settings

$MyCollection = @()

$vpg = Get-VDPortgroup | where {$_.Name.substring(0,10) -ne "DVUplinks-"}
$vpc = $vpg.count

$vminfo = Get-VDPortGroup | Select Name, NumPorts, @{N="AutoExpand";E={$_.ExtensionData.Config.AutoExpand}} | where {$_.AutoExpand -ne $false}
foreach ($vmtemp in $vminfo) {
	if($vmtemp.Name.substring(0,10) -ne "DVUplinks-"){
		$Details = New-object PSObject
		$Details | Add-Member -Name Name -Value $vmtemp.Name -Membertype NoteProperty
		$Details | Add-Member -Name NumPorts -Value $vmtemp.NumPorts -Membertype NoteProperty
		$Details | Add-Member -Name AutoExpand -Value $vmtemp.AutoExpand -Membertype NoteProperty
		$MyCollection += $Details
	}
}

if($MyCollection.count -eq 0){
	$MyCollection = New-object PSObject
	$detail = "**************** All $vpc DVS Port Groups Passed - Autoexpand disabled ****************"
	$MyCollection | Add-Member -Name PASSED -Value $detail -Membertype NoteProperty
	$Display = "List"
}

$MyCollection

$Title = "vNetwork-disable-dvportgroup-autoexpand"
$Header = "Harden vNetwork (Audit only): Verify that the autoexpand option for VDS dvPortgroups is disabled"
$Comments = "vNetwork disable-dvportgroup-autoexpand: If the 'no-unused-dvports' guideline is followed, there should be only the amount of ports on a VDS that are actually needed. The Autoexpand feature on VDS dvPortgroups can override that limit. The feature allows dvPortgroups to automatically add 10 virtual distributed switch ports to a dvPortgroup that has run out of available ports. The risk is that maliciously or inadvertently, a virtual machine that is not supposed to be part of that portgroup is able to affect confidentiality, integrity or authenticity of data of other virtual machines on that portgroup. To reduce the risk of inappropriate dvPortgroup access, the autoexpand option on VDS should be disabled. By default the option is disabled, but regular monitoring should be implemented to verify this has not been changed. ** Production PCI-compliant hosts should show 0 OpenPorts & AutoExpand disabled, but this section can be ignored in the QA/BCP environment. **"
$Author = "Greg Hatch"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# SIG # Begin signature block
# MIIOrQYJKoZIhvcNAQcCoIIOnjCCDpoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1fI7wpsZJTh1Hv8es/t4R7Fi
# 2tmgggwfMIIFtjCCBJ6gAwIBAgIKXWDzyQAAAAAAAjANBgkqhkiG9w0BAQUFADBA
# MRMwEQYKCZImiZPyLGQBGRYDY29tMRMwEQYKCZImiZPyLGQBGRYDcmpmMRQwEgYD
# VQQDEwtSSkYgUm9vdCBDQTAeFw0xMjAzMTMxOTIxMTZaFw0yMjAzMTMxOTMxMTZa
# MEkxEzARBgoJkiaJk/IsZAEZFgNjb20xEzARBgoJkiaJk/IsZAEZFgNyamYxHTAb
# BgNVBAMTFFJKRiBJbnRlcm1lZGlhdGUgQ0ExMIIBIjANBgkqhkiG9w0BAQEFAAOC
# AQ8AMIIBCgKCAQEAknqLxFvhoooUS4gRFg/y0bmxGR8jBRAjJ/HMq/WQoZsEBHvC
# 3SvC9Xekns5KhrVcIttFpRKemVV0HktFQjaq/FZv7LTZCDDO8ypmBrKKe3BEJbWP
# 9cF8pw/hCfs9M21dz4iwL/bQGimeXUw1BABwJbpfPiOlfAV0/aobN6DO6B2C51+e
# tYphLDL5mVzbHOgB4uYqI/gZ+AXuoFFI47o/ZJDbKMD5dberHngR/o4CNAyBs5IO
# 01mrI7+iCClyzUIGW7Iz+d+Z7LHbF1WIkSdE6dvmYlwOetGzOdQiB5aI+Vmp9OS6
# Ql3WGZ+XFpkF5rJ9uBtxrrEIHCfqs3kZQZctVwIDAQABo4ICpzCCAqMwEAYJKwYB
# BAGCNxUBBAMCAQAwHQYDVR0OBBYEFOtfPg3C3BQKUqQEvXhlzh/qphMbMBkGCSsG
# AQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTAD
# AQH/MB8GA1UdIwQYMBaAFGy7gxZyguUsyPWl1aVnmLC9yjwIMIIBBAYDVR0fBIH8
# MIH5MIH2oIHzoIHwhoG4bGRhcDovLy9DTj1SSkYlMjBSb290JTIwQ0EsQ049U1BV
# UkZPV0wxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2
# aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWludHJvb3QsREM9Y29tP2NlcnRpZmlj
# YXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRp
# b25Qb2ludIYzaHR0cDovL2dvYnkyLnJqZi5jb20vQ2VydEVucm9sbC9SSkYlMjBS
# b290JTIwQ0EuY3JsMIIBDAYIKwYBBQUHAQEEgf8wgfwwga4GCCsGAQUFBzAChoGh
# bGRhcDovLy9DTj1SSkYlMjBSb290JTIwQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtl
# eSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9aW50
# cm9vdCxEQz1jb20/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRp
# ZmljYXRpb25BdXRob3JpdHkwSQYIKwYBBQUHMAKGPWh0dHA6Ly9nb2J5Mi5yamYu
# Y29tL0NlcnRFbnJvbGwvU1BVUkZPV0wxX1JKRiUyMFJvb3QlMjBDQS5jcnQwDQYJ
# KoZIhvcNAQEFBQADggEBANWlmBSDlGP9E69sRH0kVucmdegSpF03eru6OOIKoXae
# IzGigm3q/GnKfiPZXzFpCvbTPAc/goZg9vwKigAxzMKkagno/aG/q4gRtNF7zlCz
# /o7rDu/oaLoUpZzO/YWFocbio02PKTTxHxamFgzukfE0QdaLEPS0kWP6KczIrxeR
# rkV8GULeKU54htMA34urqgvzZO8j16C0Wc43n01J+AeA+DIAY3smqJ+Lt+zhIngj
# BaL1zjYVwcUolrfYDCVQajCCIXsiM0nSLde+WJc/Y4XUA/LF+/yO2WSfyxMzmNoO
# 5oUxVbYqqsHzQ8yEbMG1nnCXa75T2BKhKuFqJXXxYWQwggZhMIIFSaADAgECAgoR
# c67eAAAAAESOMA0GCSqGSIb3DQEBBQUAMEkxEzARBgoJkiaJk/IsZAEZFgNjb20x
# EzARBgoJkiaJk/IsZAEZFgNyamYxHTAbBgNVBAMTFFJKRiBJbnRlcm1lZGlhdGUg
# Q0ExMB4XDTE0MDUyODEyMzgwM1oXDTE2MDUyNzEyMzgwM1owgYsxCzAJBgNVBAYT
# AlVTMRAwDgYDVQQIEwdGbG9yaWRhMRcwFQYDVQQHEw5TdC4gUGV0ZXJzYnVyZzEg
# MB4GA1UEChMXUmF5bW9uZCBKYW1lcyBGaW5hbmNpYWwxGjAYBgNVBAsTEUlULVdl
# YiBPcGVyYXRpb25zMRMwEQYDVQQDEwpHcmVnIEhhdGNoMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAjy685uw11PVZrbRhCunPm0RUDYKLdTrHe44GLLit
# 9xVBF0atstgK++g9CsH4dmdHqZiHJxPv1zmtr1GjgS6GqA0vpVUZNISH9cL2CiLd
# m44duQpoIN23gLnsEbpdW9Fm6+ka+Sf50gM/MFDXscOJ+Nj0lFRRpqKgFlHAz9hK
# 5eAh6ZqxkqbV5JHVU7JHajm3HeN46g7JC45zBVvN1FuW0gP8MYlsqLN8h4nq7MWv
# fQIwEGNokqKRL4X8PNCcRtFzJq8JXQ5n67kZMUsmOmoARbisINxlhRs0RUzW+KOL
# R4xKQTP9BXGcNFSm9dD5Ca/aRIZZwZ5NzDBRTUIxJyvY9QIDAQABo4IDBjCCAwIw
# HQYDVR0OBBYEFOu1fn8ZaSPX8DtpMzfYmZIsa0ELMB8GA1UdIwQYMBaAFOtfPg3C
# 3BQKUqQEvXhlzh/qphMbMIIBFgYDVR0fBIIBDTCCAQkwggEFoIIBAaCB/oaBvWxk
# YXA6Ly8vQ049UkpGJTIwSW50ZXJtZWRpYXRlJTIwQ0ExLENOPUdPQlkyLENOPUNE
# UCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25m
# aWd1cmF0aW9uLERDPWludHJvb3QsREM9Y29tP2NlcnRpZmljYXRlUmV2b2NhdGlv
# bkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludIY8aHR0
# cDovL2dvYnkyLnJqZi5jb20vQ2VydEVucm9sbC9SSkYlMjBJbnRlcm1lZGlhdGUl
# MjBDQTEuY3JsMIIBJAYIKwYBBQUHAQEEggEWMIIBEjCBtwYIKwYBBQUHMAKGgaps
# ZGFwOi8vL0NOPVJKRiUyMEludGVybWVkaWF0ZSUyMENBMSxDTj1BSUEsQ049UHVi
# bGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlv
# bixEQz1pbnRyb290LERDPWNvbT9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xh
# c3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTBWBggrBgEFBQcwAoZKaHR0cDovL2dv
# YnkyLnJqZi5jb20vQ2VydEVucm9sbC9HT0JZMi5yamYuY29tX1JKRiUyMEludGVy
# bWVkaWF0ZSUyMENBMS5jcnQwCwYDVR0PBAQDAgeAMD8GCSsGAQQBgjcVBwQyMDAG
# KCsGAQQBgjcVCIOK9mSHxocch8GVD4ea9QmDlOoSOI3Y8b4VjfXDrn4CAWQCAQgw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEFBQcD
# AzANBgkqhkiG9w0BAQUFAAOCAQEAOw7Xx22vDsGvf01rLqyVc5akeDi+zawaxjvC
# AZBL8jiD9REDcalSnnSzh878y+qOOVvCEwqWkeZx8jg7ipzBasznZw0R1LMGTaCp
# VKKCmizEQw4wgxuRodiFgkKLlfeOJV12bKW+bnIPlEQiDNp8h0thvd42RYX0vGyy
# +6M/EaCcnmQEVLbu6yBHmcskBMYIiGpZSSR+2GQF8zQ8JtRx5bRA1LDEgNZN0ir4
# r7DgraARdjuI4d53ftPzBovl9wrNKcYWfMeFoPQD5I8bp0U1f+qP8/Qisk6kOKYy
# k0zkwMnAtrjHbB8FfVfy1w1FfMfeZHVkhFUVIkbzHxJUAjpNWjGCAfgwggH0AgEB
# MFcwSTETMBEGCgmSJomT8ixkARkWA2NvbTETMBEGCgmSJomT8ixkARkWA3JqZjEd
# MBsGA1UEAxMUUkpGIEludGVybWVkaWF0ZSBDQTECChFzrt4AAAAARI4wCQYFKw4D
# AhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZI
# hvcNAQkEMRYEFPZrsdLmgsubztTQyE+LTEkb8pf4MA0GCSqGSIb3DQEBAQUABIIB
# AHAOC3ZtFaESyVJDltueOFb3ooeZNuTV3b6UwRk+aBhwefU17QIOeCAj4PfCLsPK
# XXSEQZjjm4Me5tZkOoS1Mnt77OHOhKHAXeZITO8oo4fx3oH2JElsWPmyrAtAhO7z
# ARNlbjwm5q4FSlq8g5EcGIX3XlpLyCV1bm1rZygtVeUv+oyTEqNIYPWBdfw6Za/y
# 1h2fbnNMEGoJyLuK0huk9P7fJubtjrX4eJbX6NyUKBZgUF6cra/7mb+kwIiH67Yb
# Sj5CTE5RoXJ7EP8Z70Begaej3mC9A8jFQRa6ZQQF8r0QFGU183bODaXiVJeqKoW3
# TGgzN18/yH6BLoKnf8bODQs=
# SIG # End signature block
