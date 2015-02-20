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
 
# Start of Settings
# SRM RPO Violations: Set the number of minutes an RPO has exceeded to report on
$RPOviolationMins = 240
# SRM RPO Violations: Only look for RPO events on VMs with these names: (regex)
$VMNameRegex = ""
# SRM RPO Violations: Report on unresolved RPO violations only?
$ActiveViolationsOnly = $true
# End of Settings
 
# Changelog
## 0.1 : Initial version.
## 0.2 : Minor tweaks. Removed two unnecessary configurable variables. Utilized existing $MaxSampleVIEvent variable.
## 0.3 : Removed extra timing in output as this is displayed as part of Write-CustomOut
## 0.4 : Fixed a bug/typo while filtering results by duration of RPO violation. ($RPOviolationMin should have been $RPOviolationMins)
## 0.5 : Fixed a bug where filtering results by duration of RPO violation was not working.

## Begin code block obtained from: http://www.virtu-al.net/2013/06/14/reporting-on-rpo-violations-from-vsphere-replication/
#  modified by Joel Gibson
$VMs = $VM | Where { $_.name -match $VMNameRegex }
 
$Results = @()
Foreach ($RPOvm in $VMs) {
                Write-CustomOut ".... Retrieving events for $($RPOvm.name)"
                $Events = Get-VIEvent -MaxSamples $MaxSampleVIEvent -Entity $RPOvm
                Write-CustomOut ".... Filtering RPO events for $($RPOvm.name)"
                $RPOEvents = $Events | where { $_.EventTypeID -match "rpo" } | Where { $_.Vm.Name -eq $RPOvm.Name } | Select EventTypeId, CreatedTime, FullFormattedMessage, @{Name="VMName";Expression={$_.Vm.Name}} | Sort CreatedTime
                if ($RPOEvents) {
                                $Count = 0
                                Write-CustomOut ".... Finding replication results for $($RPOvm.Name)"
                                do {
                                                $details = "" | Select VMName, ViolationStart, ViolationEnd, Mins
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
                                                                                                $details.Mins = $Time.TotalMinutes
                    
                                                                                } Else {
                                                                                                $details.ViolationEnd = "No End Date"
                                                                                                $Time = $(Get-Date) - $details.ViolationStart
                                                                                                $details.Mins = $Time.TotalMinutes
                
                                                                                }
                                                                }
                                                }
                                                $Results += $details
                                                $Count++
                                } until ($count -gt $RPOEvents.Count)
                }
}
## End of code block obtained from: http://www.virtu-al.net/2013/06/14/reporting-on-rpo-violations-from-vsphere-replication/.
 
## filter the results based on the number of minutes an RPO has been exceeded by
$Results = $Results | Where { $_.Mins -gt $RPOviolationMins}

## format the number of minutes for the RPO violation
Foreach ($event in $Results) {
    if ($event.ViolationEnd -eq "No End Date") {
        $EventDurationTime = $(Get-Date) - $event.ViolationStart

    } else {
        $EventDurationTime = $event.ViolationEnd - $event.ViolationStart

    }

    $event.Mins = "{0:N2}" -f $EventDurationTime.TotalMinutes

}
 
## filter the results based on unresolved violations, if desired
if ($ActiveViolationsOnly) {
 
    ## filter results based on open violations
    $Results = $Results | Where { $_.ViolationEnd -eq "No End Date" }
 
    }
  
## output VMs that have exceeded their RPO by $RPOviolationMins, based on defined criteria
$Results
 
$Title = "Site Recovery Manager - RPO Violation Report"
$Header = "Site Recovery Manager - RPO Violations: $(@($Results).count)"
$Comments = "This is a customizable report of RPO violations found in the vCenter event log."
$Display = "Table"
$Author = "Joel Gibson, based on work by Alan Renouf"
$PluginVersion = 0.5
$PluginCategory = "vSphere"
