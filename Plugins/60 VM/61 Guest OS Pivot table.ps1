$Title = "VMs by Operating System"
$Header = "VMs by Operating System : [count]"
$Comments = "The following Operating Systems are in use in this vCenter"
$Display = "Table"
$Author = "Raymond"
$Version = 1.3
$PluginCategory = "vSphere"

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
  $MyDetails = "" | Select-Object OS, Count
  $MyDetails.OS = $gosname
  $MyDetails.Count = $VMOSversions.$gosname
  $myCol += $MyDetails
}

$myCol | Sort-Object Count -desc
Remove-Variable VMOSversions