$EphemeralReport = @()
 
$EphemeralPG = Get-VDSwitch | Get-VDPortgroup | where {$_.PortBinding -eq "Ephemeral"}
$vNetworkAdapter = $VM | Get-NetworkAdapter | where {$_.NetworkName -contains $EphemeralPG}
 
ForEach ($v in $vNetworkAdapter)
    {
    $vDSSummary = "" | Select VMName, Portgroup
                $vDSSummary.Portgroup = $v.NetworkName
        $vDSSummary.VMName = $v.parent
        $EphemeralReport += $vDSSummary
        }
$EphemeralReport

Title = "VMs on Ephemeral Portgroup"
$Header = "VMs on Ephemeral Portgroup: $(@($EphemeralReport).Count)"
$Comments = "...."
$Display = "Table"
$Author = "Tim Williams"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
