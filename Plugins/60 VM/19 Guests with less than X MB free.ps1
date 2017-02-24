$Title = "Guests with less than X MB free"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# VM Disk space left, set the amount you would like to report on MBFree
$MBFree = 1024
# VM Disk space left, set the amount you would like to report on MBDiskMinSize
$MBDiskMinSize = 1024
# End of Settings

# Update settings where there is an override
$MBFree = Get-vCheckSetting $Title "MBFree" $MBFree
$MBDiskMinSize = Get-vCheckSetting $Title "MBDiskMinSize" $MBDiskMinSize

$MyCollection = @()
$AllVMs = $FullVM | Where-Object {-not $_.Config.Template -and $_.Runtime.PowerState -eq "poweredOn" -And ($_.Guest.toolsStatus -ne "toolsNotInstalled" -And $_.Guest.ToolsStatus -ne "toolsNotRunning")} | Select-Object *, @{N="NumDisks";E={@($_.Guest.Disk.Length)}} | Sort-Object -Descending NumDisks
ForEach ($VMdsk in $AllVMs){
   Foreach ($disk in $VMdsk.Guest.Disk){
      if ((([math]::Round($disk.Capacity / 1MB)) -gt $MBDiskMinSize) -and (([math]::Round($disk.FreeSpace / 1MB)) -lt $MBFree)){
         New-Object -TypeName PSObject -Property ([ordered]@{
            "Name"            = $VMdsk.name
            "Path"            = $Disk.DiskPath
            "Capacity (MB)"   = ([math]::Round($disk.Capacity/ 1MB))
            "Free Space (MB)" =([math]::Round($disk.FreeSpace / 1MB))
         })
      }
   }
}

$Header = "VMs with less than $MBFree MB : [count]"
$Comments = ("The following guests have less than {0} MB Free, if a guest disk fills up it may cause issues with the guest Operating System" -f $MBFree)

# Change Log
## 1.3 : Added Get-vCheckSetting, code refactor