$Title = "Connection settings for vCenter"
$Author = "Alan Renouf"
$PluginVersion = 1.20
$Header = "Connection Settings"
$Comments = "Connection Plugin for connecting to vSphere"
$Display = "None"
$PluginCategory = "vSphere"

# Start of Settings
# Please Specify the address (and optional port) of the vCenter server to connect to [servername(:port)]
$Server = "vcenterappliance1.internal.cornerstonenw.com"
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

# SIG # Begin signature block
# MIIaJAYJKoZIhvcNAQcCoIIaFTCCGhECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5G8diwTm2d8zN3rIJhE+IzUP
# hVmgghTdMIIG3jCCBMagAwIBAgITLAAACIZKKD9KFQrLmwAAAAAIhjANBgkqhkiG
# 9w0BAQ0FADBlMRMwEQYKCZImiZPyLGQBGRYDY29tMR0wGwYKCZImiZPyLGQBGRYN
# Y29ybmVyc3RvbmVudzEYMBYGCgmSJomT8ixkARkWCGludGVybmFsMRUwEwYDVQQD
# EwxDU05XIFJvb3QgQ0EwHhcNMjEwNTAzMjI0MDA1WhcNMjIwNTAzMjI0MDA1WjB7
# MRMwEQYKCZImiZPyLGQBGRYDY29tMR0wGwYKCZImiZPyLGQBGRYNY29ybmVyc3Rv
# bmVudzEYMBYGCgmSJomT8ixkARkWCGludGVybmFsMREwDwYDVQQLDAhPVV91c2Vy
# czEYMBYGA1UEAxMPVGhvbWFzLkZyZWFyc29uMFkwEwYHKoZIzj0CAQYIKoZIzj0D
# AQcDQgAE/PoIlU91LMGtwMi0ry9sKeeRq0TyOzWDZSW7N1XrLa+6mAdgUDciVp8J
# 1fqcyWMHFh4kRnuNq2+/zb92wWL99aOCAzowggM2MDwGCSsGAQQBgjcVBwQvMC0G
# JSsGAQQBgjcVCIX31ziG/ox0htmRD4bVkEqCuvg/XYfyuz+is2ECAWQCAQgwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsGCSsGAQQBgjcVCgQO
# MAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFKguBJKXvZckUGfMS1UGRjg1A8EQMB8G
# A1UdIwQYMBaAFFNLHk1vGE692PjWZ1QEcop+y1wOMIIBsQYDVR0fBIIBqDCCAaQw
# ggGgoIIBnKCCAZiGRWh0dHA6Ly9kYzEuaW50ZXJuYWwuY29ybmVyc3RvbmVudy5j
# b20vQ2VydEVucm9sbC9DU05XJTIwUm9vdCUyMENBLmNybIaBxWxkYXA6Ly8vQ049
# Q1NOVyUyMFJvb3QlMjBDQSxDTj1kYzEsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUy
# MFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9aW50ZXJu
# YWwsREM9Y29ybmVyc3RvbmVudyxEQz1jb20/Y2VydGlmaWNhdGVSZXZvY2F0aW9u
# TGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50hkdmaWxl
# Oi8vLy9kYzEuaW50ZXJuYWwuY29ybmVyc3RvbmVudy5jb20vQ2VydEVucm9sbC9D
# U05XJTIwUm9vdCUyMENBLmNybIY+aHR0cDovL3BraS5pbnRlcm5hbC5jb3JuZXJz
# dG9uZW53LmNvbS9wa2kvQ1NOVyUyMFJvb3QlMjBDQS5jcmwwgYAGCCsGAQUFBwEB
# BHQwcjBwBggrBgEFBQcwAYZkaHR0cDovL2RjMS5pbnRlcm5hbC5jb3JuZXJzdG9u
# ZW53LmNvbS9DZXJ0RW5yb2xsL2RjMS5pbnRlcm5hbC5jb3JuZXJzdG9uZW53LmNv
# bV9DU05XJTIwUm9vdCUyMENBLmNydDA8BgNVHREENTAzoDEGCisGAQQBgjcUAgOg
# IwwhdGhvbWFzLmZyZWFyc29uQGNvcm5lcnN0b25lbncuY29tMA0GCSqGSIb3DQEB
# DQUAA4ICAQBZn8FwZAJPkVZXMRL0gRu0HZmeBwXA/6B+RxABPMwdlPpm844MNCeg
# DF4C5Bu0LeePT5Ab1i0NtGecog58xF69Dbd6uvw72QdVbc9vndF1vqSmY3wJsqY/
# HCFaC0sJmvZf+HWxY+vI9ji96juPGJnQekpoChtQP5Ne/7AlGhYC6Vk4x6GIMmsI
# NvIK533hT7JYmivCmG0EupVJkzKnOe1HtDmFXFTIjznXB6lmU/f9ODSkGc8/3kN9
# 9QsL9hBoAtpltPYZ51raqGh8HDBK26BzvAFR46uM/r+Bn5tadrNph7zjC15Y4TpT
# dx4/zKXC98lcdXcWHez4yM8qB/lQmdb1QSlEErD2Jg3hWI31t9J29bnK5fKFS+4B
# lg+EIDPkniEOILPfDXX2ctsDebwsYGLvdI0fVg52ApaWjCTwt0K22CH26pvTMQsL
# KDnQFyZy5c8xqmPGgxtTzGY/80DKhO3u65TF9ouPr07tjcwejyJjt/4uj8O/pVML
# +bRU/m1krkIZ6cDkezT/xb36N9psESlQuhnaRaF8u1OxmvzR98yzI1mox/6vT6EJ
# ttw0pGF7hN0LT5vPNTcJOTlouWLgKBv/tdV1watycAvx84HOvreWIhE5ulhnQHdN
# u/vGgZUHyTnE4ohwTl3rnRUA4CNs+Y+AaUKnNx94O8PHKjMxZLV8EjCCBuwwggTU
# oAMCAQICEDAPb6zdZph0fKlGNqd4LbkwDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0
# eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VS
# VHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE5MDUwMjAwMDAw
# MFoXDTM4MDExODIzNTk1OVowfTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0
# ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSUwIwYDVQQDExxTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIENB
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyBsBr9ksfoiZfQGYPyCQ
# vZyAIVSTuc+gPlPvs1rAdtYaBKXOR4O168TMSTTL80VlufmnZBYmCfvVMlJ5Lslj
# whObtoY/AQWSZm8hq9VxEHmH9EYqzcRaydvXXUlNclYP3MnjU5g6Kh78zlhJ07/z
# Obu5pCNCrNAVw3+eolzXOPEWsnDTo8Tfs8VyrC4Kd/wNlFK3/B+VcyQ9ASi8Dw1P
# s5EBjm6dJ3VV0Rc7NCF7lwGUr3+Az9ERCleEyX9W4L1GnIK+lJ2/tCCwYH64TfUN
# P9vQ6oWMilZx0S2UTMiMPNMUopy9Jv/TUyDHYGmbWApU9AXn/TGs+ciFF8e4KRmk
# KS9G493bkV+fPzY+DjBnK0a3Na+WvtpMYMyou58NFNQYxDCYdIIhz2JWtSFzEh79
# qsoIWId3pBXrGVX/0DlULSbuRRo6b83XhPDX8CjFT2SDAtT74t7xvAIo9G3aJ4oG
# 0paH3uhrDvBbfel2aZMgHEqXLHcZK5OVmJyXnuuOwXhWxkQl3wYSmgYtnwNe/YOi
# U2fKsfqNoWTJiJJZy6hGwMnypv99V9sSdvqKQSTUG/xypRSi1K1DHKRJi0E5FAMe
# KfobpSKupcNNgtCN2mu32/cYQFdz8HGj+0p9RTbB942C+rnJDVOAffq2OVgy728Y
# UInXT50zvRq1naHelUF6p4MCAwEAAaOCAVowggFWMB8GA1UdIwQYMBaAFFN5v1qq
# K0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBQaofhhGSAPw0F3RSiO0TVfBhIEVTAO
# BgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggr
# BgEFBQcDCDARBgNVHSAECjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0
# cDovL2NybC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25B
# dXRob3JpdHkuY3JsMHYGCCsGAQUFBwEBBGowaDA/BggrBgEFBQcwAoYzaHR0cDov
# L2NydC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUG
# CCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEB
# DAUAA4ICAQBtVIGlM10W4bVTgZF13wN6MgstJYQRsrDbKn0qBfW8Oyf0WqC5SVmQ
# KWxhy7VQ2+J9+Z8A70DDrdPi5Fb5WEHP8ULlEH3/sHQfj8ZcCfkzXuqgHCZYXPO0
# EQ/V1cPivNVYeL9IduFEZ22PsEMQD43k+ThivxMBxYWjTMXMslMwlaTW9JZWCLjN
# XH8Blr5yUmo7Qjd8Fng5k5OUm7Hcsm1BbWfNyW+QPX9FcsEbI9bCVYRm5LPFZgb2
# 89ZLXq2jK0KKIZL+qG9aJXBigXNjXqC72NzXStM9r4MGOBIdJIct5PwC1j53BLwE
# NrXnd8ucLo0jGLmjwkcd8F3WoXNXBWiap8k3ZR2+6rzYQoNDBaWLpgn/0aGUpk6q
# PQn1BWy30mRa2Coiwkud8TleTN5IPZs0lpoJX47997FSkc4/ifYcobWpdR9xv1tD
# XWU9UIFuq/DQ0/yysx+2mZYm9Dx5i1xkzM3uJ5rloMAMcofBbk1a0x7q8ETmMm8c
# 6xdOlMN4ZSA7D0GqH+mhQZ3+sbigZSo04N6o+TzmwTC7wKBjLPxcFgCo0MR/6hGd
# HgbGpm0yXbQ4CStJB6r97DDa8acvz7f9+tCjhNknnvsBZne5VhDhIG7GrrH5trrI
# NV0zdo7xfCAMKneutaIChrop7rRaALGMq+P5CslUXdS5anSevUiumDCCBwcwggTv
# oAMCAQICEQCMd6AAj/TRsMY9nzpIg41rMA0GCSqGSIb3DQEBDAUAMH0xCzAJBgNV
# BAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1Nh
# bGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGln
# byBSU0EgVGltZSBTdGFtcGluZyBDQTAeFw0yMDEwMjMwMDAwMDBaFw0zMjAxMjIy
# MzU5NTlaMIGEMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVz
# dGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQx
# LDAqBgNVBAMMI1NlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgU2lnbmVyICMyMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkYdLLIvB8R6gntMHxgHKUrC+
# eXldCWYGLS81fbvA+yfaQmpZGyVM6u9A1pp+MshqgX20XD5WEIE1OiI2jPv4ICmH
# rHTQG2K8P2SHAl/vxYDvBhzcXk6Th7ia3kwHToXMcMUNe+zD2eOX6csZ21ZFbO5L
# IGzJPmz98JvxKPiRmar8WsGagiA6t+/n1rglScI5G4eBOcvDtzrNn1AEHxqZpIAC
# TR0FqFXTbVKAg+ZuSKVfwYlYYIrv8azNh2MYjnTLhIdBaWOBvPYfqnzXwUHOrat2
# iyCA1C2VB43H9QsXHprl1plpUcdOpp0pb+d5kw0yY1OuzMYpiiDBYMbyAizE+cgi
# 3/kngqGDUcK8yYIaIYSyl7zUr0QcloIilSqFVK7x/T5JdHT8jq4/pXL0w1oBqlCl
# i3aVG2br79rflC7ZGutMJ31MBff4I13EV8gmBXr8gSNfVAk4KmLVqsrf7c9Tqx/2
# RJzVmVnFVmRb945SD2b8mD9EBhNkbunhFWBQpbHsz7joyQu+xYT33Qqd2rwpbD1W
# 7b94Z7ZbyF4UHLmvhC13ovc5lTdvTn8cxjwE1jHFfu896FF+ca0kdBss3Pl8qu/C
# dkloYtWL9QPfvn2ODzZ1RluTdsSD7oK+LK43EvG8VsPkrUPDt2aWXpQy+qD2q4lQ
# +s6g8wiBGtFEp8z3uDECAwEAAaOCAXgwggF0MB8GA1UdIwQYMBaAFBqh+GEZIA/D
# QXdFKI7RNV8GEgRVMB0GA1UdDgQWBBRpdTd7u501Qk6/V9Oa258B0a7e0DAOBgNV
# HQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDBABgNVHSAEOTA3MDUGDCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRw
# czovL3NlY3RpZ28uY29tL0NQUzBEBgNVHR8EPTA7MDmgN6A1hjNodHRwOi8vY3Js
# LnNlY3RpZ28uY29tL1NlY3RpZ29SU0FUaW1lU3RhbXBpbmdDQS5jcmwwdAYIKwYB
# BQUHAQEEaDBmMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29SU0FUaW1lU3RhbXBpbmdDQS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQBKA3iQQjPsexqDCTYz
# mFW7nUAGMGtFavGUDhlQ/1slXjvhOcRbuumVkDc3vd/7ZOzlgreVzFdVcEtO9KiH
# 3SKFple7uCEn1KAqMZSKByGeir2nGvUCFctEUJmM7D66A3emggKQwi6Tqb4hNHVj
# ueAtD88BN8uNovq4WpquoXqeE5MZVY8JkC7f6ogXFutp1uElvUUIl4DXVCAoT8p7
# s7Ol0gCwYDRlxOPFw6XkuoWqemnbdaQ+eWiaNotDrjbUYXI8DoViDaBecNtkLwHH
# waHHJJSjsjxusl6i0Pqo0bglHBbmwNV/aBrEZSk1Ki2IvOqudNaC58CIuOFPePBc
# ysBAXMKf1TIcLNo8rDb3BlKao0AwF7ApFpnJqreISffoCyUztT9tr59fClbfErHD
# 7s6Rd+ggE+lcJMfqRAtK5hOEHE3rDbW4hqAwp4uhn7QszMAWI8mR5UIDS4DO5E3m
# KgE+wF6FoCShF0DV29vnmBCk8eoZG4BU+keJ6JiBqXXADt/QaJR5oaCejra3QmbL
# 2dlrL03Y3j4yHiDk7JxNQo2dxzOZgjdE1CYpJkCOeC+57vov8fGP/lC4eN0Ult4c
# DnCwKoVqsWxo6SrkECtuIf3TfJ035CoG1sPx12jjTwd5gQgT/rJkXumxPObQeCOy
# CSziJmK/O6mXUczHRDKBsq/P3zGCBLEwggStAgEBMHwwZTETMBEGCgmSJomT8ixk
# ARkWA2NvbTEdMBsGCgmSJomT8ixkARkWDWNvcm5lcnN0b25lbncxGDAWBgoJkiaJ
# k/IsZAEZFghpbnRlcm5hbDEVMBMGA1UEAxMMQ1NOVyBSb290IENBAhMsAAAIhkoo
# P0oVCsubAAAAAAiGMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ07kOPJ79Pciiv7lsfzfozPO7N
# hzALBgcqhkjOPQIBBQAESDBGAiEA+TOmZV0qoLbezjFMz2sg/rnL2DxsQASHIfZ8
# nZB3/loCIQCXs4xphMPItka4hswmzcm3tAJj0aA822ExVymBklSTEqGCA0wwggNI
# BgkqhkiG9w0BCQYxggM5MIIDNQIBATCBkjB9MQswCQYDVQQGEwJHQjEbMBkGA1UE
# CBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3Rh
# bXBpbmcgQ0ECEQCMd6AAj/TRsMY9nzpIg41rMA0GCWCGSAFlAwQCAgUAoHkwGAYJ
# KoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjEwNjA0MjM1
# NjA0WjA/BgkqhkiG9w0BCQQxMgQwydK/kFO5I/eOwwvXiYyCkst7NJR/pZFS6awb
# eH6IHJ0Cm53gwpAakUOxYSbH63UKMA0GCSqGSIb3DQEBAQUABIICAAyG4FQUOiER
# JDQCcQi17PtmxAdn+27+8l/PJVlBGvG4h7ykVdXTfMOHQMRfHPt6QOg+QlHZJzn8
# +YtmXQrmuhkSA9leb/UgzeDCzbJXGCraNCVLinLZazw1cn6iq8cwP85JhwMrdlVs
# u81quryTrkzCoLUAyRgzWKEhye4wD/NH1mhCqBOGCpxlyiY+JJo3Z+18zDPWqjgO
# GxyMhW1jTieHrMK5JWBC2vnXj43f3kYcRlcHENUiVveg9NURqr31mb8eZPGhMHVQ
# 1nXjESuMBe3gDgbgJKHlWIFyNSUwE7W2MOH/anGWiUmn/J1MjrtVI2IYmmUpYkrm
# 8nApLGyzuyk0/zxO2/kEBX96aK8+rTUYPeyaXgilFtTiyKWz2W25ilRrQg6N9nYL
# 122p1uMOe8ErAKn4JOKW1KcFa2/c5ddDXx9b4WwBu6Euewu5R9xQKDu+XSXUEDFN
# 4DZu0fWvFukcarz6DqRGwqHPpDx8OGJq05cqcVQWcvEfNwdy0eVrl3KPOJuZnXmY
# 2NTWiOltCdZI4jSyGA1ukGxAvX4QgXB8cvPcnJBbK3maoKJAzxQnetQLMvxAYIWa
# J8KFsa5QizxOdFHKMiUYo5sDEGXynOn/G2U4UrnTebX+1z0TYac2SOjGXtt6Hn2Q
# oIuo/cUlo/s1nF5n0TOAmq//e4fqKYu5
# SIG # End signature block
