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
   Version    : 6.25

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
#Requires -Version 3.0
[CmdletBinding()]
param (
	[Switch]$config,

	[Switch]$GUIConfig,

	[ValidateScript({ Test-Path $_ -PathType 'Container' })]
	[string]$Outputpath=$Env:TEMP,

	[ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
	[string]$job
)

$vCheckVersion = "6.25"
$Date = Get-Date

# Setup all paths required for script to run
$ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)
$PluginsFolder = $ScriptPath + "\Plugins\"

#region Internationalization
################################################################################
#                             Internationalization                             #
################################################################################
# Default language en-US
Import-LocalizedData -BaseDirectory ($ScriptPath + '\lang') -BindingVariable lang -UICulture en-US -ErrorAction SilentlyContinue

# Override the default (en-US) if it exists in lang directory
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable lang -ErrorAction SilentlyContinue

#endregion Internationalization

#region functions
################################################################################
#                                  Functions                                   #
################################################################################
<# Write timestamped output to screen #>
function Write-CustomOut ($Details) {
	$LogDate = Get-Date -Format "HH:mm:ss"
	Write-OutPut "[$($LogDate)] $Details"
}

<# Placeholder for now, just return the setting passed to it. Eventually this
   will be used for new settings handling #>
function Get-vCheckSetting
{
   param 
   (
      [string]$Module,
      [string]$Setting,
      $default
   )
   
   return $default
}

<# Search $file_content for name/value pair with ID_Name and return value #>
Function Get-ID-String ($file_content, $ID_name) {
	if ($file_content | Select-String -Pattern "\$+$ID_name\s*=") {
		$value = (($file_content | Select-String -pattern "\$+${ID_name}\s*=").toString().split("=")[1]).Trim(' "')
		return ($value)
	}
}

<# Get basic information abount a plugin #>
Function Get-PluginID ($Filename) {
	# Get the identifying information for a plugin script
	$file = Get-Content $Filename
	$Title = Get-ID-String $file "Title"
	if (!$Title) { $Title = $Filename }
	$PluginVersion = Get-ID-String $file "PluginVersion"
	$Author = Get-ID-String $file "Author"
	$Ver = "{0:N1}" -f $PluginVersion
	
	return @{ "Title" = $Title; "Version" = $Ver; "Author" = $Author }
}


Function Invoke-Settings {
	
	<#
	.DESCRIPTION
		Run through settings for specified file, expects question on one line, and variable/value on following line
	.NOTES
		Updated: 20150428
		Updated By: Kevin Kirkpatrick (@vScripter - Twitter/GitHub)
		Update Notes:
		- Remove Write-Host in favor of Write-Warning; this was based on setting the color of Write-Host to 'warning' colors
		- converted function to advanced function
		- moved parameters out of function declaration and into the param declaration
		- moved all code into the PROCESS block
		- improved code spacing for improved readability
		- added comment based help section for notes/comments
	#>
	
	[CmdletBinding(PositionalBinding = $true)]
	param (
		[parameter(Position = 0)]
		$Filename,
		[parameter(Position = 1)]
		$GB
	)
	
	PROCESS {
		
		$file = Get-Content $filename
		$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
		$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber
		
		if (!(($OriginalLine + 1) -eq $EndLine)) {
			
			$Array = @()
			$Line = $OriginalLine
			$PluginName = (Get-PluginID $Filename).Title
			
			If ($PluginName.EndsWith(".ps1", 1)) {
				
				$PluginName = ($PluginName.split("\")[-1]).split(".")[0]
				
			} # end if
			
			Write-Warning -Message "`n$PluginName"
			
			do {
				
				$Question = $file[$Line]
				$Line++
				$Split = ($file[$Line]).Split("=")
				$Var = $Split[0]
				$CurSet = $Split[1].Trim()
				
				# Check if the current setting is in speech marks
				$String = $false
				if ($CurSet -match '"') {					
					$String = $true
					$CurSet = $CurSet.Replace('"', '').Trim()					
				} # end if
				
				$NewSet = Read-Host "$Question [$CurSet]"
				
				If (-not $NewSet) {					
					$NewSet = $CurSet					
				} # end if
				
				If ($String) {					
					$Array += $Question
					$Array += "$Var= `"$NewSet`""					
				} Else {					
					$Array += $Question
					$Array += "$Var= $NewSet"					
				} # end if/else
				
				$Line++
				
			} Until ($Line -ge ($EndLine - 1))
			
			$Array += "# End of Settings"
			
			$out = @()
			$out = $File[0..($OriginalLine - 1)]
			$out += $array
			$out += $File[$Endline..($file.count - 1)]
			
			if ($GB) {				
				$out[$SetupLine] = '$SetupWizard = $False'				
			}  # end if
			
			$out | Out-File $Filename
			
		} # end if
		
	} # end PROCESS block
	
} # end Function Invoke-Settings

Function Invoke-HTMLSettings {
	
	<#
	.DESCRIPTION
		Run through settings for specified file, expects question on one line, and variable/value on following line.  
		Outputs settings to HTML file, which accepts input, and can create a configuration file.
	.NOTES
		Updated: 20160830
		Updated By: David Seibel
		Update Notes:
		- Initial creation
	#>
	
	[CmdletBinding(PositionalBinding = $true)]
	param (
		[parameter(Position = 0)]
		$Filename,
		[parameter(Position = 1)]
		$GB
	)
	
	PROCESS {
		
		$file = Get-Content $filename
		$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
		$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber
		
		if (!(($OriginalLine + 1) -eq $EndLine)) {

			$Line = $OriginalLine
			$PluginInfo = Get-PluginID $Filename
			$PluginName = $PluginInfo.Title
			
			$htmlOutput = ""
			If ($PluginName.EndsWith(".ps1", 1)) {				
				$PluginName = ($PluginName.split("\")[-1]).split(".")[0]				
			} # end if

			$htmlOutput += "<table>"
			
			do {				
				$Question = $file[$Line]
				$QuestionWithoutHash = $Question.Replace("# ", "")
				$Line++
				$Split = ($file[$Line]).Split("=")
				$Var = $Split[0].Trim()
				if ($Split.count -gt 1) {
					$CurSet = $Split[1].Trim()
					# Check if the current setting is in speech marks
					$String = $false
					if ($CurSet -match '"') {					
						$String = $true
						$CurSet = $CurSet.Replace('"', '').Trim()					
					} # end if

					$htmlOutput += "<tr><td>$QuestionWithoutHash</td><td><input name='$Filename|$Question|$Var' type='text' value='$CurSet' size=60 /></td></tr>`n"
				}
			} Until ($Line -ge ($EndLine - 1))
			
			$htmlOutput += "</table>"
			$PluginConfig += New-Object PSObject -Property @{
				"Details" = $htmlOutput;
				"Header" = $PluginName;
				"PluginID" = $PluginName;
			}

			return $PluginConfig
		} # end if
		
	} # end PROCESS block
	
} # end Function Invoke-HTMLSettings

<# Replace HTML Entities in string. Used to stop <br /> tags from being mangled in tables #>
function Format-HTMLEntities {
	param ([string]$content)
	
	$replace = @{
		"&lt;" = "<";
		"&gt;" = ">";
	}
	
	foreach ($r in $replace.Keys.GetEnumerator()) {
		$content = $content -replace $r, $replace[$r]
	}
	return $content
}

<# Takes an array of content, and optional formatRules and generated HTML table #>
Function Get-HTMLTable {
	param ($Content, $FormatRules)
	
	# Use an XML object for ease of use
	$XMLTable = [xml]($content | ConvertTo-Html -Fragment)
	$XMLTable.table.SetAttribute("width", "100%")
	
	# If only one column, fix up the table header
	if (($content | Get-Member -MemberType Properties).count -eq 1)
	{
		$XMLTable.table.tr[0].th = (($content | Get-Member -MemberType Properties) | Select-Object -ExpandProperty Name -First 1).ToString()
	}
	
	# If format rules are specified
	if ($FormatRules) {
		# Check each cell to see if there are any format rules
		for ($RowN = 1; $RowN -lt $XMLTable.table.tr.count; $RowN++) {
			for ($ColN = 0; $ColN -lt $XMLTable.table.tr[$RowN].td.count; $ColN++) {
				if ($FormatRules.keys -contains $XMLTable.table.tr[0].th[$ColN]) {
					# Current cell has a rule, test to see if they are valid
					foreach ($rule in $FormatRules[$XMLTable.table.tr[0].th[$ColN]]) {
						if ($XMLTable.table.tr[$RowN].td[$ColN]."#text")
						{
							$value = $XMLTable.table.tr[$RowN].td[$ColN]."#text"
						}
						else
						{
							$value = $XMLTable.table.tr[$RowN].td[$ColN]
						}
						if ($value -notmatch "^[0-9.]+$") {
							$value = """$value"""
						}
						if (Invoke-Expression ("{0} {1}" -f $value, [string]$rule.Keys)) {
							# Find what to
							$RuleScope = ([string]$rule.Values).split(",")[0]
							$RuleActions = ([string]$rule.Values).split(",")[1].split("|")
							
							switch ($RuleScope) {
								"Row"  {
									for ($TRColN = 0; $TRColN -lt $XMLTable.table.tr[$RowN].td.count; $TRColN++) {
										$XMLTable.table.tr[$RowN].selectSingleNode("td[$($TRColN + 1)]").SetAttribute($RuleActions[0], $RuleActions[1])
									}
								}
								"Cell" {
									if ($RuleActions[0] -eq "cid") {
										# Do Image - create new XML node for img and clear #text
										$XMLTable.table.tr[$RowN].selectSingleNode("td[$($ColN + 1)]")."#text" = ""
										$elem = $XMLTable.CreateElement("img")
										$elem.SetAttribute("src", ("cid:{0}" -f $RuleActions[1]))
										# Add img size if specified
										if ($RuleActions[2] -match "(\d+)x(\d+)") {
											$elem.SetAttribute("width", $Matches[1])
											$elem.SetAttribute("height", $Matches[2])
										}
										
										$XMLTable.table.tr[$RowN].selectSingleNode("td[$($ColN + 1)]").AppendChild($elem) | Out-Null
										# Increment usage counter (so we don't have .bin attachments)
										Set-ReportResource $RuleActions[1]
									} else {
										$XMLTable.table.tr[$RowN].selectSingleNode("td[$($ColN + 1)]").SetAttribute($RuleActions[0], $RuleActions[1])
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return (Format-HTMLEntities ([string]($XMLTable.OuterXml)))
}

<# Takes an array of content, and returns HTML table with header column #>
Function Get-HTMLList {
	param ([array]$content)
	
	if ($content.count -gt 0) {
		# Create XML doc from HTML. Remove colgroup and header row
		if ($content.count -gt 1) {
			[xml]$XMLTable = $content | ConvertTo-HTML -Fragment
			$XMLTable.table.RemoveChild($XMLTable.table.colgroup) | out-null
			$XMLTable.table.RemoveChild($XMLTable.table.tr[0]) | out-null
			$XMLTable.table.SetAttribute("width", "100%")
		} else {
			[xml]$XMLTable = $content | ConvertTo-HTML -Fragment -As List
		}
		
		# Replace the first column td with th
		for ($i = 0; $i -lt $XMLTable.table.tr.count; $i++) {
			$node = $XMLTable.table.tr[$i].SelectSingleNode("/table/tr[$($i + 1)]/td[1]")
			$elem = $XMLTable.CreateElement("th")
			$elem.InnerText = $node."#text"
			$trNode = $XMLTable.SelectSingleNode("/table/tr[$($i + 1)]")
			$trNode.ReplaceChild($elem, $node) | Out-Null
		}
		
		# If only one column, fix up the table header
		if (($content | Get-Member -MemberType Properties).count -eq 1)
		{
			$XMLTable.table.tr[0].th = (($content | Get-Member -MemberType Properties) | Select-Object -ExpandProperty Name -First 1).ToString()
		}
		
		return (Format-HTMLEntities ([string]($XMLTable.OuterXml)))
	}
}

<# Returns HTML fragment for chart. Calls Get-ChartResource to generate chart image #>
function Get-HTMLChart {
	param (
		[string]$cidbase,
		[Object[]]$ChartObjs
	)
	$html = ""
	$i = 0
	foreach ($ChartObj in $ChartObjs) {
		$i++
		$base64 = Get-ChartResource $ChartObj
		$cid = $cidbase + "-" + $i
		Add-ReportResource -cid $cid -ResourceData $Base64 -Type "Base64" -Used $true
		$html += "<img src='cid:$cid' />"
	}
	return $html
}

<# Create a new Chert object, this will get fed back down the output stream as part 
   of plugin processing. This allows us to keep the same interface for plugins content #>
function New-Chart {
	param (
		[int]$height,
		[int]$width,
		[Parameter(Mandatory = $true)]
		[Hashtable[]]$data,
		[string]$title,
		[string]$titleX,
		[string]$titleY,
		[ValidateSet("Area", "Bar", "BoxPlot", "Bubble", "Candlestick", "Column", "Doughnut", "ErrorBar", "FastLine",
						 "FastPoint", "Funnel", "Kagi", "Line", "Pie", "Point", "PointAndFigure", "Polar", "Pyramid",
						 "Radar", "Range", "RangeBar", "RangeColumn", "Renko", "Spline", "SplineArea", "SplineRange",
						 "StackedArea", "StackedArea100", "StackedBar", "StackedBar100", "StackedColumn",
						 "StackedColumn100", "StepLine", "Stock", "ThreeLineBreak")]
		$ChartType = "bar"
	)
	
	# If chartsize is specified in style, use it unless explicitly set
	if ($ChartSize -and (-not $height -and -not $width)) {
		if ($ChartSize -match "(\d+)x(\d+)") {
			$height = $Matches[1]
			$width = $Matches[2]
		}
	}
	# if size not set in style or function call, default to 400x400 (maybe make this a globalVariable?)
	if (-not $ChartSize -and (-not $height -and -not $width)) {
		$height = 400
		$width = 400
	}
	
	return New-Object PSObject -Property @{
		"height" = $height;
		"width" = $width;
		"data" = $data;
		"title" = $title;
		"titleX" = $titleX;
		"titleY" = $titleY;
		"ChartType" = $ChartType
	}
}

<# Creates a chart Image #>
function Get-ChartResource {
	param (
		$ChartDef
	)
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
	
	# Create a new chart object
	$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
	$Chart.Width = $ChartDef.width
	$Chart.Height = $ChartDef.height
	$Chart.AntiAliasing = "All"
	
	# Create a chartarea to draw on and add to chart
	$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
	$Chart.ChartAreas.Add($ChartArea)
	
	# Set title and axis labels
	if ($ChartDef.title) {
		$titleRef = $Chart.Titles.Add($ChartDef.title)
	}
	if ($ChartDef.titleX) {
		$ChartArea.AxisX.Title = $ChartDef.titleX
	}
	if ($ChartDef.titleY) {
		$ChartArea.AxisY.Title = $ChartDef.titleY
	}
	
	# change chart colours
	if ($ChartBackground) {
		$Chart.BackColor = Get-ChartColours $ChartBackground
		$ChartArea.BackColor = Get-ChartColours $ChartBackground
	} else {
		$Chart.BackColor = [System.Drawing.Color]::Transparent
		$ChartArea.BackColor = [System.Drawing.Color]::Transparent
	}
	# If we have style
	if ($ChartColours) {
		$Chart.PaletteCustomColors = Get-ChartColours $ChartColours
		$Chart.Palette = [System.Windows.Forms.DataVisualization.Charting.ChartColorPalette]::None
	}
	
	if ($ChartFontColour) {
		$Chart.ForeColor = Get-ChartColours $ChartFontColour
	}
	
	# Add data to chart and set chart type
	for ($i = 0; $i -lt $ChartDef.data.count; $i++) {
		[void]$Chart.Series.Add("Data$i")
		$Chart.Series["Data$i"].Points.DataBindXY($ChartDef.data[$i].Keys, $ChartDef.data[$i].Values)
		$Chart.Series["Data$i"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::($ChartDef.ChartType)
	}
	
	# Do some funky work to increase the DPI so charts look nice. Default 96 DPI looks terrible :(
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
	
	$bmp = New-Object System.Drawing.Bitmap(($ChartDef.width), ($ChartDef.height))
	$bmp.SetResolution(384, 384);
	if ($ChartArea.BackColor -eq [System.Drawing.Color]::Transparent) {
		$bmp.MakeTransparent()
	}
	$chart.DrawToBitmap($bmp, (new-object System.Drawing.Rectangle(0, 0, $ChartDef.width, $ChartDef.height)))
	$ms = new-Object IO.MemoryStream
	$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png);
	$ms.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
	$byte = New-Object byte[] $ms.Length
	$ms.read($byte, 0, $ms.length) | Out-Null
	
	return ("png|{0}" -f [System.Convert]::ToBase64String($byte))
}

<# Takes Array of HTML colour codes and returns Color object #>
function Get-ChartColours {
	param (
		[string[]]$ChartColours
	)
	
	foreach ($colour in $ChartColours) {
		[System.Drawing.Color]::FromArgb([Convert]::ToInt32($colour.Substring(0, 2), 16),
		[Convert]::ToInt32($colour.Substring(2, 2), 16),
		[Convert]::ToInt32($colour.Substring(4, 2), 16));
	}
}

<# Adds a resource to the resource array, to be included in report.
   At the moment, only "File" types are supported- this will be expanded to include
   SystemIcons and raw byte data (so images can be packaged completely in styles if desired
 #>
function Add-ReportResource {
	param (
		$cid,
		$ResourceData,
		[ValidateSet("File", "SystemIcons", "Base64")]
		$Type = "File",
		$Used = $false
	)
	
	# If cid does not exist, add it
	if ($global:ReportResources.Keys -notcontains $cid) {
		$global:ReportResources.Add($cid, @{
			"Data" = ("{0}|{1}" -f $Type, $ResourceData);
			"Uses" = 0
		})
	}
	
	# Update uses count if $Used set (Should normally be incremented with Set-ReportResource)
	# Useful for things like headers where they are always required.
	if ($Used) {
		($global:ReportResources[$cid].Uses)++
	}
}

Function Set-ReportResource {
	param (
		$cid
	)
	
	# Increment use
	($global:ReportResources[$cid].Uses)++
}

<# Gets a resource in the specified ReturnType (eventually support both a 
base64 encoded string, and Linked Resource for email #>
function Get-ReportResource {
	param (
		$cid,
		[ValidateSet("embed", "linkedresource")]
		$ReturnType = "embed"
	)
	
	$data = $global:ReportResources[$cid].Data.Split("|")
	
	# Process each resource type differently
	switch ($data[0]) {
		"File"   {
			# Check the path exists
			if (Test-Path $data[1] -ErrorAction SilentlyContinue) {
				if ($ReturnType -eq "embed") {
					# return a MIME/Base64 combo for embedding in HTML
					$imgData = Get-Content ($data[1]) -Encoding Byte
					$type = $data[1].substring($data[1].LastIndexOf(".") + 1)
					return ("data:image/{0};base64,{1}" -f $type, [System.Convert]::ToBase64String($imgData))
				}
				if ($ReturnType -eq "linkedresource") {
					# return a linked resource to be added to mail message
					$lr = New-Object system.net.mail.LinkedResource($data[1])
					$lr.ContentId = $cid
					return $lr;
				}
			} else {
				Write-Warning ($lang.resFileWarn -f $cid)
			}
		}
		"SystemIcons" {
			# Take the SystemIcon Name - see http://msdn.microsoft.com/en-us/library/system.drawing.systemicons(v=vs.110).aspx
			# Load the image into a MemoryStream in PNG format (to preserve transparency)
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
			$bmp = ([System.Drawing.SystemIcons]::($data[1])).toBitmap()
			$bmp.MakeTransparent()
			$ms = new-Object IO.MemoryStream
			$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::PNG)
			$ms.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
			
			if ($ReturnType -eq "embed") {
				# return a MIME/Base64 combo for embedding in HTML
				$byte = New-Object byte[] $ms.Length
				$ms.read($byte, 0, $ms.length) | Out-Null
				return ("data:image/png;base64," + [System.Convert]::ToBase64String($byte))
			}
			if ($ReturnType -eq "linkedresource") {
				# return a linked resource to be added to mail message
				$lr = New-Object system.net.mail.LinkedResource($ms)
				$lr.ContentId = $cid
				return $lr;
			}
		}
		"Base64" {
			if ($ReturnType -eq "embed") {
				return ("data:image/{0};base64,{1}" -f $data[1], $data[2])
			}
			if ($ReturnType -eq "linkedresource") {
				$w = [system.convert]::FromBase64String($data[2])
				$ms = new-Object IO.MemoryStream
				$ms.Write($w, 0, $w.Length);
				$ms.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
				$lr = New-Object system.net.mail.LinkedResource($ms)
				$lr.ContentId = $cid
				return $lr;
			}
		}
	}
}


function Get-ConfigScripts {
	return "function createCSV() {
			var inputs = document.getElementsByTagName('input');
			
			var strsplit = null
			//var output = 'filename,question,var\n'
			var output = '<vCheck>\n'
			for (var i = 0; i < inputs.length; i += 1) {
				strsplit = inputs[i].name.split('|')
				output += '\t<setting>\n'
				output += '\t\t<filename>'
				output += strsplit[0]
				output += '</filename>\n'
				output += '\t\t<question>'
				output += strsplit[1]
				output += '</question>\n'
				output += '\t\t<varname>'
				output += strsplit[2] 
				output += '</varname>\n'
				output += '\t\t<var>""'
				output += inputs[i].value
				output += '""</var>\n'
				output += '\t</setting>\n'   
			}
			output += '</vCheck>'
			downloadFile('vCheckSettings.xml', output)
		}
		function downloadFile(filename, rows) {
			var fileContent = '';
			for (var i = 0; i < rows.length; i++) {
				fileContent += rows[i];
			}

			var blob = new Blob([fileContent], { type: 'text/xml;charset=utf-8;' });
			if (navigator.msSaveBlob) { // IE 10+
				navigator.msSaveBlob(blob, filename);
			} else {
				var link = document.createElement('a');
				if (link.download !== undefined) { // feature detection
					// Browsers that support HTML5 download attribute
					var url = URL.createObjectURL(blob);
					link.setAttribute('href', url);
					link.setAttribute('download', filename);
					link.style.visibility = 'hidden';
					document.body.appendChild(link);
					link.click();
					document.body.removeChild(link);
				}
			}
		}"
}
#endregion functions

#region initialization
################################################################################
#                                Initialization                                #
################################################################################
# if we have the job parameter set, get the paths from the config file.
if ($job) {
	[xml]$jobConfig = Get-Content $job
	
	# Use GlobalVariables path if it is valid, otherwise use default
	if (Test-Path $jobConfig.vCheck.globalVariables) {
		$GlobalVariables = (Get-Item $jobConfig.vCheck.globalVariables).FullName
	} else {
		$GlobalVariables = $ScriptPath + "\GlobalVariables.ps1"
		Write-Warning ($lang.gvInvalid -f $GlobalVariables)
	}
	
	# Get Plugin paths
	$PluginPaths = @()
	if ($jobConfig.vCheck.plugins.path) {
		foreach ($PluginPath in ($jobConfig.vCheck.plugins.path -split ";")) {
			if (Test-Path $PluginPath) {
				$PluginPaths += (Get-Item $PluginPath).Fullname
				$PluginPaths += Get-Childitem $PluginPath -Recurse | ?{ $_.PSIsContainer } | Select-Object -ExpandProperty FullName
			} else {
				$PluginPaths += $ScriptPath + "\Plugins"
				Write-Warning ($lang.pluginpathInvalid -f $PluginPath, ($ScriptPath + "\Plugins"))
			}
		}
		$PluginPaths = $PluginPaths | Sort-Object -unique
		
		# Get all plugins and test they are correct
		$vCheckPlugins = @()
		foreach ($plugin in $jobConfig.vCheck.plugins.plugin) {
			$testedPaths = 0
			foreach ($PluginPath in $PluginPaths) {
				$testedPaths++
				if (Test-Path ("{0}\{1}" -f $PluginPath, $plugin)) {
					$vCheckPlugins += Get-Item ("{0}\{1}" -f $PluginPath, $plugin)
					break;
				}
				# Plugin not found in any search path
				elseif ($testedPaths -eq $PluginPaths.Count) {
					Write-Warning ($lang.pluginInvalid -f $plugin)
				}
			}
		}
	}
	# if no valid plugins specified, fall back to default
	if (!$vCheckPlugins) {
		$vCheckPlugins = Get-ChildItem -Path $PluginsFolder -filter "*.ps1" -Recurse | Sort-Object FullName
	}
} else {
	$ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
	$vCheckPlugins = @(Get-ChildItem -Path $PluginsFolder -filter "*.ps1" -Recurse | Where-Object { $_.Directory -match "initialize" } | Sort-Object $ToNatural)
	$PluginsSubFolder = Get-ChildItem -Path $PluginsFolder | Where-Object { ($_.PSIsContainer) -and ($_.Name -notmatch "initialize") -and ($_.Name -notmatch "finish") }
	$vCheckPlugins += $PluginsSubFolder | % { Get-ChildItem -Path $_.FullName -filter "*.ps1" | Sort-Object $ToNatural }
	$vCheckPlugins += Get-ChildItem -Path $PluginsFolder -filter "*.ps1" -Recurse | Where-Object { $_.Directory -match "finish" } | Sort-Object $ToNatural
	$GlobalVariables = $ScriptPath + "\GlobalVariables.ps1"
}

## Determine if the setup wizard needs to run
$file = Get-Content $GlobalVariables
$Setup = ($file | Select-String -Pattern '# Set the following to true to enable the setup wizard for first time run').LineNumber
$SetupLine = $Setup++
$SetupSetting = Invoke-Expression (($file[$SetupLine]).Split("="))[1]


## Include GlobalVariables and validate settings (at the moment just check they exist)
. $GlobalVariables

$vcvars = @("SetupWizard", "reportHeader", "SMTPSRV", "EmailFrom", "EmailTo", "EmailSubject", "DisplaytoScreen", "SendEmail", "SendAttachment", "TimeToRun", "PluginSeconds", "Style", "Date")
foreach ($vcvar in $vcvars) {
	if (!($(Get-Variable -Name "$vcvar" -Erroraction 'SilentlyContinue'))) {
		Write-Error ($lang.varUndefined -f $vcvar)
	}
}

# Create empty array of resources (i.e. Images)
$global:ReportResources = @{ }

## Set the StylePath and include it
$StylePath = $ScriptPath + "\Styles\" + $Style
if (!(Test-Path ($StylePath))) {
	# The path is not valid
	# Use the default style
	Write-Warning "Style path ($($StylePath)) is not valid"
	$StylePath = $ScriptPath + "\Styles\VMware"
	Write-Warning "Using $($StylePath)"
}

# Import the Style
. ("$($StylePath)\Style.ps1")


if ($SetupSetting -or $config -or $GUIConfig) {	
	#Clear-Host
	
	($lang.GetEnumerator() | Where-Object { $_.Name -match "setupMsg[0-9]*" } | Sort-Object Name) | ForEach-Object {		
		Write-Warning -Message "$($_.value)"
	}	

	if ($GUIConfig) {
		$PluginResult = @()        

		# Set the output filename 
		if (-not (Test-Path -PathType Container $Outputpath)) { New-Item $Outputpath -type directory | Out-Null }
		$Filename = ("{0}\{1}_vCheck-Config_{2}.html" -f $Outputpath, $Server, (Get-Date -Format "yyyyMMdd_HHmm"))

		#$configHTML = "<table>"
		#$configHTML += Invoke-HTMLSettings -Filename $GlobalVariables
		$PluginResult += Invoke-HTMLSettings -Filename $GlobalVariables
		Foreach ($plugin in $vCheckPlugins) {
			#$configHTML += Invoke-HTMLSettings -Filename $plugin.Fullname
			$PluginResult += Invoke-HTMLSettings -Filename $plugin.Fullname
		}

		# Run Style replacement
		$MyConfig = Get-ReportHTML
		# Always generate the report with embedded images
		$embedConfig = $MyConfig
		# Loop over all CIDs and replace them
		Foreach ($cid in $global:ReportResources.Keys) {
			$embedConfig = $embedConfig -replace ("cid:{0}" -f $cid), (Get-ReportResource $cid -ReturnType "embed")
		}

		$embedConfig | Out-File $Filename
		Invoke-Item $Filename
		($lang.GetEnumerator() | Where-Object { $_.Name -match "configMsg[0-9]*" } | Sort-Object Name) | ForEach-Object {		
			Write-Warning -Message "$($_.value)"
		}

	} elseif ($config) {
		Invoke-Settings -Filename $GlobalVariables -GB $true
		Foreach ($plugin in $vCheckPlugins) {
			Invoke-Settings -Filename $plugin.Fullname
		}
	}
}

#endregion initialization
if (-not $GUIConfig) {

	#region scriptlogic
	################################################################################
	#                                 Script logic                                 #
	################################################################################
	# Start generating the report
	$PluginResult = @()

	Write-Warning -Message $lang.pluginBegin

	# Loop over all enabled plugins
	$p = 0
	$vCheckPlugins | Foreach {
		$TableFormat = $null
		$PluginInfo = Get-PluginID $_.Fullname
		$p++
		Write-CustomOut ($lang.pluginStart -f $PluginInfo["Title"], $PluginInfo["Author"], $PluginInfo["Version"], $p, $vCheckPlugins.count)
		$pluginStatus = ($lang.pluginStatus -f $p, $vCheckPlugins.count, $_.Name)
		Write-Progress -ID 1 -Activity $lang.pluginActivity -Status $pluginStatus -PercentComplete (100 * $p/($vCheckPlugins.count))
		$TTR = [math]::round((Measure-Command { $Details = @(. $_.FullName)}).TotalSeconds, 2)

		Write-CustomOut ($lang.pluginEnd -f $PluginInfo["Title"], $PluginInfo["Author"], $PluginInfo["Version"], $p, $vCheckPlugins.count)
		# Do a replacement for [count] for number of items returned in $header
		$Header = $Header -replace "\[count\]", $Details.count

		$PluginResult += New-Object PSObject -Property @{
			"Title" = $Title;
			"Author" = $PluginInfo["Author"];
			"Version" = $PluginInfo["Version"];
			"Details" = $Details;
			"Display" = $Display;
			"TableFormat" = $TableFormat;
			"Header" = $Header;
			"Comments" = $Comments;
			"TimeToRun" = $TTR;
		}
	}
	Write-Progress -ID 1 -Activity $lang.pluginActivity -Status $lang.Complete -Completed

	# Add report on plugins
	if ($reportOnPlugins) {
		$Comments = "Plugins in numerical order"
		$Plugins = @()
		foreach ($Plugin in (Get-ChildItem $PluginsFolder -Include *.ps1, *.ps1.disabled -Recurse)) {
			$Plugins += New-Object PSObject -Property @{
				"Name" = (Get-PluginID  $Plugin.FullName).Title;
				"Enabled" = (($vCheckPlugins | Select-Object -ExpandProperty FullName) -Contains $plugin.FullName)
			}
		}

		if ($ListEnabledPluginsFirst) {
			$Plugins = $Plugins | Sort-Object -property @{ Expression = "Enabled"; Descending = $true }
			$Comments = "Plugins in numerical order, enabled plugins listed first"
		}

		$PluginResult += New-Object PSObject -Property @{
			"Title" = $lang.repPRTitle;
			"Author" = "vCheck";
			"Version" = $vCheckVersion;
			"Details" = $Plugins;
			"Display" = "Table";
			"TableFormat" = $null;
			"Header" = $lang.repPRTitle;
			"Comments" = $Comments;
			"TimeToRun" = 0;
		}
	}

	# Add Time to Run detail for plugins - if specified in GlobalVariables.ps1
	if ($TimeToRun) {
		$Finished = Get-Date
		$PluginResult += New-Object PSObject -Property @{
			"Title" = $lang.repTTRTitle;
			"Author" = "vCheck";
			"Version" = $vCheckVersion;
			"Details" = ($PluginResult | Where-Object { $_.TimeToRun -gt $PluginSeconds } | Select-Object Title, TimeToRun | Sort-Object TimeToRun -Descending);
			"Display" = "List";
			"TableFormat" = $null;
			"Header" = ($lang.repTime -f [math]::round(($Finished - $Date).TotalMinutes, 2), ($Finished.ToLongDateString()), ($Finished.ToLongTimeString()));
			"Comments" = ($lang.slowPlugins -f $PluginSeconds);
			"TimeToRun" = 0;
		}
	}

	#endregion scriptlogic

	#region output
	################################################################################
	#                                    Output                                    #
	################################################################################
	# Loop over plugin results and generate HTML from style
	$emptyReport = $true
	$p = 1
	Foreach ($pr in $PluginResult) {
		If ($pr.Details) {
			$emptyReport = $false
			switch ($pr.Display) {
				"List"  { $pr.Details = Get-HTMLList $pr.Details }
				"Table" { $pr.Details = Get-HTMLTable $pr.Details $pr.TableFormat }
				"Chart" { $pr.Details = Get-HTMLChart "plugin$($p)" $pr.Details }
				default { $pr.Details = $null }
			}
			$pr | Add-Member -Type NoteProperty -Name pluginID -Value "plugin-$p"
			$p++
		}
		if ($pr.Details -ne $null)
		{
			$emptyReport = $false
		}
	}

	# Run Style replacement
	$MyReport = Get-ReportHTML

	# Set the output filename 
	if (-not (Test-Path -PathType Container $Outputpath)) { New-Item $Outputpath -type directory | Out-Null }
	$Filename = ("{0}\{1}_vCheck_{2}.htm" -f $Outputpath, $VIServer, (Get-Date -Format "yyyyMMdd_HHmm"))

	# Always generate the report with embedded images
	$embedReport = $MyReport
	# Loop over all CIDs and replace them
	Foreach ($cid in $global:ReportResources.Keys) {
		$embedReport = $embedReport -replace ("cid:{0}" -f $cid), (Get-ReportResource $cid -ReturnType "embed")
	}
	$embedReport | Out-File -encoding ASCII -filepath $Filename

	# Display to screen
	if ($DisplayToScreen -and (!($emptyReport -and !$DisplayReportEvenIfEmpty))) {
		Write-CustomOut $lang.HTMLdisp
		Invoke-Item $Filename
	}

	# Generate email
	if ($SendEmail -and (!($emptyReport -and !$EmailReportEvenIfEmpty))) {
		Write-CustomOut $lang.emailSend
		$msg = New-Object System.Net.Mail.MailMessage ($EmailFrom, $EmailTo)
		# If CC address specified, add
		If ($EmailCc -ne "") {
			$msg.CC.Add($EmailCc)
		}
		$msg.subject = $EmailSubject

		# if send attachment, just send plaintext email with HTML report attached
		If ($SendAttachment) {
			$msg.Body = $lang.emailAtch
			$attachment = new-object System.Net.Mail.Attachment $Filename
			$msg.Attachments.Add($attachment)
		}
		# Otherwise send the HTML email
		else {
			$msg.IsBodyHtml = $true;
			$html = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($MyReport, $null, 'text/html')
			$msg.AlternateViews.Add($html)

			# Loop over all CIDs and replace them
			Foreach ($cid in $global:ReportResources.Keys) {
				if ($global:ReportResources[$cid].Uses -gt 0) {
					$lr = (Get-ReportResource $cid -ReturnType "linkedresource")
					$html.LinkedResources.Add($lr);
				}
			}
		}
		# Send the email
		$smtpClient = New-Object System.Net.Mail.SmtpClient

		# Find the VI Server and port from the global settings file
		$smtpClient.Host = ($SMTPSRV -Split ":")[0]
		if (($SMTPSRV -split ":")[1]) {
			$smtpClient.Port = ($SMTPSRV -split ":")[1]
		}

		if ($EmailSSL -eq $true) {
			$smtpClient.EnableSsl = $true
		}
		$smtpClient.UseDefaultCredentials = $true;
		$smtpClient.Send($msg)
		If ($SendAttachment) { $attachment.Dispose() }
		$msg.Dispose()
	}

	# Run EndScript once everything else is complete
	if (Test-Path ($ScriptPath + "\EndScript.ps1")) {
		. ($ScriptPath + "\EndScript.ps1")
	}

	#endregion output
}
