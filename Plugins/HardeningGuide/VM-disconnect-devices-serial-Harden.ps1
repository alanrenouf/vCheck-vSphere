# Start of Settings 
$Display = "Table"
# End of Settings


#http://blogs.vmware.com/vipowershell/2012/05/working-with-vm-devices-in-powercli.html
function Get-SerialPort { 
    param ( 
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)] 
        $VM 
    ) 
    process { 
        foreach ($VMachine in $VM) { 
            foreach ($Device in $VMachine.ExtensionData.Config.Hardware.Device) { 
                if ($Device.gettype().Name -eq "VirtualSerialPort"){ 
                    $Details = New-Object PsObject 
                    $Details | Add-Member Noteproperty VM -Value $VMachine 
                    $Details | Add-Member Noteproperty Name -Value $Device.DeviceInfo.Label 
                    if ($Device.Backing.FileName) { $Details | Add-Member Noteproperty Filename -Value $Device.Backing.FileName } 
                    if ($Device.Backing.Datastore) { $Details | Add-Member Noteproperty Datastore -Value $Device.Backing.Datastore } 
                    if ($Device.Backing.DeviceName) { $Details | Add-Member Noteproperty DeviceName -Value $Device.Backing.DeviceName } 
                    $Details | Add-Member Noteproperty Connected -Value $Device.Connectable.Connected 
                    $Details | Add-Member Noteproperty StartConnected -Value $Device.Connectable.StartConnected 
                    $Details 
                } 
            } 
        } 
    } 
}

function Remove-SerialPort { 
    param ( 
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)] 
        $VM, 
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)] 
        $Name 
    ) 
    process { 
        $VMSpec = New-Object VMware.Vim.VirtualMachineConfigSpec 
        $VMSpec.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec 
        $VMSpec.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec 
        $VMSpec.deviceChange[0].operation = "remove" 
        $Device = $VM.ExtensionData.Config.Hardware.Device | foreach { 
            $_ | where {$_.gettype().Name -eq "VirtualSerialPort"} | where { $_.DeviceInfo.Label -eq $Name } 
        } 
        $VMSpec.deviceChange[0].device = $Device 
        $VM.ExtensionData.ReconfigVM_Task($VMSpec) 
    } 
}


$MyCollection = @()

$MyCollection = $VM | Get-SerialPort | select VM, Name, Connected, StartConnected
if($ScriptType -eq "Remediate"){
	$null = $vmtemp | Get-SerialPort | Remove-SerialPort
}

if($MyCollection.count -eq 0){
	$MyCollection = New-object PSObject
	$detail = "**************** All " + (@($VM).Count) + " VMs Passed - No serial devices present ****************"
	$MyCollection | Add-Member -Name PASSED -Value $detail -Membertype NoteProperty
	$Display = "List"
}

$MyCollection

$Title = "VM-disconnect-devices-serial"
$Header = "Harden VM (Audit & Remediate): Disconnect unauthorized devices"
$Comments = "VM disconnect-devices-serial: Besides disabling unnecessary virtual devices from within the virtual machine, you should ensure that no device is connected to a virtual machine if it is not required to be there. for example, serial and parallel ports are rarely used for virtual machines in a datacenter environment, and CD/DVD drives are usually connected only temporarily during software installation. for less commonly used devices that are not required, either the parameter should not be present or its value must be FALSE.  NOTE: The parameters listed are not sufficient to ensure that a device is usable; other parameters are required to indicate specifically how each device is instantiated.  Any enabled or connected device represents another potential attack channel."
$Author = "Greg Hatch"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# SIG # Begin signature block
# MIIO2AYJKoZIhvcNAQcCoIIOyTCCDsUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUW8bGVkjXYLQzzm/skui1xNiP
# U0WgggxKMIIFtjCCBJ6gAwIBAgIKXWDzyQAAAAAAAjANBgkqhkiG9w0BAQUFADBA
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
# BDEWBBQGXf7awMrVZVP+SfQx3PlDOVwi8zANBgkqhkiG9w0BAQEFAASCAQBxF3DX
# Q1rrU5xKq/1eejttcjbwSWGPSLk9ExHnOSXEuPNZqJPPSrNaR60f1VUZ6/78+szH
# ZJdjmQxqaKAul1y0byTjCJV3kVrgTBeOSGFiiYJ4v3GhODAVXtiY3/4bWOAte0xX
# dH3tmhWVGGH9vRI21LFCFdn0vaF96bJPElhgp+87O+hM8HqtIZrlk59wyN3Dh4qd
# bWLsyOF/D6tN/vIfkTmxgx9Pt4btSJI1yp0jLZMUkRP2K/QeNwh41Qmo29YNAmoE
# 6UzlS2V52545LDISxRVqbkyrVRmzKddQV9i32ZWpIELeIwwXdKlfs8hcDFVQSve6
# kz8yrLESuSKza7HK
# SIG # End signature block
