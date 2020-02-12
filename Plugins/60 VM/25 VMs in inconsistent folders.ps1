$Title = "VMs in inconsistent folders"
$Header = "VMs in Inconsistent folders: [count]"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings
# Specify which Datastore(s) to filter from report
$DatastoreIgnore = "local"
# Exclude VMs by name
$ExcludeVM = "Guest Introspection|ExcludeMe"
# End of Settings

# Update settings where there is an override
$DatastoreIgnore = Get-vCheckSetting $Title "DatastoreIgnore" $DatastoreIgnore

Foreach ($CHKVM in ($FullVM | Where-Object {$_.Name -notmatch $ExcludeVM}) ){
   $Folder = ((($CHKVM.Summary.Config.VmPathName).Split(']')[1]).Split('/'))[0].TrimStart(' ')
   $Path = ($CHKVM.Summary.Config.VmPathName).Split('/')[0]
   If (($CHKVM.Name-ne $Folder) -and ($Path -notmatch $DatastoreIgnore)){
      New-Object -TypeName PSObject -Property @{
         "VM" = $CHKVM.Name
         "Path" = $Path }
      }
}

$Comments = ("The following VMs are not stored in folders consistent to their names (excluding those on datastores {0}), this may cause issues when trying to locate them from the datastore manually" -f $DatastoreIgnore)

# Change Log
## 1.2 : Datastore filtering added by monahancj
## 1.3 : Added Get-vCheckSetting, code refactor
## 1.4 : Added VM exclusion setting
