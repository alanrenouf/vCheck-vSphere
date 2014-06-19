# Start of Settings 
# Set the warning threshold for number of snapshots
$MaxNumberSnapshots = 1
# End of Settings

$OutputQuantitySnapshots = @()

Foreach ($theVM in $VM){
        # Inventory the VM snapshots
        $vmsnapshots = $theVM | Get-Snapshot

        # Check to see if the VM has exceeded the max snapshot count
        If (($vmsnapshots.count) -gt $MaxNumberSnapshots){
            $Details = New-object PSObject
            $Details | Add-Member -Name "VM Name" -Value $theVM.name -Membertype NoteProperty
            $Details | Add-Member -Name "Number of snapshots" -Value $vmsnapshots.count -Membertype NoteProperty
            $OutputQuantitySnapshots += $Details
        }
}

$OutputQuantitySnapshots

$Title = "Quantity of snapshots"
$Header = "VMs with more than $MaxNumberSnapshots Snapshot(s): $(@($OutputQuantitySnapshots).count)"
$Comments = "The following VMs have more than $MaxNumberSnapshots snapshot(s)"
$Display = "Table"
$Author = "Mads Fog Albrechtslund"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
