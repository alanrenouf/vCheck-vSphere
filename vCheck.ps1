<# 
.SYNOPSIS 
   vCheck is a PowerShell HTML framework script, designed to run as a scheduled
   task before you get into the office to present you with key information via
   an email directly to your inbox in a nice easily readable format.
.DESCRIPTION
   vCheck Daily Report for vSphere

   vCheck is a PowerShell HTML framework script, the script is designed to run 
   as a scheduled task before you get into the office to present you with key 
   information via an email directly to your inbox in a nice easily readable format.

   This script picks on the key known issues and potential issues scripted as 
   plugins for various technologies written as powershell scripts and reports 
   it all in one place so all you do in the morning is check your email.

   One of they key things about this report is if there is no issue in a particular 
   place you will not receive that section in the email, for example if there are 
   no datastores with less than 5% free space (configurable) then the disk space 
   section in the virtual infrastructure version of this script, it will not show 
   in the email, this ensures that you have only the information you need in front 
   of you when you get into the office.

   This script is not to be confused with an Audit script, although the reporting 
   framework can also be used for auditing scripts too. I dont want to remind you 
   that you have 5 hosts and what there names are and how many CPUs they have each 
   and every day as you dont want to read that kind of information unless you need 
   it, this script will only tell you about problem areas with your infrastructure.

.NOTES 
   File Name  : vCheck.ps1 
   Author     : Alan Renouf - @alanrenouf
   Version    : 6.19
   
   Thanks to all who have commented on my blog to help improve this project
   all beta testers and previous contributors to this script.
   
.LINK
   http://www.virtu-al.net/vcheck-pluginsheaders/vcheck
.LINK
   https://github.com/alanrenouf/vCheck-vSphere/

.INPUTS
   No inputs required
.OUTPUTS
   HTML formatted email, Email with attachment, HTML File
    
.PARAMETER config
   If this switch is set, run the setup wizard
   
.PARAMETER Outputpath
   This parameter specifies the output location for files.
   
.PARAMETER job
   This parameter lets you specify an xml config file for this invokation
#>
param (
   [Switch]$config,
   [ValidateScript({Test-Path $_ -PathType 'Container'})]
   [string]$Outputpath,
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [string]$job
)
$Version = "6.19"

function Write-CustomOut ($Details){
	$LogDate = Get-Date -Format T
	Write-Host "$($LogDate) $Details"
}
Function Get-ID-String ($file_content,$ID_name) {
   if ($file_content | Select-String -Pattern "\$+$ID_name\s*=") {	
      $value = (($file_content | Select-String -pattern "\$+${ID_name}\s*=").toString().split("=")[1]).Trim(' "')
      return ( $value ) 
   }
}

Function Get-PluginID ($Filename){
   # Get the identifying information for a plugin script
   # Write-Host "Filename: $Filename"
   $file = Get-Content $Filename
   $Title = Get-ID-String $file "Title"
   if ( !$Title ) { $Title = $Filename }
   $PluginVersion = Get-ID-String $file "PluginVersion"
   $Author = Get-ID-String $file "Author"
   $Ver = "{0:N1}" -f $PluginVersion
			
   # Write-Host "Title: $Title, PluginVersion: $PluginVersion, Ver: $Ver, Author: $Author"
   return @{"Title"=$Title; "Version"=$Ver; "Author"=$Author }		
}

Function Invoke-Settings ($Filename, $GB) {
	$file = Get-Content $filename
	$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
	$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber
	if (!(($OriginalLine +1) -eq $EndLine)) {
		$Array = @()
		$Line = $OriginalLine
		do {
			$Question = $file[$Line]
			$Line ++
			$Split= ($file[$Line]).Split("=")
			$Var = $Split[0]
			$CurSet = $Split[1]
			
			# Check if the current setting is in speech marks
			$String = $false
			if ($CurSet -match '"') {
				$String = $true
				$CurSet = $CurSet.Replace('"', '')
			}
			$NewSet = Read-Host "$Question [$CurSet]"
			If (-not $NewSet) {
				$NewSet = $CurSet
			}
			If ($String) {
				$Array += $Question
				$Array += "$Var=`"$NewSet`""
			} Else {
				$Array += $Question
				$Array += "$Var=$NewSet"
			}
			$Line ++ 
		} Until ( $Line -ge ($EndLine -1) )
		$Array += "# End of Settings"

		$out = @()
		$out = $File[0..($OriginalLine -1)]
		$out += $array
		$out += $File[$Endline..($file.count -1)]
		if ($GB) { $out[$SetupLine] = '$SetupWizard =$False' }
		$out | Out-File $Filename
	}
}

# Add all global variables.
$ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)

# Setup language hashtable
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable lang

# if we have the job parameter set, get the paths from the config file.
if ($job) {
   [xml]$jobConfig = Get-Content $job
   
   # Use GlobalVariables path if it is valid, otherwise use default
   if (Test-Path $jobConfig.vCheck.globalVariables) {
      $GlobalVariables = (Get-Item $jobConfig.vCheck.globalVariables).FullName
   }
   else {      
      $GlobalVariables = $ScriptPath + "\GlobalVariables.ps1"
      Write-Warning ($lang.gvInvalid -f $GlobalVariables)
   }
   
   # Get Plugin paths
   $PluginPaths = @()
   foreach ($PluginPath in ($jobConfig.vCheck.plugins.path -split ";")) {
      if (Test-Path $PluginPath) {
         $PluginPaths += (Get-Item $PluginPath).Fullname
      }
      else {      
         $PluginPaths += $ScriptPath + "\Plugins"
         Write-Warning ($lang.pluginpathInvalid -f $PluginPath, ($ScriptPath + "\Plugins"))
      }
   }
   $PluginPaths = $PluginPaths | Sort-Object -unique
   
   # Get all plugins and test they are correct
   $Plugins = @()
   foreach ($plugin in $jobConfig.vCheck.plugins.plugin) {
      $testedPaths = 0
      foreach ($PluginPath in $PluginPaths) {        
         $testedPaths++
         if (Test-Path ("{0}\{1}" -f $PluginPath, $plugin)) {
            $Plugins += Get-Item ("{0}\{1}" -f $PluginPath, $plugin)
            break;
         }
         # Plugin not found in any search path
         elseif ($testedPaths -eq $PluginPaths.Count) {
            Write-Warning ($lang.pluginInvalid -f $plugin)
         }
      }
   }
   
   # if no valid plugins specified, fall back to default
   if (!$Plugins) {
      $Plugins = Get-ChildItem -Path $PluginPath -filter "*.ps1" | Sort Name
   }
}
else {
   $PluginsFolder = $ScriptPath + "\Plugins\"
   $Plugins = Get-ChildItem -Path $PluginsFolder -filter "*.ps1" | Sort Name
   $GlobalVariables = $ScriptPath + "\GlobalVariables.ps1"
}

$file = Get-Content $GlobalVariables
$Setup = ($file | Select-String -Pattern '# Set the following to true to enable the setup wizard for first time run').LineNumber
$SetupLine = $Setup ++
$SetupSetting = Invoke-Expression (($file[$SetupLine]).Split("="))[1]
if ($config) {
	$SetupSetting = $true
}
If ($SetupSetting) {
	Clear-Host 
   ($lang.GetEnumerator() | where {$_.Name -match "setupMsg[0-9]*"} | Sort-Object Name) | Foreach {
      Write-Host -foreground $host.PrivateData.WarningForegroundColor -background $host.PrivateData.WarningBackgroundColor $_.value
   }
	
	Invoke-Settings -Filename $GlobalVariables -GB $true
	Foreach ($plugin in $Plugins) { 
		Invoke-Settings -Filename $plugin.Fullname
	}
}

. $GlobalVariables

$vcvars = @("SetupWizard" , "Server" , "SMTPSRV" , "EmailFrom" , "EmailTo" , "EmailSubject", "DisplaytoScreen" , "SendEmail" , "SendAttachment", "TimeToRun" , "PluginSeconds" , "Style" , "Date")
foreach($vcvar in $vcvars) {
	if (!($(Get-Variable -Name "$vcvar" -Erroraction 'SilentlyContinue'))) {
		Write-Error ($lang.varUndefined -f $vcvar)
	} 
}

$StylePath = $ScriptPath + "\Styles\" + $Style
if(!(Test-Path ($StylePath))) {
	# The path is not valid
	# Use the default style
	Write-Warning "Style path ($($StylePath)) is not valid"
	$StylePath = $ScriptPath + "\Styles\VMware"
	Write-Warning "Using $($StylePath)"
}

# Import the Style
. ("$($StylePath)\Style.ps1")


Function Get-Base64Image ($Path) {
	$pic = Get-Content $Path -Encoding Byte
	return [Convert]::ToBase64String($pic)
}

Function Get-CustomHTML {
   param (
      $Header, 
      $HeaderImg
   )
	$Report = $HTMLHeader -replace "_HEADER_", $Header
   $Report = $Report -replace "_HEADERIMG_", $HeaderImg
	Return $Report
}

Function Get-CustomHeader0 ($Title){
	$Report = $CustomHeader0 -replace "_TITLE_", $Title
	Return $Report
}

Function Get-CustomHeader ($Title, $Comments){
	$Report = $CustomHeaderStart -replace "_TITLE_", $Title
	If ($Comments) {
		$Report += $CustomheaderComments -replace "_COMMENTS_", $Comments
	}
	$Report += $CustomHeaderEnd
	Return $Report
}

Function Get-CustomHeaderClose{
	$Report = $CustomHeaderClose
	Return $Report
}

Function Get-CustomHeader0Close{
	$Report = $CustomHeader0Close
	Return $Report
}

Function Get-CustomHTMLClose{
	$Report = $CustomHTMLClose
	Return $Report
}

Function Get-HTMLTable {
	param([array]$Content, [array]$FormatRules)
	
	# If format rules are specified
	if ($FormatRules) {
		# Use an XML object for ease of use
		$XMLTable = [xml]($content | ConvertTo-Html -Fragment)
		$XMLTable.table.RemoveChild($XMLTable.table.colgroup) | out-null
		
		# Check each cell to see if there are any format rules
		for ($RowN = 1; $RowN -lt $XMLTable.table.tr.count; $RowN++) {
			for ($ColN = 0; $ColN -lt $XMLTable.table.tr[$RowN].td.count; $ColN++) {
				if ( $Tableformat.keys -contains $XMLTable.table.tr[0].th[$ColN]) {
					# Current cell has a rule, test to see if they are valid
					foreach ( $rule in $Tableformat[$XMLTable.table.tr[0].th[$ColN]] ) {
						if ( Invoke-Expression ("`$XMLTable.table.tr[`$RowN].td[`$ColN] {0}" -f [string]$rule.Keys) ) {
							# Find what to 
							$RuleScope = ([string]$rule.Values).split(",")[0]
							$RuleActions = ([string]$rule.Values).split(",")[1].split("|")
							
							switch ($RuleScope) {
								"Row"  { $XMLTable.table.tr[$RowN].SetAttribute($RuleActions[0], $RuleActions[1]) }
								"Cell" { $XMLTable.table.tr[$RowN].selectSingleNode("td[$($ColN+1)]").SetAttribute($RuleActions[0], $RuleActions[1]) }
							}
						}
					}
				}
			}	
		}
		return [string]($XMLTable.OuterXml)
	}
	else {
		$HTMLTable = $Content | ConvertTo-Html -Fragment
		$HTMLTable = $HTMLTable -Replace '<TABLE>', $HTMLTableReplace
		$HTMLTable = $HTMLTable -Replace '<td>', $HTMLTdReplace
		$HTMLTable = $HTMLTable -Replace '<th>', $HTMLThReplace
		$HTMLTable = $HTMLTable -replace '&lt;', '<'
		$HTMLTable = $HTMLTable -replace '&gt;', '>'
		Return $HTMLTable
	}
}

function Get-HTMLList {
   param ([array]$content)
   
   # Create XML doc from HTML. Remove colgroup and header row
   [xml]$XMLTable = $content | ConvertTo-HTML -Fragment
   $XMLTable.table.RemoveChild($XMLTable.table.colgroup) | out-null
   $XMLTable.table.RemoveChild($XMLTable.table.tr[0]) | out-null
   
   for ($i = 0; $i -lt $XMLTable.table.tr.count; $i++) {
      $node = $XMLTable.table.tr[$i].SelectSingleNode("/table/tr[$($i+1)]/td[1]")
      $elem = $XMLTable.CreateElement("th")
      $elem.InnerText = $node."#text"
      $trNode = $XMLTable.SelectSingleNode("/table/tr[$($i+1)]")
      $trNode.ReplaceChild($elem, $node) | Out-Null
   }
   return [string]($XMLTable.OuterXml)
}

# Adding all plugins
$TTRReport = @()
$MyReport = Get-CustomHTML -Header "$Server vCheck" -HeaderImg (Get-Base64Image $HeaderImg)
$MyReport += Get-CustomHeader0 ($Server)

# added counter which will increment each time a plug-in provides output
$PluginsOutputCounter = 0 

$Plugins | Foreach {
   $TableFormat = $null
	$IDinfo = Get-PluginID $_.Fullname
	Write-CustomOut ($lang.pluginStart -f $IDinfo["Title"], $IDinfo["Author"], $IDinfo["Version"])
	$TTR = [math]::round((Measure-Command {$Details = . $_.FullName}).TotalSeconds, 2)
	$TTRReport += New-Object PSObject -Property @{"Name"=$_.Name; "TimeToRun"=$TTR}	
	$ver = "{0:N1}" -f $PluginVersion
	Write-CustomOut ($lang.pluginEnd -f $IDinfo["Title"], $IDinfo["Author"], $IDinfo["Version"])
   
	If ($Details) {

        # increment counter
        $PluginsOutputCounter++

   	    $MyReport += Get-CustomHeader $Header $Comments
		If ($Display -eq "List"){
				$MyReport += Get-HTMLList $Details
			}
		If ($Display -eq "Table") {
			$MyReport += Get-HTMLTable $Details $TableFormat
		}
      $MyReport += Get-CustomHeaderClose	
	}
}

# Add Time to Run detail for plugins - if specified in GlobalVariables.ps1
if ($TimeToRun) {
   $MyReport += Get-CustomHeader ($lang.repTime -f [math]::round(((Get-Date) - $Date).TotalMinutes,2)) ($lang.slowPlugins -f $PluginSeconds)
   $TTRReport = $TTRReport | Where { $_.TimeToRun -gt $PluginSeconds } | Sort-Object TimeToRun -Descending
   $MyReport += Get-HTMLList $TTRReport 
   $MyReport += Get-CustomHeaderClose
   $MyReport += Get-CustomHeader0Close
   $MyReport += Get-CustomHTMLClose
}

# Save the file somewhere, depending on report options
if ($Outputpath) {
	$DateHTML = Get-Date -Format "yyyyMMddHH"
	$ArchiveFilePath = $Outputpath + "\Archives\" + $VIServer
	if (-not (Test-Path -PathType Container $ArchiveFilePath)) { New-Item $ArchiveFilePath -type directory | Out-Null }
	$Filename = $ArchiveFilePath + "\" + $VIServer + "_vCheck_" + $DateHTML + ".htm"
}
else {
   $Filename = $Env:TEMP + "\" + $Server + "vCheck" + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".htm"
}

# Create the file
$MyReport | Out-File -encoding ASCII -filepath $Filename

if ($DisplayToScreen -or $SetupSetting) {
	Write-CustomOut $lang.HTMLdisp
	Invoke-Item $Filename
}

Function Send-Email () {

    ## send e-mail
    Write-CustomOut "..Sending Email"

    ## if an atachment is to be used
	If ($SendAttachment) {
		send-Mailmessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -SmtpServer $SMTPSRV -Body "vCheck attached to this email" -Attachments $Filename

    ## otherwise, send as HTML
	} Else {
		send-Mailmessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -SmtpServer $SMTPSRV -Body $MyReport -BodyAsHtml

	}

}

# if an e-mail is to be generated
if ($SendEmail) {

    # check if the plugins provided content or not
    # if the counter = 0, no output was returned by the plugins
    if ($PluginsOutputCounter -eq 0) {
        Write-CustomOut "..No output was returned by the plugins."

        ## should a blank report be sent?
        if ($SendReportEvenIfEmpty) {                 
            Send-Email

        } else {
            Write-CustomOut "..E-mail not sent. Empty report."

        }


    # the plugins returned output, send e-mail
    } else {
       Send-Email

    } # end of if ($PluginsOutputCounter -eq 0)
	
} # end of if ($SendEmail)

# Run EndScript once everything else is complete
if (Test-Path ($ScriptPath + "\EndScript.ps1")) {
	. ($ScriptPath + "\EndScript.ps1")
}
