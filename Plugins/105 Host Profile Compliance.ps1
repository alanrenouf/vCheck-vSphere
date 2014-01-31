# Start of Settings 
# Show detailed information in report
$ShowDetail = $true
# Show compliant servers
$ShowCompliant = $false
# End of Settings

# Get all host profiles
$HostProfiles = Get-VMHostProfile 

# ShowDetail will include all failures for the host profile
if ($ShowDetail) {
	foreach ($Profile in $HostProfiles) {
      $Failures = $Profile | Test-VMHostProfileCompliance -UseCache 
      
	  	# If there are no failures, we need to do a bit more work to get the VMHost
		if (!$Failures) {
			if ($ShowCompliant) {
	            $VMHosts = $VMH | Where {(($Profile.ExtensionData.entity | Where {$_.type -eq "HostSystem" } | Select @{n="Id";e={"HostSystem-{0}" -f $_.Value}}) | Select -expandProperty Id) -contains $_.Id}
	            foreach ($VMHost in $VMHosts) {
	               $Profile | Select @{Name="VMHostProfile";Expression={$_.Name}}, @{Name="Host";Expression={$VMHost.Name}}, @{Name="Compliant";Expression={$true}}, @{Name="Failures";Expression={"None"}}
	            }
        	}
      	}
      	# Otherwise just spit out the failures
      	else {
         	$Failures | Select VMHostProfile, @{Name='Host';Expression={$_.vmhost.name}}, @{Name='Compliant';Expression={$false}}, @{Name="Failures";Expression={($_.IncomplianceElementList | Select -expandproperty Description) -join "<br />"}}
      	}
   	}
}
# If we don't care about details, we can just return the compliance status using Test-VMHostProfileCompliance
else {
   $HostProfiles | Select Name, @{Name="Compliant";Expression={@($_ | Test-VMHostProfileCompliance -UseCache).count -eq 0 }}
}

$Title = "Host Profile Compliance"
$Header =  "List of host profiles and compliance status"
$Comments = ""
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Table formatting rules - requires formatting modification
$TableFormat = @{"Compliant" = @(@{ "-eq `$true"     = "Cell,class|green"; },
                                 @{ "-eq `$false"    = "Cell,class|red" })
                 }
