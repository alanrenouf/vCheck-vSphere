# Start of Settings 
# Set the number of days to go back and check for s/vMotions
$vMotionAge = 14
# End of Settings

# Search for any vmotion-related events
$EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
$EventFilterSpec.Category = "info"
$EventFilterSpec.Time = New-Object VMware.Vim.EventFilterSpecByTime
$EventFilterSpec.Time.beginTime = (get-date).adddays(-$vMotionAge)
$EventFilterSpec.Type = "VmMigratedEvent", "DrsVmMigratedEvent", "VmBeingHotMigratedEvent", "VmBeingMigratedEvent"
$vmotions = @((get-view (get-view ServiceInstance -Property Content.EventManager).Content.EventManager).QueryEvents($EventFilterSpec)) 

$Motions = @()
# Group by chainID - each chain should have a start and finish event
foreach($vmotion in ($vmotions | Sort-object CreatedTime | Group-Object ChainID)) {
    if($vmotion.Group.count -eq 2){
            $Motions += New-Object PSObject -Property @{
                Name = $vmotion.Group[0].vm.name
                Type = &{if($vmotion.Group[0].Host.Name -eq $vmotion.Group[1].Host.Name){"SvMotion"}else{"vMotion"}}
                StartTime = $vmotion.Group[0].CreatedTime
                EndTime = $vmotion.Group[1].CreatedTime
                Duration = New-TimeSpan -Start $vmotion.Group[0].CreatedTime -End $vmotion.Group[1].CreatedTime
            }
    }
}
$Motions

$Title = "s/vMotion Information"
$Header = "s/vMotion Information (Over $vMotionAge Days Old) : $(@($Motions).count)"
$Comments = "s/vMotions and how long they took to migrate between hosts and datastores"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

Remove-Variable Motions, EventFilterSpec, vmotions
