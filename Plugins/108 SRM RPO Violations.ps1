##
# vCheck Plug-in: vCenter Site Recovery Manager - RPO Violation Report
#
# This plug-in can be used to generate a custom report of RPO violations found in the vCenter event log. It is heavily
# based on Alan Renouf's work found at: http://www.virtu-al.net/2013/06/14/reporting-on-rpo-violations-from-vsphere-replication/.
#
# The settings are mostly self-explanatory:
#
# $RPOviolationMins     - report on events that indicate an RPO exceeded by x minutes
# $MaxHours             - review vCenter events that are no older than x hours
# $MaxEvents            - the maximum number of vCenter events to review
# $VMNameExpression     - only look for RPO events on VMs with these names
# $ActiveViolationsOnly - report can display all RPO events based on above criteria, or only active unresolved ones
# $EnableEmailReport    - if set to $true, will set vCheck's e-mail reporting to $true if RPO violations found.
#                         this is useful if you run the report regularly, but only want to receive an e-mail when
#                         there is a violation that meets the defined criteria (vCheck e-mail reporting would
#                         need to be set to $false for this to have any effect)
#
# Note, the RPO violation start time is based on the violations found within the configured event search criteria.
# For example, if you are only searching through four hours of events, then the ViolationStart will reflect the
# a start time within that four hour window, though the violation may have actually begun earlier.
#
# Use at your own risk.
#
##
 
# Start of Settings
# Set the number of minutes an RPO has exceeded to report on
$RPOviolationMins = 240
# Set the maximum number of hours to go back and review vCenter events
$MaxHours = 72
# Set the maximum number of vCenter events to retrieve
$MaxEvents = 100000
# Set a VM name filter to report RPO violations on
$VMNameExpression = "*"
# Report on unresolved RPO violations only?
$ActiveViolationsOnly = $true
# Enable vCheck e-mail report?
$EnableEmailReport = $true
#End of Settings
 
# Changelog
## 0.1 : Initial version.
 
## Begin code block obtained from: http://www.virtu-al.net/2013/06/14/reporting-on-rpo-violations-from-vsphere-replication/
#  modified by Joel Gibson
Write-Host "[$(Get-Date)] Retrieving VMs"
$VMs = Get-VM -Name $VMNameExpression
 
 
$Results = @()
Foreach ($VM in $VMs) {
                Write-Host "[$(Get-Date)] Retrieving events for $($VM.name)"
                $Events = Get-VIEvent -MaxSamples $MaxEvents -Entity $VM -Start $(Get-Date).AddHours(-$MaxHours)
                Write-Host "[$(Get-Date)] Filtering RPO events for $($VM.name)"
                $RPOEvents = $Events | where { $_.EventTypeID -match "rpo" } | Where { $_.Vm.Name -eq $VM.Name } | Select EventTypeId, CreatedTime, FullFormattedMessage, @{Name="VMName";Expression={$_.Vm.Name}} | Sort CreatedTime
                if ($RPOEvents) {
                                $Count = 0
                                Write-Host "[$(Get-Date)] Finding replication results for $($VM.Name)"
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
                                                                                                $details.Mins = "{0:N2}" -f $Time.TotalMinutes
                    
                                                                                } Else {
                                                                                                $details.ViolationEnd = "No End Date"
                                                                                                $details.Mins = "N/A"
               
 
                                                                                }
                                                                }
                                                }
                                                $Results += $details
                                                $Count++
                                } until ($count -gt $RPOEvents.Count)
                }
}
## End of code block obtained from: http://www.virtu-al.net/2013/06/14/reporting-on-rpo-violations-from-vsphere-replication/.
 
## filter the results based on unresolved violations, if desired
if ($ActiveViolationsOnly) {
 
    ## filter results based on open violations
    $Results = @($Results | Where { $_.ViolationEnd -eq "No End Date" })
 
    }
 
## if e-mail reporting is enabled
if ($EnableEmailReport) {
 
    ## if there are open violations, enable e-mail reporting (if not already)
    if ($Results.Count -gt 0) { $SendEmail = $true }
   
    }      
 
## output VMs that have exeeded their RPO by $RPOviolationMins, based on defined criteria
$Results
 
$Title = "Site Recovery Manager - RPO Violation Report"
$Header =  "Site Recovery Manager - RPO Violations: $(@($SRMViolations).count)"
$Comments = "This is a customizable report of RPO violations found in the vCenter event log."
$Display = "Table"
$Author = "Joel Gibson, based on work by Alan Renouf"
$PluginVersion = 0.1
$PluginCategory = "vSphere"
