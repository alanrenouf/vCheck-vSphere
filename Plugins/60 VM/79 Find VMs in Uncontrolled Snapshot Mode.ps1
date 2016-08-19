# Start of Settings
# End of Settings

$VMFolder = @()
foreach ($eachDS in $Datastores) {
    $FilePath = $eachDS.DatastoreBrowserPath + '\*\*delta.vmdk*'
    $fileList = Get-ChildItem -Path "$FilePath" | Select Name, FolderPath, FullName
    $FilePath = $eachDS.DatastoreBrowserPath + '\*\-*-flat.vmdk'
    $fileList += Get-ChildItem -Path "$FilePath" | Select Name, FolderPath, FullName

    foreach ($vmFile in $filelist | sort FolderPath) {
        $vmFile.FolderPath -match '^\[([^\]]+)\] ([^/]+)' > $null
        $VMName = $matches[2]
        $eachVM = $FullVM | where {$_.Name -eq $VMName}
        if (!$eachVM.snapshot) { # Only process VMs without snapshots
            $Details = "" | Select-Object VM, Datacenter, Path
            $Details.VM = $eachVM.Name
            $Details.Datacenter = $eachDS.Datacenter
            $Details.Path = $vmFile.FullName
            $VMFolder += $Details
        }
    }
}
$Results = $VMFolder | sort VM
$Results

$Title = "VMs in uncontrolled snapshot mode"
$Header = "VMs in uncontrolled snapshot mode: $(@($Result).Count)"
$Comments = "The following VMs are in snapshot mode, but vCenter isn't aware of it. See http://kb.vmware.com/kb/1002310"
$Display = "Table"
$Author = "Rick Glover, Matthias Koehler, Dan Rowe"
$PluginVersion = 1.4
$PluginCategory = "vSphere"
