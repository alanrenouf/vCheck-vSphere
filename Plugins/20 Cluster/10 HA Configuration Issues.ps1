$Title = "HA configuration issues"
$Header = "HA configuration issues: [count]"
$Comments = "The following clusters have HA configuration issues. This will impact your disaster recovery."
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# HA Configuration Issues, do not report on any Clusters that are defined here
$ClustersDoNotInclude = "Example_Cluster_*|Test_Cluster_*"
# HA should be set to ...
$CLusterHAShouldBeEnabled = $true
# HA host monitoring should be set to ...
$ClusterHAHostMonitoringShouldBeEnabled = $true
# HA Admission Control should be set to ...
$ClusterHAAdmissionControlShouldBeEnabled = $true
# End of Settings

# Update settings where there is an override
$ClustersDoNotInclude = Get-vCheckSetting $Title "ClustersDoNotInclude" $ClustersDoNotInclude
$CLusterHAShouldBeEnabled = Get-vCheckSetting $CLusterHAShouldBeEnabled "vMotionAge" $CLusterHAShouldBeEnabled
$ClusterHAHostMonitoringShouldBeEnabled = Get-vCheckSetting $Title "ClusterHAHostMonitoringShouldBeEnabled" $ClusterHAHostMonitoringShouldBeEnabled
$ClusterHAAdmissionControlShouldBeEnabled = Get-vCheckSetting $Title "ClusterHAAdmissionControlShouldBeEnabled" $ClusterHAAdmissionControlShouldBeEnabled


# Setup plugin-specific language table
$pLang = DATA {
   ConvertFrom-StringData @' 
      HADisabled = HA config not compliant on this cluster. 
      HAMonDisabled = Host Monitoring config not compliant.
      HAACDisabled = HA Admission Control config not compliant.
'@
}
# Override the default (en) if it exists in lang directory
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang -ErrorAction SilentlyContinue

# Clusters with HA disabled
$HAIssues = @()
$HAIssues += $Clusters | Where-Object {$_.Name -notmatch $ClustersDoNotInclude -and $_.HAEnabled -ne $CLusterHAShouldBeEnabled } |
  Select-Object @{Name="Cluster";Expression={$_.Name}},@{Name="Configuration Issue";Expression={$pLang.HADisabled}}

# Clusters with host monitoring disabled 
$HAIssues += $clusviews | Where-Object {$_.Name -notmatch $ClustersDoNotInclude -and ( $_.Configuration.DasConfig.HostMonitoring -eq "enabled" ) -ne $ClusterHAHostMonitoringShouldBeEnabled } |
   Select-Object @{Name="Cluster";Expression={$_.Name}}, @{N="Configuration Issue";E={$pLang.HAMonDisabled}}

# Clusters with admission Control Disabled
$HAIssues += $Clusters | Where-Object {$_.Name -notmatch $ClustersDoNotInclude -and $_.HAAdmissionControlEnabled -ne $ClusterHAAdmissionControlShouldBeEnabled } |
  Select-Object @{Name="Cluster";Expression={$_.Name}},@{Name="Configuration Issue";Expression={$pLang.HAACDisabled}}

# Sort and return
$HAIssues | Sort-Object Cluster

Remove-Variable HAIssues, pLang