$Title = "VM Spectre Vunerability"
$Header = "VMs that are affected by Spectre Vunerability : [count]"
$Comments = "Following VMs are vunerable by Spectre"
$Display = "Table"
$Author = "Felix Longardt"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

# Based on the origial function by William Lam
Function Verify-ESXiMicrocodePatchAndVM {
    param(
        [Parameter(Mandatory=$false)][String]$VMName,
        [Parameter(Mandatory=$false)][String]$ClusterName
    )

    if($ClusterName) {
        $cluster = Get-View -ViewType ClusterComputeResource -Property Name,ResourcePool -Filter @{"name"=$ClusterName}
        $vms = Get-View ((Get-View $cluster.ResourcePool).VM) -Property Name,Config.Version,Runtime.PowerState,Runtime.FeatureRequirement
    } elseif($VMName) {
        $vms = Get-View -ViewType VirtualMachine -Property Name,Config.Version,Runtime.PowerState,Runtime.FeatureRequirement -Filter @{"name"=$VMName}
    } else {
        $vms = Get-View -ViewType VirtualMachine -Property Name,Config.Version,Runtime.PowerState,Runtime.FeatureRequirement
    }

    $results = @()
    foreach ($vm in $vms | Sort-Object -Property Name) {
        # Only check VMs that are powered on
        if($vm.Runtime.PowerState -eq "poweredOn") {
            $vmDisplayName = $vm.Name
            $vmvHW = $vm.Config.Version

            $vHWPass = $false
            $IBRSPass = $false
            $IBPBPass = $false
            $STIBPPass = $false
            $vmAffected = $true
            if ($vmvHW -match 'vmx-[0-9]{2}') {
              if ( [int]$vmvHW.Split('-')[-1] -gt 8 ) {
                $vHWPass = $true
              } else {
                $vHWPass = "N/A"
              }

              $cpuFeatures = $vm.Runtime.FeatureRequirement
              foreach ($cpuFeature in $cpuFeatures) {
                  if($cpuFeature.key -eq "cpuid.IBRS") {
                      $IBRSPass = $true
                  } elseif($cpuFeature.key -eq "cpuid.IBPB") {
                      $IBPBPass = $true
                  } elseif($cpuFeature.key -eq "cpuid.STIBP") {
                      $STIBPPass = $true
                  }
              }

              if( ($IBRSPass -eq $true -or $IBPBPass -eq $true -or $STIBPPass -eq $true) -and $vHWPass -eq $true) {
                  $vmAffected = $false
              } elseif($vHWPass -eq "N/A") {
                  $vmAffected = $vHWPass
              }
            } else {
              $IBRSPass = "N/A"
              $IBPBPass = "N/A"
              $STIBPPass = "N/A"
              $vmAffected = "N/A"
            }

            $tmp = [pscustomobject] @{
                VM = $vmDisplayName;
                IBRSPresent = $IBRSPass;
                IBPBPresent = $IBPBPass;
                STIBPPresent = $STIBPPass;
                vHW = $vmvHW;
                HypervisorAssistedGuestAffected = $vmAffected;
            }
            $results+=$tmp
        }
    }
    $results
}

Verify-ESXiMicrocodePatchAndVM | Where-Object {$_.HypervisorAssistedGuestAffected -match "$true"} | FT *
