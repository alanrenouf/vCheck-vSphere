##
# vCheck Plug-in: vCenter Site Recovery Manager - RPO Violation Report
#
# This plug-in can be used to generate a custom report of RPO violations found in the vCenter event log. It is heavily
# based on Alan Renouf's work found at: http://www.virtu-al.net/2013/06/14/reporting-on-rpo-violations-from-vsphere-replication/.
#
# The settings are mostly self-explanatory:
#
# $RPOviolationMins     - report on events that indicate an RPO exceeded by x minutes
# $VMNameRegex          - only look for RPO events on VMs with these names (regex)
# $ActiveViolationsOnly - report can display all RPO events based on above criteria, or only active unresolved ones
#
# Note, the RPO violation start time is based on the violations found within the configured event search criteria.
# For example, if you are only searching through four hours of events, then the ViolationStart will reflect 
# a start time within that four hour window, even though the violation may have actually begun earlier. This is
# controlled with the $MaxSampleVIEvent variable in '00 Connection Plugin for vCenter.ps1'.
#
# Use at your own risk.
#
##

$Title = "Site Recovery Manager - RPO Violation Report"
$Header = "Site Recovery Manager - RPO Violations: [count]"
$Comments = "This is a customizable report of RPO violations found in the vCenter event log."
$Display = "Table"
$Author = "Joel Gibson, based on work by Alan Renouf"
$PluginVersion = 0.7
$PluginCategory = "vSphere"

# Start of Settings
# SRM RPO Violations: Set the number of minutes an RPO has exceeded to report on
$RPOviolationMins = 240
# SRM RPO Violations: Only look for RPO events on VMs with these names: (regex)
$VMNameRegex = ""
# SRM RPO Violations: Report on unresolved RPO violations only?
$ActiveViolationsOnly = $true
# End of Settings

# Update settings where there is an override
$RPOviolationMins = Get-vCheckSetting $Title "RPOviolationMins" $RPOviolationMins
$VMNameRegex = Get-vCheckSetting $Title "VMNameRegex" $VMNameRegex
$ActiveViolationsOnly = Get-vCheckSetting $Title "ActiveViolationsOnly" $ActiveViolationsOnly

# Changelog
## 0.1 : Initial version.
## 0.2 : Minor tweaks. Removed two unnecessary configurable variables. Utilized existing $MaxSampleVIEvent variable.
## 0.3 : Removed extra timing in output as this is displayed as part of Write-CustomOut
## 0.4 : Fixed a bug/typo while filtering results by duration of RPO violation. ($RPOviolationMin should have been $RPOviolationMins)
## 0.5 : Fixed a bug where filtering results by duration of RPO violation was not working.
## 0.6 : Change to Get-VIEventPlus, removed MaxSampleVIEvent variable.
## 0.7 : Update to Get-vCheckSetting, layout changes

## Begin code block obtained from: http://www.virtu-al.net/2013/06/14/reporting-on-rpo-violations-from-vsphere-replication/
#  modified by Joel Gibson

Foreach ($RPOvm in ($VMs | Where-Object { $_.name -match $VMNameRegex })) {
   $RPOEvents = Get-VIEventPlus -Entity $RPOvm -EvenTypeId "hbr.primary.RpoTooLowForServerEvent" | Where-Object { $_.Vm.Name -eq $RPOvm.Name } | Select-Object EventTypeId, CreatedTime, FullFormattedMessage, @{Name="VMName";Expression={$_.Vm.Name}} | Sort-Object CreatedTime
   if ($RPOEvents) {
      $Count = 0

      do {
            $details = "" | Select-Object VMName, ViolationStart, ViolationEnd, Mins
            if ($RPOEvents[$count].EventTypeID -match "Violated") {
               If (-not $details.Start) {
                  $Details.VMName = $RPOEvents[$Count].VMName
                  $Details.ViolationStart = $RPOEvents[$Count].CreatedTime
                  Do {
                     $Count++
                  } until (($RPOEvents[$Count].EventTypeID -match "Restored") -or ($Count -gt $RPOEvents.Count))
                  if ($RPOEvents[$count].EventTypeID -match "Restored") {
                     $details.ViolationEnd = $RPOEvents[$Count].CreatedTime
                     $Time = $details.ViolationEnd - $details.ViolationStart
                     
                  } Else {
                     $details.ViolationEnd = "No End Date"
                     $Time = $(Get-Date) - $details.ViolationStart
                     
                  }
                  $details.Mins = ("{0:N2}" -f $Time.TotalMinutes)
               }
            }

            ## filter the results based on the number of minutes an RPO has been exceeded by
            ## filter the results based on unresolved violations, if desired
            if ($details.Mins -gt $RPOviolationMins)
            {
               if ((-not $ActiveViolationsOnly) -or ($ActiveViolationsOnly -and $details.ViolationEnd -eq "No End Date"))
               {
                  $details
               }
            }
            $Count++
      } until ($count -gt $RPOEvents.Count)
   }
}
## End of code block obtained from: http://www.virtu-al.net/2013/06/14/reporting-on-rpo-violations-from-vsphere-replication/.
