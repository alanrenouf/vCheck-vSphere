$Title = "Removable Media Issues"
## 2.1 : add some power filter
$Header = "Removable Media Issues: [count]"
$Comments = "The following VMs have removable media connected, this may cause issues if this machine needs to be migrated to a different host"
$Display = "Table"
$Author = "Felix Longardt"
$PluginVersion = 2.1
$PluginCategory = "vSphere"
# End of Settings

# BlacklistVM 1 or more VM from beeing checked i.e. "VM1","VM2"
$BlacklistVM = ""
# BlacklistISO with regex .i.e = ".*(VMTools-10.2.0-windows.iso)|.*(ubuntu).*"
$BlacklistISO = ""
# FilterConnected States $true, $false or .* for any
$FilterConnected = "$true|$false|.*"
# FilterStartupConnected States $true, $false or .* for any
$FilterStartupConnected = "$true|$false|.*"
#$FilterPowerState = "^(PoweredOn)$|^(PoweredOff)$|.*"
$FilterPowerState = "^(PoweredOn)$"

function Get-VMMediaDevice{
[CmdletBinding()]
        Param(
                $MediaCheckCommand = $args[0],
                $MediaPathName = $args[1],
                $MediaVM = $args[2]
                )
Invoke-Expression "$MediaCheckCommand $MediaVM" | Where-Object {$PSItem.$MediaPathName.Length -ne "$null"} |
												  Where-Object {-not $PSItem.$MediaPathName -match $BlacklistISO} |
                                                  Where-Object {$_.ConnectionState.Connected -match $FilterConnected -and $_.ConnectionState.StartConnected -match $FilterStartupConnected} |
                                                  Select-Object @{N="Name";E={($_.Parent)}},
																@{N="IsoPath";E={($PSItem.$MediaPathName)}},
																@{N="Connected";E={($_.ConnectionState.Connected) -replace "True","yes" -replace "False", "no"}},
																@{N="on Startup";E={($_.ConnectionState.StartConnected)  -replace "True","yes" -replace "False", "no"}}

}
foreach ($VM in Get-VM | Where-Object {$_.Name -notin $BlacklistVM -and $_.PowerState -match $FilterPowerState})
                                          {
                                           Get-VMMediaDevice Get-CDDrive IsoPath $VM
                                           Get-VMMediaDevice Get-FloppyDrive FloppyImagePath $VM
                                          }
										  
$Comments = ("The following vms have removable media issues")

# Change Log
## 1.0 : Initial release
## 2.0 : Rewrite-add function and floppy
## 2.1 : add some power filter
