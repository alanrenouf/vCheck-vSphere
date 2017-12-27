$Title = "VM CPU %RDY"
$Comments = "The following VMs have high CPU RDY times, this can cause performance issues for more information please read <a href='http://communities.vmware.com/docs/DOC-7390' target='_blank'>This article</a>"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# CPU ready on VMs should not exceed
$PercCPUReady = 10.0
# End of Settings

# Setup plugin-specific language table
$pLang = DATA {
   ConvertFrom-StringData @' 
      pluginActivity = Checking VM CPU RDY %
'@
}

# Override the default (en) if it exists in lang directory
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang -ErrorAction SilentlyContinue

# Update settings where there is an override
$PercCPUReady = Get-vCheckSetting $Title "PercCPUReady" $PercCPUReady

$i=0
ForEach ($v in ($VM | Where-Object {$_.PowerState -eq "PoweredOn"})){
   Write-Progress -ID 2 -Parent 1 -Activity $plang.pluginActivity -Status $v.Name -PercentComplete ((100*$i)/$VM.Count)
   For ($cpunum = 0; $cpunum -lt $v.NumCpu; $cpunum++){
      $PercReady = [Math]::Round((($v | Get-Stat -ErrorAction SilentlyContinue -Stat Cpu.Ready.Summation -Realtime | Where-Object {$_.Instance -eq $cpunum} | Measure-Object -Property Value -Average).Average)/200,1)
      
      if ($PercReady -gt $PercCPUReady)
      {
         New-Object -TypeName PSObject -Property @{
            VM = $v.Name
            VMHost = $v.VMHost
            CPU = $cpunum
            PercReady = $PercReady
         }
      }
   }
   $i++
}
Write-Progress -ID 2 -Parent 1 -Activity $plang.pluginActivity -Status $lang.Complete -Completed

$Header = ("VM CPU % RDY over {0}: [count]" -f $PercCPUReady)

# Change Log
## 1.2 :  Added Get-vCheckSetting, code refactor
