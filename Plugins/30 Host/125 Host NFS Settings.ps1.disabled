$Title = "Host NFS Settings"
$Comments = "The following hosts may not have the recommended settings for NFS storage.  See <a href='https://kb.vmware.com/s/article/2239' target='_blank'>VMware KB 2239</a> and your storage vendor's documentation for the recommended settings."
$Display = "Table"
$Author = "Doug Taliaferro"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Create an object to store the settings - the property names match the ESXi advanced setting name so we
# can use them to get each setting from the host and compare them
$myObj = "" | Select-Object Misc.APDTimeout, NFS.HeartbeatTimeout, NFS.SendBufferSize, NFS.ReceiveBufferSize, NFS.MaxVolumes, `
    Net.TcpipHeapMax, Net.TcpipHeapSize, NFS.HeartbeatFrequency, NFS.HeartbeatDelta, NFS.HeartbeatMaxFailures
# Start of Settings
# APD Timeout - default of 140 is usually recommended (consult with your storage vendor)
$myObj.'Misc.APDTimeout' = "140"
# NFS Heartbeat Timeout - default of 5 is usually recommended (consult with your storage vendor)
$myObj.'NFS.HeartbeatTimeout' = "5"
# NFS Send Buffer Size - default of 264 is usually recommended (consult with your storage vendor)
$myObj.'NFS.SendBufferSize' = "264"
# NFS Receive Buffer Size - default of 256 is usually recommended (consult with your storage vendor)
$myObj.'NFS.ReceiveBufferSize' = "256"
# NFS Max Volumes - ESXi host default is 8, but 256 is often recommended (see VMware KB 2239)
$myObj.'NFS.MaxVolumes' = "256"
# Net TCPIP Heap Max - for ESXi 6.x this can be increased to '1536' (see VMware KB 2239)
$myObj.'Net.TcpipHeapMax' = "512"
# Net TCPIP Heap Size - ESXi host default is 0, but 32 is often recommended (see VMware KB 2239)
$myObj.'Net.TcpipHeapSize' = "32"
# NFS Heartbeat Frequency - default of 12 is usually recommended (consult with your storage vendor)
$myObj.'NFS.HeartbeatFrequency' = "12"
# NFS Heartbeat Delta - default of 5 is usually recommended (consult with your storage vendor)
$myObj.'NFS.HeartbeatDelta' = "5"
# NFS Heartbeat Max Failures - default of 10 is usually recommended (consult with your storage vendor)
$myObj.'NFS.HeartbeatMaxFailures' = "10"
# End of Settings

$hostResults = @()
Foreach ($esxhost in ($HostsViews | Where-Object {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {

    # Create an object to store the host settings
    $hostObj = New-Object Object
    # Iterate through each property in the custom object containing the settings
    $myObj.psobject.Properties | % {
        $PropertyName = $_.Name
        $hostObj | Add-Member -MemberType NoteProperty -Name $PropertyName -Value ($esxhost.Config.Option | Where-Object { $_.Key -eq $PropertyName }).Value
    }

    # Compare the two objects for differences
    If ((Compare-Object ($hostObj | Out-String -Stream) ($myObj | Out-String -Stream)).count -gt 0) {
        # If they don't match, create a final object that includes the host name
        $finalObj = New-Object Object
        $finalObj | Add-Member -MemberType NoteProperty -Name VMHost -Value $esxhost.Name
        Foreach ( $Property in $hostObj.psobject.Properties){
            $finalObj | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.value
        }
		$hostResults += $finalObj
    }
}

# If there are results, create a header row to show the plugin settings in the report
if ($hostResults.Count -gt 0) { 
    $headObj = New-Object Object
    $headObj | Add-Member -MemberType NoteProperty -Name VMHost -Value "Plugin Settings"
    foreach ( $Property in $myObj.psobject.Properties){
                $headObj | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.value
    }
    $hostResults = ,$headObj + $hostResults
}
$hostResults

$Header = "Host NFS settings that don't match : [count]"
# Table formatting - highlight cells without matching settings
$TableFormat = @{}
foreach ($Property in $myObj.psObject.Properties) {
    $TableFormat += @{"$($Property.Name)" = @(@{"-ne $($Property.Value)" = "Cell,class|critical"; })}
}
