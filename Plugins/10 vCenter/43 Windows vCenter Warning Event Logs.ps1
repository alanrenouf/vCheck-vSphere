# Start of Settings 
# End of Settings 

If (! $VCSA) {
	$ConvDate = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime([DateTime]::Now.AddDays(-$VCEvntlgAge))
	If (Test-Path $Credfile) {
		$LoadedCredentials = Import-Clixml $Credfile
		$creds = New-Object System.Management.Automation.PsCredential($LoadedCredentials.Username,($LoadedCredentials.Password | ConvertTo-SecureString))
		$WMI = @(Get-WmiObject -Credential $creds -computer $VIServer -query ("Select * from Win32_NTLogEvent Where Type='Warning' and TimeWritten >='" + $ConvDate + "'") -ErrorAction SilentlyContinue| Where {$_.Message -like "*VMware*"} | Select @{N="TimeGenerated";E={$_.ConvertToDateTime($_.TimeGenerated)}}, Message)
	} Else {
		@($WMI = Get-WmiObject -computer $VIServer -query ("Select * from Win32_NTLogEvent Where Type='Warning' and TimeWritten >='" + $ConvDate + "'") -ErrorAction SilentlyContinue | Where {$_.Message -like "*VMware*"} | Select @{N="TimeGenerated";E={$_.ConvertToDateTime($_.TimeGenerated)}}, Message)
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
		$WMI = @(Get-WmiObject -Credential $Credential -computer $VIServer -query ("Select * from Win32_NTLogEvent Where Type='Warning' and TimeWritten >='" + $ConvDate + "'") -ErrorAction SilentlyContinue | Where {$_.Message -like "*VMware*"} | Select @{N="TimeGenerated";E={$_.ConvertToDateTime($_.TimeGenerated)}}, Message)
		}
	}

	$WMI
}

$Title = "Windows vCenter Warning Event Logs"
$Header = "$VIServer Event Logs - Warning ($VCEvntlgAge day(s)): $(@($WMI).Count)"
$Comments = "The following warnings were found in the vCenter Event Logs, you may wish to check these further"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
