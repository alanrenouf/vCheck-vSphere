$Title = "VMs with configuration files (*.vmx, etc) isolated from their disks"
$Header = "VMs with configuration files (*.vmx, etc) isolated from their disks : [count]"
$Comments = "The following VMs have their configuration files (*.vmx, etc) stored in a different datastore than their disks"
$Display = "Table"
$Author = "Kristofor Hines"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings 

Foreach ($CHKVM in $FullVM)
{
   $vmxDatastore = (($CHKVM.Summary.Config.VmPathName).Split(']')[0].TrimStart('['))
   $vmdkDatastores = @()
   $CHKVM.Config.Hardware.Device | % {
      If ($_.Backing.Filename -ne $null) 
      {
         $vmdkDatastores += ($_.Backing.Filename).Split(']')[0].TrimStart('[')
      }
   }
    
   If ( -not ($vmdkDatastores.Contains($vmxDatastore)))
   {
      New-Object -TypeName PSObject -Property @{
         "VM" = $CHKVM.Name
         "VmxDatastore" = $vmxDatastore
         "VmdkDatastores" = ($vmdkDatastores -join ", ") }
    }
}
