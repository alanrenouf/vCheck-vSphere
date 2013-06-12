# Start of Settings 
# CPU ready on VMs should not exceed
$PercCPUReady = 10.0
# End of Settings


$myCol = @()
ForEach ($v in ($VM | Where {$_.PowerState -eq "PoweredOn"})){
	For ($cpunum = 0; $cpunum -lt $v.NumCpu; $cpunum++){
		$myObj = "" | Select VM, VMHost, CPU, PercReady
		$myObj.VM = $v.Name
		$myObj.VMHost = $v.VMHost
		$myObj.CPU = $cpunum
		$myObj.PercReady = [Math]::Round((($v | Get-Stat -ErrorAction SilentlyContinue -Stat Cpu.Ready.Summation -Realtime | Where {$_.Instance -eq $cpunum} | Measure-Object -Property Value -Average).Average)/200,1)
		$myCol += $myObj
	}
}
$Result = @($myCol | Where {$_.PercReady -gt $PercCPUReady} | Sort PercReady -Descending)
$Result

$Title = "VM CPU %RDY"
$Header =  "VM CPU % RDY over $($PercCPUReady): $(@($Result).Count)"
$Comments = "The following VMs have high CPU RDY times, this can cause performance issues for more information please read <a href='http://communities.vmware.com/docs/DOC-7390' target='_blank'>This article</a>"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
