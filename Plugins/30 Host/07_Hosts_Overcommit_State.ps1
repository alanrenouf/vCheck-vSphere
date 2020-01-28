$Title = "Hosts Overcommit state"
$Header = "Hosts overcommitting memory: [count]"
$Comments = "Overcommitted hosts may cause issues with performance if memory is not issued when needed, this may cause ballooning and swapping"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings
# Return results in GB or MB?
$Units = "GB"
# End of Settings

# Update settings where there is an override
$Units = Get-vCheckSetting $Title "Units" $Units

# Setup plugin-specific language table
$pLang = DATA {
   ConvertFrom-StringData @' 
      pluginActivity = Checking overcommit state for hosts
'@
}
# Override the defaults (en) if language file exists in lang driectory
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang -ErrorAction SilentlyContinue

$OverCommit = @()
$i = 0
$VMHCount = $VMH | Measure
Foreach ($VMHost in $VMH) {
   Write-Progress -ID 2 -Parent 1 -Activity $plang.pluginActivity -Status $VMHost.Name -PercentComplete ((100*$i)/$VMHCount.Count)
   if ($VMMem) { Clear-Variable VMMem }
   $VM | Where-Object {$_.VMHost.Name -eq $VMHost.Name -and $_.PowerState -ne "PoweredOff"} | Foreach-Object {
      [INT]$VMMem += $_.MemoryMB
   }

   If ([Math]::Round(($VMMem - $VMHost.MemoryTotalMB), 0) -gt 0) {
      $OverCommitMB = [Math]::Round(($VMMem - $VMHost.MemoryTotalMB), 0)

      if ($Units -eq "MB") {
         $OverCommit += New-Object PSObject -Property @{"Host" = $VMHost.Name;
                        "TotalMemMB" = [Math]::Round($VMHost.MemoryTotalMB,0);
                        "TotalAssignedMemMB" = $VMMem;
                        "TotalUsedMB" = [Math]::Round($VMHost.MemoryUsageMB,0);
                        "OverCommitMB" = $OverCommitMB;
                                                      }
      }
      else {
         $OverCommit += New-Object PSObject -Property @{"Host" = $VMHost.Name;
                        "TotalMemGB" = [Math]::Round(($VMHost.MemoryTotalMB)/1024,0);
                        "TotalAssignedMemGB" = [Math]::Round($VMMem/1024,0);
                        "TotalUsedGB" = [Math]::Round(($VMHost.MemoryUsageMB)/1024,0);
                        "OverCommitGB" = [Math]::Round($OverCommitMB/1024, 0);
                                                      }
      }
   }
   $i++
}
Write-Progress -ID 2 -Parent 1 -Activity $plang.pluginActivity -Status $lang.Complete -Completed

$OverCommit | Select-Object Host, "TotalMem$Units", "TotalAssignedMem$Units", "TotalUsed$Units", "OverCommit$Units"
