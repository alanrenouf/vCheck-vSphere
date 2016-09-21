# Start of Settings 
# Reportmode (Weekly, Monthly as String or Hour as Integer)
$reportMode = "Weekly"
# End of Settings


# Get all Sessions (Backup/BackupCopy/Replica)
$allSesh = Get-VBRBackupSession
# Get all Restore Sessions
$allResto = Get-VBRRestoreSession

# Convert mode (timeframe) to hours
If ($reportMode -eq "Monthly") {
        $HourstoCheck = 720
} Elseif ($reportMode -eq "Weekly") {
        $HourstoCheck = 168
} Else {
        $HourstoCheck = $reportMode
}

# Gather Backup jobs
$allJobsBk = @(Get-VBRJob | ? {$_.JobType -eq "Backup"})
# Gather BackupCopy jobs
$allJobsBkC = @(Get-VBRJob | ? {$_.JobType -eq "BackupSync"})

# Get Replica jobs
# $repList = @(Get-VBRJob | ? {$_.IsReplica})

# Gather all Backup sessions within timeframe
$seshListBk = @($allSesh | ?{($_.CreationTime -ge (Get-Date).AddHours(-$HourstoCheck)) -and $_.JobType -eq "Backup"})
# Gather all BackupCopy sessions within timeframe
# $seshListBkc = @($allSesh | ?{($_.CreationTime -ge (Get-Date).AddHours(-$HourstoCheck)) -and $_.JobType -eq "BackupSync"})
# Gather all Replication sessions within timeframe
# $seshListRepl = @($allSesh | ?{($_.CreationTime -ge (Get-Date).AddHours(-$HourstoCheck)) -and $_.JobType -eq "Replica"})

# Get Backup session information
$totalxferBk = 0
$totalReadBk = 0
$seshListBk | %{$totalxferBk += $([Math]::Round([Decimal]$_.Progress.TransferedSize/1GB, 0))}
$seshListBk | %{$totalReadBk += $([Math]::Round([Decimal]$_.Progress.ReadSize/1GB, 0))}


# Preparing Backup Session Reports
$successSessionsBk = @($seshListBk | ?{$_.Result -eq "Success"})
$warningSessionsBk = @($seshListBk | ?{$_.Result -eq "Warning"})
$failsSessionsBk = @($seshListBk | ?{$_.Result -eq "Failed"})
$runningSessionsBk = @($allSesh | ?{$_.State -eq "Working" -and $_.JobType -eq "Backup"})
$failedSessionsBk = @($seshListBk | ?{($_.Result -eq "Failed") -and ($_.WillBeRetried -ne "True")})

# Preparing Backup Copy Session Reports
# $successSessionsBkC = @($seshListBkC | ?{$_.Result -eq "Success"})
# $warningSessionsBkC = @($seshListBkC | ?{$_.Result -eq "Warning"})
# $failsSessionsBkC = @($seshListBkC | ?{$_.Result -eq "Failed"})
# $runningSessionsBkC = @($allSesh | ?{$_.State -eq "Working" -and $_.JobType -eq "BackupSync"})
# $IdleSessionsBkC = @($allSesh | ?{$_.State -eq "Idle" -and $_.JobType -eq "BackupSync"})
# $failedSessionsBkC = @($seshListBkC | ?{($_.Result -eq "Failed") -and ($_.WillBeRetried -ne "True")})

# Preparing Replicatiom Session Reports
# $successSessionsRepl = @($seshListRepl | ?{$_.Result -eq "Success"})
# $warningSessionsRepl = @($seshListRepl | ?{$_.Result -eq "Warning"})
# $failsSessionsRepl = @($seshListRepl | ?{$_.Result -eq "Failed"})
# $runningSessionsRepl = @($allSesh | ?{$_.State -eq "Working" -and $_.JobType -eq "Replica"})
# $failedSessionsRepl = @($seshListRepl | ?{($_.Result -eq "Failed") -and ($_.WillBeRetried -ne "True")})

$SessionReport = @()
$SessionReport = $row = "" | select "Backup Success", "Backup Warning", "Backup Failed", "Backup Total Transfer", "Backup Total Read"
                 $row."Backup Success" = $successSessionsBk.Count
	             $row."Backup Warning" = $warningSessionsBk.Count
			     $row."Backup Failed" = $failedSessionsBk.Count
                 $row."Backup Total Transfer" = "$totalxferBk GB"
                 $row."Backup Total Read" = "$totalReadBk GB"  
                
$SessionReport

$Title = "Veeam BR Backup Sessions"
$Header = "Veeam BR Backup Sessions Report"
$Comments = "Count of Backup Sessions on BR Host $BRHost"
$Display = "Table"
$Author = "Markus Kraus"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

$TableFormat = @{"Backup Warning" = @(@{ "-gt 0"     = "Row,class|warning"; });
                 "Backup Failed"  = @(@{ "-gt 0"     = "Row,class|critical";})								   	   
				}
