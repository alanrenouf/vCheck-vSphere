$Title = "VM CPU Usage"
$Comments = "The following VMs have high CPU usage and may have rogue guest processes or not enough CPU resource assigned"
$Display = "Table"
$Author = "Alan Renouf, Sam McGeown"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# VM Not to go over the following amount of CPU
$CPUValue = 75
# VM CPU not allowed to go over the previous amount for how many days?
$CPUDays = 1
# End of Settings

# Update settings where there is an override
$CPUValue = Get-vCheckSetting $Title "CPUValue" $CPUValue
$CPUDays = Get-vCheckSetting $Title "CPUDays" $CPUDays

$VM | Select-Object Name, @{N="AverageCPU";E={[Math]::Round(($_ | Get-Stat -Stat cpu.usage.average -IntervalMins 60 -MaxSamples ($CPUDays*24) -ErrorAction SilentlyContinue | Measure-Object -Property Value -Average).Average)}}, NumCPU, VMHost | Where-Object {$_.AverageCPU -gt $CPUValue} | Sort-Object AverageCPU -Descending

$Header = ("VM(s) CPU above {0}%: [count]" -f $CPUValue)

# ChangeLog
## 1.3 : Performance tweaks (approx 75% faster with IntervalMins than Start/Finish). 
## 1.4 : Added Get-vCheckSetting