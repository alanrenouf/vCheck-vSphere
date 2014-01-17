# Start of Settings
# End of Settings

$VMFolder = @()
foreach ($vm in $FullVM) {
  $snapList = Get-Snapshot -VM $vm.Name
  if (!$snapList) { # Only process VMs without snapshots
    $vm.Summary.Config.VmPathName -match '^\[([^\]]+)\] ([^/]+)' > $null
    $Datastore = $matches[1]
    $VMPath = $matches[2]
    $DC = Get-Datacenter -VM $vm.Name
    if ($DC.ParentFolder.Parent) { #Check if Datacenter has a parent folder
      $DCPath = $DC.ParentFolder.Name
    }
    else {
      $DCPath = ''
    }
    $gciloc = (Get-ChildItem vmstores: | Select -first 1).Name
    $fileList = Get-ChildItem "vmstores:\$gciloc\$DCPath\$DC\$Datastore\$VMPath"
    foreach ($file in $fileList) {
      if ($file.Name -like '*delta.vmdk*' -or $file -like '-*-flat.vmdk') { 
        $Details = "" | Select-Object VM, Datacenter, Path
        $Details.VM = $vm.Name
        $Details.Datacenter = $DC.Name
        $Details.Path = $Datastore + '/' + $VMPath + '/' + $file.Name
        $VMFolder += $Details
        break
      }
    }
  }
}
$VMFolder

$Title = "VMs in uncontrolled snapshot mode"
$Header =  "VMs in uncontrolled snapshot mode: $(@($Result).Count)"
$Comments = "The following VMs are in snapshot mode, but vCenter isn't aware of it. See http://kb.vmware.com/kb/1002310"
$Display = "Table"
$Author = "Rick Glover, Matthias Koehler"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
