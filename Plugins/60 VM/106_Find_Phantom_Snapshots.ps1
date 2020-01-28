$Title = "Find Phantom Snapshots"
$Header = "VM's with Phantom Snapshots: [count]"
$Comments = "The following VM's have Phantom Snapshots"
$Display = "Table"
$Author = "Mads Fog Albrechtslund"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings

$OutputPhantomSnapshots = @()

ForEach ($theVM in $VM){
   ForEach ($theVMdisk in ($theVM | Get-HardDisk | Where-Object {$_.Filename -match "-\d{6}.vmdk"})){
      # Find VM's which don't have normal Snapshots registered 
      if (!(Get-Snapshot $theVM))
      {
         New-Object -TypeName PSObject -Property @{
            "VM Name" = $theVM.name
            "VMDK Path" = $theVMdisk.Filename
         }
      }
   }
}

# Change Log
## 1.2 : Code refactor