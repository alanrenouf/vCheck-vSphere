$Title = "s/vMotion Information"
$Comments = "s/vMotions and how long they took to migrate between hosts and datastores"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days to go back and check for s/vMotions
$vMotionAge = 5
# Include vMotions in report
$IncludevMotions = $true;
# Include Storage vMotions in report
$IncludeSvMotions = $true;
# End of Settings

# Update settings where there is an override
$vMotionAge = Get-vCheckSetting $Title "vMotionAge" $vMotionAge
$IncludevMotions = Get-vCheckSetting $Title "IncludevMotions" $IncludevMotions
$IncludeSvMotions = Get-vCheckSetting $Title "IncludeSvMotions" $IncludeSvMotions

# Search for any vmotion-related events
$EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
$EventFilterSpec.Category = "info"
$EventFilterSpec.Time = New-Object VMware.Vim.EventFilterSpecByTime
$EventFilterSpec.Time.beginTime = (get-date).adddays(-$vMotionAge)
$EventFilterSpec.Type = "VmMigratedEvent", "DrsVmMigratedEvent", "VmBeingHotMigratedEvent", "VmBeingMigratedEvent"
$vmotions = @((get-view (get-view ServiceInstance -Property Content.EventManager).Content.EventManager).QueryEvents($EventFilterSpec)) 

$Motions = @()
foreach($vmotion in ($vmotions | Sort-object CreatedTime | Group-Object ChainID)) {
    if($vmotion.Group.count -eq 2){
            $type = &{if($vmotion.Group[0].Host.Name -eq $vmotion.Group[1].Host.Name){"SvMotion"}else{"vMotion"}}
            if ($type -eq "SvMotion")
            {
               $src = $vmotion.Group[0].ds.name
               $dst = $vmotion.Group[0].DestDatastore.Name  
            }
            else
            {
               $src = $vmotion.Group[0].Host.name
               $dst = $vmotion.Group[0].DestHost.Name
            }
            
            $Motions += New-Object PSObject -Property @{
                Name = $vmotion.Group[0].vm.name
                Type = $type
                Source = $src
                Destination =  $dst
                StartTime = $vmotion.Group[0].CreatedTime
                EndTime = $vmotion.Group[1].CreatedTime
                Duration = New-TimeSpan -Start $vmotion.Group[0].CreatedTime -End $vmotion.Group[1].CreatedTime
            }
    }
}
# Filter out unwanted vMotion Events
if (-not $IncludevMotions) { $Motions = $Motions | Where-Object { $_.Type -ne "vMotion" }}
if (-not $IncludeSvMotions) { $Motions = $Motions | Where-Object { $_.Type -ne "SvMotion" }}
$Motions

$Header = ("s/vMotion Information (Over {0} Days Old): [count]" -f $vMotionAge)

Remove-Variable Motions, EventFilterSpec, vmotions