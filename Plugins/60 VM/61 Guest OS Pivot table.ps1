# Start of Settings
# End of Settings

# - VM Guest OS Pivot Table -

$VMOSversions = @{ }
$FullVM | % {
  # Prefer to use GuestFullName but try AltGuestName first
  if ($_.Config.AlternateGuestName) { $VMOSversion = $_.Config.AlternateGuestName }
  if ($_.Guest.GuestFullName) { $VMOSversion = $_.Guest.GuestFullName }
  # Seeing if any of these options worked
  if (!($VMOSversion)) {
    # No 'version' so checking for tools
    if (!($_.Guest.ToolsStatus.Value__ )) {
      $VMOSversion = "Unknown - no VMTools"
    } else {
      # Still no 'version', must be old tools
      $toolsversion = $_.Config.Tools.ToolsVersion
      $VMOSversion = "Unknown - tools version $toolsversion"
    }
  }
  $VMOSversions.$VMOSversion++
}

$myCol = @()
foreach ( $gosname in $VMOSversions.Keys | sort) {
  $MyDetails = "" | select OS, Count
  $MyDetails.OS = $gosname
  $MyDetails.Count = $VMOSversions.$gosname
  $myCol += $MyDetails
}

$vVMOSversions = $myCol | sort Count -desc
If (($vVMOSversions | Measure-Object).count -gt 0) {
  $Header = "VMs by Operating System : $($vVMOSversions.count)"
  $vVMOSversions
}
$vVMOSversions = $null


$Title = "VMs by Operating System"
$Comments = "The following Operating Systems are in use in this vCenter"
$Display = "Table"
$Author = "Raymond"
$Version = 1.3
$PluginCategory = "vSphere"
