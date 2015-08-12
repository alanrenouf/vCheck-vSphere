# Start of Settings 
$Display = "Table"
# End of Settings

$MyCollection = @()
$null = New-VIProperty -Name ToolsUpgradePolicy -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.ToolsUpgradePolicy' -Force 

foreach ($vmtemp in $VM) {
	$vminfo = Get-VM -Name $vmtemp | Select Name, ToolsUpgradePolicy
	if($vminfo.ToolsUpgradePolicy -ne "manual"){
		$Details = New-object PSObject
		$Details | Add-Member -Name Name -Value $vmtemp.Name -Membertype NoteProperty
		$Details | Add-Member -Name ToolsUpgradePolicy -Value $vminfo.ToolsUpgradePolicy -Membertype NoteProperty
		$MyCollection += $Details
		if($ScriptType -eq "Remediate"){
			$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
			$spec.changeVersion = $vmtemp.ExtensionData.Config.ChangeVersion
			$spec.tools = New-Object VMware.Vim.ToolsConfigInfo
			$spec.tools.toolsUpgradePolicy = "manual"
			$_this = Get-View -Id $vmtemp.Id
			$null = $_this.ReconfigVM_Task($spec)
		}
	}
}

if($MyCollection.count -eq 0){
	$MyCollection = New-object PSObject
	$detail = "**************** All " + (@($VM).Count) + " VMs Passed - No tools auto-upgrade ****************"
	$MyCollection | Add-Member -Name PASSED -Value $detail -Membertype NoteProperty
	$Display = "List"
}

$MyCollection

$Title = "VM-disable-autoinstall"
$Header = "Harden VM (Audit & Remediate): Disable tools auto install on these VMs"
$Comments = "VM disable-autoinstall: Tools auto install can initiate an automatic reboot, disabling this option will prevent tools from being installed automatically and prevent automatic machine reboots"
$Author = "Greg Hatch"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# SIG # Begin signature block
# MIIO2AYJKoZIhvcNAQcCoIIOyTCCDsUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPGIQDUilzcKz0d6YKrzxp2Wz
# 8eagggxKMIIFtjCCBJ6gAwIBAgIKXWDzyQAAAAAAAjANBgkqhkiG9w0BAQUFADBA
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
# 5oUxVbYqqsHzQ8yEbMG1nnCXa75T2BKhKuFqJXXxYWQwggaMMIIFdKADAgECAgo8
# 4mWlAAAAAALpMA0GCSqGSIb3DQEBBQUAMEkxEzARBgoJkiaJk/IsZAEZFgNjb20x
# EzARBgoJkiaJk/IsZAEZFgNyamYxHTAbBgNVBAMTFFJKRiBJbnRlcm1lZGlhdGUg
# Q0ExMB4XDTEzMDUyMDE3NDY0NFoXDTE0MDUyMDE3NDY0NFowgbYxCzAJBgNVBAYT
# AlVTMQswCQYDVQQIEwJGTDEZMBcGA1UEBxMQU2FpbnQgUGV0ZXJzYnVyZzEgMB4G
# A1UEChMXUmF5bW9uZCBKYW1lcyBGaW5hbmNpYWwxGjAYBgNVBAsTEUlULVdlYiBP
# cGVyYXRpb25zMR8wHQYDVQQDExZHcmVnIEhhdGNoIC0gU2t5QnJpZGdlMSAwHgYJ
# KoZIhvcNAQkBFhFJVC1XZWIgT3BlcmF0aW9uczCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAL4opGowqeH98EQ+vFPdGR3T4VBTwS7xIGsj3PMTs7suZPEc
# T68xly6eo0Am9OvLAS/Q3HAcDI6Y1aCWq/NmzLgcUvERvkcmh4J+e7ina0hJFJZb
# ov5iMqyFhHATCUfK7OMSeWndA5GD/uM4eBKdl/AQguZvzXLD/ZzHW2MoSPXqkK3h
# IqGVanvedMa5cjCRbxACd4fKKq85GZoNRlTvGS6DrYkohSBZvOYq9NlRdrW4zrwT
# Q0uU/H9yO95pQynv11b9WwgmKe4BKdlnyFy8IeBh4Ms8jViEZ+/5hYAsjckxl68z
# uTEM4YPkcVoOuC0Y02iYWf8lSeUu+wniaCJ8tXkCAwEAAaOCAwYwggMCMD8GCSsG
# AQQBgjcVBwQyMDAGKCsGAQQBgjcVCIOK9mSHxocch8GVD4ea9QmDlOoSOI3Y8b4V
# jfXDrn4CAWQCAQcwEwYDVR0lBAwwCgYIKwYBBQUHAwMwCwYDVR0PBAQDAgeAMBsG
# CSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFHxf29k6Vvt9teZ9
# Bqf1gAhtZX4bMB8GA1UdIwQYMBaAFOtfPg3C3BQKUqQEvXhlzh/qphMbMIIBFgYD
# VR0fBIIBDTCCAQkwggEFoIIBAaCB/oaBvWxkYXA6Ly8vQ049UkpGJTIwSW50ZXJt
# ZWRpYXRlJTIwQ0ExLENOPUdPQlkyLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBT
# ZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWludHJvb3Qs
# REM9Y29tP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFz
# cz1jUkxEaXN0cmlidXRpb25Qb2ludIY8aHR0cDovL2dvYnkyLnJqZi5jb20vQ2Vy
# dEVucm9sbC9SSkYlMjBJbnRlcm1lZGlhdGUlMjBDQTEuY3JsMIIBJAYIKwYBBQUH
# AQEEggEWMIIBEjCBtwYIKwYBBQUHMAKGgapsZGFwOi8vL0NOPVJKRiUyMEludGVy
# bWVkaWF0ZSUyMENBMSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMs
# Q049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1pbnRyb290LERDPWNvbT9j
# QUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhv
# cml0eTBWBggrBgEFBQcwAoZKaHR0cDovL2dvYnkyLnJqZi5jb20vQ2VydEVucm9s
# bC9HT0JZMi5yamYuY29tX1JKRiUyMEludGVybWVkaWF0ZSUyMENBMS5jcnQwDQYJ
# KoZIhvcNAQEFBQADggEBAGWE+Qi2dVnCGXNoaKhGvq0sIe3b9lZny2HBjMArNMVE
# 38iH3+kv6ExmZC29QSwrGf8czvrvchsKCwfINzI6RiTBcitcz5ZoCM7w+QA1gWkf
# qFX+nQT6ZTkuILs3hXT1AzFI/x8Flwk/T2kJRzYANdrIvctrSofAijnJ8H/HqSVY
# yyuZU+mR6X1bhDqFcw9IMyN6a40Ij1+u/8j4BncIC4WnrAH//73bvBdlJICstXCw
# 7j39dJfkIi30azJoBfWJyG3hBaW1vBueaLXiJx5m35PhbCQBXXRTnbcpoA0ssOQQ
# I4YWKuRJwAGSW6HP591ZYCk9yaVrXfxphh7U4gt1IlMxggH4MIIB9AIBATBXMEkx
# EzARBgoJkiaJk/IsZAEZFgNjb20xEzARBgoJkiaJk/IsZAEZFgNyamYxHTAbBgNV
# BAMTFFJKRiBJbnRlcm1lZGlhdGUgQ0ExAgo84mWlAAAAAALpMAkGBSsOAwIaBQCg
# eDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEE
# AYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJ
# BDEWBBSbdEv75JOztUDjG9TxfZ8MwGYzWzANBgkqhkiG9w0BAQEFAASCAQAtxGrz
# EWVaO0yW/ajgLhrnzQvizQV1e/XrxZW5VDfsyiAEnKXyOHYUAXwTY+tH1Yc7RHF5
# C1yEUz0KKrW5gv85b4x6PR9WgbnijPEgCnn7cIFFy917kLpsi44IIv2X9XgFk0ab
# r5IYE3f/wCVu3rJVayVNyV0AfKqKBZGbGNMo1g3FzMKSZtMNU9FEFgV+nhCUY7zD
# UvbdIPK/bzmcrH03l9YzZP0Qlls2eKcciXav7NcYn0Q5P3iVtlj3TAch7lOZOcwR
# zmixmmfwBCQvghka0YfdZhGc7fSOHjs73r0/yymLd7cuGjzcqUjUWX8d6AZCB9LK
# XP0wqagCh+rE7aMD
# SIG # End signature block
