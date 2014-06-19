# Report on Plugins.ps1

# List plugins and whether they're enabled or disabled by Select-Plugins.ps1

# Start of Settings
# List Enabled Plugins First
$ListEnabledPluginsFirst = $False
# End of Settings

# Changelog
## 1.1 : Minor Cleanup - Added Recurse to gci - Changed sort to numeric

$Comments = "Plugins in numerical order"

Push-Location
If ($pwd -notmatch '$plugins') {
  cd $ScriptPath\Plugins\
}

$plugins = Get-ChildItem -Include *.ps1, *.ps1.disabled -Recurse |
   Sort {[int]($_.Name -replace '\D')} |
   Select @{Label="Plugin";expression={$_.Name -replace '(.*)\.ps1(?:\.disabled|)$', '$1'}},
          @{Label="Enabled";expression={$_.Name -notmatch '.*\.disabled$'}}

If ($ListEnabledPluginsFirst) {
  $Plugins |
    Sort -property @{Expression="Enabled";Descending=$true}, @{Expression={[int]($_.Plugin -replace '\D')};Descending=$false}
  $Comments = "Plugins in numerical order, enabled plugins listed first"
} Else {
  $Plugins
}
Pop-Location

$Title = "Report on Plugins"
$Header = "Plugins Report"
$Display = "Table"
$Author = "Phil Randal"
$PluginVersion = 1.1
$PluginCategory = "vCheck"
