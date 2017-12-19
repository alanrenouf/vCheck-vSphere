$Title = "Connection settings for vCenter"
$Author = "Alan Renouf"
$PluginVersion = 1.20
$Header = "Connection Settings"
$Comments = "Connection Plugin for connecting to vSphere"
$Display = "None"
$PluginCategory = "vSphere"

# Start of Settings
# Please Specify the address (and optional port) of the vCenter server to connect to [servername(:port)]
$Server = "vcsa.local.lab"
# End of Settings

# Update settings where there is an override
$Server = Get-vCheckSetting $Title "Server" $Server

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
      collectAlarms = Collecting Alarm Definitions
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

#
# Adding PowerCLI core module/pssnapin
#
# Possibilities:
# 1) PSSnpain (-le 5.8R1)
# 2) Module + PSSnapin (-gt 5.8R1/-lt 6.5R1)
# 3) Module (-ge 6.5R1)

function Get-CorePlatform {
    [cmdletbinding()]
    param()
    #Thanks to @Lucd22 (Lucd.info) for this great function!
    $osDetected = $false
    try{
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        Write-Verbose -Message 'Windows detected'
        $osDetected = $true
        $osFamily = 'Windows'
        $osName = $os.Caption
        $osVersion = $os.Version
        $nodeName = $os.CSName
        $architecture = $os.OSArchitecture
    }
    catch{
        Write-Verbose -Message 'Possibly Linux or Mac'
        $uname = "$(uname)"
        if($uname -match '^Darwin|^Linux'){
            $osDetected = $true
            $osFamily = $uname
            $osName = "$(uname -v)"
            $osVersion = "$(uname -r)"
            $nodeName = "$(uname -n)"
            $architecture = "$(uname -p)"
        }
        # Other
        else
        {
            Write-Warning -Message "Kernel $($uname) not covered"
        }
    }
    [ordered]@{
        OSDetected = $osDetected
        OSFamily = $osFamily
        OS = $osName
        Version = $osVersion
        Hostname = $nodeName
        Architecture = $architecture
    }
}

$Platform = Get-CorePlatform
switch ($platform.OSFamily) {
    "Darwin" { 
        $templocation = "/tmp"
        $Outputpath = $templocation
        Get-Module -ListAvailable PowerCLI* | Import-Module
    }
    "Linux" { 
        $templocation = "/tmp"
        $Outputpath = $templocation
        Get-Module -ListAvailable PowerCLI* | Import-Module
    }
    "Windows" { 
        $templocation = "$ENV:Temp"
        $pcliCore = 'VMware.VimAutomation.Core'

        $pssnapinPresent = $false
        $psmodulePresent = $false

        if(Get-Module -Name $pcliCore -ListAvailable){
            $psmodulePresent = $true
            if(!(Get-Module -Name $pcliCore)){
                Import-Module -Name $pcliCore
            }
        }

        if(Get-PSSnapin -Name $pcliCore -Registered -ErrorAction SilentlyContinue){
            $pssnapinPresent = $true
            if(!(Get-PSSnapin -Name $pcliCore -ErrorAction SilentlyContinue)){
                Add-PSSnapin -Name $pcliCore
            }
        }

        if(!$pssnapinPresent -and !$psmodulePresent){
            Write-Error "Can't find PowerCLI. Is it installed?"
            return
        }
    }
}

$OpenConnection = $global:DefaultVIServers | Where-Object { $_.Name -eq $VIServer }
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
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine] $vm)
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
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine] $vm)

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

Write-CustomOut $pLang.collectVM
$VM = Get-VM | Sort-Object Name
Write-CustomOut $pLang.collectHost
$VMH = Get-VMHost | Sort-Object Name
Write-CustomOut $pLang.collectCluster
$Clusters = Get-Cluster | Sort-Object Name
Write-CustomOut $pLang.collectDatastore
$Datastores = Get-Datastore | Sort-Object Name
Write-CustomOut $pLang.collectDVM
$FullVM = Get-View -ViewType VirtualMachine | Where-Object {-not $_.Config.Template}
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
Write-CustomOut $pLang.collectAlarms
$valarms = $alarmMgr.GetAlarm($null) | Select-Object value, @{N="name";E={(Get-View -Id $_).Info.Name}}

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
      [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItem[]]$Entity,
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
         Where-Object {$_.Info.Name -match $ScheduledTask} |
         Select-Object -First 1 |
         Select-Object -ExpandProperty MoRef
      }
      if(!$Entity){
         $Entity = @(Get-Folder -NoRecursion)
      }
      $entity | Foreach-Object {
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

function Get-FriendlyUnit{
<#
.SYNOPSIS  Convert numbers into smaller binary multiples
.DESCRIPTION The function accepts a value and will convert it
into the biggest binary unit available.
.NOTES  Author:  Luc Dekens
.PARAMETER Value
The value you want to convert.
This number must be positive.
.PARAMETER IEC
A switch to indicate if the function shall return the IEC
unit names, or the more commonly used unit names.
The default is to use the commonly used unit names.
.EXAMPLE
PS> Get-FriendlyUnit -Value 123456
.EXAMPLE
PS> 123456 | Get-FriendlyUnit -IEC
.EXAMPLE
PS> Get-FriendlyUnit -Value 123456,789123, 45678
#>

    param(
        [CmdletBinding()]
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [double[]]$Value,
        [switch]$IEC
    )

    begin{
        $OldUnits = "B","KB","MB","GB","TB","PB","EB","ZB","YB"
        $IecUnits = "B","KiB","MiB","GiB","TiB","PiB","EiB","ZiB","YiB"
        if($IEC){$units = $IecUnits}else{$units=$OldUnits}
    }

    process{
        $Value | %{
            if($_ -lt 0){
                write-Error "Numbers must be positive."
                break
            }
            if($value -gt 0){
                $modifier = [math]::Floor([Math]::Log($_,1KB))
            }
            else{
                $modifier = 0
            }
            New-Object PSObject -Property @{
                Value = $_ / [math]::Pow(1KB,$modifier)
                Unit = &{if($modifier -lt $units.Count){$units[$modifier]}else{"1KB E{0}" -f $modifier}}
            }
        }
    }
}

function Get-HttpDatastoreItem{
<#
.SYNOPSIS  Get file and folder info from datastore
.DESCRIPTION This function will retrieve a file and folders
list from a datastore. The function uses the HTTP access to
a datastore to obtain the list.
.NOTES  Author:  Luc Dekens
.PARAMETER Datastore
The datastore for which to retrieve the list
.PARAMETER Path
The folder path from where to start listing files and folders.
The default is to start from the root of the datastore.
.EXAMPLE
.PARAMETER Credential
A credential for an account that has access to the datastore
.PARAMETER Recurse
A switch that defines if the files and folders list shall be recursive
.PARAMETER IncludeRoot
A switch to indicate if the root of the search path shall be included
.PARAMETER Unit
A switch that defines if the filesize shall be returned in friendly units.
Requires the Get-FriednlyUnit function
.EXAMPLE
PS> Get-HttpDatastoreItem -Datastore DS1 -Credential $cred
.EXAMPLE
PS> Get-Datastore | Get-HttpDatastoreItem -Credential $cred
.EXAMPLE
PS> Get-Datastore | Get-HttpDatastoreItem -Credential $cred -Recurse
#>

    [cmdletbinding()]
    param(
        [VMware.VimAutomation.ViCore.Types.V1.VIServer]$Server = $global:DefaultVIServer,
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName,ParameterSetName="Datastore")]
        [Alias('Name')]
        [string]$Datastore,
        [parameter(Mandatory=$true,ParameterSetName="Path")]
        [string]$Path = '',
        [PSCredential]$Credential,
        [Switch]$Recurse = $false,
        [Switch]$IncludeRoot = $false,
        [Switch]$Unit = $false
    )

    Begin{
        $regEx = [RegEx]'<tr><td><a.*?>(?<Filename>.*?)</a></td><td.*?>(?<Timestamp>.*?)</td><td.*?>(?<Filesize>[0-9]+|[ -]+)</td></tr>'
    }

    Process{
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack;">Entering {0}" -f $s[0].FunctionName)"
        Write-Verbose -Message "$(Get-Date) Datastore:$($Datastore)  Path:$($Path)"
        Write-Verbose -Message "$(Get-Date) Recurse:$($Recurse.IsPresent)"

        Switch($PSCmdlet.ParameterSetName){
            'Datastore' {
                $Folder = ''
            }
            'Path' {
                $Datastore,$folderQualifier = $Path.Split('\[\] /',[System.StringSplitOptions]::RemoveEmptyEntries)

                if(-not $folderQualifier){
                    $lastParent = ''
                    $lastQualifier = ''
                }
                else{
                    if($folderQualifier.Count -eq 1){
                        $lastParent = ''
                        $lastQualifier = "$($folderQualifier)$(if($Path -match "/$"){'/'})"
                    }
                    else{
                        $lastQualifier = "$($folderQualifier[-1])$(if($Path -match "/$"){'/'})"
                        $lastParent = "$($folderQualifier[0..($folderQualifier.Count-2)] -join '/')/"
                    }
                }
            }
            Default {
                Throw "Invalid parameter combination"
            }                                                                                                                                                                        
        }
        $folderQualifier = $folderQualifier -join '/'
        if($Path -match "/$" -and $folderQualifier -notmatch "/$"){
            $folderQualifier += '/'
        }
        $stack = Get-PSCallStack | Select -ExpandProperty Command
        if(($stack | Group-Object -AsHashTable -AsString)[$stack[0]].Count -eq 1){
            Write-Verbose "First call"
            $sDFile = @{
                Server = $Server
                Credential = $Credential
                Path = "[$($Datastore)]$(if($lastParent){"" $($lastParent)""})"
                Recurse = $Recurse.IsPresent
                IncludeRoot = $IncludeRoot.IsPresent
                Unit = $Unit.IsPresent
            }
            $allEntry = Get-HttpDatastoreItem @sDFile
            $entry = $allEntry | where{$_.Name -match "^$($lastQualifier)/*$"}
            if($entry.Name -match "\/$"){
            # It's a folder
                if($lastQualifier -notmatch "/$"){
                    $folderQualifier += '/'
                }
                if($IncludeRoot.IsPresent){
                    $entry
                }
            }
            else{
            # It's a file
                $entry
            }
        }

        if($folderQualifier -match "\/$" -or -not $folderQualifier){
            $ds = Get-Datastore -Name $Datastore -Server $Server -Verbose:$false
            $dc = Get-VMHost -Datastore $ds -Verbose:$false -Server $Server | Get-Datacenter -Verbose:$false -Server $Server
            $uri = "https://$($Server.Name)/folder$(if($folderQualifier){'/' + $folderQualifier})?dcPath=$($dc.Name)&dsName=$($ds.Name)"
            Write-Verbose "Looking at URI: $($uri)"
            Try{
                $response = Invoke-WebRequest -Uri $Uri -Method Get -Credential $Credential 
            }
            Catch{
                $errorMsg = "`n$(Get-Date -Format 'yyyyMMdd HH:mm:ss') HTTP $($_.Exception.Response.ProtocolVersion)" +
                    " $($_.Exception.Response.Method) $($_.Exception.Response.StatusCode.Value__)" +
                    " $($_.Exception.Response.StatusDescription)`n" +
                    "$(Get-Date -Format 'yyyyMMdd HH:mm:ss') Uri $($_.Exception.Response.ResponseUri)`n "
                Write-Error -Message $errorMsg
                break
            }
            foreach($entry in $response){
                $regEx.Matches($entry.Content) | 
                Where{$_.Success -and $_.Groups['Filename'].Value -notmatch 'Parent Datacenter|Parent Directory'} | %{
                    Write-Verbose "`tFound $($_.Groups['Filename'].Value)"
                    $fName = $_.Groups['Filename'].Value
                    $obj = [ordered]@{
                        Name = $_.Groups['Filename'].Value
                        FullName = "[$($ds.Name)] $($folderQualifier)$(if($folderQualifier -notmatch '/$' -and $folderQualifier){'/'})$($_.Groups['Filename'].Value)"
                        Timestamp = [DateTime]$_.Groups['Timestamp'].Value
                    }
                    if($fName -notmatch "/$"){
                        $tSize = $_.Groups['Filesize'].Value
                        if($Unit.IsPresent){
                            $friendly = $tSize | Get-FriendlyUnit
                            $obj.Add('Size',[Math]::Round($friendly.Value,0))
                            $obj.Add('Unit',$friendly.Unit)
                        }
                        else{
                            $obj.Add('Size',$tSize)
                        }
                    }
                    else{
                        $obj.Add('Size','')
                        if($Unit.IsPresent){
                            $obj.Add('Unit','')
                        }
                    }
                    New-Object PSObject -Property $obj
                    if($_.Groups['Filename'].Value -match "/$" -and $Recurse.IsPresent){
                        $sDFile = @{
                            Server = $Server
                            Credential = $Credential
                            Path = "[$($ds.Name)] $($folderQualifier)$(if($folderQualifier -notmatch '/$' -and $folderQualifier){'/'})$($_.Groups['Filename'].Value)"
                            Recurse = $Recurse.IsPresent
                            IncludeRoot = $IncludeRoot
                            Unit = $Unit.IsPresent
                        }
                        Get-HttpDatastoreItem @sDFile
                    }
                }
            }
        }
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack;"<Leaving {0}" -f $s[0].FunctionName)"
    }
}