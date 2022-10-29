$Title = "VMs with over CPU Count"
$Display = "Table"
$Author = "Alan Renouf, Bill Wall"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# Define the maximum amount of vCPUs your VMs are allowed
$vCPU = 2
# Include Powered off VMs?
$vCPUPoweredOff = $false
# End of Settings

# Update settings where there is an override
$vCPU = Get-vCheckSetting $Title "vCPU" $vCPU

If ($vCPUPoweredOff) {
    $VM | Where-Object {$_.NumCPU -gt $vCPU} | Select-Object Name, PowerState, NumCPU | Sort-Object -Property NumCPU -Descending | Sort-Object -Property Name
} else {
    $VM |  Where-Object {$_.NumCPU -match "PoweredOn"} | Where-Object {$_.NumCPU -gt $vCPU} | Select-Object Name, PowerState, NumCPU | Sort-Object -Property NumCPU -Descending | Sort-Object -Property Name
}

$Header = ("VMs with over {0} vCPUs: [count]" -f $vCPU)
$Comments = ("The following VMs have over {0} CPU(s) and may impact performance due to CPU scheduling" -f $vCPU)

# Changelog
## 1.2 : Added Get-vCheckSetting
## 1.3 : Added Powered Off setting
