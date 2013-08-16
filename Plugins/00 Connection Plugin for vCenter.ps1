$Title = "Connection settings for vCenter"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$Header =  "Connection Settings"
$Comments = "Connection Plugin for connecting to vSphere"
$Display = "List"
$PluginCategory = "vSphere"

# Start of Settings 
# Maximum number of samples to gather for events
$MaxSampleVIEvent = 100000
# End of Settings

# Find the VI Server from the global settings file
$VIServer = $Server
# Path to credentials file which is automatically created if needed
$Credfile = $ScriptPath + "\Windowscreds.xml"

# Adding PowerCLI core snapin
if (!(get-pssnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
	add-pssnapin VMware.VimAutomation.Core
}

$OpenConnection = $global:DefaultVIServers | where { $_.Name -eq $VIServer }
if($OpenConnection.Connected) {
	Write-CustomOut "Re-using connection to VI Server"
	$VIConnection = $OpenConnection
} else {
	Write-CustomOut "Connecting to VI Server"
	$VIConnection = Connect-VIServer $VIServer
}

if (-not $VIConnection.IsConnected) {
	Write-Host "Unable to connect to vCenter, please ensure you have altered the vCenter server address correctly "
	Write-Host " to specify a username and password edit the connection string in the file $GlobalVariables"
	break
}


Write-CustomOut "Adding Custom properties"

function Get-VMLastPoweredOffDate {
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl] $vm)
  process {
    $Report = "" | Select-Object -Property Name,LastPoweredOffDate
     $Report.Name = $_.Name
    $Report.LastPoweredOffDate = (Get-VIEvent -Entity $vm | `
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
    $Report.LastPoweredOnDate = (Get-VIEvent -Entity $vm | `
      Where-Object { $_.Gettype().Name -eq "VmPoweredOnEvent" } | `
       Select-Object -First 1).CreatedTime
     $Report
  }
}

New-VIProperty -Name LastPoweredOffDate -ObjectType VirtualMachine -Value {(Get-VMLastPoweredOffDate -vm $Args[0]).LastPoweredOffDate} | Out-Null
New-VIProperty -Name LastPoweredOnDate -ObjectType VirtualMachine -Value {(Get-VMLastPoweredOnDate -vm $Args[0]).LastPoweredOnDate} | Out-Null

New-VIProperty -Name PercentFree -ObjectType Datastore -Value {
	param($ds)
	[math]::Round(((100 * ($ds.FreeSpaceMB)) / ($ds.CapacityMB)),0)
} -Force | Out-Null

New-VIProperty -Name "HWVersion" -ObjectType VirtualMachine -Value {
	param($vm)

	$vm.ExtensionData.Config.Version[5-6]
} -BasedOnExtensionProperty "Config.Version" -Force | Out-Null

Write-CustomOut "Collecting VM Objects"
$VM = Get-VM | Sort Name
Write-CustomOut "Collecting VM Host Objects"
$VMH = Get-VMHost | Sort Name
Write-CustomOut "Collecting Cluster Objects"
$Clusters = Get-Cluster | Sort Name
Write-CustomOut "Collecting Datastore Objects"
$Datastores = Get-Datastore | Sort Name
Write-CustomOut "Collecting Detailed VM Objects"
$FullVM = Get-View -ViewType VirtualMachine | Where {-not $_.Config.Template}
Write-CustomOut "Collecting Template Objects"
$VMTmpl = Get-Template
Write-CustomOut "Collecting Detailed VI Objects"
$ServiceInstance = get-view ServiceInstance
Write-CustomOut "Collecting Detailed Alarm Objects"
$alarmMgr = get-view $ServiceInstance.Content.alarmManager
Write-CustomOut "Collecting Detailed VMHost Objects"
$HostsViews = Get-View -ViewType hostsystem
Write-CustomOut "Collecting Detailed Cluster Objects"
$clusviews = Get-View -ViewType ClusterComputeResource
Write-CustomOut "Collecting Detailed Datastore Objects"
$storageviews = Get-View -ViewType Datastore

# Find out which version of the API we are connecting to
$VIVersion = ((Get-View ServiceInstance).Content.About.Version).Chars(0)

# Check for vSphere
If ($VIVersion -ge 4){
	$vSphere = $true
}

$date = Get-Date

