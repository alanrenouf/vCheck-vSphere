# Start of Settings
# Misnamed VMs, do not report on any VMs who are defined here
$MNDoNotInclude = "VM1_*|VM2_*"
# End of Settings

$misnamed = @()
foreach ($vmguest in ($FullVM | Where {$_.Runtime.PowerState -eq 'poweredOn' -AND $_.Name -notmatch $MNDoNotInclude -AND $_.Guest.HostName -ne "" -AND $_.Guest.HostName -notmatch $_.Name })) {
	$myObj = "" | select Cluster,Folder,VMName,GuestName
	$myObj.Cluster = (Get-VMHost -Id ($vmguest.Runtime.Host.Type + "-" + $vmguest.Runtime.Host.Value)).Parent.Name
	$myObj.Folder = (Get-Folder -Id ($vmguest.Parent.Type + "-" + $vmguest.Parent.Value)).Name
	$myObj.VMName = $vmguest.name
	$myObj.GuestName = $vmguest.Guest.HostName
	$misnamed += $myObj
}

$misnamed | Sort-Object Folder,VMName

$Title = "Mis-named virtual machines"
$Header = "Mis-named virtual machines"
$Comments = "The following guest names do not match the name inside of the guest."
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

<#
20141002 monahancj - Added filter to exclude powered off VMs.  Because powered off VMs aren't running the VMtools
                     to get the guest host name it report as null and then potentially a false positive for a name
                     mismatch.

                     Added the columns Cluster and Folder, and sorted by folder and VM name, to make it easier to
                     find a problem VM and decide if there is an urgent problem.  For instance, I'm not gong to 
                     worry about a misnamed VM in the folder "testingstuff".
#>
