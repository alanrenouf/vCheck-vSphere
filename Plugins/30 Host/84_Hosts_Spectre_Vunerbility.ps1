$Title = "Hosts Spectre Vunerability"
$Header = "Hosts that are affected by Spectre Vunerability : [count]"
$Comments = "Following Hosts are vunerable by Spectre"
$Display = "Table"
$Author = "Felix Longardt"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

# Based on the origial function by William Lam
Function Verify-ESXiMicrocodePatch {
    param(
        [Parameter(Mandatory=$false)][String]$VMHostName,
        [Parameter(Mandatory=$false)][String]$ClusterName,
        [Parameter(Mandatory=$false)][Boolean]$IncludeMicrocodeVerCheck=$false,
        [Parameter(Mandatory=$false)][String]$PlinkPath,
        [Parameter(Mandatory=$false)][String]$ESXiUsername,
        [Parameter(Mandatory=$false)][String]$ESXiPassword
    )

    if($ClusterName) {
        $cluster = Get-View -ViewType ClusterComputeResource -Property Name,Host -Filter @{"name"=$ClusterName}
        $vmhosts = Get-View $cluster.Host -Property Name,Config.FeatureCapability,Hardware.CpuFeature,Summary.Hardware,ConfigManager.ServiceSystem
    } elseif($VMHostName) {
        $vmhosts = Get-View -ViewType HostSystem -Property Name,Config.FeatureCapability,Hardware.CpuFeature,Summary.Hardware,ConfigManager.ServiceSystem -Filter @{"name"=$VMHostName}
    } else {
        $vmhosts = Get-View -ViewType HostSystem -Property Name,Config.FeatureCapability,Hardware.CpuFeature,Summary.Hardware,ConfigManager.ServiceSystem
    }

    # Merge of tables from https://kb.vmware.com/s/article/52345 and https://kb.vmware.com/s/article/52085
    $procSigUcodeTable = @(
	    [PSCustomObject]@{Name = "Sandy Bridge DT";  procSig = "0x000206a7"; ucodeRevFixed = "0x0000002d"; ucodeRevSightings = ""}
	    [PSCustomObject]@{Name = "Sandy Bridge EP";  procSig = "0x000206d7"; ucodeRevFixed = "0x00000713"; ucodeRevSightings = ""}
	    [PSCustomObject]@{Name = "Ivy Bridge DT";  procSig = "0x000306a9"; ucodeRevFixed = "0x0000001f"; ucodeRevSightings = ""}
	    [PSCustomObject]@{Name = "Ivy Bridge EP";  procSig = "0x000306e4"; ucodeRevFixed = "0x0000042c"; ucodeRevSightings = "0x0000042a"}
	    [PSCustomObject]@{Name = "Ivy Bridge EX";  procSig = "0x000306e7"; ucodeRevFixed = "0x00000713"; ucodeRevSightings = ""}
	    [PSCustomObject]@{Name = "Haswell DT";  procSig = "0x000306c3"; ucodeRevFixed = "0x00000024"; ucodeRevSightings = "0x00000023"}
	    [PSCustomObject]@{Name = "Haswell EP";  procSig = "0x000306f2"; ucodeRevFixed = "0x0000003c"; ucodeRevSightings = "0x0000003b"}
	    [PSCustomObject]@{Name = "Haswell EX";  procSig = "0x000306f4"; ucodeRevFixed = "0x00000011"; ucodeRevSightings = "0x00000010"}
	    [PSCustomObject]@{Name = "Broadwell H";  procSig = "0x00040671"; ucodeRevFixed = "0x0000001d"; ucodeRevSightings = "0x0000001b"}
	    [PSCustomObject]@{Name = "Broadwell EP/EX";  procSig = "0x000406f1"; ucodeRevFixed = "0x0b00002a"; ucodeRevSightings = "0x0b000025"}
	    [PSCustomObject]@{Name = "Broadwell DE";  procSig = "0x00050662"; ucodeRevFixed = "0x00000015"; ucodeRevSightings = ""}
	    [PSCustomObject]@{Name = "Broadwell DE";  procSig = "0x00050663"; ucodeRevFixed = "0x07000012"; ucodeRevSightings = "0x07000011"}
	    [PSCustomObject]@{Name = "Broadwell DE";  procSig = "0x00050664"; ucodeRevFixed = "0x0f000011"; ucodeRevSightings = ""}
	    [PSCustomObject]@{Name = "Broadwell NS";  procSig = "0x00050665"; ucodeRevFixed = "0x0e000009"; ucodeRevSightings = ""}
	    [PSCustomObject]@{Name = "Skylake H/S";  procSig = "0x000506e3"; ucodeRevFixed = "0x000000c2"; ucodeRevSightings = ""} # wasn't actually affected by Sightings, ucode just re-released
	    [PSCustomObject]@{Name = "Skylake SP";  procSig = "0x00050654"; ucodeRevFixed = "0x02000043"; ucodeRevSightings = "0x0200003A"}
	    [PSCustomObject]@{Name = "Kaby Lake H/S/X";  procSig = "0x000906e9"; ucodeRevFixed = "0x00000084"; ucodeRevSightings = "0x0000007C"}
	    [PSCustomObject]@{Name = "Zen EPYC";  procSig = "0x00800f12"; ucodeRevFixed = "0x08001227"; ucodeRevSightings = ""}
    )

    # Remote SSH commands for retrieving current ESXi host microcode version
    $plinkoptions = "-ssh -pw $ESXiPassword"
    $cmd = "vsish -e cat /hardware/cpu/cpuList/0 | grep `'Current Revision:`'"
    $remoteCommand = '"' + $cmd + '"'

    $results = @()
    foreach ($vmhost in $vmhosts | Sort-Object -Property Name) {
        $vmhostDisplayName = $vmhost.Name
        $cpuModelName = $($vmhost.Summary.Hardware.CpuModel -replace '\s+', ' ')

        $IBRSPass = $false
        $IBPBPass = $false
        $STIBPPass = $false

        $cpuFeatures = $vmhost.Config.FeatureCapability
        foreach ($cpuFeature in $cpuFeatures) {
            if($cpuFeature.key -eq "cpuid.IBRS" -and $cpuFeature.value -eq 1) {
                $IBRSPass = $true
            } elseif($cpuFeature.key -eq "cpuid.IBPB" -and $cpuFeature.value -eq 1) {
                $IBPBPass = $true
            } elseif($cpuFeature.key -eq "cpuid.STIBP" -and $cpuFeature.value -eq 1) {
                $STIBPPass = $true
            }
        }

        $vmhostAffected = $true
        if($IBRSPass -or $IBPBPass -or $STIBPass) {
           $vmhostAffected = $false
        }

        # Retrieve Microcode version if user specifies which unfortunately requires SSH access
        if($IncludeMicrocodeVerCheck -and $PlinkPath -ne $null -and $ESXiUsername -ne $null -and $ESXiPassword -ne $null) {
            $serviceSystem = Get-View $vmhost.ConfigManager.ServiceSystem
            $services = $serviceSystem.ServiceInfo.Service
            foreach ($service in $services) {
                if($service.Key -eq "TSM-SSH") {
                    $ssh = $service
                    break
                }
            }

            $command = "echo yes | " + $PlinkPath + " " + $plinkoptions + " " + $ESXiUsername + "@" + $vmhost.Name + " " + $remoteCommand

            if($ssh.Running){
                $plinkResults = Invoke-Expression -command $command
                $microcodeVersion = $plinkResults.split(":")[1]
            } else {
                $microcodeVersion = "SSHNeedsToBeEnabled"
            }
        } else {
            $microcodeVersion = "N/A"
        }

        #output from $vmhost.Hardware.CpuFeature is a binary string ':' delimited to nibbles
        #the easiest way I could figure out the hex conversion was to make a byte array
        $cpuidEAX = ($vmhost.Hardware.CpuFeature | Where-Object {$_.Level -eq 1}).Eax -Replace ":",""
        $cpuidEAXbyte = $cpuidEAX -Split "(?<=\G\d{8})(?=\d{8})"
        $cpuidEAXnibble = $cpuidEAX -Split "(?<=\G\d{4})(?=\d{4})"

        $cpuSignature = "0x" + $(($cpuidEAXbyte | Foreach-Object {[System.Convert]::ToByte($_, 2)} | Foreach-Object {$_.ToString("X2")}) -Join "")

        # https://software.intel.com/en-us/articles/intel-architecture-and-processor-identification-with-cpuid-model-and-family-numbers
        $ExtendedFamily = [System.Convert]::ToInt32($($cpuidEAXnibble[1] + $cpuidEAXnibble[2]), 2)
        $Family = [System.Convert]::ToInt32($cpuidEAXnibble[5], 2)

        # output now in decimal, not hex!
        $cpuFamily = $ExtendedFamily + $Family
        $cpuModel = [System.Convert]::ToByte($($cpuidEAXnibble[3] + $cpuidEAXnibble[6]), 2)
        $cpuStepping = [System.Convert]::ToByte($cpuidEAXnibble[7], 2)
               
        
        $intelSighting = "N/A"
        $goodUcode = "N/A"

        # check and compare ucode
        if ($IncludeMicrocodeVerCheck) {
         
            $intelSighting = $false
            $goodUcode = $false
            $matched = $false

            foreach ($cpu in $procSigUcodeTable) {
                if ($cpuSignature -eq $cpu.procSig) {
                    $matched = $true
                    if ($microcodeVersion -eq $cpu.ucodeRevSightings) {
                        $intelSighting = $true
                    } elseif ($microcodeVersion -as [int] -ge $cpu.ucodeRevFixed -as [int]) {
                        $goodUcode = $true
                    }
                }
            } 
            if (!$matched) {
                # CPU is not in procSigUcodeTable, check with BIOS vendor / Intel based procSig or FMS (dec) in output
                $goodUcode = "Unknown"
            }
        }

        $tmp = [pscustomobject] @{
            VMHost = $vmhostDisplayName;
            "CPU Model Name" = $cpuModelName;
            Family = $cpuFamily;
            Model = $cpuModel;
            Stepping = $cpuStepping;
            Microcode = $microcodeVersion;
            procSig = $cpuSignature;
            IBRSPresent = $IBRSPass;
            IBPBPresent = $IBPBPass;
            STIBPPresent = $STIBPPass;
            HypervisorAssistedGuestAffected = $vmhostAffected;
            "Good Microcode" = $goodUcode;
            IntelSighting = $intelSighting;
        }
        $results+=$tmp
    }
    $results 
}

Verify-ESXiMicrocodePatch | Where-Object {$_.HypervisorAssistedGuestAffected -match "$true"} | Select * 
