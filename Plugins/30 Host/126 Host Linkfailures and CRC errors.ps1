$Title = "Check Fibre Channel Link failures and CRC errors on HBA cards"
$Comments = "Fibre Channel Link failures and CRC errors can effect storage performance in a FC SAN environment"
$Display = "Table"
$Author = "Wim Baars"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings 
# Set max link failures to tolerate.
$MaxLinkFails = 1
# Set max CRC errors to tolerate.
$MaxCRCerrors = 1
# End of Settings

# Update settings where there is an override
$MaxLinkFails = Get-vCheckSetting $Title "MaxLinkFails" $MaxLinkFails
$MaxCRCerrors = Get-vCheckSetting $Title "MaxCRCerrors" $MaxCRCerrors

$listwithhbaerrors = @()
foreach ($esxhost in ($HostsViews | Where-Object {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {

   $esxcli = Get-EsxCli -V2 -VMHost $esxhost.Name
   Get-VMHostHba -VMHost $esxhost.Name -Type FibreChannel | Foreach-Object {
        $hbastats = $esxcli.storage.san.fc.stats.get.Invoke(@{adapter = $_.name})
        $Properties = [ordered]@{
            'ESXhost' = $esxhost.name;
            'HBA' = $_.name;
            'HBAModel' = $_.Model;
            'LinkFailures' = $hbastats.LinkFailureCount;
            'CRCErrors' = $hbastats.InvalidCRCCount;
        }

        if (($hbastats.LinkFailureCount -ge $MaxLinkFails) -or ($hbastats.InvalidCRCCount -gt $MaxCRCerrors)){
            $objecty = New-Object PsObject -Property $Properties
            $listwithhbaerrors += $objecty
        }
   }

}
$listwithhbaerrors
$Header = ("Hosts with more than {0} Link Failures and {1} CRC errors: [count]" -f $MaxLinkFails,$MaxCRCerrors)

