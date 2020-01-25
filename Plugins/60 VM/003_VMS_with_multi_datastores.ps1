$Title = "VMS with multiple Datastores"
# 1.0 - Initiale Version (written on powerclicore)
$Header = "VMS with multiple Datastores: [count]"
# End of Settings
$Title = "VMS with multiple Datastores"
$Header = "VMS with multiple Datastores: [count]"
$Display = "Table"
$Author = "Felix Longardt"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

#Name of VMS to be ignored
$BlacklistVM = " "
#Nummer of too Much Datastores [default=2]
$DatastoreCount = "2"
# Round Used Space up to n [default=3]
$RoundSizetoLast = "3"

Get-VM | Where-Object {$_.Name -notlike $BlacklistVM} | 
	     Where-Object {
			           Get-HardDisk -VM $_.Name | select Filename |%{ $_ -replace '].*', ']' }| 
					   Get-Unique |  Measure-Object | Select Count | 
					   Where-Object {$_.Count -ge $DatastoreCount}
		   			  }|
		 Select-Object Name, 
					   @{N="Used Space - GB";E={[math]::Round($_.UsedSpaceGB,$RoundSizetoLast)}}, 
					   @{N="Datastore Count";E={($_.DatastoreIdList.count)}}, 
					   @{N="Datastore Name";E={(Get-Datastore -id $_.DatastoreIdList) -join ', '}}, 
					   CreateDate, 
					   Notes
			  
$Comments = ("The following vms are operating on multiple datastores")

# Change Log

# 1.0 - Initiale Version (written on powerclicore)
