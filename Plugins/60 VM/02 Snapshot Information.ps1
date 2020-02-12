# Start of Settings 
# Set the warning threshold for snapshots in days old
$SnapshotAge = 14
# Set snapshot name exception (regex)
$ExcludeName = "^(ExcludeMe|ExcludeMeToo)$"
# Set snapshot creator exception (regex)
$ExcludeCreator = "^(ExcludeMe|ExcludeMeToo)$"
# End of Settings

Add-Type -AssemblyName System.Web
$Output = @()

foreach ($Snapshot in ($VM | Get-Snapshot | Where-Object { $_.Created -lt (Get-Date).AddDays(- $SnapshotAge) -and $_.Name -notmatch $ExcludeName })) {

    # This little +/-1 minute time span is a small buffer in case of time differences between the vCenter and the reporting server. This might cause wrong
    # results in the uncommon case of two different people creating a snapshot for the same VM within two minutes. In this scenario the wrong creator will be
    # displayed but nevertheless this approach shows every existing snapshot. Usage of Get-VIEventPlus in the style of "85 Snapshot Activity.ps1".
    $SnapshotEvents = Get-VIEventPlus -Entity $Snapshot.VM -EventType "TaskEvent" -Start $Snapshot.Created.AddMinutes(-1) -Finish $Snapshot.Created.AddMinutes(1)
    $SnapshotEvent = $SnapshotEvents | Where-Object { $_.Info.DescriptionId -eq "VirtualMachine.createSnapshot" } | Select-Object -First 1

    if ($SnapshotEvent -eq $null) {
        $SnapshotCreator = "Unknown"
    } elseif ($SnapshotEvent.UserName -match $ExcludeCreator) {
        # This is the earliest point where I can neglect snapshots from certain creators
        continue
    } else {
        $SnapshotCreator = $SnapshotEvent.UserName
    }

    $Output += [PSCustomObject]@{
        VM = $Snapshot.VM
        SnapName = [System.Web.HttpUtility]::HtmlEncode($Snapshot.Name)
        DaysOld = ((Get-Date) - $Snapshot.Created).Days
        Creator = $SnapshotCreator
        SizeGB = $Snapshot.SizeGB.ToString("f1")
        Created = $Snapshot.Created.DateTime
        Description = [System.Web.HttpUtility]::HtmlEncode($Snapshot.Description)
    }
}

# Output result
$Output

$Title = "Snapshot Information"
$Header = "Snapshots (Over $SnapshotAge Days Old): [count]"
$Comments = "VMware snapshots which are kept for a long period of time may cause issues, filling up datastores and also may impact performance of the virtual machine."
$Display = "Table"
$Author = "Alan Renouf, Raphael Schitz, Marcel Schuster"
$PluginVersion = 1.6
$PluginCategory = "vSphere"

# Changelog
## 1.3 : Cleanup - Fixed Creator - Changed Size to GB
## 1.4 : Decode URL-encoded snapshot name (i.e. the %xx caharacters)
## 1.5 : ???
## 1.6 : Complete restructuring because of missing creator names. Also removed $excludeDesc.
