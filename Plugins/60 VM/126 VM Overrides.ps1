$Title = "VM Overrides"
$Header = "VMs with Overrides configured : [count]"
$Comments = "The following VMs have overrides and behave differently from their default Cluster configuration"
$Display = "Table"
$Author = "Fabio Freire"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings
# VMs which should be excluded from results (regex)
$excludedVMs = "$Z-VRA"
# End of Settings 

$VM | Select-Object Name, DrsAutomationLevel, HARestartPriority, HAIsolationResponse |
    Where-Object {($_.Name -notmatch $excludedVMs) -and ($_.DrsAutomationLevel -ne "AsSpecifiedByCluster" -or $_.HARestartPriority -ne "ClusterRestartPriority" -or $_.HAIsolationResponse -ne "AsSpecifiedByCluster")} |
    Sort-Object Name
