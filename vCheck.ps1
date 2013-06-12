param ([Switch]$config, $Outputpath)
###############################
# vCheck - Daily Error Report # 
###############################
# Thanks to all who have commented on my blog to help improve this project
# all beta testers and previous contributors to this script.
#
$Version = "6.15"

function Write-CustomOut ($Details){
	$LogDate = Get-Date -Format T
	Write-Host "$($LogDate) $Details"
	#write-eventlog -logname Application -source "Windows Error Reporting" -eventID 12345 -entrytype Information -message "vCheck: $Details"
}

Function Invoke-Settings ($Filename, $GB) {
	$file = Get-Content $filename
	$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
	$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber
	if (($OriginalLine +1) -eq $EndLine) {
		} Else {
		$Array = @()
		$Line = $OriginalLine
		do {
			$Question = $file[$Line]
			$Line ++
			$Split= ($file[$Line]).Split("=")
			$Var = $Split[0]
			$CurSet = $Split[1]
			
			# Check if the current setting is in speach marks
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
$PluginsFolder = $ScriptPath + "\Plugins\"
$Plugins = Get-ChildItem -Path $PluginsFolder -filter "*.ps1" | Sort Name
$GlobalVariables = $ScriptPath + "\GlobalVariables.ps1"

$file = Get-Content $GlobalVariables

$Setup = ($file | Select-String -Pattern '# Set the following to true to enable the setup wizard for first time run').LineNumber
$SetupLine = $Setup ++
$SetupSetting = invoke-Expression (($file[$SetupLine]).Split("="))[1]
if ($config) {
	$SetupSetting = $true
}
If ($SetupSetting) {
	cls
	Write-Host
	Write-Host -ForegroundColor Yellow "Welcome to vCheck by Virtu-Al http://virtu-al.net"
	Write-Host -ForegroundColor Yellow "================================================="
	Write-Host -ForegroundColor Yellow "This is the first time you have run this script or you have re-enabled the setup wizard."
	Write-Host
	Write-Host -ForegroundColor Yellow "To re-run this wizard in the future please use vCheck.ps1 -Config"
	Write-Host -ForegroundColor Yellow "To define a path to store each vCheck report please use vCheck.ps1 -Outputpath C:\tmp"
	Write-Host 
	Write-Host -ForegroundColor Yellow "Please complete the following questions or hit Enter to accept the current setting"
	Write-Host -ForegroundColor Yellow "After completing ths wizard the vCheck report will be displayed on the screen."
	Write-Host
	
	Invoke-Settings -Filename $GlobalVariables -GB $true
	Foreach ($plugin in $Plugins) { 
		Invoke-Settings -Filename $plugin.Fullname
	}
}

. $GlobalVariables

$DspHeader0 = "
	BORDER-RIGHT: #bbbbbb 1px solid;
	PADDING-RIGHT: 0px;
	BORDER-TOP: #bbbbbb 1px solid;
	DISPLAY: block;
	PADDING-LEFT: 0px;
	FONT-WEIGHT: bold;
	FONT-SIZE: 8pt;
	MARGIN-BOTTOM: -1px;
	MARGIN-LEFT: 0px;
	BORDER-LEFT: #bbbbbb 1px solid;
	COLOR: #$($TitleTxtColour);
	MARGIN-RIGHT: 0px;
	PADDING-TOP: 4px;
	BORDER-BOTTOM: #bbbbbb 1px solid;
	FONT-FAMILY: Tahoma;
	POSITION: relative;
	HEIGHT: 2.25em;
	WIDTH: 95%;
	TEXT-INDENT: 10px;
	BACKGROUND-COLOR: #$($Colour1);
"

$DspHeader1 = "
	BORDER-RIGHT: #bbbbbb 1px solid;
	PADDING-RIGHT: 0px;
	BORDER-TOP: #bbbbbb 1px solid;
	DISPLAY: block;
	PADDING-LEFT: 0px;
	FONT-WEIGHT: bold;
	FONT-SIZE: 8pt;
	MARGIN-BOTTOM: -1px;
	MARGIN-LEFT: 0px;
	BORDER-LEFT: #bbbbbb 1px solid;
	COLOR: #$($TitleTxtColour);
	MARGIN-RIGHT: 0px;
	PADDING-TOP: 4px;
	BORDER-BOTTOM: #bbbbbb 1px solid;
	FONT-FAMILY: Tahoma;
	POSITION: relative;
	HEIGHT: 2.25em;
	WIDTH: 95%;
	TEXT-INDENT: 10px;
	BACKGROUND-COLOR: #$($Colour2);
"

$dspcomments = "
	BORDER-RIGHT: #bbbbbb 1px solid;
	PADDING-RIGHT: 0px;
	BORDER-TOP: #bbbbbb 1px solid;
	DISPLAY: block;
	PADDING-LEFT: 0px;
	FONT-WEIGHT: bold;
	FONT-SIZE: 8pt;
	MARGIN-BOTTOM: -1px;
	MARGIN-LEFT: 0px;
	BORDER-LEFT: #bbbbbb 1px solid;
	COLOR: #$($TitleTxtColour);
	MARGIN-RIGHT: 0px;
	PADDING-TOP: 4px;
	BORDER-BOTTOM: #bbbbbb 1px solid;
	FONT-FAMILY: Tahoma;
	POSITION: relative;
	HEIGHT: 2.25em;
	WIDTH: 95%;
	TEXT-INDENT: 10px;
	BACKGROUND-COLOR:#FFFFE1;
	COLOR: #000000;
	FONT-STYLE: ITALIC;
	FONT-WEIGHT: normal;
	FONT-SIZE: 8pt;
"

$filler = "
	BORDER-RIGHT: medium none; 
	BORDER-TOP: medium none; 
	DISPLAY: block; 
	BACKGROUND: none transparent scroll repeat 0% 0%; 
	MARGIN-BOTTOM: -1px; 
	FONT: 100%/8px Tahoma; 
	MARGIN-LEFT: 43px; 
	BORDER-LEFT: medium none; 
	COLOR: #ffffff; 
	MARGIN-RIGHT: 0px; 
	PADDING-TOP: 4px; 
	BORDER-BOTTOM: medium none; 
	POSITION: relative
"

$dspcont ="
	BORDER-RIGHT: #bbbbbb 1px solid;
	BORDER-TOP: #bbbbbb 1px solid;
	PADDING-LEFT: 0px;
	FONT-SIZE: 8pt;
	MARGIN-BOTTOM: -1px;
	PADDING-BOTTOM: 5px;
	MARGIN-LEFT: 0px;
	BORDER-LEFT: #bbbbbb 1px solid;
	WIDTH: 95%;
	COLOR: #000000;
	MARGIN-RIGHT: 0px;
	PADDING-TOP: 4px;
	BORDER-BOTTOM: #bbbbbb 1px solid;
	FONT-FAMILY: Tahoma;
	POSITION: relative;
	BACKGROUND-COLOR: #f9f9f9
"

Function Get-Base64Image ($Path) {
	$pic = Get-Content $Path -Encoding Byte
	[Convert]::ToBase64String($pic)
}

$HeaderImg = Get-Base64Image ((Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path) + "\Header.jpg")

Function Get-CustomHTML ($Header){
$Report = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>$($Header)</title>
		<META http-equiv=Content-Type content='text/html; charset=windows-1252'>

		<style type="text/css">

		TABLE 		{
						TABLE-LAYOUT: fixed; 
						FONT-SIZE: 100%; 
						WIDTH: 100%
					}
		*
					{
						margin:0
					}

		.pageholder	{
						margin: 0px auto;
					}
					
		td 				{
						VERTICAL-ALIGN: TOP; 
						FONT-FAMILY: Tahoma
					}
					
		th 			{
						VERTICAL-ALIGN: TOP; 
						COLOR: #018AC0; 
						TEXT-ALIGN: left
					}
					
		</style>
	</head>
	<body margin-left: 4pt; margin-right: 4pt; margin-top: 6pt;>
<div style="font-family:Arial, Helvetica, sans-serif; font-size:20px; font-weight:bolder; background-color:#$($Colour1);"><center>
<p class="accent">
<!--[if gte mso 9]>
	<H1><FONT COLOR="White">vCheck</Font></H1>
<![endif]-->
<!--[if !mso]><!-->
	<IMG SRC="data:image/jpg;base64,$($HeaderImg)" ALT="vCheck">
<!--<![endif]-->
</p>
</center></div>
	        <div style="font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:bold;"><center>vCheck v$($version) by Alan Renouf (<a href='http://virtu-al.net' target='_blank'>http://virtu-al.net</a>) generated on $($ENV:Computername)
			</center></div>
"@
Return $Report
}

Function Get-CustomHeader0 ($Title){
$Report = @"
		<div style="margin: 0px auto;">		

		<h1 style="$($DspHeader0)">$($Title)</h1>
	
    	<div style="$($filler)"></div>
"@
Return $Report
}

Function Get-CustomHeader ($Title, $cmnt){
$Report = @"
	    <h2 style="$($dspheader1)">$($Title)</h2>
"@
If ($Comments) {
	$Report += @"
			<div style="$($dspcomments)">$($cmnt)</div>
"@
}
$Report += @"
        <div style="$($dspcont)">
"@
Return $Report
}

Function Get-CustomHeaderClose{

	$Report = @"
		</DIV>
		<div style="$($filler)"></div>
"@
Return $Report
}

Function Get-CustomHeader0Close{
	$Report = @"
</DIV>
"@
Return $Report
}

Function Get-CustomHTMLClose{
	$Report = @"
</div>

</body>
</html>
"@
Return $Report
}

Function Get-HTMLTable {
	param([array]$Content)
	$HTMLTable = $Content | ConvertTo-Html -Fragment
	$HTMLTable = $HTMLTable -Replace '<TABLE>', '<TABLE><style>tr:nth-child(even) { background-color: #e5e5e5; TABLE-LAYOUT: Fixed; FONT-SIZE: 100%; WIDTH: 100%}</style>' 
	$HTMLTable = $HTMLTable -Replace '<td>', '<td style= "FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;">'
	$HTMLTable = $HTMLTable -Replace '<th>', '<th style= "COLOR: #$($Colour1); FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;">'
	$HTMLTable = $HTMLTable -replace '&lt;', "<"
	$HTMLTable = $HTMLTable -replace '&gt;', ">"
	Return $HTMLTable
}

Function Get-HTMLDetail ($Heading, $Detail){
$Report = @"
<TABLE TABLE-LAYOUT: Fixed; FONT-SIZE: 100%; WIDTH: 100%>
	<tr>
	<th width='50%';VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma; FONT-SIZE: 8pt; COLOR: #$($Colour1);><b>$Heading</b></th>
	<td width='50%';VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;>$($Detail)</td>
	</tr>
</TABLE>
"@
Return $Report
}

# Adding all plugins
$TTRReport = @()
$MyReport = Get-CustomHTML "$Server vCheck"
	$MyReport += Get-CustomHeader0 ($Server)
	$Plugins | Foreach {
		$TTR = [math]::round((Measure-Command {$Details = . $_.FullName}).TotalSeconds, 2)
		$TTRTable = "" | Select Plugin, TimeToRun
		$TTRTable.Plugin = $_.Name
		$TTRTable.TimeToRun = $TTR
		$TTRReport += $TTRTable
		$ver = "{0:N1}" -f $PluginVersion
		Write-CustomOut "..finished calculating $Title by $Author v$Ver"
		If ($Details) {
			If ($Display -eq "List"){
				$MyReport += Get-CustomHeader $Header $Comments
				$AllProperties = $Details | Get-Member -MemberType Properties
				$AllProperties | Foreach {
					$MyReport += Get-HTMLDetail $_.Name $Details.($_.Name)
				}
				$MyReport += Get-CustomHeaderClose			
			}
			If ($Display -eq "Table") {
				$MyReport += Get-CustomHeader $Header $Comments
						$MyReport += Get-HTMLTable $Details
				$MyReport += Get-CustomHeaderClose
			}
		}
	}	
	$MyReport += Get-CustomHeader ("This report took " + [math]::round(((Get-Date) - $Date).TotalMinutes,2) + " minutes to run all checks.") "The following plugins took longer than $PluginSeconds seconds to run, there may be a way to optimize these or remove them if not needed"
	$TTRReport = $TTRReport | Where { $_.TimeToRun -gt $PluginSeconds }
	$TTRReport |  Foreach {$MyReport += Get-HTMLDetail $_.Plugin $_.TimeToRun}
	$MyReport += Get-CustomHeaderClose
$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

if ($DisplayToScreen -or $SetupSetting) {
	Write-CustomOut "..Displaying HTML results"
	$Filename = $Env:TEMP + "\" + $Server + "vCheck" + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".htm"
	$MyReport | out-file -encoding ASCII -filepath $Filename
	Invoke-Item $Filename
}

if ($SendAttachment) {
	$Filename = $Env:TEMP + "\" + $Server + "vCheck" + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".htm"
	$MyReport | out-file -encoding ASCII -filepath $Filename
}

if ($Outputpath) {
	$DateHTML = Get-Date -Format "yyyyMMddHH"
	$ArchiveFilePath = $Outputpath + "\Archives\" + $VIServer
	if (-not (Test-Path -PathType Container $ArchiveFilePath)) { New-Item $ArchiveFilePath -type directory | Out-Null }
	$Filename = $ArchiveFilePath + "\" + $VIServer + "_vCheck_" + $DateHTML + ".htm"
	$MyReport | out-file -encoding ASCII -filepath $Filename
}

if ($SendEmail) {
	Write-CustomOut "..Sending Email"
	If ($SendAttachment) {
		send-Mailmessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -SmtpServer $SMTPSRV -Body "vCheck attached to this email" -Attachments $Filename
	} Else {
		send-Mailmessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -SmtpServer $SMTPSRV -Body $MyReport -BodyAsHtml
	}
}

if ($SendAttachment -eq $true -and $DisplaytoScreen -ne $true) {
	Write-CustomOut "..Removing temporary file"
	Remove-Item $Filename -Force
}

$End = $ScriptPath + "\EndScript.ps1"
. $End