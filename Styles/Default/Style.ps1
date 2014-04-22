# Use the following area to define the title color
$Colour1 ="0A77BA"
# Use the following area to define the Heading color
$Colour2 ="1D6325"
# Use the following area to define the Title text color
$TitleTxtColour ="FFFFFF"

# Add Header resource
Add-ReportResource "Header" ($StylePath + "\Header.jpg") -Used $true

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


$HTMLHeader = @"
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Frameset//EN' 'http://www.w3.org/TR/html4/frameset.dtd'>
<html><head><title>_HEADER_</title>
		<META http-equiv=Content-Type content='text/html; charset=windows-1252'>
		<style type='text/css'>
		TABLE 		{
						TABLE-LAYOUT: fixed; 
						FONT-SIZE: 100%; 
						WIDTH: 100%
					}
		*		{
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
		.warning { background: #FFFBAA !important }
		.critical { background: #FFDDDD !important }
		</style>
	</head>
	<body margin-left: 4pt; margin-right: 4pt; margin-top: 6pt;>
	<a name='top'></a>
<div style='font-family:Arial, Helvetica, sans-serif; font-size:20px; font-weight:bolder; background-color:#$($Colour1);'><center>
<p class='accent'>
<!--[if gte mso 9]>
	<H1><FONT COLOR='White'>vCheck</Font></H1>
<![endif]-->
<!--[if !mso]><!-->
	<IMG SRC='cid:Header' ALT='vCheck'>
<!--<![endif]-->
</p>
</center></div>
	        <div style='font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:bold;'><center>vCheck v$($version) by Alan Renouf (<a href='http://virtu-al.net' target='_blank'>http://virtu-al.net</a>) generated on $($ENV:Computername) on $($Date.ToLongDateString()) at $($Date.ToLongTimeString())
			</center></div>
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
		<div style='$($filler)'></div>
"@

$CustomHeader0Close = @"
	<!-- CustomHeader0Close -->
</DIV>
<div style='width: 95%; margin: 0px auto; font-size: 8pt; text-align: right'><a href="#top">Back to Top</a></div>
"@

$CustomHTMLClose = @"
	<!-- CustomHTMLClose -->
</div>
</body>
</html>
"@

$HTMLTableReplace = '<TABLE><style>tr:nth-child(even) { background-color: #e5e5e5; TABLE-LAYOUT: Fixed; FONT-SIZE: 100%; WIDTH: 100%}</style>' 
$HTMLTdReplace = '<td style= "FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;">'
$HTMLThReplace = '<th style= "COLOR: #$($Colour1); FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;">'
$HTMLLtReplace = "<"
$HTMLGtReplace = ">"

$HTMLDetail = @"
<TABLE TABLE-LAYOUT: Fixed; FONT-SIZE: 100%; WIDTH: 100%>
	<tr>
	<th width='50%';VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma; FONT-SIZE: 8pt; COLOR: #$($Colour1);><b>_HEADING_</b></th>
	<td width='50%';VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;>_DETAIL_</td>
	</tr>
</TABLE>
"@


