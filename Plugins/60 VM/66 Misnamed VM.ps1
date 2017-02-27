$Title = "Mis-named virtual machines"
$Header = "Mis-named virtual machines: [count]"
$Comments = "The following guest names do not match the name inside of the guest."
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings
# Misnamed VMs, do not report on any VMs who are defined here
$MNDoNotInclude = "VM1_*|VM2_*"
# End of Settings

# Update settings where there is an override
$MNDoNotInclude = Get-vCheckSetting $Title "MNDoNotInclude" $MNDoNotInclude

($FullVM | Where-Object {$_.Runtime.PowerState -eq 'poweredOn' -AND $_.Name -notmatch $MNDoNotInclude -AND $_.Guest.HostName -ne "" -AND $_.Guest.HostName -notmatch $_.Name }) |
   Foreach-Object {
      $vmguest = $_
      if ($vmguest.Parent -ne $null)
      {
         $Parent = (Get-Folder -Id $vmguest.Parent.ToString()).Name;
      }
      else
      {
         $Parent = (Get-vApp -Id $vmguest.ParentVApp.ToString()).Name;
      }
      New-Object PSObject -Property @{
         Cluster = (Get-VMHost -Id $vmguest.Runtime.Host.ToString()).Parent.Name
         Folder = $Parent
         VMName = $vmguest.name
         GuestName = $vmguest.Guest.HostName
      }
   } | Sort-Object Folder,VMName

<#
20141002 monahancj - Added filter to exclude powered off VMs.  Because powered off VMs aren't running the VMtools
                     to get the guest host name it report as null and then potentially a false positive for a name
                     mismatch.
                     Added the columns Cluster and Folder, and sorted by folder and VM name, to make it easier to
                     find a problem VM and decide if there is an urgent problem.  For instance, I'm not gong to 
                     worry about a misnamed VM in the folder "testingstuff".
#>