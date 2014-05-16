$Title = "Connection settings for vCenter"
$Author = "Alan Renouf"
$PluginVersion = 1.4
$Header = "Connection Settings"
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

# Setup plugin-specific language table
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang

# Adding PowerCLI core snapin
if (!(get-pssnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
	add-pssnapin VMware.VimAutomation.Core
}

$OpenConnection = $global:DefaultVIServers | where { $_.Name -eq $VIServer }
if($OpenConnection.IsConnected) {
	Write-CustomOut $pLang.connReuse
	$VIConnection = $OpenConnection
} else {
	Write-CustomOut $pLang.connOpen
	$VIConnection = Connect-VIServer $VIServer
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

	$vm.ExtensionData.Config.Version.Substring(4)
} -BasedOnExtensionProperty "Config.Version" -Force | Out-Null

Write-CustomOut $pLang.collectVM
$VM = Get-VM | Sort Name
Write-CustomOut $pLang.collectHost
$VMH = Get-VMHost | Sort Name
Write-CustomOut $pLang.collectCluster
$Clusters = Get-Cluster | Sort Name
Write-CustomOut $pLang.collectDatastore
$Datastores = Get-Datastore | Sort Name
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
