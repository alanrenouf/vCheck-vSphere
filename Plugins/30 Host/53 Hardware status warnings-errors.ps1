# Start of Settings 
# End of Settings 

$HWalarms = @()
foreach ($HostsView in ($HostsViews|?{$_.runtime.connectionstate -eq "Connected"})) {
	$HealthStatus = ((Get-View ($HostsView).ConfigManager.HealthStatusSystem).runtime)
	$HWStatus = $HealthStatus.HardwareStatusInfo
	if ($HWStatus) {
		$HWStatusProp = $HWStatus|gm|?{$_.membertype -eq "property"}
		$HWStatusDetails = $HWStatusProp|%{$HWStatus.($_.name)}|?{$_.status.key -inotmatch "green" -band $_.status.key -inotmatch "unknown"}|select @{N="sensor";E={$_.name}},@{N="status";E={$_.status.key}}
		$HealthStatusDetails = ($HealthStatus.SystemHealthInfo).NumericSensorInfo|?{$_.HealthState.key -inotmatch "green" -band $_.HealthState.key -inotmatch "unknown"}|select @{N="sensor";E={$_.name}},@{N="status";E={$_.HealthState.key}}
		if ($HWStatusDetails) {
			foreach ($HWStatusDetail in $HWStatusDetails) {
				$Details = "" | Select-Object Cluster, Host, Sensor, Status
				$Details.Cluster = $HostsView | %{(Get-View $_.Parent).Name}
				$Details.Host = $HostsView.name
				$Details.Sensor = $HWStatusDetail.sensor
				$Details.Status = $HWStatusDetail.status
				$HWalarms += $Details
			}
		}
		if ($HealthStatusDetails) {
			foreach ($HealthStatusDetail in $HealthStatusDetails) {
				$Details = "" | Select-Object Cluster, Host, Sensor, Status
				$Details.Cluster = $HostsView | %{(Get-View $_.Parent).Name}
				$Details.Host = $HostsView.name
				$Details.Sensor = $HealthStatusDetail.sensor
				$Details.Status = $HealthStatusDetail.status
				$HWalarms += $Details
			}
		}
	}
	Remove-Variable -name "HWStatus" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
	Remove-Variable -name "HWStatusDetails" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
	Remove-Variable -name "HealthStatusDetails" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
}

$HWalarms

$Title = "Hardware status warnings/errors"
$Header = "Hardware status warnings/errors"
$Comments = "Details can be found in the Hardware Status tab"
$Display = "Table"
$Author = "Raphael Schitz"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
