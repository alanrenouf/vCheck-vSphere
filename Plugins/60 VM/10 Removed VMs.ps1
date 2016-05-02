# Start of Settings 
# Set the number of days to show VMs removed for
$VMsNewRemovedAge = 5
# End of Settings

$Events = Get-VIEventPlus -Start ((get-date).adddays(-$VMsNewRemovedAge)) -EventType "VmRemovedEvent"

$report = @()
ForEach ($Event in $Events){
$report += New-Object psobject -Property @{VMName=$($Event.vm.name);User=$($Event.username);Created=$($Event.CreatedTime)}
}

@($report)

$Title = "Removed VMs"
$Header = "VMs Removed (Last $VMsNewRemovedAge Day(s)) : [count]"
$Comments = "The following VMs have been removed/deleted over the last $($VMsNewRemovedAge) days"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
