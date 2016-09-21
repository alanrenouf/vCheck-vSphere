# Start of Settings 
# BR Host
$BRHost = "cc01vbb0001.vop.loc"
# End of Settings

# Start Load VEEAM Snapin (if not already loaded)
if (!(Get-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue)) {
	if (!(Add-PSSnapin -PassThru VeeamPSSnapIn)) {
		# Error out if loading fails
		Write-Error "ERROR: Cannot load the VEEAM Snapin."
		Exit
	}
}
# End Load VEEAM Snapin (if not already loaded)

# Start BRHost Connection
$OpenConnection = (Get-VBRServerSession).Server
if($OpenConnection -eq $BRHost) {
} elseif ($OpenConnection -eq $null ) {
	Connect-VBRServer -Server $BRHost
} else {
    Disconnect-VBRServer
    Connect-VBRServer -Server $BRHost
}

$NewConnection = (Get-VBRServerSession).Server
if ($NewConnection -eq $null ) {
	Write-Error "Error: BRHost Connection Failed"
	Exit
}



$Title = "Veeam BR Connect"
$Header = "Connect to Veeam BR Host: $BRHost"  
$Comments = "Connect to Veeam BR Host via Veeam PowerShell SnapIn."
$Display = "Table"
$Author = "Markus Kraus"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


