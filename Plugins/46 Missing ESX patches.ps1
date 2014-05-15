# Start of Settings 
# End of Settings 

# Note: This plugin needs the vCenter Update Manager PowerCLI snap-in installed
# https://communities.vmware.com/community/vmtn/automationtools/powercli/updatemanager
# (Current version 5.1 locks up in PowerShell v3; use "-version 2" when launching.)

$Results = @()

If (Get-PSSnapin Vmware.VumAutomation -ErrorAction SilentlyContinue) {
	foreach($esx in $VMH){
		foreach($baseline in (Get-Compliance -Entity $esx -Detailed | where {$_.Status -eq "NotCompliant"})){
			$Results = $baseline.NotCompliantPatches |
			select @{N="Host";E={$esx.Name}},
			@{N="Baseline";E={$baseline.Baseline.Name}},Name,ReleaseDate,IdByVendor,
			@{N="KB";E={(Select-String "(?<url>http://[\w|\.|/]*\w{1})" -InputObject $_.Description).Matches[0].Groups['url'].Value}}
		}
	}
}

$Results

$Title = "Missing ESX(i) updates and patches"
$Header = "Missing ESX(i) updates and patches: $(@($Results).Count)"
$Comments = "The following updates and/or patches are not applied."
$Display = "Table"
$Author = "Luc Dekens"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
