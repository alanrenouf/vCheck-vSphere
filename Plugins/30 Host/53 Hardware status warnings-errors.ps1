$Title = "Hardware status warnings/errors"
$Header = "Hardware status warnings/errors"
$Comments = "Details can be found in the Hardware Status tab"
$Display = "Table"
$Author = "Raphael Schitz"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

foreach ($HostsView in ($HostsViews|Where-Object {$_.runtime.connectionstate -eq "Connected"})) {
   $HealthStatus = ((Get-View ($HostsView).ConfigManager.HealthStatusSystem).runtime)
   $HWStatus = $HealthStatus.HardwareStatusInfo
   if ($HWStatus) {
      $HWStatusProp = $HWStatus|gm|Where-Object {$_.membertype -eq "property"}
      $HWStatusDetails = $HWStatusProp|Foreach-Object {$HWStatus.($_.name)}|Where-Object {$_.status.key -inotmatch "green" -band $_.status.key -inotmatch "unknown"}| Select-Object @{N="sensor";E={$_.name}},@{N="status";E={$_.status.key}}
      $HealthStatusDetails = ($HealthStatus.SystemHealthInfo).NumericSensorInfo|Where-Object {$_.HealthState.key -inotmatch "green" -band $_.HealthState.key -inotmatch "unknown"}|Select-Object @{N="sensor";E={$_.name}},@{N="status";E={$_.HealthState.key}}
      if ($HWStatusDetails) {
         foreach ($HWStatusDetail in $HWStatusDetails) {
            New-Object PSObject -Property @{
               Cluster = ($HostsView | Foreach-Object {(Get-View $_.Parent).Name})
               Host = $HostsView.name
               Sensor = $HWStatusDetail.sensor
               Status = $HWStatusDetail.status
            }
         }
      }
      if ($HealthStatusDetails) {
         foreach ($HealthStatusDetail in $HealthStatusDetails) {
            New-Object PSObject -Property @{
               Cluster = ($HostsView | Foreach-Object {(Get-View $_.Parent).Name})
               Host = $HostsView.name
               Sensor = $HealthStatusDetail.sensor
               Status = $HealthStatusDetail.status
            }
         }
      }
   }
   Remove-Variable -name "HWStatus" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
   Remove-Variable -name "HWStatusDetails" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
   Remove-Variable -name "HealthStatusDetails" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
}