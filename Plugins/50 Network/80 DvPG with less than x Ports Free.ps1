# Start of Settings 
# Distributed vSwitch PortGroup Ports Left
$DvSwitchLeft = 10
# End of Settings

if (Get-PSSnapin VMware.VimAutomation.Vds -ErrorAction SilentlyContinue)
{
    if ($vdspg = Get-VDSwitch | Sort-Object -Property Name | Get-VDPortgroup)
    {
        $ImpactedDVS = @() 

        Foreach ($PG in $vdspg | Where-Object {-not $_.IsUplink -and $_.PortBinding -ne 'Ephemeral' -and -not ($_.PortBinding -eq 'Static' -and $_.ExtensionData.Config.AutoExpand)} )
        {
            $NumPorts = $PG.NumPorts
            $NumVMs = ($PG.ExtensionData.VM).Count
            $OpenPorts = $NumPorts - $NumVMs

            If ($OpenPorts -lt $DvSwitchLeft)
            {
                $myObj = "" | select vDSwitch,Name,OpenPorts
                $myObj.vDSwitch = $PG.VDSwitch
                $myObj.Name = $PG.Name
                $myObj.OpenPorts = $OpenPorts

                $ImpactedDVS += $myObj
            }
        }

        $ImpactedDVS
    }
}

$Title = "Checking Distributed vSwitch Port Groups for Ports Free"
$Header = "Distributed vSwitch Port Groups with less than $vSwitchLeft Port(s) Free: $(@($ImpactedDVS).Count)"
$Comments = "The following Distributed vSwitch Port Groups have less than $vSwitchLeft left"
$Display = "Table"
$Author = "Kyle Ruddy"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
