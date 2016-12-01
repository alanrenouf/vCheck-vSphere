$Title = "Checking Distributed vSwitch Port Groups for Ports Free"
$Display = "Table"
$Author = "Kyle Ruddy"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# Distributed vSwitch PortGroup Ports Left
$DvSwitchLeft = 10
# End of Settings

# Update settings where there is an override
$DvSwitchLeft = Get-vCheckSetting $Title "DvSwitchLeft" $DvSwitchLeft

if ((Get-PSSnapin VMware.VimAutomation.Vds -ErrorAction SilentlyContinue) -or (Get-Module VMware.VimAutomation.Vds -ErrorAction SilentlyContinue))
{
   if ($vdspg = Get-VDSwitch | Sort-Object -Property Name | Get-VDPortgroup)
    {
        Foreach ($PG in $vdspg | Where-Object {-not $_.IsUplink -and $_.PortBinding -ne 'Ephemeral' -and -not ($_.PortBinding -eq 'Static' -and $_.ExtensionData.Config.AutoExpand)} )
        {
            If (($PG.NumPorts -($PG.ExtensionData.VM).Count) -lt $DvSwitchLeft)
            {
               New-Object -TypeName PSObject -Property @{
                  "vDSwitch" = $PG.VDSwitch
                  "Name" = $PG.Name
                  OpenPorts = ($PG.NumPorts -($PG.ExtensionData.VM).Count) }
            }
        }
    }
}

$Header = "Distributed vSwitch Port Groups with less than $vSwitchLeft Port(s) Free: [count]"
$Comments = "The following Distributed vSwitch Port Groups have less than $vSwitchLeft left"