# Start of Settings
# End of Settings

$VMFolder = @()
foreach ($vm in $FullVM) {
      $snapList = Get-Snapshot -VM $vm.Name
      if (!$snapList) { # Only process VMs without snapshots
            $Path = ($vm.Summary.Config.VmPathName).Split('/')[0] -replace "[\[\]]", "" -replace " ", "\"
            $dc = Get-Datacenter -VM $vm.Name
            $gciloc = (get-childitem vmstores: | Select -first 1).Name
            $fileList = Get-ChildItem "vmstores:\$gciloc\$dc\$Path"
            foreach ($file in $fileList) {
                  if ($file -contains '-delta.vmdk' -or $file -like '-*-flat.vmdk') {
                        $Details = "" | Select-Object VM, Datacenter, Path
                        $Details.VM = $vm.Name
                        $Details.Datacenter = $dc
                        $Details.Path = ($vm.Summary.Config.VmPathName).Split('/')[0]
                        $VMFolder += $Details
                        break
                  }
            }
      }
}
$VMFolder

$Title = "VMs in uncontrolled snapshot mode"
$Header =  "VMs in uncontrolled snapshot mode: $(@($Result).Count)"
$Comments = "The following VMs are in snapshot mode, but vCenter isn't aware of it. You'll need to shut down the VM and consolidate it (vmkfstools)"
$Display = "Table"
$Author = "Rick Glover"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
