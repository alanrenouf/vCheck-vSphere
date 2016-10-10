$Title = "VMs in uncontrolled snapshot mode"
$Header = "VMs in uncontrolled snapshot mode: [count]"
$Comments = "The following VMs are in snapshot mode, but vCenter isn't aware of it. See http://kb.vmware.com/kb/1002310"
$Display = "Table"
$Author = "Rick Glover, Matthias Koehler, Dan Rowe"
$PluginVersion = 1.5
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

# Setup plugin-specific language table
$pLang = DATA {
   ConvertFrom-StringData @' 
      pluginActivity = Searching Datastores
      pluginStatus = [{0} of {1}] {2}
      Complete = Complete
'@
}
# Override the default (en) if it exists in lang directory
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang -ErrorAction SilentlyContinue

$VMFolder = @()
$i=0;
foreach ($eachDS in ($Datastores | Where {$_.Accessible})) {
   Write-Progress -ID 2 -Parent 1 -Activity $pLang.pluginActivity -Status ($pLang.pluginStatus -f $i, $Datastores.count, $eachDS.Name) -PercentComplete ($i*100/$Datastores.count)
   $eachDS.Name
   $FilePath = $eachDS.DatastoreBrowserPath + '\*\*delta.vmdk*'
   $fileList = @(Get-ChildItem -Path "$FilePath" | Select Name, FolderPath, FullName)
   $FilePath = $eachDS.DatastoreBrowserPath + '\*\-*-flat.vmdk'
   $fileList += Get-ChildItem -Path "$FilePath" | Select Name, FolderPath, FullName

   $i++
   
   foreach ($vmFile in $filelist | sort FolderPath) 
   {
      $vmFile.FolderPath -match '^\[([^\]]+)\] ([^/]+)' > $null
      $VMName = $matches[2]
      $eachVM = $FullVM | where {$_.Name -eq $VMName}
      if (!$eachVM.snapshot) 
      { 
         # Only process VMs without snapshots
         $Details = "" | Select-Object VM, Datacenter, Path
         $Details.VM = $eachVM.Name
         $Details.Datacenter = $eachDS.Datacenter
         $Details.Path = $vmFile.FullName
         $VMFolder += $Details
      }
   }
}
Write-Progress -ID 1 -Activity $pLang.pluginActivity -Status $pLang.Complete -Completed
$VMFolder | sort VM
