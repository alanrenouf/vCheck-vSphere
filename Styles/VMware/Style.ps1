# Use the following area to define the title color
$Colour1 ="0A77BA"
# Use the following area to define the Heading color
$Colour2 ="1D6325"
# Use the following area to define the Title text color
$TitleTxtColour ="FFFFFF"

# Define Chart Colours
$ChartColours = @("377C2B", "0A77BA", "1D6325", "89CBE1")
$ChartBackground = "FFFFFF"

# Set Chart dimensions (WidthxHeight)
$ChartSize = "200x200"

# Header Images
Add-ReportResource "Header-vCheck" ($StylePath + "\Header.jpg") -Used $true
Add-ReportResource "Header-VMware" ($StylePath + "\Header-vmware.png") -Used $true

$HTMLHeader = @"
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Frameset//EN' 'http://www.w3.org/TR/html4/frameset.dtd'>
<html>
   <head>
      <title>_HEADER_</title>
		<meta http-equiv=Content-Type content='text/html; charset=windows-1252'>
		<style type='text/css'>
         body {
                  margin-left: 4pt;
                  margin-right: 4pt; 
                  margin-top: 6pt;
               }
         table	{
                  width: 100%;
               }
         *	{
               margin:0;
               font-family: Tahoma, sans-serif
            }
         tr:nth-child(even) { 
               background-color: #e5e5e5; 
            }
         td {
               vertical-align: top; 
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
            }
                  
         th {
               vertical-align: top;  
               color: #018AC0; 
               text-align: left;
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
            }
         #header { 
               font-family:Arial, Helvetica, sans-serif; 
               font-size:20px; 
               font-weight:bolder; 
               background-color:#$($Colour1);
            }
         #vcheck {
               font-family:Arial, Helvetica, sans-serif; 
               font-size:14px; 
               font-weight:bold;
               text-align: center;
               margin-bottom: 10px;
            }
         .customHeader0 {
               margin: 0px auto;
            }
            
         .customHeader0 h1 {
            background-color: #$($Colour1);

            line-height: 2.25em;
            vertical-align: middle; 
            width: 95%;
            margin: 0px auto;
            
            text-indent: 10px;           
            font-family: Tahoma, sans-serif;
            font-weight: bold;
            font-size: 8pt;
            color: #$($TitleTxtColour);
         }
         
         h2.dspheader1 {
            background-color: #$($Colour2);
            border: 1px solid #$($Colour2);
            
            text-indent: 10px;
            font-family: Tahoma, sans-serif;
            font-weight: bold;
            font-size: 8pt;
            color: #$($TitleTxtColour);
            
            line-height: 2.25em;
            vertical-align: middle; 
            width: 95%;
            margin: 10px auto 0px auto;
           
         }
         
         .dspcomments {
            line-height: 2.25em;
            width: 95%;
            margin: 0px auto;
            text-indent: 10px;
            
            background-color: #FFFFE1;
            color: #000000;
            font-style: italic;
            font-size: 8pt;
            
            border-right: 1px solid #bbbbbb;
            border-left: 1px solid #bbbbbb;
         }
         .dspcont {
         	border: #bbbbbb 1px solid;          
            width: 95%;
            color: #000000;
            font-size: 8pt;
            margin: 0px auto;            
            background-color: #f9f9f9
         }
         .warning { background: #FFFBAA !important }
			.critical { background: #FFDDDD !important }
		</style>
	</head>
	<body>
      <div id='header'>
         <!--[if gte mso 9]>
            <H1 style='text-align: center; color: white'>vCheck</Font></H1>
         <![endif]-->
         <!--[if !mso]><!-->
            <img src='cid:Header-vCheck' ALT='vCheck' /><div style='float:right'><img src='cid:Header-VMware' alt='VMware' /></div>
         <!--<![endif]-->
      </div>
	   <div id='vcheck'>vCheck v$($version) by Alan Renouf (<a href='http://virtu-al.net' target='_blank'>http://virtu-al.net</a>) generated on $($ENV:Computername) on $($Date.ToLongDateString()) at $($Date.ToLongTimeString())</div>
"@

$CustomHeader0 = @"
	<!-- CustomHeader0 -->
		<div class='customHeader0'>		
         <h1>_TITLE_</h1>
"@

$CustomHeaderStart = @"
	<!-- CustomHeaderStart -->
	   <h2 class='dspheader1'>_TITLE_</h2>
"@

$CustomHeaderComments = @"
	<!-- CustomHeaderComments -->
		<div class='dspcomments'>_COMMENTS_</div>
"@

$CustomHeaderEnd = @"
	<!-- CustomHeaderEnd -->
			<div class='dspcont'>
"@
	
$CustomHeaderClose = @"
	<!-- CustomHeaderClose -->
		</div>
"@

$CustomHeader0Close = @"
	<!-- CustomHeader0Close -->
</div>
"@

$CustomHTMLClose = @"
	<!-- CustomHTMLClose -->
</div>
</body>
</html>
"@

$HTMLTableReplace = '<table>' 
$HTMLTdReplace = '<td>'
$HTMLThReplace = '<th>'
$HTMLLtReplace = "<"
$HTMLGtReplace = ">"
