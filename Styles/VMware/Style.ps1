$StyleVersion = 1.0

# Define Chart Colours
$ChartColours = @("377C2B", "0A77BA", "1D6325", "89CBE1")
$ChartBackground = "FFFFFF"

# Set Chart dimensions (WidthxHeight)
$ChartSize = "200x200"

# Header Images
Add-ReportResource "Header-vCheck" ($StylePath + "\Header.jpg") -Used $true
Add-ReportResource "Header-VMware" ($StylePath + "\Header-vmware.png") -Used $true

$HTMLHeader = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
   <head>
      <title>_HEADER_</title>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
		<style type='text/css'>
         table	{
            width: 100%;
            margin: 0px;
            padding: 0px;
         }

         tr:nth-child(even) { 
               background-color: #e5e5e5; 
         }
            
         td {
               vertical-align: top; 
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
               padding: 0px;
         }
                  
         th {
               vertical-align: top;  
               color: #018AC0; 
               text-align: left;
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
         }
         .pluginContent td { padding: 5px; }

         .warning { background: #FFFBAA !important }
			.critical { background: #FFDDDD !important }
      </style>
	</head>
	<body style="padding: 0 10px; margin: 0px; font-family:Arial, Helvetica, sans-serif; ">
        <table width='100%' style='background-color: #0A77BA; border-collapse: collapse; border: 0px; margin: 0; padding: 0;'>
         <tr>
            <td>
               <img src='cid:Header-vCheck' alt='vCheck' />
            </td>
            <td style='width: 171px'>
               <img src='cid:Header-VMware' alt='VMware' />
            </td>
         </tr>
      </table>
      <div style='height: 10px; font-size: 10px;'>&nbsp;</div>
"@

$CustomHeader0 = @"
      <table width='100%'><tr><td style='background-color: #0A77BA; border: 1px solid #0A77BA; vertical-align: middle; height: 30px; text-indent: 10px; font-family: Tahoma, sans-serif; font-weight: bold; font-size: 8pt; color: #FFFFFF;'>_TITLE_</td></tr></table>
"@

$CustomHeaderStart = @"
	<!-- CustomHeaderStart -->
      <div style='height: 10px; font-size: 10px;'>&nbsp;</div>
	   <table width='100%' style='padding: 0px; border-collapse: collapse;'><tr><td style='background-color: #1D6325; border: 1px solid #1D6325; font-family: Tahoma, sans-serif; font-weight: bold; font-size: 8pt; color: #FFFFFF; text-indent: 10px; height: 30px; vertical-align: middle;'>_TITLE_</td></tr>
"@

$CustomHeaderComments = @"
	<!-- CustomHeaderComments -->
		<tr><td style='margin: 0px; background-color: #f4f7fc; color: #000000; font-style: italic; font-size: 8pt; text-indent: 10px; vertical-align: middle; border-right: 1px solid #bbbbbb; border-left: 1px solid #bbbbbb;'>_COMMENTS_</td></tr>
"@

$CustomHeaderEnd = @"
	<!-- CustomHeaderEnd -->
			<tr><td style='margin: 0px; padding: 0px; background-color: #f9f9f9; color: #000000; font-size: 8pt; border: #bbbbbb 1px solid;'>
"@
	
$CustomHeaderClose = @"
	<!-- CustomHeaderClose -->
		</td></tr></table>
"@

$CustomHeader0Close = @"
"@

$CustomHTMLClose = @"
   <!-- CustomHTMLClose -->
   <div style='height: 10px; font-size: 10px;'>&nbsp;</div>
   <table width='100%'><tr><td style='font-size:14px; font-weight:bold; height: 25px; text-align: center; vertical-align: middle; background-color:#0A77BA; color: white;'>vCheck v$($vCheckVersion) by <a href='http://virtu-al.net' sytle='color: white;'>Alan Renouf</a> generated on $($ENV:Computername) on $($Date.ToLongDateString()) at $($Date.ToLongTimeString())</td></tr></table>
   </body>
</html>
"@

$HTMLTableReplace = "<table width='100%'>"
$HTMLTdReplace = '<td>'
$HTMLThReplace = '<th>'
$HTMLLtReplace = "<"
$HTMLGtReplace = ">"
