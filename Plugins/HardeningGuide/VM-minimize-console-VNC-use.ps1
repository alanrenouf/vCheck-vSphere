# Start of Settings 
$Display = "Table"
# End of Settings

$MyCollection = @()

foreach ($vmtemp in $VM) {
	$vminfo = Get-VM -Name $vmtemp | Get-AdvancedSetting "RemoteDisplay.vnc.enabled" | Select Entity, Value
	if(($vminfo.Value -eq $null) -or ($vminfo.Value -eq $true)){
		$Details = New-object PSObject
		$Details | Add-Member -Name Name -Value $vmtemp.Name -Membertype NoteProperty
		$MyCollection += $Details
		if($ScriptType -eq "Remediate"){
			$null = $vmtemp | New-AdvancedSetting -Name "RemoteDisplay.vnc.enabled" -value $false -Confirm:$false -Force
		}
	}
}

if($MyCollection.count -eq 0){
	$MyCollection = New-object PSObject
	$detail = "**************** All " + (@($VM).Count) + " VMs Passed  - Feature disabled ****************"
	$MyCollection | Add-Member -Name PASSED -Value $detail -Membertype NoteProperty
	$Display = "List"
}

$MyCollection

$Title = "VM-minimize-console-VNC-use"
$Header = "Harden VM (Audit & Remediate): Control access to VM console via VNC protocol"
$Comments = "VM minimize-console-VNC-use: The VM console enables you to connect to the console of a virtual machine, in effect seeing what a monitor on a physical server would show. This console is also availabe via the VNC protocol. Setting up this access also involves setting up firewall rules on each ESXi server the virtual machine will run on."
$Author = "Greg Hatch"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# SIG # Begin signature block
# MIIOrQYJKoZIhvcNAQcCoIIOnjCCDpoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqXE3gusp7mPW2ZrHgWDk2bXw
# 1f+gggwfMIIFtjCCBJ6gAwIBAgIKXWDzyQAAAAAAAjANBgkqhkiG9w0BAQUFADBA
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
# hvcNAQkEMRYEFBLMtJ8JMtVFuyZHyWiJt98ifSmNMA0GCSqGSIb3DQEBAQUABIIB
# AEmGHd31G92o0mzORdepsGXkidHhRHwQsqStEjipa8mlsC5nQAdvY9Oy80qVgJfV
# XXbPQ8xiXvxZx6Zl55/UIuRZZVCxyoaSkBmKsguTWgUpXYNv2h42jHnNzBNvbsWu
# axFBjZInuXt3PHXRJQrqpcReRVqbESf/9UmRMoag9htBaS9TZ67i3eZv/9ujE53C
# zt9LZ/gp/y3KUAxxiAPfYi8ZZgrp1MwwcGt8ve8rBtdyEuZnldvyIav3xPGiqxur
# 0nHosDmdyvc8RuC3j6LZ/BN7mva3WC428WCM7LC+aONNDbsH6SJ3VfrZ8baH3yoj
# Hh5zw5DaDR5Xmne3ScZpcrA=
# SIG # End signature block
