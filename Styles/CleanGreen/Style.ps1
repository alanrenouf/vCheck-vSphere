#################################
# Clean Green Style
# Author: Sam McGeown
#################################
# Use the following area to define the title color
$Colour1 ="0A77BA"
# Use the following area to define the Heading color
$Colour2 ="1D6325"
# Use the following area to define the Title text color
$TitleTxtColour ="FFFFFF"

# Add Header Resource
Add-ReportResource "Header" ($StylePath + "\Header.jpg") -Used $true

$FontFamily = "font-family: Tahoma, Arial, sans-serif;"

$DspHeader0 = "border: 0px; $($FontFamily) font-size: medium; padding: 8px; margin: 0px 0px 10px 0px; text-transform:uppercase;"
$DspHeader1 = "border: 0px; background: #6CB82E; color: #FFF; font-size: small; $($FontFamily) padding: 6px; margin: 0px;"
$dspcomments = "border: 0px; background: #E1E1E1; font-size: x-small; $($FontFamily) padding: 4px 4px 4px 6px; margin: 0px 0px 4px 0px;"
$filler = "border: 0px; DISPLAY: block; margin: 0px"
$dspcont ="border: 1px solid #E1E1E1; margin: 0px 0px 10px 0px;"

$HTMLHeader = @"
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Frameset//EN' 'http://www.w3.org/TR/html4/frameset.dtd'>
<html>
<head>
	<title>_HEADER_</title>
	<META http-equiv=Content-Type content='text/html; charset=windows-1252'>
	<style type='text/css'>
	TABLE { TABLE-LAYOUT: fixed; FONT-SIZE: 100%;  WIDTH: 100%}
	* { margin:0 }
	.pageholder	{ margin: 0px auto; }
	.warning { background: #FFFBAA !important }
	.critical { background: #FFDDDD !important }
	</style>
</head>
<body margin-left: 4pt; margin-right: 4pt; margin-top: 6pt;>
<div style='$($FontFamily) font-size:20px; font-weight:bolder; background-color:#$($Colour1);'>
	<center>
		<p class='accent'>
		<!--[if gte mso 9]>
			<H1><FONT COLOR='White'>vCheck</Font></H1>
		<![endif]-->
		<!--[if !mso]><!-->
			<IMG SRC='cid:Header' ALT='vCheck'>
		<!--<![endif]-->
		</p>
	</center>
</div>

"@

$CustomHeader0 = @"
	<!-- CustomHeader0 -->
		<div style='margin: 0px auto;'>		
		<h1 style='$($DspHeader0)'>_TITLE_</h1>
    	<div style='$($filler)'></div>
"@

$CustomHeaderStart = @"
	<!-- CustomHeaderStart -->
	    <h2 style='$($dspheader1)'>_TITLE_</h2>
"@

$CustomHeaderComments = @"
	<!-- CustomHeaderComments -->
		<div style='$($dspcomments)'>_COMMENTS_</div>
"@

$CustomHeaderEnd = @"
	<!-- CustomHeaderEnd -->
			<div style='$($dspcont)'>
"@
	
$CustomHeaderClose = @"
	<!-- CustomHeaderClose -->
		</DIV>
		<!--<div style='$($filler)'></div>-->
"@

$CustomHeader0Close = @"
	<!-- CustomHeader0Close -->
</DIV>
"@

$CustomHTMLClose = @"
	<!-- CustomHTMLClose -->
</div>
<div style='$($FontFamily) font-size: small;'>
	<center>vCheck v$($version) by Alan Renouf (<a href='http://virtu-al.net' target='_blank'>http://virtu-al.net</a>) generated on $($ENV:Computername) on $($Date.ToLongDateString()) at $($Date.ToLongTimeString())</center>
</div>
</body>
</html>
"@

$HTMLTableReplace = '<TABLE><style>tr:nth-child(even) { background-color: #e5e5e5; TABLE-LAYOUT: Fixed; FONT-SIZE: 100%; WIDTH: 100%}</style>' 
$HTMLTdReplace = '<td style= "font-family: Tahoma,Arial, sans-serif; font-size: x-small; vertical-align: top;">'
$HTMLThReplace = '<th style= "color: #000; font-family: Tahoma,Arial, sans-serif; font-size: x-small; text-align: left; vertical-align: top; text-transform: capitalize;">'

$HTMLDetail = @"
<!-- HTMLDetail -->
<TABLE TABLE-LAYOUT: Fixed; font-size: small; width: 100%>
	<tr>
		<th width='50%'; style='text-align: left; $($FontFamily) font-size: x-small; color: #$($Colour1); font-weight: bold;'>_HEADING_</th>
		<td width='50%'; style='$($FontFamily) font-size: x-small;'>_DETAIL_</td>
	</tr>
</TABLE>
<!-- /HTMLDetail -->
"@


