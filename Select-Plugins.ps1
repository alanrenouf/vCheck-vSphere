# Select-Plugins.ps1

# selectively enable / disable vCheck Plugins

# presents a list of plugins whose names match *.ps1 or *.ps1.disabled
# 
# disabled plugins will be renamed as appropriate to <pluginname>.ps1.disabled
# enabled plugins will be renamed as appropriate to <plugin name>.ps1

# To use, run from the vCheck directory
#     or, if you wish to be perverse, copy to the plugins directory and rename to 
#         "ZZ Select Plugins for Next Run.ps1" and run vCheck as normal.

# Great for testing plugins.  When done, untick it...

# If run as a plugin, it will affect the next vCheck run, not the current one,
#   as vCheck has already collected its list of plugins when it is invoked
#   so make it the very last plugin executed to avoid counter-intuitive behaviour

# based on code from Select-GraphicalFilteredObject.ps1 in
#  "Windows Powershell Cookbook" by Lee Holmes.
#  Copyright 2007 Lee Holmes.
#  Published by O'Reilly ISBN 978-0-596-528492
# and used under the 'free use' provisions specified on Preface page xxv

$Title = "Plugin Selection Plugin"
$Author = "Phil Randal"
$PluginVersion = 2.1
$Header =  "Plugin Selection"
$Comments = "Plugin Selection"
$Display = "None"

# Start of Settings
# End of Settings

# Changelog
## 2.1 : Added Select All/Deselect All buttons - Changed sort to numeric

$PluginPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)
If ($PluginPath -notmatch 'plugins$') {
  $PluginPath += "\Plugins"
}
$plugins = Get-ChildItem -Path $PluginPath -Include *.ps1, *.ps1.disabled -Recurse |
   Sort {[int]($_.Name -replace '\D')} |
   Select FullName, Name, 
          @{Label="Plugin";expression={$_.Name -replace '(.*)\.ps1(?:\.disabled|)$', '$1'}},
          @{Label="Enabled";expression={$_.Name -notmatch '.*\.disabled$'}}

$selectallButton_OnClick = {
	for($i = 0; $i -lt $listbox.Items.Count; $i++) {
    	$listbox.SetItemChecked($i,$true)
	}
}

$deselectallButton_OnClick = {
	for($i = 0; $i -lt $listbox.Items.Count; $i++) {
    	$listbox.SetItemChecked($i,$false)
	}
}

## Load the Windows Forms assembly
[void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

## Create the main form
$form = New-Object Windows.Forms.Form
$form.Size = New-Object Drawing.Size @(600,600)

## Create the listbox to hold the items from the pipeline
$listbox = New-Object Windows.Forms.CheckedListBox
$listbox.CheckOnClick = $true
$listbox.Dock = "Fill"
$form.Text = "Select the plugins you wish to enable"
# create list box items from plugin list, tick as enabled where appropriate
ForEach ($plugin in $Plugins) {
  $i=$listBox.Items.Add($plugin.Plugin)
  $listbox.SetItemChecked($i, $Plugin.Enabled)
}

## Create the button panel to hold the OK and Cancel buttons
$buttonPanel = New-Object Windows.Forms.Panel
$buttonPanel.Size = New-Object Drawing.Size @(600,30)
$buttonPanel.Dock = "Bottom"

## Create the Cancel button, which will anchor to the bottom right
$cancelButton = New-Object Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = "Cancel"
$cancelButton.Top = $buttonPanel.Height - $cancelButton.Height - 5
$cancelButton.Left = $buttonPanel.Width - $cancelButton.Width - 10
$cancelButton.Anchor = "Right"

## Create the OK button, which will anchor to the left of Cancel
$okButton = New-Object Windows.Forms.Button
$okButton.Text = "Ok"
$okButton.DialogResult = "Ok"
$okButton.Top = $cancelButton.Top
$okButton.Left = $cancelButton.Left - $okButton.Width - 5
$okButton.Anchor = "Right"

## Create the Select All button, which will anchor to the bottom left
$selectallButton = New-Object Windows.Forms.Button
$selectallButton.Text = "Select All"
$selectallButton.Top = $cancelButton.Top
$selectallButton.Left = 10
$selectallButton.Anchor = "Left"
$selectallButton.add_Click($selectallButton_OnClick)

## Create the Deselect All button, which will anchor to the right of Select All
$deselectallButton = New-Object Windows.Forms.Button
$deselectallButton.Text = "Deselect All"
$deselectallButton.Top = $cancelButton.Top
$deselectallButton.Left = $selectallButton.Width + 15
$deselectallButton.Anchor = "Left"
$deselectallButton.add_Click($deselectallButton_OnClick)

## Add the buttons to the button panel
$buttonPanel.Controls.Add($okButton)
$buttonPanel.Controls.Add($cancelButton)
$buttonPanel.Controls.Add($selectallButton)
$buttonPanel.Controls.Add($deselectallButton)

## Add the button panel and list box to the form, and also set
## the actions for the buttons
$form.Controls.Add($listBox)
$form.Controls.Add($buttonPanel)
$form.AcceptButton = $okButton
$form.CancelButton = $cancelButton
$form.Add_Shown( { $form.Activate() } )

## Show the form, and wait for the response
$result = $form.ShowDialog()

## If they pressed OK (or Enter,)
## enumerate list of plugins and rename those whose status has changed
if($result -eq "OK") {
  $i = 0
  ForEach ($plugin in $plugins) {
    $oldname = $plugin.Name
    $newname = $plugin.Plugin + $(If ($listbox.GetItemChecked($i)) {'.ps1'} else {'.ps1.disabled'})
    If ($newname -ne $oldname) {
      If (Test-Path (($plugin.FullName | Split-Path) + "\" + $newname)) {
        Write-Host "Attempting to rename ""$oldname"" to ""$newname"", which already exists - please delete or rename the superfluous file and try again"
      } Else {
        Rename-Item (($plugin.FullName | Split-Path) + "\" + $oldname) $newname
      }
    }
    $i++
  }
}
