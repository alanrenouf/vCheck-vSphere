$Title = "VMDK consistency"
$Header =  "VMDK consistency"
$Comments = "This simple plug-in checks if every FLAT-VMDK file found in a folder, has a corresponding VMDK file also present; For more information to fix the problem, please take a look at <a href='http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1002511'>Recreating a missing virtual machine disk descriptor file (1002511)</a>"
$Display = "List"
$Author = "Peronnik Beijer"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

$VMDK_check_out = @()

# Main plug-in script
foreach ( $Datastore in $Datastores )
{
   New-PSDrive -Location (Get-Datastore "$Datastore") -Name "$($Datastore.Name)" -PSProvider VimDatastore -Root "" -EA 0 -Confirm:$false | Out-Null
   Set-location "$($Datastore.Name):" -EA 0 | Out-Null
   If (!($?)) {
      Write-Error $error[0]
      Exit 
   } 
   $folders = Get-Item * -Exclude ".vSphere-HA" | ? { $_.PSIsContainer } | % { $_.Name }
   foreach ( $folder in $Folders )
   {
      $VmDiskfileCount = 0
      $fileCount = 0
      $vmdks = Get-ChildItem "$folder\*.vmdk" -Exclude "*-ctk.vmdk"
      If (!($?)) {
         Write-Host "There was an error getting the files from $folder, please investigate first, this plugin will now Exit" -ForegroundColor Red -BackgroundColor black
         Write-Error $error[0]
         Exit 
      }
      foreach ($vmdk in $vmdks)
      {
         If ($vmdk.itemtype -Like "VmDiskFile") { $VmDiskfileCount += 1 } 
         ElseIf ( $vmdk.itemtype -Like "File" ) { $fileCount += 1 }
      }
      If ( $VmDiskfileCount -ne $fileCount) {
         New-Object -TypeName PSObject -Property @{
            "Info" = ("In the folder : [{0}]/$folder/ are flat-VMDK file(s) found, but not enough corresponding VMDK file(s)! " -f $Datastore.Name)
         }
      }
   }
   Set-location "C:" -EA 0 | Out-Null
   Remove-PSDrive "$($Datastore.Name):" -Force -EA 0 | Out-Null
}