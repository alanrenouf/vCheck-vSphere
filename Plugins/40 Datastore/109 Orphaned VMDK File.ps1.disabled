## 
# vCheck Plugin: Search for Orphaned VMDK Files
#
# This plugin can be used to generate a custom report of orphaned VMDK files.
#
# PLEASE NOTE: This plugin can take quite a while to run, depending on the environment. It has been 
# disabled by default (file has been called .ps1.disabled) because of the length of time required to
# run, and possible resources consumed. Also, not all files that show up in the report may actually
# be orphaned. (i.e. VMDKs used by SRM, VMDKs used by a different vCenter, and so on.) This is for
# informational purposes only and simply one way to detect possible orphaned files. It is not
# recommending or suggesting any specific actions.
#
# The core algorithm used for this plug-in was obtained from Jason Coleman's blog: 
#         http://virtuallyjason.blogspot.ca/2013/08/orphaned-vmdk-files.html
# and was written by: HJA van Bokhoven, and modified by LucD, Jason Coleman, and Joel Gibson.
#
# The plug-in settings are mostly self-explanatory:
#
# $excludeDatastoreRegex - regex pattern used to exclude datastores by name,
#                          useful for omitting unused datastores, and those shared between vCenters
#
# $excludeVMPathRegex    - regex pattern used to exclude VMs by VM path
#                          useful for omitting SRM placeholders, and other VMs that should not
#                          appear in the report
#
# Use at your own risk.
#
##
$Title = "Orphaned VMDK File Plugin"
$Header = "Orphaned VMDK Files: [count]"
$Comments = "This plugin can be used to generate a custom report of orphaned VMDK files. Note: This plugin can take quite a while to run, depending on the environment."
$Display = "Table"
$Author = "Joel Gibson et al."
$PluginVersion = 0.2
$PluginCategory = "vSphere"

# Start of Settings
# Orphaned Delta File: Exclude datatores by DS name? (regex)
$excludeDatastoreRegex = '^$'
# Orphaned Delta File: Exclude VMs by VM path (regex)
$excludeVMPathRegex = '^$'
# End of Settings

# Update settings where there is an override
$excludeDatastoreRegex = Get-vCheckSetting $Title "excludeDatastoreRegex" $excludeDatastoreRegex
$excludeVMPathRegex = Get-vCheckSetting $Title "excludeVMPathRegex" $excludeVMPathRegex

$report = @()
$arrUsedDisks = $FullVM | % {$_.Layout} | % {$_.Disk} | % {$_.DiskFile}

#Write-CustomOut "..filtering list to exclude datastores that match this regex pattern: $excludeDatastoreRegex"
$arrDS = $storageviews | Sort-Object -property Name | Where-Object {$_.name -notmatch $excludeDatastoreRegex }

foreach ($strDatastore in $arrDS) {
   # Write-CustomOut "..$($strDatastore.Name) Orphaned Disks:"
   $ds = Get-Datastore -Name $strDatastore.Name | % {Get-View $_.Id}
   $fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
   $fileQueryFlags.FileSize = $true
   $fileQueryFlags.FileType = $true
   $fileQueryFlags.Modification = $true
   $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
   $searchSpec.details = $fileQueryFlags
   $searchSpec.matchPattern = "*.vmdk"
   $searchSpec.sortFoldersFirst = $true
   $dsBrowser = Get-View $ds.browser
   $rootPath = "[" + $ds.Name + "]"
   $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)

   foreach ($folder in $searchResult)
   {
      if ($folder.FolderPath -notmatch $excludeVMPathRegex)
      {
         foreach ($fileResult in $folder.File)
         {
            if ($fileResult.Path)
            {
               $pathAsString = out-string -InputObject $FileResult.Path
               if (-not ($arrUsedDisks -contains ($folder.FolderPath + $fileResult.Path)))
               {
                  # Changed Black Tracking creates ctk.vmdk files that are not referenced in the VMX.  This prevents them from showing as false positives.
                  if (-not ($pathAsString.toLower().contains("-ctk.vmdk"))) 
                  {
                     # Site Recovery Manager creates -000000.vmdk and -000000-delta.vmdk files. This excludes these patterns from being displayed.
                     if ($pathAsString -notmatch "-[0-9]{6}\.vmdk|-[0-9]{6}-delta\.vmdk")
                     {
                        New-Object -TypeName PSObject -Property @{
                           "Datastore" = $strDatastore.Name
                           "Path" = $folder.FolderPath 
                           "File" = $fileResult.Path
                           "Size" = $fileResult.FileSize
                           "ModDate" = $fileResult.Modification
                        }
                        #Write-CustomOut "..$($row.Path)$($row.File)"
                     } # end of SRM filter

                  } # end of CBT filter
               } # end of if (-not ($arrUsedDisks -contains ($folder.FolderPath + $fileResult.Path)))
            } # end of if ($fileResult.Path)
         } # end of foreach ($fileResult in $folder.File)
      } # end of if ($folder.FolderPath -notmatch $excludeVMPathRegex)
   } # end of foreach ($folder in $searchResult)
} # end of foreach ($strDatastore in $arrDS)

# End of code block obtained from: http://virtuallyjason.blogspot.ca/2013/08/orphaned-vmdk-files.html

# Changelog
## 0.1 : Initial version.
## 0.2 : Modified the $excludeDatastoreRegex and $excludeVMPathRegex variable values from "" into '^$'
## 1.0 : Added Get-vCheckSetting, removed Write-CustomOut which will break output (need to find a solution to this)

# Begin code block obtained from: http://virtuallyjason.blogspot.ca/2013/08/orphaned-vmdk-files.html

# PowerShell script to discover VMDK files that are not referenced in any VM's VMX file.
# Also detects VMDKs from machines that need snapshot consolidation (from differentials that exist but are not part of the tree).
# Author: HJA van Bokhoven
# Modifications: LucD, Joel Gibson, and Robert van den Nieuwendijk