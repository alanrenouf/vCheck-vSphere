$vCheckJobName = Read-Host -Prompt "Enter the name of the vCheck job to create"
$TriggerTime = Read-Host -Prompt "Enter the time $vCheckJobName should run at, in the format 'H:MM AM/PM' (e.g. '2:00 AM')"
$Location = Read-Host -Prompt "Enter the fully qualified location where the vCheck script resides"
$sb = [scriptblock]::Create($Location)

$dailyTrigger = New-JobTrigger -Daily -At $TriggerTime
$option = New-ScheduledJobOption -StartIfOnBattery –StartIfIdle
Register-ScheduledJob -Name $vCheckJobName -Trigger $dailyTrigger -ScheduledJobOption $option `
   -ScriptBlock $sb
