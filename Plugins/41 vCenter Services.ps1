# Start of Settings 
# End of Settings 

If (! $VCSA) {
	If (Test-Path $Credfile) {
		$LoadedCredentials = Import-Clixml $Credfile
		$creds = New-Object System.Management.Automation.PsCredential($LoadedCredentials.Username,($LoadedCredentials.Password | ConvertTo-SecureString))
		$Services = get-wmiobject -Credential $creds win32_service -ComputerName $VIServer -ErrorAction SilentlyContinue| Where {$_.DisplayName -like "VMware*" }
	} Else {
		$Services = get-wmiobject win32_service -ComputerName $VIServer -ErrorAction SilentlyContinue | Where {$_.DisplayName -like "VMware*" }
		if ($Error[0].Exception.Message -match "Access is denied.") { 
			# Access Denied Error found so asking to store windows credentials in a file for future use
			Write-Host "Current windows credentials do not allow for access to WMI on the host $VIServer, please enter Administrator credentials for this check to work, these will be stored in an encrypted file: $credfile" 
			$Credential = Get-Credential
			$Pass = $credential.Password | ConvertFrom-SecureString
			$Username = $Credential.UserName
			$Store = "" | Select Username, Password
			$Store.Username = $Username
			$Store.Password = $Pass
			$Store | Export-Clixml $credfile
		$Services = get-wmiobject win32_service -ComputerName $VIserver -ErrorAction SilentlyContinue | Where {$_.DisplayName -like "VMware*" }
		}
	}

	$myCol = @()
	Foreach ($service in $Services){
		$MyDetails = "" | select-Object Name, State, StartMode, Health
		If ($service.StartMode -eq "Auto")
		{
			if ($service.State -eq "Stopped")
			{
				$MyDetails.Name = $service.Displayname
				$MyDetails.State = $service.State
				$MyDetails.StartMode = $service.StartMode
				$MyDetails.Health = "Unexpected State"
			}
		}
		If ($service.StartMode -eq "Auto")
		{
			if ($service.State -eq "Running")
			{
				$MyDetails.Name = $service.Displayname
				$MyDetails.State = $service.State
				$MyDetails.StartMode = $service.StartMode
				$MyDetails.Health = "OK"
			}
		}
		If ($service.StartMode -eq "Disabled")
		{
			If ($service.State -eq "Running")
			{
				$MyDetails.Name = $service.Displayname
				$MyDetails.State = $service.State
				$MyDetails.StartMode = $service.StartMode
				$MyDetails.Health = "Unexpected State"
			}
		}
		If ($service.StartMode -eq "Disabled")
		{
			if ($service.State -eq "Stopped")
			{
				$MyDetails.Name = $service.Displayname
				$MyDetails.State = $service.State
				$MyDetails.StartMode = $service.StartMode
				$MyDetails.Health = "OK"
			}
		}
		$myCol += $MyDetails
	}

	$Results = $MyCol | Where {$_.Name -ne $null -and $_.Health -ne "OK"}
	$Results
}

$Title = "VC Services"
$Header = "$VIServer Service Details: $(@($Results).Count)"
$Comments = "The following vCenter Services are not in the required state"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
