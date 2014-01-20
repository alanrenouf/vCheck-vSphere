$Title = "Connection settings for vCenter"
$Author = "Alan Renouf"
$PluginVersion = 1.31
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
if($OpenConnection.IsConnected) {
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

	$vm.ExtensionData.Config.Version.Substring(4)
} -BasedOnExtensionProperty "Config.Version" -Force | Out-Null

# Check each enabled plugin for references to vCheck objects
$CheckRequirements = @{'$VM'             = @("VM Objects", '$VM = Get-VM | Sort Name');
                       '$VMH'            = @("VM Host Objects", '$VMH = Get-VMHost | Sort Name');
                       '$Clusters'       = @("Cluster Objects", '$Clusters = Get-Cluster | Sort Name');
                       '$Datastores'     = @("Datastore Objects", '$Datastores = Get-Datastore | Sort Name');
                       '$FullVM'         = @("Detailed VM Objects", '$FullVM = Get-View -ViewType VirtualMachine | Where {-not $_.Config.Template}');
                       '$VMTmpl'         = @("Template Objects", '$VMTmpl = Get-Template');
                       '$ServiceInstance'= @("Detailed VI Objects", '$ServiceInstance = get-view ServiceInstance');
                       '$alarmMgr'       = @("Detailed Alarm Objects", '$alarmMgr = get-view $ServiceInstance.Content.alarmManager');
                       '$HostsViews'     = @("Detailed VMHost Objects", '$HostsViews = Get-View -ViewType hostsystem');
                       '$clusviews'      = @("Detailed Cluster Objects", '$clusviews = Get-View -ViewType ClusterComputeResource');
                       '$storageviews'   = @("Detailed Datastore Objects", '$storageviews = Get-View -ViewType Datastore');
                       }
                       
# Track all requirements that used in plugins
$Requirements = @{}

$Plugins | Foreach {
   # Skip the connection plugin, otherwise you will return everything
   if ($_.Name -ne "00 Connection Plugin for vCenter.ps1") {
      $pluginContent = Get-Content $_.Fullname
      foreach ($Requirement in $CheckRequirements.GetEnumerator()) {
         if ($pluginContent -match ("\{0} " -f $Requirement.Name)) {
            $Requirements.Add($Requirement.Name, $Requirement)
         }
      }
   }
}


# Now load each requirement
foreach ($Requirement in $Requirements.GetEnumerator()) {
   Write-CustomOut ("Collecting {0}" -f $Requirement.Value.Value[0])
   Invoke-Expression $Requirement.Value.Value[1]
}

# Find out which version of the API we are connecting to
$VIVersion = ((Get-View ServiceInstance).Content.About.Version).Chars(0)

# Check for vSphere
If ($VIVersion -ge 4){
	$vSphere = $true
}

$date = Get-Date

