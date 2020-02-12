$Title = "Removable Media Connected"
$Header = "VMs with Removable Media Connected: [count]"
$Comments = "The following VMs have removable media connected (i.e. CD/Floppy), this may cause issues if this machine needs to be migrated to a different host"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings 
# VMs with removable media not to report on
$IgnoreVMMedia = ""
# End of Settings

# Update settings where there is an override
$IgnoreVMMedia = Get-vCheckSetting $Title "IgnoreVMMedia" $IgnoreVMMedia

$FullVM | Where-Object {$_.runtime.powerState -eq "PoweredOn" -And $_.Name -notmatch $IgnoreVMMedia} | 
   % { $VMName = $_.Name; $_.config.hardware.device | Where-Object {($_ -is [VMware.Vim.VirtualFloppy] -or $_ -is [VMware.Vim.VirtualCdrom]) -and $_.Connectable.Connected} | 
      Select-Object @{Name="VMName"; Expression={ $VMName}}, 
             @{Name="Device Type"; Expression={ $_.GetType().Name}},
             @{Name="Device Name"; Expression={ $_.DeviceInfo.Label}},
             @{Name="Device Backing"; Expression={ $_.DeviceInfo.Summary}}
     }
     
# Change Log
## 1.0 : Initial release
## 1.1 : Added Get-vCheckSetting