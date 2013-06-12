# Start of Settings 
# VM Not to go over the following amount of CPU
$CPUValue = 75
# VM CPU not allowed to go over the previous amount for how many days?
$CPUDays =1
# End of Settings


$Result = $VM | Select Name, @{N="AverageCPU";E={[Math]::Round(($_ | Get-Stat -ErrorAction SilentlyContinue -Stat cpu.usage.average -Start (($Date).AddDays(-$CPUDays)) -Finish ($Date) | Measure-Object -Property Value -Average).Average)}}, NumCPU, VMHost | Where {$_.AverageCPU -gt $CPUValue} | Sort AverageCPU -Descending
$Result

$Title = "VM CPU Usage"
$Header =  "VM(s) CPU above $($CPUValue)% : $(@($Result).Count)"
$Comments = "The following VMs have high CPU usage and may have rogue guest processes or not enough CPU resource assigned"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2			
$PluginCategory = "vSphere"
