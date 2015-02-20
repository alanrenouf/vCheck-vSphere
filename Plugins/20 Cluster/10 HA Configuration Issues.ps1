# Start of Settings
# HA Configuration Issues, do not report on any Clusters that are defined here
$ClustersDoNotInclude = "Example_Cluster_*|Test_Cluster_*"
# End of Settings

# Setup plugin-specific language table
$pLang = DATA {
   ConvertFrom-StringData @' 
      HADisabled = HA Disabled on this cluster. 
      HAMonDisabled = Host Monitoring disabled.
      HAACDisabled = HA Admission Control disabled. 
'@
}
# Override the default (en) if it exists in lang directory
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang -ErrorAction SilentlyContinue

# Clusters with HA disabled
$HAIssues = @()
$HAIssues += $Clusters | Where-Object {$_.Name -notmatch $ClustersDoNotInclude -and -not $_.HAEnabled} |
  Select-Object @{Name="Cluster";Expression={$_.Name}},@{Name="Configuration Issue";Expression={$pLang.HADisabled}}

# Clusters with host monitoring disabled 
$HAIssues += $clusviews | where {$_.Name -notmatch $ClustersDoNotInclude -and $_.Configuration.DasConfig.HostMonitoring -eq "disabled"} |
   Select-Object @{Name="Cluster";Expression={$_.Name}}, @{N="Configuration Issue";E={$pLang.HAMonDisabled}}

# Clusters with admission Control Disabled
$HAIssues += $Clusters | Where-Object {$_.Name -notmatch $ClustersDoNotInclude -and -not $_.HAAdmissionControlEnabled} |
  Select-Object @{Name="Cluster";Expression={$_.Name}},@{Name="Configuration Issue";Expression={$pLang.HAACDisabled}}
   
   
# Sort and return
$HAIssues | Sort-Object Cluster
   
$Title = "HA configuration issues"
$Header = "HA configuration issues: [count]"
$Comments = "The following clusters have HA configuration issues. This will impact your disaster recovery."
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
