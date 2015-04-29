# Start of Settings 
# VMs with removable media not to report on
$IgnoreVMMedia = "APP*|ETC*"
# End of Settings

$FullVM | ?{$_.runtime.powerState -eq "PoweredOn" -And $_.Name -notmatch $IgnoreVMMedia} | 
   % { $VMName = $_.Name; $_.config.hardware.device | ?{($_ -is [VMware.Vim.VirtualFloppy] -or $_ -is [VMware.Vim.VirtualCdrom]) -and $_.Connectable.Connected} | 
      Select @{Name="VMName"; Expression={ $VMName}}, 
             @{Name="Device Type"; Expression={ $_.GetType().Name}},
             @{Name="Device Name"; Expression={ $_.DeviceInfo.Label}},
             @{Name="Device Backing"; Expression={ $_.DeviceInfo.Summary}}
     }

$Title = "Removable Media Connected"
$Header = "VMs with Removable Media Connected: [count]"
$Comments = "The following VMs have removable media connected (i.e. CD/Floppy), this may cause issues if this machine needs to be migrated to a different host"
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
# Based on code submitted by Alan Renouf, Frederic Martin