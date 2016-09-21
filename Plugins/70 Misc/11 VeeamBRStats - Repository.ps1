# Start of Settings 
# Repository Critical 
$repoCritical = 10
# Repository Warning 
$repoWarn = 50
# End of Settings

# Functions
Function Get-vPCRepoInfo {
[CmdletBinding()]
        param (
                [Parameter(Position=0, ValueFromPipeline=$true)]
                [PSObject[]]$Repository
                )
        Begin {
                $outputAry = @()
                Function Build-Object {param($name, $repohost, $path, $free, $total)
                        $repoObj = New-Object -TypeName PSObject -Property @{
                                        Target = $name
										RepoHost = $repohost
                                        Storepath = $path
                                        StorageFree = [Math]::Round([Decimal]$free/1GB,2)
                                        StorageTotal = [Math]::Round([Decimal]$total/1GB,2)
                                        FreePercentage = [Math]::Round(($free/$total)*100)
                                }
                        Return $repoObj | Select Target, RepoHost, Storepath, StorageFree, StorageTotal, FreePercentage
                }
        }
        Process {
                Foreach ($r in $Repository) {
                	# Refresh Repository Size Info
					[Veeam.Backup.Core.CBackupRepositoryEx]::SyncSpaceInfoToDb($r, $true)
					
					If ($r.HostId -eq "00000000-0000-0000-0000-000000000000") {
						$HostName = ""
					}
					Else {
						$HostName = $($r.GetHost()).Name.ToLower()
					}
					$outputObj = Build-Object $r.Name $Hostname $r.Path $r.info.CachedFreeSpace $r.Info.CachedTotalSpace
					}
                $outputAry += $outputObj
        }
        End {
                $outputAry
        }
}


# Get VBR Server object
$vbrserverobj = Get-VBRLocalhost
# Get all Proxies
$viProxyList = Get-VBRViProxy
# Get all Repositories
$repoList = Get-VBRBackupRepository

$RepoReport = $repoList | Get-vPCRepoInfo | Select @{Name="Repository Name"; Expression = {$_.Target}},
	            @{Name="Host"; Expression = {$_.RepoHost}},
			    @{Name="Path"; Expression = {$_.Storepath}},
                @{Name="Free (GB)"; Expression = {$_.StorageFree}},
	            @{Name="Total (GB)"; Expression = {$_.StorageTotal}},
                @{Name="Free (%)"; Expression = {$_.FreePercentage}},
			    @{Name="Status"; Expression = {
				    If ($_.FreePercentage -lt $repoCritical) {"Critical"} 
				    ElseIf ($_.FreePercentage -lt $repoWarn) {"Warning"}
				    ElseIf ($_.FreePercentage -eq "Unknown") {"Unknown"}
				    Else {"OK"}}} | `
			    Sort "Repository Name" 

$RepoReport

$Title = "Veeam BR Repository Report"
$Header = "Veeam BR Repositories: $(@($RepoReport).Count)"
$Comments = "Veeam BR Repositories with Space Usage on BR Host $BRHost / Warning at: $repoWarn % / Critical at: $repoCritical %."
$Display = "Table"
$Author = "Markus Kraus"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


$TableFormat = @{"Status" = @(@{ "-eq 'Warning'"     = "Row,class|warning"; },
								   @{ "-eq 'Critical'"     = "Row,class|critical" })	   
				}
	
