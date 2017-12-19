$StyleVersion = 1.1

# Define Chart Colours
$ChartColours = @("377C2B", "0A77BA", "1D6325", "89CBE1")
$ChartBackground = "FFFFFF"

# Set Chart dimensions (WidthxHeight)
$ChartSize = "200x200"

# Header Images
Add-ReportResource "Header-vCheck" ($StylePath + "\Header.jpg") -Used $true

# Hash table of key/value replacements
if ($GUIConfig) {
    $StyleReplace = @{"_HEADER_" = ("'$reportHeader'");
                      "_SCRIPT_" = "Get-ConfigScripts";
                      "_CONTENT_" = "Get-ReportContentHTML";
                      "_CONFIGEXPORT_" = ("'<div style=""text-align:center;""><button type=""button"" onclick=""createCSV()"">Export Settings</button></div>'")
                      "_TOC_" = ("''")}
} else {
    $StyleReplace = @{"_HEADER_" = ("'$reportHeader'");
                      "_CONTENT_" = "Get-ReportContentHTML";
                      "_CONFIGEXPORT_" = ("''")
                      "_TOC_" = "Get-ReportTOC"}
}

#region Function Defniitions
<#
   Get-ReportHTML - *REQUIRED*
   Returns the HTML for the report
#>
function Get-ReportHTML {  
   foreach ($replaceKey in $StyleReplace.Keys.GetEnumerator()) {
      $ReportHTML = $ReportHTML -replace $replaceKey, (Invoke-Expression $StyleReplace[$replaceKey])
   }

   return $reportHTML
}

<#
   Get-ReportContentHTML
   Called to replace the content section of the HTML template
#>
function Get-ReportContentHTML {
   $ContentHTML = ""
   
   foreach ($pr in $PluginResult) {
      if ($pr.Details) {
         $ContentHTML += Get-PluginHTML $pr
      }
   }
   return $ContentHTML
}
<#
   Get-PluginHTML
   Called to populate the plugin content in the report
#>
function Get-PluginHTML {
   param ($PluginResult)

   $FinalHTML = $PluginHTML -replace "_TITLE_", $PluginResult.Header
   $FinalHTML = $FinalHTML -replace "_COMMENTS_", $PluginResult.Comments
   $FinalHTML = $FinalHTML -replace "_PLUGINCONTENT_", $PluginResult.Details
   $FinalHTML = $FinalHTML -replace "_PLUGINID_", $PluginResult.PluginID
   
   return $FinalHTML
}

<#
   Get-ReportTOC
   Generate table of contents
#>
function Get-ReportTOC {
   if ($ShowTOC) {
      $TOCHTML = "<ul>"
      foreach ($pr in ($PluginResult | Where-Object {$_.Details})) {
            $TOCHTML += ("<li><a style='font-size: 8pt' href='#{0}'>{1}</a></li>" -f $pr.PluginID, $pr.Title)
      }
      $TOCHTML += "</ul>"

      return $TOCHTML
   }
}
#endregion

# Report HTML structure
$ReportHTML = @"
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
               color: #000000; 
               text-align: left;
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
         }
         input {
            float:right;
            clear:both;
         }
         .pluginContent td { padding: 5px; }

         .warning { background: #FFFBAA !important }
			.critical { background: #FFDDDD !important }
      </style>
      <script>
        _SCRIPT_
      </script>
	</head>
	<body style="padding: 0 10px; margin: 0px; font-family:Arial, Helvetica, sans-serif; ">
      <a name="top" />
        <table width='100%' style='background-color: black; margin: 0; padding: 0;'>
         <tr>
            <td style='background-color: black;'>
               <img src='cid:Header-vCheck' alt='vCheck' />
            </td>
         </tr>
      </table>
      <div style='height: 10px; font-size: 10px;'>&nbsp;</div>
      <table width='100%'><tr><td style='vertical-align: middle; text-indent: 10px; font-family: Tahoma, sans-serif; font-weight: bold; font-size: 12pt; color: #000000;'>_HEADER_</td></tr></table>
      <div>_TOC_</div>
      _CONTENT_
      _CONFIGEXPORT_
   <!-- CustomHTMLClose -->
   <div style='height: 10px; font-size: 10px;'>&nbsp;</div>
   <table width='100%'><tr><td style='font-size:9pt; height: 25px; text-align: center; vertical-align: middle; color: #000000;'>vCheck v$($vCheckVersion) by <a href='http://virtu-al.net' sytle='color: white;'>Alan Renouf</a> generated on $($ENV:Computername) on $($Date.ToLongDateString()) at $($Date.ToLongTimeString())</td></tr></table>
   </body>
</html>      
"@

# Structure of each Plugin
$PluginHTML = @"
	<!-- Plugin Start - _TITLE_ -->
      <div style='height: 10px; font-size: 10px;'>&nbsp;</div>
      <a name="_PLUGINID_" />
      <table width='100%' style='padding: 0px; border-collapse: collapse;'><tr><td style='background-color: #6CB82E; border: 1px solid #6CB82E; font-family: Tahoma, sans-serif; font-weight: bold; font-size: 9pt; color: #FFFFFF; text-indent: 10px; height: 30px; vertical-align: middle;'>_TITLE_</td></tr>
         <tr><td style='margin: 0px; background-color: #E1E1E1; color: #000000; font-style: italic; font-size: 8pt; text-indent: 10px; vertical-align: middle; border-right: 1px solid #E1E1E1; border-left: 1px solid #E1E1E1; height: 20px;'>_COMMENTS_</td></tr>
         <tr><td style='margin: 0px; padding: 0px; background-color: #FFFFFF; color: #000000; font-size: 8pt; border: #E1E1E1 1px solid;'>_PLUGINCONTENT_</td></tr>
         <tr><td style="text-align: right; background: #FFFFFF"><a href="#top" style="color: black">Back To Top</a>
      </table>
   <!-- Plugin End -->
"@