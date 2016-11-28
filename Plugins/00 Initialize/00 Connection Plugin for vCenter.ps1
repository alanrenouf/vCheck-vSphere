$Title = "Connection settings for vCenter"
$Author = "Alan Renouf"
$PluginVersion = 1.7
$Header = "Connection Settings"
$Comments = "Connection Plugin for connecting to vSphere"
$Display = "None"
$PluginCategory = "vSphere"

# Start of Settings
# Maximum number of samples to gather for events
$MaxSampleVIEvent = 100000
# End of Settings

# Setup plugin-specific language table
$pLang = DATA {
   ConvertFrom-StringData @' 
      connReuse = Re-using connection to VI Server
      connOpen  = Connecting to VI Server
      connError = Unable to connect to vCenter, please ensure you have altered the vCenter server address correctly. To specify a username and password edit the connection string in the file $GlobalVariables
      custAttr  = Adding Custom properties
      collectVM = Collecting VM Objects
      collectHost = Collecting VM Host Objects
      collectCluster = Collecting Cluster Objects
      collectDatastore = Collecting Datastore Objects
      collectDVM = Collecting Detailed VM Objects
      collectTemplate = Collecting Template Objects
      collectDVIO = Collecting Detailed VI Objects
      collectAlarm = Collecting Detailed Alarm Objects
      collectDHost = Collecting Detailed VMHost Objects
      collectDCluster = Collecting Detailed Cluster Objects
      collectDDatastore = Collecting Detailed Datastore Objects
      collectDDatastoreCluster = Collecting Detailed Datastore Cluster Objects
'@
}
# Override the default (en) if it exists in lang directory
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang -ErrorAction SilentlyContinue

# Find the VI Server and port from the global settings file
$VIServer = ($Server -Split ":")[0]
if (($server -split ":")[1]) {
   $port = ($server -split ":")[1]
}
else
{
   $port = 443
}

# Path to credentials file which is automatically created if needed
$Credfile = $ScriptPath + "\Windowscreds.xml"

# Adding PowerCLI core snapin, also check if powerCLI module is alsready added
if (!(get-module -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
	if (!(get-pssnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
		add-pssnapin VMware.VimAutomation.Core -erroraction silentlycontinue
	}
}

$OpenConnection = $global:DefaultVIServers | where { $_.Name -eq $VIServer }
if($OpenConnection.IsConnected) {
	Write-CustomOut ( "{0}: {1}" -f $pLang.connReuse, $Server )
	$VIConnection = $OpenConnection
} else {
	Write-CustomOut ( "{0}: {1}" -f $pLang.connOpen, $Server )
	$VIConnection = Connect-VIServer -Server $VIServer -Port $Port
}

if (-not $VIConnection.IsConnected) {
	Write-Error $pLang.connError
}

Write-CustomOut $pLang.custAttr

function Get-VMLastPoweredOffDate {
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl] $vm)
  process {
    $Report = "" | Select-Object -Property Name,LastPoweredOffDate
     $Report.Name = $_.Name
    $Report.LastPoweredOffDate = (Get-VIEventPlus -Entity $vm | `
      Where-Object { $_.Gettype().Name -eq "VmPoweredOffEvent" } | `
       Select-Object -First 1).CreatedTime
     $Report
  }
}

function Get-VMLastPoweredOnDate {
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl] $vm)

  process {
    $Report = "" | Select-Object -Property Name,LastPoweredOnDate
     $Report.Name = $_.Name
    $Report.LastPoweredOnDate = (Get-VIEventPlus -Entity $vm | `
      Where-Object { $_.Gettype().Name -match "VmPoweredOnEvent" } | `
       Select-Object -First 1).CreatedTime
     $Report
  }
}

New-VIProperty -Name LastPoweredOffDate -ObjectType VirtualMachine -Value {(Get-VMLastPoweredOffDate -vm $Args[0]).LastPoweredOffDate} | Out-Null
New-VIProperty -Name LastPoweredOnDate -ObjectType VirtualMachine -Value {(Get-VMLastPoweredOnDate -vm $Args[0]).LastPoweredOnDate} | Out-Null

New-VIProperty -Name PercentFree -ObjectType Datastore -Value {
	param($ds)
	[math]::Round(((100 * ($ds.FreeSpaceMB)) / ($ds.CapacityMB)),2)
} -Force | Out-Null

New-VIProperty -Name "HWVersion" -ObjectType VirtualMachine -Value {
	param($vm)

	$vm.ExtensionData.Config.Version.Substring(4)
} -BasedOnExtensionProperty "Config.Version" -Force | Out-Null

if ( $DataCenter ) {
	Write-CustomOut $pLang.collectVM
	$VM = Get-VM -Location "$DataCenter" | Sort Name
	Write-CustomOut $pLang.collectHost
	$VMH = Get-VMHost -Location "$DataCenter" | Sort Name
	Write-CustomOut $pLang.collectCluster
	$Clusters = Get-Cluster -Location "$DataCenter" | Sort Name
	Write-CustomOut $pLang.collectDatastore
	$Datastores = Get-Datastore -Location "$DataCenter" | Sort Name
 } else {
	Write-CustomOut $pLang.collectVM
	$VM = Get-VM | Sort Name
	Write-CustomOut $pLang.collectHost
	$VMH = Get-VMHost | Sort Name
	Write-CustomOut $pLang.collectCluster
	$Clusters = Get-Cluster | Sort Name
	Write-CustomOut $pLang.collectDatastore
	$Datastores = Get-Datastore | Sort Name
}

Write-CustomOut $pLang.collectDVM
$FullVM = Get-View -ViewType VirtualMachine | Where {-not $_.Config.Template}
Write-CustomOut $pLang.collectTemplate 
$VMTmpl = Get-Template
Write-CustomOut $pLang.collectDVIO
$ServiceInstance = get-view ServiceInstance
Write-CustomOut $pLang.collectAlarm
$alarmMgr = get-view $ServiceInstance.Content.alarmManager
Write-CustomOut $pLang.collectDHost
$HostsViews = Get-View -ViewType hostsystem
Write-CustomOut $pLang.collectDCluster
$clusviews = Get-View -ViewType ClusterComputeResource
Write-CustomOut $pLang.collectDDatastore
$storageviews = Get-View -ViewType Datastore

# Find out which version of the API we are connecting to
$VIVersion = ((Get-View ServiceInstance).Content.About.Version).Chars(0)

# Check to see if its a VCSA or not
if ($ServiceInstance.Client.ServiceContent.About.OsType -eq "linux-x64"){ $VCSA = $true }

# Check for vSphere
If ($VIVersion -ge 4){
	$vSphere = $true
}

if ($VIVersion -ge 5) {
	Write-CustomOut $pLang.collectDDatastoreCluster
	$DatastoreClustersView = Get-View -viewtype StoragePod
}

<#   
.SYNOPSIS  Returns vSphere events    
.DESCRIPTION The function will return vSphere events. With
	the available parameters, the execution time can be
	improved, compered to the original Get-VIEvent cmdlet. 
.NOTES  Author:  Luc Dekens   
.PARAMETER Entity
	When specified the function returns events for the
	specific vSphere entity. By default events for all
	vSphere entities are returned. 
.PARAMETER EventType
	This parameter limits the returned events to those
	specified on this parameter. 
.PARAMETER Start
	The start date of the events to retrieve 
.PARAMETER Finish
	The end date of the events to retrieve. 
.PARAMETER Recurse
	A switch indicating if the events for the children of
	the Entity will also be returned 
.PARAMETER User
	The list of usernames for which events will be returned 
.PARAMETER System
	A switch that allows the selection of all system events. 
.PARAMETER ScheduledTask
	The name of a scheduled task for which the events
	will be returned 
.PARAMETER FullMessage
	A switch indicating if the full message shall be compiled.
	This switch can improve the execution speed if the full
	message is not needed.   
.PARAMETER UseUTC
	A switch indicating if the event shoukld remain in UTC or
	local time.
.EXAMPLE
	PS> Get-VIEventPlus -Entity $vm
.EXAMPLE
	PS> Get-VIEventPlus -Entity $cluster -Recurse:$true
#>
function Get-VIEventPlus {
	 
	param(
		[VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl[]]$Entity,
		[string[]]$EventType,
		[DateTime]$Start,
		[DateTime]$Finish = (Get-Date),
		[switch]$Recurse,
		[string[]]$User,
		[Switch]$System,
		[string]$ScheduledTask,
		[switch]$FullMessage = $false,
		[switch]$UseUTC = $false
	)

	process {
		$eventnumber = 100
		$events = @()
		$eventMgr = Get-View EventManager
		$eventFilter = New-Object VMware.Vim.EventFilterSpec
		$eventFilter.disableFullMessage = ! $FullMessage
		$eventFilter.entity = New-Object VMware.Vim.EventFilterSpecByEntity
		$eventFilter.entity.recursion = &{if($Recurse){"all"}else{"self"}}
		$eventFilter.eventTypeId = $EventType
		if($Start -or $Finish){
			$eventFilter.time = New-Object VMware.Vim.EventFilterSpecByTime
			if($Start){
				$eventFilter.time.beginTime = $Start
			}
			if($Finish){
				$eventFilter.time.endTime = $Finish
			}
		}
		if($User -or $System){
			$eventFilter.UserName = New-Object VMware.Vim.EventFilterSpecByUsername
			if($User){
				$eventFilter.UserName.userList = $User
			}
			if($System){
				$eventFilter.UserName.systemUser = $System
			}
		}
		if($ScheduledTask){
			$si = Get-View ServiceInstance
			$schTskMgr = Get-View $si.Content.ScheduledTaskManager
			$eventFilter.ScheduledTask = Get-View $schTskMgr.ScheduledTask |
			where {$_.Info.Name -match $ScheduledTask} |
			Select -First 1 |
			Select -ExpandProperty MoRef
		}
		if(!$Entity){
			$Entity = @(Get-Folder -NoRecursion)
		}
		$entity | %{
			$eventFilter.entity.entity = $_.ExtensionData.MoRef
			$eventCollector = Get-View ($eventMgr.CreateCollectorForEvents($eventFilter))
			$eventsBuffer = $eventCollector.ReadNextEvents($eventnumber)
			while($eventsBuffer){
				$events += $eventsBuffer
				$eventsBuffer = $eventCollector.ReadNextEvents($eventnumber)
			}
			$eventCollector.DestroyCollector()
		}
		if (-not $UseUTC)
		{
			$events | % { $_.createdTime = $_.createdTime.ToLocalTime() }
		}
		
		$events
	}
}
