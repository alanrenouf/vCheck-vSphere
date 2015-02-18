# Determine VMs that have not been backed up recently.  That is, all VMs that have not seen a 
# snapshot by $backupUser in the last $backupMaxAge days
#

# Maximum age of a backup snapshot, in days
$backupMaxAge = 2

# Backup system username that creates the snapshots. Typically a service account.
$backupUser = "KASTLEWAN\nakivovcenter"

# Regular expression denoting VM names that we don't care about
$excludedVMs = "(^(DC|NY|CH|HO)[0-9]{4}$|^XFS-.*|.*VLAN 666.*)"

#
# Catalog all VMs with recent snapshots
$vms = @{}
Get-VIEvent -Start (Get-Date).AddDays(-$backupMaxAge) -Finish (Get-Date) -Username $backupUser | 
    Where-Object { ($_.fullFormattedMessage -eq "Task: Create virtual machine snapshot") -and 
       ($_.vm.name -notmatch $excludedVMs) } | 
    Select @{N="backupTime";E={$_.createdTime}}, @{N="vmName";E={$_.vm.name}} | 
    Sort-Object backupTime |
    ForEach-Object { $vms.Set_Item($_.vmName, $_.backupTime) }

# Get all of the VMs and add to our hashtable if not already present
Get-View -ViewType VirtualMachine -Property Name | Where-Object {$_.Name -notmatch $excludedVMs } | 
    ForEach-Object { if (!$vms.ContainsKey($_.Name)) { $vms.Add($_.Name, $null) } }

# Output VMs without a backupTime
$vms.GetEnumerator() | Where-Object { $_.Value -eq $null } | Sort-Object Name | Select Name

$Title = "Backup Snapshots NOT created"
$Header =  "Backup snapshots NOT created (Last $backupMaxAge Day(s)) (by user $backupUser)"
$Comments = "Determine VMs that have not been backed up recently--all VMs that have not seen a snapshot by $backupUser in the last $backupMaxAge days."
$Display = "Table"
$Author = "Todd Scalzott"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
