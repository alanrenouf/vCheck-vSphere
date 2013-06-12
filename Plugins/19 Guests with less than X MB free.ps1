# Start of Settings 
# VM Disk space left, set the amount you would like to report on
$MBFree =1024
# End of Settings

$MyCollection = @()
$AllVMs = $FullVM | Where {-not $_.Config.Template } | Where { $_.Runtime.PowerState -eq "poweredOn" -And ($_.Guest.toolsStatus -ne "toolsNotInstalled" -And $_.Guest.ToolsStatus -ne "toolsNotRunning")}
$SortedVMs = $AllVMs | Select *, @{N="NumDisks";E={@($_.Guest.Disk.Length)}} | Sort-Object -Descending NumDisks
ForEach ($VMdsk in $SortedVMs){
	$Details = New-object PSObject
	$DiskNum = 0
	$Details | Add-Member -Name Name -Value $VMdsk.name -Membertype NoteProperty
	Foreach ($disk in $VMdsk.Guest.Disk){
		if (([math]::Round($disk.FreeSpace / 1MB)) -lt $MBFree){
			$Details | Add-Member -Name "Disk$($DiskNum)path" -MemberType NoteProperty -Value $Disk.DiskPath
			$Details | Add-Member -Name "Disk$($DiskNum)Capacity(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.Capacity/ 1MB))
			$Details | Add-Member -Name "Disk$($DiskNum)FreeSpace(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.FreeSpace / 1MB))
			$DiskNum++
			$MyCollection += $Details
			}
	}
	
}
$MyCollection

$Title = "Guests with less than $MBFree MB"
$Header =  "VMs with less than $MBFree MB : $(@($MyCollection).count)"
$Comments = "The following guests have less than $MBFree MB Free, if a guest disk fills up it may cause issues with the guest Operating System"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
