# Start of Settings 
# Show table of centents in report?
$ShowTOC = $true
# Number of columns in table of contents
$ToCColumns = 1
# End of Settings

$StyleVersion = 1.4

# Define Chart Colours
$ChartColours = @("377C2B", "0A77BA", "1D6325", "89CBE1")
$ChartBackground = "FFFFFF"

# Set Chart dimensions (WidthxHeight)
$ChartSize = "200x200"

# Header Images
Add-ReportResource "Header-vCheck" ($StylePath + "\Header.jpg") -Used $true
Add-ReportResource "Header-VMware" ($StylePath + "\Header-vmware.png") -Used $true

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

#region Function Definitions
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
   $PluginResult.Details = $PluginResult.Details -replace "<td>", "<td class='left'>"
   $PluginResult.Details = $PluginResult.Details -replace "<th>", "<th class='left'>"
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
      $TOCHTML = @"
      <nav class="sidenav">
         <section class="sidenav-content">
         <section class="nav-group">
         <ul class="nav-list">
"@

      foreach ($pr in ($PluginResult | Where-Object {$_.Details})) {
         $TOCHTML += ("<li><a class='nav-link' href='#{0}'>{1}</a></li>" -f $pr.PluginID, $pr.Title)
      }
      $TOCHTML += "</ul>
      </section>
   </section>
   </nav>"

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
      /*!
      * Copyright (c) 2016-2017 VMware, Inc. All Rights Reserved.
      * This software is released under MIT license.
      * The full license information can be found in LICENSE in the root directory of this project.
      */
     /*!
      * Clarity v0.10.3 | MIT license | https://github.com/vmware/clarity
      */
     /*! normalize.css v4.2.0 | MIT License | github.com/necolas/normalize.css */
     
     html {
         font-family: sans-serif;
         line-height: 1.15;
         -ms-text-size-adjust: 100%;
         -webkit-text-size-adjust: 100%
     }
     body {
         margin: 0
     }
     article,
     aside,
     details,
     figcaption,
     figure,
     footer,
     header,
     main,
     menu,
     nav,
     section,
     summary {
         display: block
     }
     audio,
     canvas,
     progress,
     video {
         display: inline-block
     }
     audio:not([controls]) {
         display: none;
         height: 0
     }
     progress {
         vertical-align: baseline
     }
     template,
     [hidden] {
         display: none
     }
     a {
         background-color: transparent;
         -webkit-text-decoration-skip: objects
     }
     a:active,
     a:hover {
         outline-width: 0
     }
     abbr[title] {
         border-bottom: none;
         text-decoration: underline;
         text-decoration: underline dotted
     }
     b,
     strong {
         font-weight: inherit
     }
     b,
     strong {
         font-weight: bolder
     }
     dfn {
         font-style: italic
     }
     h1 {
         font-size: 2em;
         margin: 0.67em 0
     }
     mark {
         background-color: #ff0;
         color: #000
     }
     small {
         font-size: 80%
     }
     sub,
     sup {
         font-size: 75%;
         line-height: 0;
         position: relative;
         vertical-align: baseline
     }
     sub {
         bottom: -0.25em
     }
     sup {
         top: -0.5em
     }
     .warning { background: #FFFBAA !important; text-align: left }
     .critical { background: #FFDDDD !important; text-align: left }
     .nearcritical { background: #FCA751 !important; text-align: left }
     img {
         border-style: none
     }
     svg:not(:root) {
         overflow: hidden
     }
     code,
     kbd,
     pre,
     samp {
         font-family: monospace, monospace;
         font-size: 1em
     }
     figure {
         margin: 1em 40px
     }
     hr {
         box-sizing: content-box;
         height: 0;
         overflow: visible
     }
     button,
     input,
     optgroup,
     select,
     textarea {
         font: inherit;
         margin: 0
     }
     optgroup {
         font-weight: bold
     }
     button,
     input {
         overflow: visible
     }
     button,
     select {
         text-transform: none
     }
     button,
     html [type="button"],
     [type="reset"],
     [type="submit"] {
         -webkit-appearance: button
     }
     button::-moz-focus-inner,
     [type="button"]::-moz-focus-inner,
     [type="reset"]::-moz-focus-inner,
     [type="submit"]::-moz-focus-inner {
         border-style: none;
         padding: 0
     }
     button:-moz-focusring,
     [type="button"]:-moz-focusring,
     [type="reset"]:-moz-focusring,
     [type="submit"]:-moz-focusring {
         outline: 1px dotted ButtonText
     }
     fieldset {
         border: 1px solid #c0c0c0;
         margin: 0 2px;
         padding: 0.35em 0.625em 0.75em
     }
     legend {
         box-sizing: border-box;
         color: inherit;
         display: table;
         max-width: 100%;
         padding: 0;
         white-space: normal
     }
     textarea {
         overflow: auto
     }
     [type="checkbox"],
     [type="radio"] {
         box-sizing: border-box;
         padding: 0
     }
     [type="number"]::-webkit-inner-spin-button,
     [type="number"]::-webkit-outer-spin-button {
         height: auto
     }
     [type="search"] {
         -webkit-appearance: textfield;
         outline-offset: -2px
     }
     [type="search"]::-webkit-search-cancel-button,
     [type="search"]::-webkit-search-decoration {
         -webkit-appearance: none
     }
     ::-webkit-input-placeholder {
         color: inherit;
         opacity: 0.54
     }
     ::-webkit-file-upload-button {
         -webkit-appearance: button;
         font: inherit
     }
     .media {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex
     }
     .media-body {
         -webkit-box-flex: 1;
         -ms-flex: 1;
         flex: 1
     }
     .media-middle {
         -ms-flex-item-align: center;
         -ms-grid-row-align: center;
         align-self: center
     }
     .media-bottom {
         -ms-flex-item-align: end;
         align-self: flex-end
     }
     .media-object {
         display: block
     }
     .media-object.img-thumbnail {
         max-width: none
     }
     .media-right {
         padding-left: 10px
     }
     .media-left {
         padding-right: 10px
     }
     .media-heading {
         margin-top: 0;
         margin-bottom: 5px
     }
     .media-list {
         padding-left: 0;
         list-style: none
     }
     .align-baseline {
         vertical-align: baseline !important
     }
     .align-top {
         vertical-align: top !important
     }
     .align-middle {
         vertical-align: middle !important
     }
     .align-bottom {
         vertical-align: bottom !important
     }
     .align-text-bottom {
         vertical-align: text-bottom !important
     }
     .align-text-top {
         vertical-align: text-top !important
     }
     .bg-faded {
         background-color: #fff
     }
     .bg-primary {
         background-color: #0275d8 !important
     }
     a.bg-primary:focus,
     a.bg-primary:hover {
         background-color: #025aa5 !important
     }
     .bg-success {
         background-color: #5cb85c !important
     }
     a.bg-success:focus,
     a.bg-success:hover {
         background-color: #449d44 !important
     }
     .bg-info {
         background-color: #5bc0de !important
     }
     a.bg-info:focus,
     a.bg-info:hover {
         background-color: #31b0d5 !important
     }
     .bg-warning {
         background-color: #f0ad4e !important
     }
     a.bg-warning:focus,
     a.bg-warning:hover {
         background-color: #ec971f !important
     }
     .bg-danger {
         background-color: #d9534f !important
     }
     a.bg-danger:focus,
     a.bg-danger:hover {
         background-color: #c9302c !important
     }
     .bg-inverse {
         background-color: #373a3c !important
     }
     a.bg-inverse:focus,
     a.bg-inverse:hover {
         background-color: #1f2021 !important
     }
     .rounded {
         border-radius: .25rem
     }
     .rounded-top {
         border-top-right-radius: .25rem;
         border-top-left-radius: .25rem
     }
     .rounded-right {
         border-bottom-right-radius: .25rem;
         border-top-right-radius: .25rem
     }
     .rounded-bottom {
         border-bottom-right-radius: .25rem;
         border-bottom-left-radius: .25rem
     }
     .rounded-left {
         border-bottom-left-radius: .25rem;
         border-top-left-radius: .25rem
     }
     .rounded-circle {
         border-radius: 50%
     }
     .clearfix::after {
         content: "";
         display: table;
         clear: both
     }
     .d-block {
         display: block !important
     }
     .d-inline-block {
         display: inline-block !important
     }
     .d-inline {
         display: inline !important
     }
     .flex-xs-first {
         -webkit-box-ordinal-group: 0;
         -ms-flex-order: -1;
         order: -1
     }
     .flex-xs-last {
         -webkit-box-ordinal-group: 2;
         -ms-flex-order: 1;
         order: 1
     }
     .flex-xs-unordered {
         -webkit-box-ordinal-group: 1;
         -ms-flex-order: 0;
         order: 0
     }
     .flex-items-xs-top {
         -webkit-box-align: start;
         -ms-flex-align: start;
         align-items: flex-start
     }
     .flex-items-xs-middle {
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center
     }
     .flex-items-xs-bottom {
         -webkit-box-align: end;
         -ms-flex-align: end;
         align-items: flex-end
     }
     .flex-xs-top {
         -ms-flex-item-align: start;
         align-self: flex-start
     }
     .flex-xs-middle {
         -ms-flex-item-align: center;
         -ms-grid-row-align: center;
         align-self: center
     }
     .flex-xs-bottom {
         -ms-flex-item-align: end;
         align-self: flex-end
     }
     .flex-items-xs-left {
         -webkit-box-pack: start;
         -ms-flex-pack: start;
         justify-content: flex-start
     }
     .flex-items-xs-center {
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center
     }
     .flex-items-xs-right {
         -webkit-box-pack: end;
         -ms-flex-pack: end;
         justify-content: flex-end
     }
     .flex-items-xs-around {
         -ms-flex-pack: distribute;
         justify-content: space-around
     }
     .flex-items-xs-between {
         -webkit-box-pack: justify;
         -ms-flex-pack: justify;
         justify-content: space-between
     }
     @media (min-width: 576px) {
         .flex-sm-first {
             -webkit-box-ordinal-group: 0;
             -ms-flex-order: -1;
             order: -1
         }
         .flex-sm-last {
             -webkit-box-ordinal-group: 2;
             -ms-flex-order: 1;
             order: 1
         }
         .flex-sm-unordered {
             -webkit-box-ordinal-group: 1;
             -ms-flex-order: 0;
             order: 0
         }
     }
     @media (min-width: 576px) {
         .flex-items-sm-top {
             -webkit-box-align: start;
             -ms-flex-align: start;
             align-items: flex-start
         }
         .flex-items-sm-middle {
             -webkit-box-align: center;
             -ms-flex-align: center;
             align-items: center
         }
         .flex-items-sm-bottom {
             -webkit-box-align: end;
             -ms-flex-align: end;
             align-items: flex-end
         }
     }
     @media (min-width: 576px) {
         .flex-sm-top {
             -ms-flex-item-align: start;
             align-self: flex-start
         }
         .flex-sm-middle {
             -ms-flex-item-align: center;
             -ms-grid-row-align: center;
             align-self: center
         }
         .flex-sm-bottom {
             -ms-flex-item-align: end;
             align-self: flex-end
         }
     }
     @media (min-width: 576px) {
         .flex-items-sm-left {
             -webkit-box-pack: start;
             -ms-flex-pack: start;
             justify-content: flex-start
         }
         .flex-items-sm-center {
             -webkit-box-pack: center;
             -ms-flex-pack: center;
             justify-content: center
         }
         .flex-items-sm-right {
             -webkit-box-pack: end;
             -ms-flex-pack: end;
             justify-content: flex-end
         }
         .flex-items-sm-around {
             -ms-flex-pack: distribute;
             justify-content: space-around
         }
         .flex-items-sm-between {
             -webkit-box-pack: justify;
             -ms-flex-pack: justify;
             justify-content: space-between
         }
     }
     @media (min-width: 768px) {
         .flex-md-first {
             -webkit-box-ordinal-group: 0;
             -ms-flex-order: -1;
             order: -1
         }
         .flex-md-last {
             -webkit-box-ordinal-group: 2;
             -ms-flex-order: 1;
             order: 1
         }
         .flex-md-unordered {
             -webkit-box-ordinal-group: 1;
             -ms-flex-order: 0;
             order: 0
         }
     }
     @media (min-width: 768px) {
         .flex-items-md-top {
             -webkit-box-align: start;
             -ms-flex-align: start;
             align-items: flex-start
         }
         .flex-items-md-middle {
             -webkit-box-align: center;
             -ms-flex-align: center;
             align-items: center
         }
         .flex-items-md-bottom {
             -webkit-box-align: end;
             -ms-flex-align: end;
             align-items: flex-end
         }
     }
     @media (min-width: 768px) {
         .flex-md-top {
             -ms-flex-item-align: start;
             align-self: flex-start
         }
         .flex-md-middle {
             -ms-flex-item-align: center;
             -ms-grid-row-align: center;
             align-self: center
         }
         .flex-md-bottom {
             -ms-flex-item-align: end;
             align-self: flex-end
         }
     }
     @media (min-width: 768px) {
         .flex-items-md-left {
             -webkit-box-pack: start;
             -ms-flex-pack: start;
             justify-content: flex-start
         }
         .flex-items-md-center {
             -webkit-box-pack: center;
             -ms-flex-pack: center;
             justify-content: center
         }
         .flex-items-md-right {
             -webkit-box-pack: end;
             -ms-flex-pack: end;
             justify-content: flex-end
         }
         .flex-items-md-around {
             -ms-flex-pack: distribute;
             justify-content: space-around
         }
         .flex-items-md-between {
             -webkit-box-pack: justify;
             -ms-flex-pack: justify;
             justify-content: space-between
         }
     }
     @media (min-width: 992px) {
         .flex-lg-first {
             -webkit-box-ordinal-group: 0;
             -ms-flex-order: -1;
             order: -1
         }
         .flex-lg-last {
             -webkit-box-ordinal-group: 2;
             -ms-flex-order: 1;
             order: 1
         }
         .flex-lg-unordered {
             -webkit-box-ordinal-group: 1;
             -ms-flex-order: 0;
             order: 0
         }
     }
     @media (min-width: 992px) {
         .flex-items-lg-top {
             -webkit-box-align: start;
             -ms-flex-align: start;
             align-items: flex-start
         }
         .flex-items-lg-middle {
             -webkit-box-align: center;
             -ms-flex-align: center;
             align-items: center
         }
         .flex-items-lg-bottom {
             -webkit-box-align: end;
             -ms-flex-align: end;
             align-items: flex-end
         }
     }
     @media (min-width: 992px) {
         .flex-lg-top {
             -ms-flex-item-align: start;
             align-self: flex-start
         }
         .flex-lg-middle {
             -ms-flex-item-align: center;
             -ms-grid-row-align: center;
             align-self: center
         }
         .flex-lg-bottom {
             -ms-flex-item-align: end;
             align-self: flex-end
         }
     }
     @media (min-width: 992px) {
         .flex-items-lg-left {
             -webkit-box-pack: start;
             -ms-flex-pack: start;
             justify-content: flex-start
         }
         .flex-items-lg-center {
             -webkit-box-pack: center;
             -ms-flex-pack: center;
             justify-content: center
         }
         .flex-items-lg-right {
             -webkit-box-pack: end;
             -ms-flex-pack: end;
             justify-content: flex-end
         }
         .flex-items-lg-around {
             -ms-flex-pack: distribute;
             justify-content: space-around
         }
         .flex-items-lg-between {
             -webkit-box-pack: justify;
             -ms-flex-pack: justify;
             justify-content: space-between
         }
     }
     @media (min-width: 1200px) {
         .flex-xl-first {
             -webkit-box-ordinal-group: 0;
             -ms-flex-order: -1;
             order: -1
         }
         .flex-xl-last {
             -webkit-box-ordinal-group: 2;
             -ms-flex-order: 1;
             order: 1
         }
         .flex-xl-unordered {
             -webkit-box-ordinal-group: 1;
             -ms-flex-order: 0;
             order: 0
         }
     }
     @media (min-width: 1200px) {
         .flex-items-xl-top {
             -webkit-box-align: start;
             -ms-flex-align: start;
             align-items: flex-start
         }
         .flex-items-xl-middle {
             -webkit-box-align: center;
             -ms-flex-align: center;
             align-items: center
         }
         .flex-items-xl-bottom {
             -webkit-box-align: end;
             -ms-flex-align: end;
             align-items: flex-end
         }
     }
     @media (min-width: 1200px) {
         .flex-xl-top {
             -ms-flex-item-align: start;
             align-self: flex-start
         }
         .flex-xl-middle {
             -ms-flex-item-align: center;
             -ms-grid-row-align: center;
             align-self: center
         }
         .flex-xl-bottom {
             -ms-flex-item-align: end;
             align-self: flex-end
         }
     }
     @media (min-width: 1200px) {
         .flex-items-xl-left {
             -webkit-box-pack: start;
             -ms-flex-pack: start;
             justify-content: flex-start
         }
         .flex-items-xl-center {
             -webkit-box-pack: center;
             -ms-flex-pack: center;
             justify-content: center
         }
         .flex-items-xl-right {
             -webkit-box-pack: end;
             -ms-flex-pack: end;
             justify-content: flex-end
         }
         .flex-items-xl-around {
             -ms-flex-pack: distribute;
             justify-content: space-around
         }
         .flex-items-xl-between {
             -webkit-box-pack: justify;
             -ms-flex-pack: justify;
             justify-content: space-between
         }
     }
     .float-xs-left {
         float: left !important
     }
     .float-xs-right {
         float: right !important
     }
     .float-xs-none {
         float: none !important
     }
     @media (min-width: 576px) {
         .float-sm-left {
             float: left !important
         }
         .float-sm-right {
             float: right !important
         }
         .float-sm-none {
             float: none !important
         }
     }
     @media (min-width: 768px) {
         .float-md-left {
             float: left !important
         }
         .float-md-right {
             float: right !important
         }
         .float-md-none {
             float: none !important
         }
     }
     @media (min-width: 992px) {
         .float-lg-left {
             float: left !important
         }
         .float-lg-right {
             float: right !important
         }
         .float-lg-none {
             float: none !important
         }
     }
     @media (min-width: 1200px) {
         .float-xl-left {
             float: left !important
         }
         .float-xl-right {
             float: right !important
         }
         .float-xl-none {
             float: none !important
         }
     }
     .sr-only {
         position: absolute;
         width: 1px;
         height: 1px;
         padding: 0;
         margin: -1px;
         overflow: hidden;
         clip: rect(0, 0, 0, 0);
         border: 0
     }
     .sr-only-focusable:active,
     .sr-only-focusable:focus {
         position: static;
         width: auto;
         height: auto;
         margin: 0;
         overflow: visible;
         clip: auto
     }
     .w-100 {
         width: 100% !important
     }
     .h-100 {
         height: 100% !important
     }
     .mx-auto {
         margin-right: auto !important;
         margin-left: auto !important
     }
     .m-0 {
         margin: 0 0 !important
     }
     .mt-0 {
         margin-top: 0 !important
     }
     .mr-0 {
         margin-right: 0 !important
     }
     .mb-0 {
         margin-bottom: 0 !important
     }
     .ml-0 {
         margin-left: 0 !important
     }
     .mx-0 {
         margin-right: 0 !important;
         margin-left: 0 !important
     }
     .my-0 {
         margin-top: 0 !important;
         margin-bottom: 0 !important
     }
     .m-1 {
         margin: 1rem 1rem !important
     }
     .mt-1 {
         margin-top: 1rem !important
     }
     .mr-1 {
         margin-right: 1rem !important
     }
     .mb-1 {
         margin-bottom: 1rem !important
     }
     .ml-1 {
         margin-left: 1rem !important
     }
     .mx-1 {
         margin-right: 1rem !important;
         margin-left: 1rem !important
     }
     .my-1 {
         margin-top: 1rem !important;
         margin-bottom: 1rem !important
     }
     .m-2 {
         margin: 1.5rem 1.5rem !important
     }
     .mt-2 {
         margin-top: 1.5rem !important
     }
     .mr-2 {
         margin-right: 1.5rem !important
     }
     .mb-2 {
         margin-bottom: 1.5rem !important
     }
     .ml-2 {
         margin-left: 1.5rem !important
     }
     .mx-2 {
         margin-right: 1.5rem !important;
         margin-left: 1.5rem !important
     }
     .my-2 {
         margin-top: 1.5rem !important;
         margin-bottom: 1.5rem !important
     }
     .m-3 {
         margin: 3rem 3rem !important
     }
     .mt-3 {
         margin-top: 3rem !important
     }
     .mr-3 {
         margin-right: 3rem !important
     }
     .mb-3 {
         margin-bottom: 3rem !important
     }
     .ml-3 {
         margin-left: 3rem !important
     }
     .mx-3 {
         margin-right: 3rem !important;
         margin-left: 3rem !important
     }
     .my-3 {
         margin-top: 3rem !important;
         margin-bottom: 3rem !important
     }
     .p-0 {
         padding: 0 0 !important
     }
     .pt-0 {
         padding-top: 0 !important
     }
     .pr-0 {
         padding-right: 0 !important
     }
     .pb-0 {
         padding-bottom: 0 !important
     }
     .pl-0 {
         padding-left: 0 !important
     }
     .px-0 {
         padding-right: 0 !important;
         padding-left: 0 !important
     }
     .py-0 {
         padding-top: 0 !important;
         padding-bottom: 0 !important
     }
     .p-1 {
         padding: 1rem 1rem !important
     }
     .pt-1 {
         padding-top: 1rem !important
     }
     .pr-1 {
         padding-right: 1rem !important
     }
     .pb-1 {
         padding-bottom: 1rem !important
     }
     .pl-1 {
         padding-left: 1rem !important
     }
     .px-1 {
         padding-right: 1rem !important;
         padding-left: 1rem !important
     }
     .py-1 {
         padding-top: 1rem !important;
         padding-bottom: 1rem !important
     }
     .p-2 {
         padding: 1.5rem 1.5rem !important
     }
     .pt-2 {
         padding-top: 1.5rem !important
     }
     .pr-2 {
         padding-right: 1.5rem !important
     }
     .pb-2 {
         padding-bottom: 1.5rem !important
     }
     .pl-2 {
         padding-left: 1.5rem !important
     }
     .px-2 {
         padding-right: 1.5rem !important;
         padding-left: 1.5rem !important
     }
     .py-2 {
         padding-top: 1.5rem !important;
         padding-bottom: 1.5rem !important
     }
     .p-3 {
         padding: 3rem 3rem !important
     }
     .pt-3 {
         padding-top: 3rem !important
     }
     .pr-3 {
         padding-right: 3rem !important
     }
     .pb-3 {
         padding-bottom: 3rem !important
     }
     .pl-3 {
         padding-left: 3rem !important
     }
     .px-3 {
         padding-right: 3rem !important;
         padding-left: 3rem !important
     }
     .py-3 {
         padding-top: 3rem !important;
         padding-bottom: 3rem !important
     }
     .pos-f-t {
         position: fixed;
         top: 0;
         right: 0;
         left: 0;
         z-index: 1030
     }
     .text-justify {
         text-align: justify !important
     }
     .text-nowrap {
         white-space: nowrap !important
     }
     .text-truncate {
         overflow: hidden;
         text-overflow: ellipsis;
         white-space: nowrap
     }
     .text-xs-left {
         text-align: left !important
     }
     .text-xs-right {
         text-align: right !important
     }
     .text-xs-center {
         text-align: center !important
     }
     @media (min-width: 576px) {
         .text-sm-left {
             text-align: left !important
         }
         .text-sm-right {
             text-align: right !important
         }
         .text-sm-center {
             text-align: center !important
         }
     }
     @media (min-width: 768px) {
         .text-md-left {
             text-align: left !important
         }
         .text-md-right {
             text-align: right !important
         }
         .text-md-center {
             text-align: center !important
         }
     }
     @media (min-width: 992px) {
         .text-lg-left {
             text-align: left !important
         }
         .text-lg-right {
             text-align: right !important
         }
         .text-lg-center {
             text-align: center !important
         }
     }
     @media (min-width: 1200px) {
         .text-xl-left {
             text-align: left !important
         }
         .text-xl-right {
             text-align: right !important
         }
         .text-xl-center {
             text-align: center !important
         }
     }
     .text-lowercase {
         text-transform: lowercase !important
     }
     .text-uppercase {
         text-transform: uppercase !important
     }
     .text-capitalize {
         text-transform: capitalize !important
     }
     .font-weight-normal {
         font-weight: normal
     }
     .font-weight-bold {
         font-weight: bold
     }
     .font-italic {
         font-style: italic
     }
     .text-white {
         color: #fff !important
     }
     .text-muted {
         color: #818a91 !important
     }
     a.text-muted:focus,
     a.text-muted:hover {
         color: #687077 !important
     }
     .text-primary {
         color: #0275d8 !important
     }
     a.text-primary:focus,
     a.text-primary:hover {
         color: #025aa5 !important
     }
     .text-success {
         color: #5cb85c !important
     }
     a.text-success:focus,
     a.text-success:hover {
         color: #449d44 !important
     }
     .text-info {
         color: #5bc0de !important
     }
     a.text-info:focus,
     a.text-info:hover {
         color: #31b0d5 !important
     }
     .text-warning {
         color: #f0ad4e !important
     }
     a.text-warning:focus,
     a.text-warning:hover {
         color: #ec971f !important
     }
     .text-danger {
         color: #d9534f !important
     }
     a.text-danger:focus,
     a.text-danger:hover {
         color: #c9302c !important
     }
     .text-gray-dark {
         color: #747474 !important
     }
     a.text-gray-dark:focus,
     a.text-gray-dark:hover {
         color: #5b5b5b !important
     }
     .text-hide {
         font: 0/0 a;
         color: transparent;
         text-shadow: none;
         background-color: transparent;
         border: 0
     }
     .invisible {
         visibility: hidden !important
     }
     .hidden-xs-up {
         display: none !important
     }
     @media (max-width: 575px) {
         .hidden-xs-down {
             display: none !important
         }
     }
     @media (min-width: 576px) {
         .hidden-sm-up {
             display: none !important
         }
     }
     @media (max-width: 767px) {
         .hidden-sm-down {
             display: none !important
         }
     }
     @media (min-width: 768px) {
         .hidden-md-up {
             display: none !important
         }
     }
     @media (max-width: 991px) {
         .hidden-md-down {
             display: none !important
         }
     }
     @media (min-width: 992px) {
         .hidden-lg-up {
             display: none !important
         }
     }
     @media (max-width: 1199px) {
         .hidden-lg-down {
             display: none !important
         }
     }
     @media (min-width: 1200px) {
         .hidden-xl-up {
             display: none !important
         }
     }
     .hidden-xl-down {
         display: none !important
     }
     .visible-print-block {
         display: none !important
     }
     @media print {
         .visible-print-block {
             display: block !important
         }
     }
     .visible-print-inline {
         display: none !important
     }
     @media print {
         .visible-print-inline {
             display: inline !important
         }
     }
     .visible-print-inline-block {
         display: none !important
     }
     @media print {
         .visible-print-inline-block {
             display: inline-block !important
         }
     }
     @media print {
         .hidden-print {
             display: none !important
         }
     }
     .img-fluid {
         max-width: 100%;
         height: auto
     }
     .img-thumbnail {
         padding: .25rem;
         background-color: #fff;
         border: 1px solid #ddd;
         border-radius: .25rem;
         transition: all .2s ease-in-out;
         max-width: 100%;
         height: auto
     }
     .figure {
         display: inline-block
     }
     .figure-img {
         margin-bottom: .5rem;
         line-height: 1
     }
     .figure-caption {
         font-size: 90%;
         color: #eee
     }
     .list-group {
         padding-left: 0;
         margin-bottom: 0
     }
     .list-group-item {
         position: relative;
         display: block;
         padding: .75rem 1.25rem;
         margin-bottom: -1px;
         background-color: #fff;
         border: 1px solid #ddd
     }
     .list-group-item:first-child {
         border-top-right-radius: .25rem;
         border-top-left-radius: .25rem
     }
     .list-group-item:last-child {
         margin-bottom: 0;
         border-bottom-right-radius: .25rem;
         border-bottom-left-radius: .25rem
     }
     .list-group-item.disabled,
     .list-group-item.disabled:focus,
     .list-group-item.disabled:hover {
         color: #818a91;
         cursor: not-allowed;
         background-color: #eceeef
     }
     .list-group-item.disabled .list-group-item-heading,
     .list-group-item.disabled:focus .list-group-item-heading,
     .list-group-item.disabled:hover .list-group-item-heading {
         color: inherit
     }
     .list-group-item.disabled .list-group-item-text,
     .list-group-item.disabled:focus .list-group-item-text,
     .list-group-item.disabled:hover .list-group-item-text {
         color: #818a91
     }
     .list-group-item.active,
     .list-group-item.active:focus,
     .list-group-item.active:hover {
         z-index: 2;
         color: #fff;
         text-decoration: none;
         background-color: #0275d8;
         border-color: #0275d8
     }
     .list-group-item.active .list-group-item-heading,
     .list-group-item.active .list-group-item-heading>small,
     .list-group-item.active .list-group-item-heading>.small,
     .list-group-item.active:focus .list-group-item-heading,
     .list-group-item.active:focus .list-group-item-heading>small,
     .list-group-item.active:focus .list-group-item-heading>.small,
     .list-group-item.active:hover .list-group-item-heading,
     .list-group-item.active:hover .list-group-item-heading>small,
     .list-group-item.active:hover .list-group-item-heading>.small {
         color: inherit
     }
     .list-group-item.active .list-group-item-text,
     .list-group-item.active:focus .list-group-item-text,
     .list-group-item.active:hover .list-group-item-text {
         color: #a8d6fe
     }
     .list-group-flush .list-group-item {
         border-right: 0;
         border-left: 0;
         border-radius: 0
     }
     .list-group-item-action {
         width: 100%;
         color: #555;
         text-align: inherit
     }
     .list-group-item-action .list-group-item-heading {
         color: #333
     }
     .list-group-item-action:focus,
     .list-group-item-action:hover {
         color: #555;
         text-decoration: none;
         background-color: #f5f5f5
     }
     .list-group-item-success {
         color: #3c763d;
         background-color: #dff0d8
     }
     a.list-group-item-success,
     button.list-group-item-success {
         color: #3c763d
     }
     a.list-group-item-success .list-group-item-heading,
     button.list-group-item-success .list-group-item-heading {
         color: inherit
     }
     a.list-group-item-success:focus,
     a.list-group-item-success:hover,
     button.list-group-item-success:focus,
     button.list-group-item-success:hover {
         color: #3c763d;
         background-color: #d0e9c6
     }
     a.list-group-item-success.active,
     a.list-group-item-success.active:focus,
     a.list-group-item-success.active:hover,
     button.list-group-item-success.active,
     button.list-group-item-success.active:focus,
     button.list-group-item-success.active:hover {
         color: #fff;
         background-color: #3c763d;
         border-color: #3c763d
     }
     .list-group-item-info {
         color: #31708f;
         background-color: #d9edf7
     }
     a.list-group-item-info,
     button.list-group-item-info {
         color: #31708f
     }
     a.list-group-item-info .list-group-item-heading,
     button.list-group-item-info .list-group-item-heading {
         color: inherit
     }
     a.list-group-item-info:focus,
     a.list-group-item-info:hover,
     button.list-group-item-info:focus,
     button.list-group-item-info:hover {
         color: #31708f;
         background-color: #c4e3f3
     }
     a.list-group-item-info.active,
     a.list-group-item-info.active:focus,
     a.list-group-item-info.active:hover,
     button.list-group-item-info.active,
     button.list-group-item-info.active:focus,
     button.list-group-item-info.active:hover {
         color: #fff;
         background-color: #31708f;
         border-color: #31708f
     }
     .list-group-item-warning {
         color: #8a6d3b;
         background-color: #fcf8e3
     }
     a.list-group-item-warning,
     button.list-group-item-warning {
         color: #8a6d3b
     }
     a.list-group-item-warning .list-group-item-heading,
     button.list-group-item-warning .list-group-item-heading {
         color: inherit
     }
     a.list-group-item-warning:focus,
     a.list-group-item-warning:hover,
     button.list-group-item-warning:focus,
     button.list-group-item-warning:hover {
         color: #8a6d3b;
         background-color: #faf2cc
     }
     a.list-group-item-warning.active,
     a.list-group-item-warning.active:focus,
     a.list-group-item-warning.active:hover,
     button.list-group-item-warning.active,
     button.list-group-item-warning.active:focus,
     button.list-group-item-warning.active:hover {
         color: #fff;
         background-color: #8a6d3b;
         border-color: #8a6d3b
     }
     .list-group-item-danger {
         color: #a94442;
         background-color: #f2dede
     }
     a.list-group-item-danger,
     button.list-group-item-danger {
         color: #a94442
     }
     a.list-group-item-danger .list-group-item-heading,
     button.list-group-item-danger .list-group-item-heading {
         color: inherit
     }
     a.list-group-item-danger:focus,
     a.list-group-item-danger:hover,
     button.list-group-item-danger:focus,
     button.list-group-item-danger:hover {
         color: #a94442;
         background-color: #ebcccc
     }
     a.list-group-item-danger.active,
     a.list-group-item-danger.active:focus,
     a.list-group-item-danger.active:hover,
     button.list-group-item-danger.active,
     button.list-group-item-danger.active:focus,
     button.list-group-item-danger.active:hover {
         color: #fff;
         background-color: #a94442;
         border-color: #a94442
     }
     .list-group-item-heading {
         margin-top: 0;
         margin-bottom: 5px
     }
     .list-group-item-text {
         margin-bottom: 0;
         line-height: 1.3
     }
     .close {
         float: right;
         font-size: 1.5rem;
         font-weight: bold;
         line-height: 1;
         color: #000;
         text-shadow: 0 1px 0 #fff;
         opacity: .2
     }
     .close:focus,
     .close:hover {
         color: #000;
         text-decoration: none;
         cursor: pointer;
         opacity: .5
     }
     button.close {
         padding: 0;
         cursor: pointer;
         background: transparent;
         border: 0;
         -webkit-appearance: none
     }
     .container {
         margin-left: auto;
         margin-right: auto;
         padding-left: 12px;
         padding-right: 12px
     }
     @media (min-width: 576px) {
         .container {
             width: 540px;
             max-width: 100%
         }
     }
     @media (min-width: 768px) {
         .container {
             width: 720px;
             max-width: 100%
         }
     }
     @media (min-width: 992px) {
         .container {
             width: 960px;
             max-width: 100%
         }
     }
     @media (min-width: 1200px) {
         .container {
             width: 1140px;
             max-width: 100%
         }
     }
     .container-fluid {
         margin-left: auto;
         margin-right: auto;
         padding-left: 12px;
         padding-right: 12px
     }
     .row {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -ms-flex-wrap: wrap;
         flex-wrap: wrap;
         margin-right: -12px;
         margin-left: -12px
     }
     @media (min-width: 576px) {
         .row {
             margin-right: -12px;
             margin-left: -12px
         }
     }
     @media (min-width: 768px) {
         .row {
             margin-right: -12px;
             margin-left: -12px
         }
     }
     @media (min-width: 992px) {
         .row {
             margin-right: -12px;
             margin-left: -12px
         }
     }
     @media (min-width: 1200px) {
         .row {
             margin-right: -12px;
             margin-left: -12px
         }
     }
     .col-xs,
     .col-xs-1,
     .col-xs-2,
     .col-xs-3,
     .col-xs-4,
     .col-xs-5,
     .col-xs-6,
     .col-xs-7,
     .col-xs-8,
     .col-xs-9,
     .col-xs-10,
     .col-xs-11,
     .col-xs-12,
     .col-sm,
     .col-sm-1,
     .col-sm-2,
     .col-sm-3,
     .col-sm-4,
     .col-sm-5,
     .col-sm-6,
     .col-sm-7,
     .col-sm-8,
     .col-sm-9,
     .col-sm-10,
     .col-sm-11,
     .col-sm-12,
     .col-md,
     .col-md-1,
     .col-md-2,
     .col-md-3,
     .col-md-4,
     .col-md-5,
     .col-md-6,
     .col-md-7,
     .col-md-8,
     .col-md-9,
     .col-md-10,
     .col-md-11,
     .col-md-12,
     .col-lg,
     .col-lg-1,
     .col-lg-2,
     .col-lg-3,
     .col-lg-4,
     .col-lg-5,
     .col-lg-6,
     .col-lg-7,
     .col-lg-8,
     .col-lg-9,
     .col-lg-10,
     .col-lg-11,
     .col-lg-12,
     .col-xl,
     .col-xl-1,
     .col-xl-2,
     .col-xl-3,
     .col-xl-4,
     .col-xl-5,
     .col-xl-6,
     .col-xl-7,
     .col-xl-8,
     .col-xl-9,
     .col-xl-10,
     .col-xl-11,
     .col-xl-12 {
         position: relative;
         min-height: 1px;
         width: 100%;
         padding-right: 12px;
         padding-left: 12px
     }
     @media (min-width: 576px) {
         .col-xs,
         .col-xs-1,
         .col-xs-2,
         .col-xs-3,
         .col-xs-4,
         .col-xs-5,
         .col-xs-6,
         .col-xs-7,
         .col-xs-8,
         .col-xs-9,
         .col-xs-10,
         .col-xs-11,
         .col-xs-12,
         .col-sm,
         .col-sm-1,
         .col-sm-2,
         .col-sm-3,
         .col-sm-4,
         .col-sm-5,
         .col-sm-6,
         .col-sm-7,
         .col-sm-8,
         .col-sm-9,
         .col-sm-10,
         .col-sm-11,
         .col-sm-12,
         .col-md,
         .col-md-1,
         .col-md-2,
         .col-md-3,
         .col-md-4,
         .col-md-5,
         .col-md-6,
         .col-md-7,
         .col-md-8,
         .col-md-9,
         .col-md-10,
         .col-md-11,
         .col-md-12,
         .col-lg,
         .col-lg-1,
         .col-lg-2,
         .col-lg-3,
         .col-lg-4,
         .col-lg-5,
         .col-lg-6,
         .col-lg-7,
         .col-lg-8,
         .col-lg-9,
         .col-lg-10,
         .col-lg-11,
         .col-lg-12,
         .col-xl,
         .col-xl-1,
         .col-xl-2,
         .col-xl-3,
         .col-xl-4,
         .col-xl-5,
         .col-xl-6,
         .col-xl-7,
         .col-xl-8,
         .col-xl-9,
         .col-xl-10,
         .col-xl-11,
         .col-xl-12 {
             padding-right: 12px;
             padding-left: 12px
         }
     }
     @media (min-width: 768px) {
         .col-xs,
         .col-xs-1,
         .col-xs-2,
         .col-xs-3,
         .col-xs-4,
         .col-xs-5,
         .col-xs-6,
         .col-xs-7,
         .col-xs-8,
         .col-xs-9,
         .col-xs-10,
         .col-xs-11,
         .col-xs-12,
         .col-sm,
         .col-sm-1,
         .col-sm-2,
         .col-sm-3,
         .col-sm-4,
         .col-sm-5,
         .col-sm-6,
         .col-sm-7,
         .col-sm-8,
         .col-sm-9,
         .col-sm-10,
         .col-sm-11,
         .col-sm-12,
         .col-md,
         .col-md-1,
         .col-md-2,
         .col-md-3,
         .col-md-4,
         .col-md-5,
         .col-md-6,
         .col-md-7,
         .col-md-8,
         .col-md-9,
         .col-md-10,
         .col-md-11,
         .col-md-12,
         .col-lg,
         .col-lg-1,
         .col-lg-2,
         .col-lg-3,
         .col-lg-4,
         .col-lg-5,
         .col-lg-6,
         .col-lg-7,
         .col-lg-8,
         .col-lg-9,
         .col-lg-10,
         .col-lg-11,
         .col-lg-12,
         .col-xl,
         .col-xl-1,
         .col-xl-2,
         .col-xl-3,
         .col-xl-4,
         .col-xl-5,
         .col-xl-6,
         .col-xl-7,
         .col-xl-8,
         .col-xl-9,
         .col-xl-10,
         .col-xl-11,
         .col-xl-12 {
             padding-right: 12px;
             padding-left: 12px
         }
     }
     @media (min-width: 992px) {
         .col-xs,
         .col-xs-1,
         .col-xs-2,
         .col-xs-3,
         .col-xs-4,
         .col-xs-5,
         .col-xs-6,
         .col-xs-7,
         .col-xs-8,
         .col-xs-9,
         .col-xs-10,
         .col-xs-11,
         .col-xs-12,
         .col-sm,
         .col-sm-1,
         .col-sm-2,
         .col-sm-3,
         .col-sm-4,
         .col-sm-5,
         .col-sm-6,
         .col-sm-7,
         .col-sm-8,
         .col-sm-9,
         .col-sm-10,
         .col-sm-11,
         .col-sm-12,
         .col-md,
         .col-md-1,
         .col-md-2,
         .col-md-3,
         .col-md-4,
         .col-md-5,
         .col-md-6,
         .col-md-7,
         .col-md-8,
         .col-md-9,
         .col-md-10,
         .col-md-11,
         .col-md-12,
         .col-lg,
         .col-lg-1,
         .col-lg-2,
         .col-lg-3,
         .col-lg-4,
         .col-lg-5,
         .col-lg-6,
         .col-lg-7,
         .col-lg-8,
         .col-lg-9,
         .col-lg-10,
         .col-lg-11,
         .col-lg-12,
         .col-xl,
         .col-xl-1,
         .col-xl-2,
         .col-xl-3,
         .col-xl-4,
         .col-xl-5,
         .col-xl-6,
         .col-xl-7,
         .col-xl-8,
         .col-xl-9,
         .col-xl-10,
         .col-xl-11,
         .col-xl-12 {
             padding-right: 12px;
             padding-left: 12px
         }
     }
     @media (min-width: 1200px) {
         .col-xs,
         .col-xs-1,
         .col-xs-2,
         .col-xs-3,
         .col-xs-4,
         .col-xs-5,
         .col-xs-6,
         .col-xs-7,
         .col-xs-8,
         .col-xs-9,
         .col-xs-10,
         .col-xs-11,
         .col-xs-12,
         .col-sm,
         .col-sm-1,
         .col-sm-2,
         .col-sm-3,
         .col-sm-4,
         .col-sm-5,
         .col-sm-6,
         .col-sm-7,
         .col-sm-8,
         .col-sm-9,
         .col-sm-10,
         .col-sm-11,
         .col-sm-12,
         .col-md,
         .col-md-1,
         .col-md-2,
         .col-md-3,
         .col-md-4,
         .col-md-5,
         .col-md-6,
         .col-md-7,
         .col-md-8,
         .col-md-9,
         .col-md-10,
         .col-md-11,
         .col-md-12,
         .col-lg,
         .col-lg-1,
         .col-lg-2,
         .col-lg-3,
         .col-lg-4,
         .col-lg-5,
         .col-lg-6,
         .col-lg-7,
         .col-lg-8,
         .col-lg-9,
         .col-lg-10,
         .col-lg-11,
         .col-lg-12,
         .col-xl,
         .col-xl-1,
         .col-xl-2,
         .col-xl-3,
         .col-xl-4,
         .col-xl-5,
         .col-xl-6,
         .col-xl-7,
         .col-xl-8,
         .col-xl-9,
         .col-xl-10,
         .col-xl-11,
         .col-xl-12 {
             padding-right: 12px;
             padding-left: 12px
         }
     }
     .col-xs {
         -ms-flex-preferred-size: 0;
         flex-basis: 0;
         -webkit-box-flex: 1;
         -ms-flex-positive: 1;
         flex-grow: 1;
         max-width: 100%
     }
     .col-xs-1 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 8.33333%;
         flex: 0 0 8.33333%;
         max-width: 8.33333%
     }
     .col-xs-2 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 16.66667%;
         flex: 0 0 16.66667%;
         max-width: 16.66667%
     }
     .col-xs-3 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 25%;
         flex: 0 0 25%;
         max-width: 25%
     }
     .col-xs-4 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 33.33333%;
         flex: 0 0 33.33333%;
         max-width: 33.33333%
     }
     .col-xs-5 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 41.66667%;
         flex: 0 0 41.66667%;
         max-width: 41.66667%
     }
     .col-xs-6 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 50%;
         flex: 0 0 50%;
         max-width: 50%
     }
     .col-xs-7 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 58.33333%;
         flex: 0 0 58.33333%;
         max-width: 58.33333%
     }
     .col-xs-8 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 66.66667%;
         flex: 0 0 66.66667%;
         max-width: 66.66667%
     }
     .col-xs-9 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 75%;
         flex: 0 0 75%;
         max-width: 75%
     }
     .col-xs-10 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 83.33333%;
         flex: 0 0 83.33333%;
         max-width: 83.33333%
     }
     .col-xs-11 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 91.66667%;
         flex: 0 0 91.66667%;
         max-width: 91.66667%
     }
     .col-xs-12 {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 100%;
         flex: 0 0 100%;
         max-width: 100%
     }
     .pull-xs-0 {
         right: auto
     }
     .pull-xs-1 {
         right: 8.33333%
     }
     .pull-xs-2 {
         right: 16.66667%
     }
     .pull-xs-3 {
         right: 25%
     }
     .pull-xs-4 {
         right: 33.33333%
     }
     .pull-xs-5 {
         right: 41.66667%
     }
     .pull-xs-6 {
         right: 50%
     }
     .pull-xs-7 {
         right: 58.33333%
     }
     .pull-xs-8 {
         right: 66.66667%
     }
     .pull-xs-9 {
         right: 75%
     }
     .pull-xs-10 {
         right: 83.33333%
     }
     .pull-xs-11 {
         right: 91.66667%
     }
     .pull-xs-12 {
         right: 100%
     }
     .push-xs-0 {
         left: auto
     }
     .push-xs-1 {
         left: 8.33333%
     }
     .push-xs-2 {
         left: 16.66667%
     }
     .push-xs-3 {
         left: 25%
     }
     .push-xs-4 {
         left: 33.33333%
     }
     .push-xs-5 {
         left: 41.66667%
     }
     .push-xs-6 {
         left: 50%
     }
     .push-xs-7 {
         left: 58.33333%
     }
     .push-xs-8 {
         left: 66.66667%
     }
     .push-xs-9 {
         left: 75%
     }
     .push-xs-10 {
         left: 83.33333%
     }
     .push-xs-11 {
         left: 91.66667%
     }
     .push-xs-12 {
         left: 100%
     }
     .offset-xs-1 {
         margin-left: 8.33333%
     }
     .offset-xs-2 {
         margin-left: 16.66667%
     }
     .offset-xs-3 {
         margin-left: 25%
     }
     .offset-xs-4 {
         margin-left: 33.33333%
     }
     .offset-xs-5 {
         margin-left: 41.66667%
     }
     .offset-xs-6 {
         margin-left: 50%
     }
     .offset-xs-7 {
         margin-left: 58.33333%
     }
     .offset-xs-8 {
         margin-left: 66.66667%
     }
     .offset-xs-9 {
         margin-left: 75%
     }
     .offset-xs-10 {
         margin-left: 83.33333%
     }
     .offset-xs-11 {
         margin-left: 91.66667%
     }
     @media (min-width: 576px) {
         .col-sm {
             -ms-flex-preferred-size: 0;
             flex-basis: 0;
             -webkit-box-flex: 1;
             -ms-flex-positive: 1;
             flex-grow: 1;
             max-width: 100%
         }
         .col-sm-1 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 8.33333%;
             flex: 0 0 8.33333%;
             max-width: 8.33333%
         }
         .col-sm-2 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 16.66667%;
             flex: 0 0 16.66667%;
             max-width: 16.66667%
         }
         .col-sm-3 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 25%;
             flex: 0 0 25%;
             max-width: 25%
         }
         .col-sm-4 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 33.33333%;
             flex: 0 0 33.33333%;
             max-width: 33.33333%
         }
         .col-sm-5 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 41.66667%;
             flex: 0 0 41.66667%;
             max-width: 41.66667%
         }
         .col-sm-6 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 50%;
             flex: 0 0 50%;
             max-width: 50%
         }
         .col-sm-7 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 58.33333%;
             flex: 0 0 58.33333%;
             max-width: 58.33333%
         }
         .col-sm-8 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 66.66667%;
             flex: 0 0 66.66667%;
             max-width: 66.66667%
         }
         .col-sm-9 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 75%;
             flex: 0 0 75%;
             max-width: 75%
         }
         .col-sm-10 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 83.33333%;
             flex: 0 0 83.33333%;
             max-width: 83.33333%
         }
         .col-sm-11 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 91.66667%;
             flex: 0 0 91.66667%;
             max-width: 91.66667%
         }
         .col-sm-12 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 100%;
             flex: 0 0 100%;
             max-width: 100%
         }
         .pull-sm-0 {
             right: auto
         }
         .pull-sm-1 {
             right: 8.33333%
         }
         .pull-sm-2 {
             right: 16.66667%
         }
         .pull-sm-3 {
             right: 25%
         }
         .pull-sm-4 {
             right: 33.33333%
         }
         .pull-sm-5 {
             right: 41.66667%
         }
         .pull-sm-6 {
             right: 50%
         }
         .pull-sm-7 {
             right: 58.33333%
         }
         .pull-sm-8 {
             right: 66.66667%
         }
         .pull-sm-9 {
             right: 75%
         }
         .pull-sm-10 {
             right: 83.33333%
         }
         .pull-sm-11 {
             right: 91.66667%
         }
         .pull-sm-12 {
             right: 100%
         }
         .push-sm-0 {
             left: auto
         }
         .push-sm-1 {
             left: 8.33333%
         }
         .push-sm-2 {
             left: 16.66667%
         }
         .push-sm-3 {
             left: 25%
         }
         .push-sm-4 {
             left: 33.33333%
         }
         .push-sm-5 {
             left: 41.66667%
         }
         .push-sm-6 {
             left: 50%
         }
         .push-sm-7 {
             left: 58.33333%
         }
         .push-sm-8 {
             left: 66.66667%
         }
         .push-sm-9 {
             left: 75%
         }
         .push-sm-10 {
             left: 83.33333%
         }
         .push-sm-11 {
             left: 91.66667%
         }
         .push-sm-12 {
             left: 100%
         }
         .offset-sm-0 {
             margin-left: 0%
         }
         .offset-sm-1 {
             margin-left: 8.33333%
         }
         .offset-sm-2 {
             margin-left: 16.66667%
         }
         .offset-sm-3 {
             margin-left: 25%
         }
         .offset-sm-4 {
             margin-left: 33.33333%
         }
         .offset-sm-5 {
             margin-left: 41.66667%
         }
         .offset-sm-6 {
             margin-left: 50%
         }
         .offset-sm-7 {
             margin-left: 58.33333%
         }
         .offset-sm-8 {
             margin-left: 66.66667%
         }
         .offset-sm-9 {
             margin-left: 75%
         }
         .offset-sm-10 {
             margin-left: 83.33333%
         }
         .offset-sm-11 {
             margin-left: 91.66667%
         }
     }
     @media (min-width: 768px) {
         .col-md {
             -ms-flex-preferred-size: 0;
             flex-basis: 0;
             -webkit-box-flex: 1;
             -ms-flex-positive: 1;
             flex-grow: 1;
             max-width: 100%
         }
         .col-md-1 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 8.33333%;
             flex: 0 0 8.33333%;
             max-width: 8.33333%
         }
         .col-md-2 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 16.66667%;
             flex: 0 0 16.66667%;
             max-width: 16.66667%
         }
         .col-md-3 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 25%;
             flex: 0 0 25%;
             max-width: 25%
         }
         .col-md-4 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 33.33333%;
             flex: 0 0 33.33333%;
             max-width: 33.33333%
         }
         .col-md-5 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 41.66667%;
             flex: 0 0 41.66667%;
             max-width: 41.66667%
         }
         .col-md-6 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 50%;
             flex: 0 0 50%;
             max-width: 50%
         }
         .col-md-7 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 58.33333%;
             flex: 0 0 58.33333%;
             max-width: 58.33333%
         }
         .col-md-8 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 66.66667%;
             flex: 0 0 66.66667%;
             max-width: 66.66667%
         }
         .col-md-9 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 75%;
             flex: 0 0 75%;
             max-width: 75%
         }
         .col-md-10 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 83.33333%;
             flex: 0 0 83.33333%;
             max-width: 83.33333%
         }
         .col-md-11 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 91.66667%;
             flex: 0 0 91.66667%;
             max-width: 91.66667%
         }
         .col-md-12 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 100%;
             flex: 0 0 100%;
             max-width: 100%
         }
         .pull-md-0 {
             right: auto
         }
         .pull-md-1 {
             right: 8.33333%
         }
         .pull-md-2 {
             right: 16.66667%
         }
         .pull-md-3 {
             right: 25%
         }
         .pull-md-4 {
             right: 33.33333%
         }
         .pull-md-5 {
             right: 41.66667%
         }
         .pull-md-6 {
             right: 50%
         }
         .pull-md-7 {
             right: 58.33333%
         }
         .pull-md-8 {
             right: 66.66667%
         }
         .pull-md-9 {
             right: 75%
         }
         .pull-md-10 {
             right: 83.33333%
         }
         .pull-md-11 {
             right: 91.66667%
         }
         .pull-md-12 {
             right: 100%
         }
         .push-md-0 {
             left: auto
         }
         .push-md-1 {
             left: 8.33333%
         }
         .push-md-2 {
             left: 16.66667%
         }
         .push-md-3 {
             left: 25%
         }
         .push-md-4 {
             left: 33.33333%
         }
         .push-md-5 {
             left: 41.66667%
         }
         .push-md-6 {
             left: 50%
         }
         .push-md-7 {
             left: 58.33333%
         }
         .push-md-8 {
             left: 66.66667%
         }
         .push-md-9 {
             left: 75%
         }
         .push-md-10 {
             left: 83.33333%
         }
         .push-md-11 {
             left: 91.66667%
         }
         .push-md-12 {
             left: 100%
         }
         .offset-md-0 {
             margin-left: 0%
         }
         .offset-md-1 {
             margin-left: 8.33333%
         }
         .offset-md-2 {
             margin-left: 16.66667%
         }
         .offset-md-3 {
             margin-left: 25%
         }
         .offset-md-4 {
             margin-left: 33.33333%
         }
         .offset-md-5 {
             margin-left: 41.66667%
         }
         .offset-md-6 {
             margin-left: 50%
         }
         .offset-md-7 {
             margin-left: 58.33333%
         }
         .offset-md-8 {
             margin-left: 66.66667%
         }
         .offset-md-9 {
             margin-left: 75%
         }
         .offset-md-10 {
             margin-left: 83.33333%
         }
         .offset-md-11 {
             margin-left: 91.66667%
         }
     }
     @media (min-width: 992px) {
         .col-lg {
             -ms-flex-preferred-size: 0;
             flex-basis: 0;
             -webkit-box-flex: 1;
             -ms-flex-positive: 1;
             flex-grow: 1;
             max-width: 100%
         }
         .col-lg-1 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 8.33333%;
             flex: 0 0 8.33333%;
             max-width: 8.33333%
         }
         .col-lg-2 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 16.66667%;
             flex: 0 0 16.66667%;
             max-width: 16.66667%
         }
         .col-lg-3 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 25%;
             flex: 0 0 25%;
             max-width: 25%
         }
         .col-lg-4 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 33.33333%;
             flex: 0 0 33.33333%;
             max-width: 33.33333%
         }
         .col-lg-5 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 41.66667%;
             flex: 0 0 41.66667%;
             max-width: 41.66667%
         }
         .col-lg-6 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 50%;
             flex: 0 0 50%;
             max-width: 50%
         }
         .col-lg-7 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 58.33333%;
             flex: 0 0 58.33333%;
             max-width: 58.33333%
         }
         .col-lg-8 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 66.66667%;
             flex: 0 0 66.66667%;
             max-width: 66.66667%
         }
         .col-lg-9 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 75%;
             flex: 0 0 75%;
             max-width: 75%
         }
         .col-lg-10 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 83.33333%;
             flex: 0 0 83.33333%;
             max-width: 83.33333%
         }
         .col-lg-11 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 91.66667%;
             flex: 0 0 91.66667%;
             max-width: 91.66667%
         }
         .col-lg-12 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 100%;
             flex: 0 0 100%;
             max-width: 100%
         }
         .pull-lg-0 {
             right: auto
         }
         .pull-lg-1 {
             right: 8.33333%
         }
         .pull-lg-2 {
             right: 16.66667%
         }
         .pull-lg-3 {
             right: 25%
         }
         .pull-lg-4 {
             right: 33.33333%
         }
         .pull-lg-5 {
             right: 41.66667%
         }
         .pull-lg-6 {
             right: 50%
         }
         .pull-lg-7 {
             right: 58.33333%
         }
         .pull-lg-8 {
             right: 66.66667%
         }
         .pull-lg-9 {
             right: 75%
         }
         .pull-lg-10 {
             right: 83.33333%
         }
         .pull-lg-11 {
             right: 91.66667%
         }
         .pull-lg-12 {
             right: 100%
         }
         .push-lg-0 {
             left: auto
         }
         .push-lg-1 {
             left: 8.33333%
         }
         .push-lg-2 {
             left: 16.66667%
         }
         .push-lg-3 {
             left: 25%
         }
         .push-lg-4 {
             left: 33.33333%
         }
         .push-lg-5 {
             left: 41.66667%
         }
         .push-lg-6 {
             left: 50%
         }
         .push-lg-7 {
             left: 58.33333%
         }
         .push-lg-8 {
             left: 66.66667%
         }
         .push-lg-9 {
             left: 75%
         }
         .push-lg-10 {
             left: 83.33333%
         }
         .push-lg-11 {
             left: 91.66667%
         }
         .push-lg-12 {
             left: 100%
         }
         .offset-lg-0 {
             margin-left: 0%
         }
         .offset-lg-1 {
             margin-left: 8.33333%
         }
         .offset-lg-2 {
             margin-left: 16.66667%
         }
         .offset-lg-3 {
             margin-left: 25%
         }
         .offset-lg-4 {
             margin-left: 33.33333%
         }
         .offset-lg-5 {
             margin-left: 41.66667%
         }
         .offset-lg-6 {
             margin-left: 50%
         }
         .offset-lg-7 {
             margin-left: 58.33333%
         }
         .offset-lg-8 {
             margin-left: 66.66667%
         }
         .offset-lg-9 {
             margin-left: 75%
         }
         .offset-lg-10 {
             margin-left: 83.33333%
         }
         .offset-lg-11 {
             margin-left: 91.66667%
         }
     }
     @media (min-width: 1200px) {
         .col-xl {
             -ms-flex-preferred-size: 0;
             flex-basis: 0;
             -webkit-box-flex: 1;
             -ms-flex-positive: 1;
             flex-grow: 1;
             max-width: 100%
         }
         .col-xl-1 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 8.33333%;
             flex: 0 0 8.33333%;
             max-width: 8.33333%
         }
         .col-xl-2 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 16.66667%;
             flex: 0 0 16.66667%;
             max-width: 16.66667%
         }
         .col-xl-3 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 25%;
             flex: 0 0 25%;
             max-width: 25%
         }
         .col-xl-4 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 33.33333%;
             flex: 0 0 33.33333%;
             max-width: 33.33333%
         }
         .col-xl-5 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 41.66667%;
             flex: 0 0 41.66667%;
             max-width: 41.66667%
         }
         .col-xl-6 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 50%;
             flex: 0 0 50%;
             max-width: 50%
         }
         .col-xl-7 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 58.33333%;
             flex: 0 0 58.33333%;
             max-width: 58.33333%
         }
         .col-xl-8 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 66.66667%;
             flex: 0 0 66.66667%;
             max-width: 66.66667%
         }
         .col-xl-9 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 75%;
             flex: 0 0 75%;
             max-width: 75%
         }
         .col-xl-10 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 83.33333%;
             flex: 0 0 83.33333%;
             max-width: 83.33333%
         }
         .col-xl-11 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 91.66667%;
             flex: 0 0 91.66667%;
             max-width: 91.66667%
         }
         .col-xl-12 {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 100%;
             flex: 0 0 100%;
             max-width: 100%
         }
         .pull-xl-0 {
             right: auto
         }
         .pull-xl-1 {
             right: 8.33333%
         }
         .pull-xl-2 {
             right: 16.66667%
         }
         .pull-xl-3 {
             right: 25%
         }
         .pull-xl-4 {
             right: 33.33333%
         }
         .pull-xl-5 {
             right: 41.66667%
         }
         .pull-xl-6 {
             right: 50%
         }
         .pull-xl-7 {
             right: 58.33333%
         }
         .pull-xl-8 {
             right: 66.66667%
         }
         .pull-xl-9 {
             right: 75%
         }
         .pull-xl-10 {
             right: 83.33333%
         }
         .pull-xl-11 {
             right: 91.66667%
         }
         .pull-xl-12 {
             right: 100%
         }
         .push-xl-0 {
             left: auto
         }
         .push-xl-1 {
             left: 8.33333%
         }
         .push-xl-2 {
             left: 16.66667%
         }
         .push-xl-3 {
             left: 25%
         }
         .push-xl-4 {
             left: 33.33333%
         }
         .push-xl-5 {
             left: 41.66667%
         }
         .push-xl-6 {
             left: 50%
         }
         .push-xl-7 {
             left: 58.33333%
         }
         .push-xl-8 {
             left: 66.66667%
         }
         .push-xl-9 {
             left: 75%
         }
         .push-xl-10 {
             left: 83.33333%
         }
         .push-xl-11 {
             left: 91.66667%
         }
         .push-xl-12 {
             left: 100%
         }
         .offset-xl-0 {
             margin-left: 0%
         }
         .offset-xl-1 {
             margin-left: 8.33333%
         }
         .offset-xl-2 {
             margin-left: 16.66667%
         }
         .offset-xl-3 {
             margin-left: 25%
         }
         .offset-xl-4 {
             margin-left: 33.33333%
         }
         .offset-xl-5 {
             margin-left: 41.66667%
         }
         .offset-xl-6 {
             margin-left: 50%
         }
         .offset-xl-7 {
             margin-left: 58.33333%
         }
         .offset-xl-8 {
             margin-left: 66.66667%
         }
         .offset-xl-9 {
             margin-left: 75%
         }
         .offset-xl-10 {
             margin-left: 83.33333%
         }
         .offset-xl-11 {
             margin-left: 91.66667%
         }
     }
     .embed-responsive {
         position: relative;
         display: block;
         height: 0;
         padding: 0;
         overflow: hidden
     }
     .embed-responsive .embed-responsive-item,
     .embed-responsive iframe,
     .embed-responsive embed,
     .embed-responsive object,
     .embed-responsive video {
         position: absolute;
         top: 0;
         bottom: 0;
         left: 0;
         width: 100%;
         height: 100%;
         border: 0
     }
     .embed-responsive-21by9 {
         padding-bottom: 42.85714%
     }
     .embed-responsive-16by9 {
         padding-bottom: 56.25%
     }
     .embed-responsive-4by3 {
         padding-bottom: 75%
     }
     .embed-responsive-1by1 {
         padding-bottom: 100%
     }
     html {
         box-sizing: border-box
     }
     *,
     *::before,
     *::after {
         box-sizing: inherit
     }
     @-ms-viewport {
         width: device-width
     }
     html {
         -ms-overflow-style: scrollbar;
         -webkit-tap-highlight-color: transparent
     }
     [tabindex="-1"]:focus {
         outline: none !important
     }
     img {
         vertical-align: middle
     }
     [role="button"] {
         cursor: pointer
     }
     a,
     area,
     button,
     [role="button"],
     input,
     label,
     select,
     summary,
     textarea {
         -ms-touch-action: manipulation;
         touch-action: manipulation
     }
     button:focus {
         outline: 1px dotted;
         outline: 5px auto -webkit-focus-ring-color
     }
     input,
     button,
     select,
     textarea {
         border-radius: 0
     }
     input[type="radio"]:disabled,
     input[type="checkbox"]:disabled {
         cursor: not-allowed
     }
     input[type="date"],
     input[type="time"],
     input[type="datetime-local"],
     input[type="month"] {
         -webkit-appearance: listbox
     }
     textarea {
         resize: vertical
     }
     fieldset {
         min-width: 0;
         padding: 0;
         margin: 0;
         border: 0
     }
     legend {
         display: block;
         width: 100%;
         padding: 0;
         line-height: inherit
     }
     input[type="search"] {
         -webkit-appearance: none
     }
     [hidden] {
         display: none !important
     }
     dl {
         margin-bottom: 0;
         margin-top: 24px
     }
     table {
         border-spacing: 0
     }
     a:link {
         color: #007cbb;
         text-decoration: none
     }
     a:hover {
         color: #007cbb;
         text-decoration: underline
     }
     a:active {
         color: #9460b8;
         text-decoration: underline
     }
     a:visited {
         color: #5659b9;
         text-decoration: none
     }
     .alert-icon,
     .clr-icon {
         display: inline-block;
         height: 16px;
         width: 16px;
         padding: 0;
         background-repeat: no-repeat;
         background-size: contain;
         vertical-align: middle
     }
     .alert-icon.clr-icon-warning,
     .alert-icon.icon-warning,
     .clr-icon.clr-icon-warning,
     .clr-icon.icon-warning {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20version%3D%221.1%22%20viewBox%3D%225%205%2026%2026%22%20preserveAspectRatio%3D%22xMidYMid%20meet%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%3E%3Cdefs%3E%3Cstyle%20type%3D%22text%2Fcss%22%3E%0A%09.clr-i-outline%7Bfill-rule%3Aevenodd%3Bclip-rule%3Aevenodd%3Bfill%3A%23747474%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Ctitle%3Eexclamation-triangle-line%3C%2Ftitle%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20class%3D%22clr-i-outline%20clr-i-outline-path-1%22%20d%3D%22M18%2C21.32a1.3%2C1.3%2C0%2C0%2C0%2C1.3-1.3V14a1.3%2C1.3%2C0%2C1%2C0-2.6%2C0v6A1.3%2C1.3%2C0%2C0%2C0%2C18%2C21.32Z%22%3E%3C%2Fpath%3E%3Ccircle%20class%3D%22clr-i-outline%20clr-i-outline-path-2%22%20cx%3D%2217.95%22%20cy%3D%2224.27%22%20r%3D%221.5%22%3E%3C%2Fcircle%3E%3Cpath%20class%3D%22clr-i-outline%20clr-i-outline-path-3%22%20d%3D%22M30.33%2C25.54%2C20.59%2C7.6a3%2C3%2C0%2C0%2C0-5.27%2C0L5.57%2C25.54A3%2C3%2C0%2C0%2C0%2C8.21%2C30H27.69a3%2C3%2C0%2C0%2C0%2C2.64-4.43Zm-1.78%2C1.94a1%2C1%2C0%2C0%2C1-.86.49H8.21a1%2C1%2C0%2C0%2C1-.88-1.48L17.07%2C8.55a1%2C1%2C0%2C0%2C1%2C1.76%2C0l9.74%2C17.94A1%2C1%2C0%2C0%2C1%2C28.55%2C27.48Z%22%3E%3C%2Fpath%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fsvg%3E")
     }
     .alert-icon.clr-icon-warning-white,
     .clr-icon.clr-icon-warning-white {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20version%3D%221.1%22%20viewBox%3D%225%205%2026%2026%22%20preserveAspectRatio%3D%22xMidYMid%20meet%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%3E%3Cdefs%3E%3Cstyle%20type%3D%22text%2Fcss%22%3E%0A%09.clr-i-outline%7Bfill-rule%3Aevenodd%3Bclip-rule%3Aevenodd%3Bfill%3A%23fff%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Ctitle%3Eexclamation-triangle-line%3C%2Ftitle%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20class%3D%22clr-i-outline%20clr-i-outline-path-1%22%20d%3D%22M18%2C21.32a1.3%2C1.3%2C0%2C0%2C0%2C1.3-1.3V14a1.3%2C1.3%2C0%2C1%2C0-2.6%2C0v6A1.3%2C1.3%2C0%2C0%2C0%2C18%2C21.32Z%22%3E%3C%2Fpath%3E%3Ccircle%20class%3D%22clr-i-outline%20clr-i-outline-path-2%22%20cx%3D%2217.95%22%20cy%3D%2224.27%22%20r%3D%221.5%22%3E%3C%2Fcircle%3E%3Cpath%20class%3D%22clr-i-outline%20clr-i-outline-path-3%22%20d%3D%22M30.33%2C25.54%2C20.59%2C7.6a3%2C3%2C0%2C0%2C0-5.27%2C0L5.57%2C25.54A3%2C3%2C0%2C0%2C0%2C8.21%2C30H27.69a3%2C3%2C0%2C0%2C0%2C2.64-4.43Zm-1.78%2C1.94a1%2C1%2C0%2C0%2C1-.86.49H8.21a1%2C1%2C0%2C0%2C1-.88-1.48L17.07%2C8.55a1%2C1%2C0%2C0%2C1%2C1.76%2C0l9.74%2C17.94A1%2C1%2C0%2C0%2C1%2C28.55%2C27.48Z%22%3E%3C%2Fpath%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fsvg%3E")
     }
     .alert-icon.clr-vmw-logo,
     .clr-icon.clr-vmw-logo {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20viewBox%3D%220%200%2036%2036%22%20version%3D%221.1%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%3E%0A%20%20%20%20%3Ctitle%3Evm%20bug%3C%2Ftitle%3E%0A%20%20%20%20%3Cdefs%3E%3C%2Fdefs%3E%0A%20%20%20%20%3Cg%20id%3D%22Headers%22%20stroke%3D%22none%22%20stroke-width%3D%221%22%20fill%3D%22none%22%20fill-rule%3D%22evenodd%22%3E%0A%20%20%20%20%20%20%20%20%3Cg%20id%3D%22CL-Headers-Specs%22%20transform%3D%22translate(-262.000000%2C%20-175.000000)%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cg%20id%3D%2201%22%20transform%3D%22translate(238.000000%2C%20163.000000)%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cg%20id%3D%22vm-bug%22%20transform%3D%22translate(24.703125%2C%2012.000000)%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20id%3D%22Rectangle-42%22%20fill-opacity%3D%220.25%22%20fill%3D%22%23DDDDDD%22%20opacity%3D%220.6%22%20x%3D%220%22%20y%3D%220%22%20width%3D%2236%22%20height%3D%2236%22%20rx%3D%223%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20d%3D%22M7.63948376%2C13.8762402%20C7.32265324%2C13.2097082%206.53978152%2C12.9085139%205.80923042%2C13.219934%20C5.07771043%2C13.5322837%204.80932495%2C14.3103691%205.13972007%2C14.9769011%20L8.20725954%2C21.3744923%20C8.68977207%2C22.3784735%209.19844491%2C22.9037044%2010.1528121%2C22.9037044%20C11.1720955%2C22.9037044%2011.6168209%2C22.3310633%2012.0983646%2C21.3744923%20C12.0983646%2C21.3744923%2014.7744682%2C15.7847341%2014.8015974%2C15.7261685%20C14.8287266%2C15.6666733%2014.9149588%2C15.4863286%2015.1872199%2C15.4872582%20C15.4178182%2C15.490047%2015.6106294%2C15.6657437%2015.6106294%2C15.9018652%20L15.6106294%2C21.3698443%20C15.6106294%2C22.212073%2016.0979865%2C22.9037044%2017.0349134%2C22.9037044%20C17.9718403%2C22.9037044%2018.4785754%2C22.212073%2018.4785754%2C21.3698443%20L18.4785754%2C16.8965503%20C18.4785754%2C16.0338702%2019.1219254%2C15.4742436%2020.0007183%2C15.4742436%20C20.8785423%2C15.4742436%2021.4637583%2C16.0524624%2021.4637583%2C16.8965503%20L21.4637583%2C21.3698443%20C21.4637583%2C22.212073%2021.9520842%2C22.9037044%2022.8880423%2C22.9037044%20C23.8240003%2C22.9037044%2024.3326731%2C22.212073%2024.3326731%2C21.3698443%20L24.3326731%2C16.8965503%20C24.3326731%2C16.0338702%2024.9750543%2C15.4742436%2025.8538472%2C15.4742436%20C26.7307023%2C15.4742436%2027.3168871%2C16.0524624%2027.3168871%2C16.8965503%20L27.3168871%2C21.3698443%20C27.3168871%2C22.212073%2027.8052131%2C22.9037044%2028.74214%2C22.9037044%20C29.6771291%2C22.9037044%2030.1848331%2C22.212073%2030.1848331%2C21.3698443%20L30.1848331%2C16.2783582%20C30.1848331%2C14.4070488%2028.6181207%2C13.0962956%2026.7307023%2C13.0962956%20C24.8452216%2C13.0962956%2023.6651006%2C14.3475536%2023.6651006%2C14.3475536%20C23.037253%2C13.5666793%2022.1720247%2C13.0972252%2020.7089847%2C13.0972252%20C19.164557%2C13.0972252%2017.8129406%2C14.3475536%2017.8129406%2C14.3475536%20C17.1841241%2C13.5666793%2016.1154267%2C13.0972252%2015.2308204%2C13.0972252%20C13.8617638%2C13.0972252%2012.7746572%2C13.675444%2012.1119292%2C15.1302871%20L10.1528121%2C19.5608189%20L7.63948376%2C13.8762402%22%20id%3D%22Fill-4%22%20fill%3D%22%23FFFFFF%22%3E%3C%2Fpath%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fg%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fg%3E%0A%20%20%20%20%20%20%20%20%3C%2Fg%3E%0A%20%20%20%20%3C%2Fg%3E%0A%3C%2Fsvg%3E")
     }
     h1 {
         color: #000;
         font-weight: 200;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 32px;
         letter-spacing: normal;
         line-height: 48px;
         margin-top: 24px;
         margin-bottom: 0
     }
     h2 {
         color: #000;
         font-weight: 200;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 28px;
         letter-spacing: normal;
         line-height: 48px;
         margin-top: 24px;
         margin-bottom: 0
     }
     h3 {
         color: #000;
         font-weight: 200;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 22px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     h4 {
         color: #000;
         font-weight: 200;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 18px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     h5 {
         font-weight: 400;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 16px;
         letter-spacing: .01em;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     h6 {
         font-weight: 500;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 14px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0;
         color: #313131
     }
     body {
         font-weight: 400;
         font-size: 14px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         margin-top: 0 !important
     }
     body p {
         font-weight: 400;
         font-size: 14px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     body .p0,
     body p.p0 {
         font-weight: 200;
         font-size: 20px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     body .p2,
     body p.p2 {
         font-weight: 500;
         font-size: 13px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     body .p3,
     body p.p3 {
         font-weight: 400;
         font-size: 13px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     body .p4,
     body p.p4 {
         font-weight: 600;
         font-size: 12px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     body .p5,
     body p.p5 {
         font-weight: 400;
         font-size: 12px;
         letter-spacing: normal;
         line-height: 24px;
         margin-top: 24px;
         margin-bottom: 0
     }
     body .p6,
     body p.p6 {
         font-weight: 600;
         font-size: 11px;
         letter-spacing: .03em;
         line-height: 12px;
         margin-top: 24px;
         margin-bottom: 0
     }
     body .p7,
     body p.p7 {
         font-weight: 400;
         font-size: 11px;
         letter-spacing: .03em;
         line-height: 12px;
         margin-top: 24px;
         margin-bottom: 0
     }
     body .p8,
     body p.p8 {
         font-weight: 400;
         font-size: 10px;
         letter-spacing: .03em;
         line-height: 12px;
         margin-top: 24px;
         margin-bottom: 0
     }
     .text-light {
         font-weight: 200
     }
     .text-right {
         text-align: right !important
     }
     .text-center {
         text-align: center !important
     }
     .text-left {
         text-align: left !important
     }
     .text-justify {
         text-align: justify !important
     }
     html {
         color: #565656;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 14px
     }
     .btn {
         cursor: pointer;
         display: inline-block;
         -webkit-appearance: none !important;
         border-radius: 3px;
         border: 1px solid;
         min-width: 72px;
         max-width: 360px;
         white-space: nowrap;
         text-overflow: ellipsis;
         overflow: hidden;
         text-align: center;
         text-decoration: none;
         text-transform: uppercase;
         vertical-align: middle;
         line-height: 36px;
         letter-spacing: .12em;
         font-size: 12px;
         font-weight: 500;
         height: 36px;
         padding: 0 12px;
         border-color: #007cbb;
         background-color: transparent;
         color: #007cbb
     }
     .btn:hover {
         text-decoration: none
     }
     .btn:visited {
         color: #007cbb
     }
     .btn:hover {
         background-color: #e1f1f6;
         color: #004a70
     }
     .btn:active {
         box-shadow: 0 1px 0 0 #0094d2 inset
     }
     .btn.disabled,
     .btn:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: transparent;
         border-color: #747474;
         opacity: 0.4
     }
     .btn-group>.btn clr-icon,
     .btn clr-icon {
         -webkit-transform: translate3d(0px, -2px, 0);
         transform: translate3d(0px, -2px, 0)
     }
     .btn.btn-secondary,
     .btn.btn-info,
     .btn.btn-outline,
     .btn.btn-primary-outline,
     .btn.btn-secondary-outline,
     .btn.btn-outline-primary,
     .btn.btn-outline-secondary,
     .btn.btn-info-outline,
     .btn-secondary .btn,
     .btn-info .btn,
     .btn-outline .btn,
     .btn-primary-outline .btn,
     .btn-secondary-outline .btn,
     .btn-outline-primary .btn,
     .btn-outline-secondary .btn,
     .btn-info-outline .btn,
     .btn-outline-info .btn {
         border-color: #007cbb;
         background-color: transparent;
         color: #007cbb
     }
     .btn.btn-secondary:visited,
     .btn.btn-info:visited,
     .btn.btn-outline:visited,
     .btn.btn-primary-outline:visited,
     .btn.btn-secondary-outline:visited,
     .btn.btn-outline-primary:visited,
     .btn.btn-outline-secondary:visited,
     .btn.btn-info-outline:visited,
     .btn-secondary .btn:visited,
     .btn-info .btn:visited,
     .btn-outline .btn:visited,
     .btn-primary-outline .btn:visited,
     .btn-secondary-outline .btn:visited,
     .btn-outline-primary .btn:visited,
     .btn-outline-secondary .btn:visited,
     .btn-info-outline .btn:visited,
     .btn-outline-info .btn:visited {
         color: #007cbb
     }
     .btn.btn-secondary:hover,
     .btn.btn-info:hover,
     .btn.btn-outline:hover,
     .btn.btn-primary-outline:hover,
     .btn.btn-secondary-outline:hover,
     .btn.btn-outline-primary:hover,
     .btn.btn-outline-secondary:hover,
     .btn.btn-info-outline:hover,
     .btn-secondary .btn:hover,
     .btn-info .btn:hover,
     .btn-outline .btn:hover,
     .btn-primary-outline .btn:hover,
     .btn-secondary-outline .btn:hover,
     .btn-outline-primary .btn:hover,
     .btn-outline-secondary .btn:hover,
     .btn-info-outline .btn:hover,
     .btn-outline-info .btn:hover {
         background-color: #e1f1f6;
         color: #004a70
     }
     .btn.btn-secondary:active,
     .btn.btn-info:active,
     .btn.btn-outline:active,
     .btn.btn-primary-outline:active,
     .btn.btn-secondary-outline:active,
     .btn.btn-outline-primary:active,
     .btn.btn-outline-secondary:active,
     .btn.btn-info-outline:active,
     .btn-secondary .btn:active,
     .btn-info .btn:active,
     .btn-outline .btn:active,
     .btn-primary-outline .btn:active,
     .btn-secondary-outline .btn:active,
     .btn-outline-primary .btn:active,
     .btn-outline-secondary .btn:active,
     .btn-info-outline .btn:active,
     .btn-outline-info .btn:active {
         box-shadow: 0 1px 0 0 #0094d2 inset
     }
     .btn.btn-secondary.disabled,
     .btn.btn-secondary:disabled,
     .btn.btn-info.disabled,
     .btn.btn-info:disabled,
     .btn.btn-outline.disabled,
     .btn.btn-outline:disabled,
     .btn.btn-primary-outline.disabled,
     .btn.btn-primary-outline:disabled,
     .btn.btn-secondary-outline.disabled,
     .btn.btn-secondary-outline:disabled,
     .btn.btn-outline-primary.disabled,
     .btn.btn-outline-primary:disabled,
     .btn.btn-outline-secondary.disabled,
     .btn.btn-outline-secondary:disabled,
     .btn.btn-info-outline.disabled,
     .btn.btn-info-outline:disabled,
     .btn-secondary .btn.disabled,
     .btn-secondary .btn:disabled,
     .btn-info .btn.disabled,
     .btn-info .btn:disabled,
     .btn-outline .btn.disabled,
     .btn-outline .btn:disabled,
     .btn-primary-outline .btn.disabled,
     .btn-primary-outline .btn:disabled,
     .btn-secondary-outline .btn.disabled,
     .btn-secondary-outline .btn:disabled,
     .btn-outline-primary .btn.disabled,
     .btn-outline-primary .btn:disabled,
     .btn-outline-secondary .btn.disabled,
     .btn-outline-secondary .btn:disabled,
     .btn-info-outline .btn.disabled,
     .btn-info-outline .btn:disabled,
     .btn-outline-info .btn.disabled,
     .btn-outline-info .btn:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: transparent;
         border-color: #747474;
         opacity: 0.4
     }
     .btn.btn-primary,
     .btn-primary .btn {
         border-color: #007cbb;
         background-color: #007cbb;
         color: #fff
     }
     .btn.btn-primary:visited,
     .btn-primary .btn:visited {
         color: #fff
     }
     .btn.btn-primary:hover,
     .btn-primary .btn:hover {
         background-color: #004a70;
         color: #fff
     }
     .btn.btn-primary:active,
     .btn-primary .btn:active {
         box-shadow: 0 2px 0 0 #002538 inset
     }
     .btn.btn-primary.disabled,
     .btn.btn-primary:disabled,
     .btn-primary .btn.disabled,
     .btn-primary .btn:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: #ccc;
         border-color: #ccc;
         opacity: 0.4
     }
     .btn.btn-success,
     .btn-success .btn {
         border-color: #62a420;
         background-color: #62a420;
         color: #fff
     }
     .btn.btn-success:visited,
     .btn-success .btn:visited {
         color: #fff
     }
     .btn.btn-success:hover,
     .btn-success .btn:hover {
         background-color: #266900;
         color: #fff
     }
     .btn.btn-success:active,
     .btn-success .btn:active {
         box-shadow: 0 2px 0 0 #1d5100 inset
     }
     .btn.btn-success.disabled,
     .btn.btn-success:disabled,
     .btn-success .btn.disabled,
     .btn-success .btn:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: #ccc;
         border-color: #ccc;
         opacity: 0.4
     }
     .btn.btn-danger,
     .btn.btn-warning,
     .btn-danger .btn,
     .btn-warning .btn {
         border-color: #e62700;
         background-color: #e62700;
         color: #fff
     }
     .btn.btn-danger:visited,
     .btn.btn-warning:visited,
     .btn-danger .btn:visited,
     .btn-warning .btn:visited {
         color: #fff
     }
     .btn.btn-danger:hover,
     .btn.btn-warning:hover,
     .btn-danger .btn:hover,
     .btn-warning .btn:hover {
         background-color: #c92100;
         color: #fff
     }
     .btn.btn-danger:active,
     .btn.btn-warning:active,
     .btn-danger .btn:active,
     .btn-warning .btn:active {
         box-shadow: 0 2px 0 0 #a32100 inset
     }
     .btn.btn-danger.disabled,
     .btn.btn-danger:disabled,
     .btn.btn-warning.disabled,
     .btn.btn-warning:disabled,
     .btn-danger .btn.disabled,
     .btn-danger .btn:disabled,
     .btn-warning .btn.disabled,
     .btn-warning .btn:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: #ccc;
         border-color: #ccc;
         opacity: 0.4
     }
     .btn.btn-success-outline,
     .btn.btn-outline-success,
     .btn-success-outline .btn,
     .btn-outline-success .btn {
         border-color: #266900;
         background-color: transparent;
         color: #318700
     }
     .btn.btn-success-outline:visited,
     .btn.btn-outline-success:visited,
     .btn-success-outline .btn:visited,
     .btn-outline-success .btn:visited {
         color: #318700
     }
     .btn.btn-success-outline:hover,
     .btn.btn-outline-success:hover,
     .btn-success-outline .btn:hover,
     .btn-outline-success .btn:hover {
         background-color: #dff0d0;
         color: #1d5100
     }
     .btn.btn-success-outline:active,
     .btn.btn-outline-success:active,
     .btn-success-outline .btn:active,
     .btn-outline-success .btn:active {
         box-shadow: 0 1px 0 0 #60b515 inset
     }
     .btn.btn-success-outline.disabled,
     .btn.btn-success-outline:disabled,
     .btn.btn-outline-success.disabled,
     .btn.btn-outline-success:disabled,
     .btn-success-outline .btn.disabled,
     .btn-success-outline .btn:disabled,
     .btn-outline-success .btn.disabled,
     .btn-outline-success .btn:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: transparent;
         border-color: #747474;
         opacity: 0.4
     }
     .btn.btn-danger-outline,
     .btn.btn-outline-danger,
     .btn.btn-warning-outline,
     .btn.btn-outline-warning,
     .btn-danger-outline .btn,
     .btn-outline-danger .btn,
     .btn-warning-outline .btn,
     .btn-outline-warning .btn {
         border-color: #c92100;
         background-color: transparent;
         color: #e62700
     }
     .btn.btn-danger-outline:visited,
     .btn.btn-outline-danger:visited,
     .btn.btn-warning-outline:visited,
     .btn.btn-outline-warning:visited,
     .btn-danger-outline .btn:visited,
     .btn-outline-danger .btn:visited,
     .btn-warning-outline .btn:visited,
     .btn-outline-warning .btn:visited {
         color: #e62700
     }
     .btn.btn-danger-outline:hover,
     .btn.btn-outline-danger:hover,
     .btn.btn-warning-outline:hover,
     .btn.btn-outline-warning:hover,
     .btn-danger-outline .btn:hover,
     .btn-outline-danger .btn:hover,
     .btn-warning-outline .btn:hover,
     .btn-outline-warning .btn:hover {
         background-color: #f5dbd9;
         color: #a32100
     }
     .btn.btn-danger-outline:active,
     .btn.btn-outline-danger:active,
     .btn.btn-warning-outline:active,
     .btn.btn-outline-warning:active,
     .btn-danger-outline .btn:active,
     .btn-outline-danger .btn:active,
     .btn-warning-outline .btn:active,
     .btn-outline-warning .btn:active {
         box-shadow: 0 1px 0 0 #ebafa6 inset
     }
     .btn.btn-danger-outline.disabled,
     .btn.btn-danger-outline:disabled,
     .btn.btn-outline-danger.disabled,
     .btn.btn-outline-danger:disabled,
     .btn.btn-warning-outline.disabled,
     .btn.btn-warning-outline:disabled,
     .btn.btn-outline-warning.disabled,
     .btn.btn-outline-warning:disabled,
     .btn-danger-outline .btn.disabled,
     .btn-danger-outline .btn:disabled,
     .btn-outline-danger .btn.disabled,
     .btn-outline-danger .btn:disabled,
     .btn-warning-outline .btn.disabled,
     .btn-warning-outline .btn:disabled,
     .btn-outline-warning .btn.disabled,
     .btn-outline-warning .btn:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: transparent;
         border-color: #747474;
         opacity: 0.4
     }
     .btn.btn-link,
     .btn-link .btn {
         border-color: transparent;
         background-color: transparent;
         color: #007cbb
     }
     .btn.btn-link:visited,
     .btn-link .btn:visited {
         color: #007cbb
     }
     .btn.btn-link:hover,
     .btn-link .btn:hover {
         background-color: transparent;
         color: #004a70
     }
     .btn.btn-link:active,
     .btn-link .btn:active {
         box-shadow: 0 0 0 0 transparent inset
     }
     .btn.btn-link.disabled,
     .btn.btn-link:disabled,
     .btn-link .btn.disabled,
     .btn-link .btn:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: transparent;
         border-color: transparent;
         opacity: 0.4
     }
     .btn.btn-inverse,
     .alert-app-level .alert-item .btn,
     .btn-inverse .btn,
     .alert-app-level .alert-item .btn .btn {
         border-color: #fff;
         background-color: transparent;
         color: #fff
     }
     .btn.btn-inverse:visited,
     .alert-app-level .alert-item .btn:visited,
     .btn-inverse .btn:visited,
     .alert-app-level .alert-item .btn .btn:visited {
         color: #fff
     }
     .btn.btn-inverse:hover,
     .alert-app-level .alert-item .btn:hover,
     .btn-inverse .btn:hover,
     .alert-app-level .alert-item .btn .btn:hover {
         background-color: rgba(255, 255, 255, 0.15);
         color: #fff
     }
     .btn.btn-inverse:active,
     .alert-app-level .alert-item .btn:active,
     .btn-inverse .btn:active,
     .alert-app-level .alert-item .btn .btn:active {
         box-shadow: 0 1px 0 0 rgba(0, 0, 0, 0.25) inset
     }
     .btn.btn-inverse.disabled,
     .alert-app-level .alert-item .btn.disabled,
     .btn.btn-inverse:disabled,
     .alert-app-level .alert-item .btn:disabled,
     .btn-inverse .btn.disabled,
     .alert-app-level .alert-item .btn .btn.disabled,
     .btn-inverse .btn:disabled,
     .alert-app-level .alert-item .btn .btn:disabled {
         color: #fff;
         cursor: not-allowed;
         background-color: transparent;
         border-color: #fff;
         opacity: 0.4
     }
     .btn.btn-sm,
     .alert-app-level .alert-item .btn,
     .btn-sm .btn,
     .alert-app-level .alert-item .btn .btn {
         line-height: 23px;
         letter-spacing: .073em;
         font-size: 11px;
         font-weight: 500;
         height: 24px;
         padding: 0 12px
     }
     .btn-block {
         display: block;
         width: 100%;
         max-width: 100%
     }
     .btn {
         margin: 6px 12px 6px 0
     }
     .btn.btn-link {
         margin: 6px 0
     }
     .btn-sm:not(.btn-link) clr-icon,
     .alert-app-level .alert-item .btn:not(.btn-link) clr-icon {
         width: 12px;
         height: 12px;
         -webkit-transform: translate3d(0px, -1px, 0);
         transform: translate3d(0px, -1px, 0)
     }
     .btn-group.btn-primary .dropdown-toggle,
     .btn-group.btn-success .dropdown-toggle,
     .btn-group.btn-warning .dropdown-toggle,
     .btn-group.btn-danger .dropdown-toggle {
         border-color: #007cbb;
         background-color: #007cbb;
         color: #fff
     }
     .btn-group.btn-primary .dropdown-toggle:visited,
     .btn-group.btn-success .dropdown-toggle:visited,
     .btn-group.btn-warning .dropdown-toggle:visited,
     .btn-group.btn-danger .dropdown-toggle:visited {
         color: #fff
     }
     .btn-group.btn-primary .dropdown-toggle:hover,
     .btn-group.btn-success .dropdown-toggle:hover,
     .btn-group.btn-warning .dropdown-toggle:hover,
     .btn-group.btn-danger .dropdown-toggle:hover {
         background-color: #004a70;
         color: #fff
     }
     .btn-group.btn-primary .dropdown-toggle:active,
     .btn-group.btn-success .dropdown-toggle:active,
     .btn-group.btn-warning .dropdown-toggle:active,
     .btn-group.btn-danger .dropdown-toggle:active {
         box-shadow: 0 2px 0 0 #002538 inset
     }
     .btn-group.btn-primary .dropdown-toggle.disabled,
     .btn-group.btn-primary .dropdown-toggle:disabled,
     .btn-group.btn-success .dropdown-toggle.disabled,
     .btn-group.btn-success .dropdown-toggle:disabled,
     .btn-group.btn-warning .dropdown-toggle.disabled,
     .btn-group.btn-warning .dropdown-toggle:disabled,
     .btn-group.btn-danger .dropdown-toggle.disabled,
     .btn-group.btn-danger .dropdown-toggle:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: #ccc;
         border-color: #ccc;
         opacity: 0.4
     }
     .btn-group.btn-link .dropdown-toggle {
         border-color: transparent;
         background-color: transparent;
         color: #007cbb
     }
     .btn-group.btn-link .dropdown-toggle:visited {
         color: #007cbb
     }
     .btn-group.btn-link .dropdown-toggle:hover {
         background-color: transparent;
         color: #004a70
     }
     .btn-group.btn-link .dropdown-toggle:active {
         box-shadow: 0 0 0 0 transparent inset
     }
     .btn-group.btn-link .dropdown-toggle.disabled,
     .btn-group.btn-link .dropdown-toggle:disabled {
         color: #565656;
         cursor: not-allowed;
         background-color: transparent;
         border-color: transparent;
         opacity: 0.4
     }
     .btn-group.btn-sm .btn-group-overflow>.dropdown-toggle,
     .alert-app-level .alert-item .btn-group.btn .btn-group-overflow>.dropdown-toggle {
         line-height: 23px;
         letter-spacing: .073em;
         font-size: 11px;
         font-weight: 500;
         height: 24px;
         padding: 0 12px
     }
     .checkbox.btn,
     .checkbox-inline.btn,
     .radio.btn,
     .radio-inline.btn {
         padding: 0
     }
     .checkbox.btn label,
     .checkbox-inline.btn label,
     .radio.btn label,
     .radio-inline.btn label {
         display: inline-table;
         line-height: inherit;
         padding: 0 12px
     }
     .checkbox.btn input[type="checkbox"]+label::before,
     .checkbox.btn input[type="checkbox"]+label::after,
     .checkbox-inline.btn input[type="checkbox"]+label::before,
     .checkbox-inline.btn input[type="checkbox"]+label::after {
         content: none
     }
     .radio.btn input[type="radio"]+label::before,
     .radio.btn input[type="radio"]+label::after,
     .radio-inline.btn input[type="radio"]+label::before,
     .radio-inline.btn input[type="radio"]+label::after {
         content: none
     }
     .checkbox.btn input[type="checkbox"]:checked+label,
     .checkbox-inline.btn input[type="checkbox"]:checked+label {
         background-color: #007cbb;
         color: #fff
     }
     .checkbox.btn label,
     .checkbox-inline.btn label {
         width: 100%
     }
     .checkbox.btn.btn-secondary input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-info input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-outline input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-primary-outline input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-secondary-outline input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-outline-primary input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-outline-secondary input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-info-outline input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-outline-info input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-secondary input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-info input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-outline input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-primary-outline input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-secondary-outline input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-outline-primary input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-outline-secondary input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-info-outline input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-outline-info input[type="checkbox"]:checked+label {
         background-color: #007cbb;
         color: #fff
     }
     .checkbox.btn.btn-primary input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-primary input[type="checkbox"]:checked+label {
         background-color: #004a70;
         color: #fff
     }
     .checkbox.btn.btn-success input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-success input[type="checkbox"]:checked+label {
         background-color: #266900;
         color: #fff
     }
     .checkbox.btn.btn-danger input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-warning input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-danger input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-warning input[type="checkbox"]:checked+label {
         background-color: #c92100;
         color: #fff
     }
     .checkbox.btn.btn-success-outline input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-outline-success input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-success-outline input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-outline-success input[type="checkbox"]:checked+label {
         background-color: #266900;
         color: #fff
     }
     .checkbox.btn.btn-danger-outline input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-outline-danger input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-warning-outline input[type="checkbox"]:checked+label,
     .checkbox.btn.btn-outline-warning input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-danger-outline input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-outline-danger input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-warning-outline input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-outline-warning input[type="checkbox"]:checked+label {
         background-color: #c92100;
         color: #fff
     }
     .checkbox.btn.btn-link input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-link input[type="checkbox"]:checked+label {
         background-color: transparent;
         color: #004a70
     }
     .checkbox.btn.btn-inverse input[type="checkbox"]:checked+label,
     .alert-app-level .alert-item .checkbox.btn input[type="checkbox"]:checked+label,
     .checkbox-inline.btn.btn-inverse input[type="checkbox"]:checked+label,
     .alert-app-level .alert-item .checkbox-inline.btn input[type="checkbox"]:checked+label {
         background-color: rgba(255, 255, 255, 0.15);
         color: #fff
     }
     .radio.btn input[type="radio"]:checked+label,
     .radio.btn input[type="radio"]:checked+label {
         background-color: #007cbb;
         color: #fff
     }
     .radio.btn label,
     .radio.btn label {
         width: 100%
     }
     .radio.btn.btn-secondary input[type="radio"]:checked+label,
     .radio.btn.btn-info input[type="radio"]:checked+label,
     .radio.btn.btn-outline input[type="radio"]:checked+label,
     .radio.btn.btn-primary-outline input[type="radio"]:checked+label,
     .radio.btn.btn-secondary-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-primary input[type="radio"]:checked+label,
     .radio.btn.btn-outline-secondary input[type="radio"]:checked+label,
     .radio.btn.btn-info-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-info input[type="radio"]:checked+label,
     .radio.btn.btn-secondary input[type="radio"]:checked+label,
     .radio.btn.btn-info input[type="radio"]:checked+label,
     .radio.btn.btn-outline input[type="radio"]:checked+label,
     .radio.btn.btn-primary-outline input[type="radio"]:checked+label,
     .radio.btn.btn-secondary-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-primary input[type="radio"]:checked+label,
     .radio.btn.btn-outline-secondary input[type="radio"]:checked+label,
     .radio.btn.btn-info-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-info input[type="radio"]:checked+label {
         background-color: #007cbb;
         color: #fff
     }
     .radio.btn.btn-primary input[type="radio"]:checked+label,
     .radio.btn.btn-primary input[type="radio"]:checked+label {
         background-color: #004a70;
         color: #fff
     }
     .radio.btn.btn-success input[type="radio"]:checked+label,
     .radio.btn.btn-success input[type="radio"]:checked+label {
         background-color: #266900;
         color: #fff
     }
     .radio.btn.btn-danger input[type="radio"]:checked+label,
     .radio.btn.btn-warning input[type="radio"]:checked+label,
     .radio.btn.btn-danger input[type="radio"]:checked+label,
     .radio.btn.btn-warning input[type="radio"]:checked+label {
         background-color: #c92100;
         color: #fff
     }
     .radio.btn.btn-success-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-success input[type="radio"]:checked+label,
     .radio.btn.btn-success-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-success input[type="radio"]:checked+label {
         background-color: #266900;
         color: #fff
     }
     .radio.btn.btn-danger-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-danger input[type="radio"]:checked+label,
     .radio.btn.btn-warning-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-warning input[type="radio"]:checked+label,
     .radio.btn.btn-danger-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-danger input[type="radio"]:checked+label,
     .radio.btn.btn-warning-outline input[type="radio"]:checked+label,
     .radio.btn.btn-outline-warning input[type="radio"]:checked+label {
         background-color: #c92100;
         color: #fff
     }
     .radio.btn.btn-link input[type="radio"]:checked+label,
     .radio.btn.btn-link input[type="radio"]:checked+label {
         background-color: transparent;
         color: #004a70
     }
     .radio.btn.btn-inverse input[type="radio"]:checked+label,
     .alert-app-level .alert-item .radio.btn input[type="radio"]:checked+label,
     .radio.btn.btn-inverse input[type="radio"]:checked+label,
     .alert-app-level .alert-item .radio.btn input[type="radio"]:checked+label {
         background-color: rgba(255, 255, 255, 0.15);
         color: #fff
     }
     .btn-group {
         display: -webkit-inline-box;
         display: -ms-inline-flexbox;
         display: inline-flex;
         margin-right: 12px
     }
     .btn-group .btn {
         margin: 0
     }
     .btn-group .btn:not(:first-child) {
         border-top-left-radius: 0;
         border-bottom-left-radius: 0
     }
     .btn-group .btn:not(:last-child) {
         border-top-right-radius: 0;
         border-bottom-right-radius: 0
     }
     .btn-group.btn-primary .btn:not(:last-child),
     .btn-group.btn-success .btn:not(:last-child),
     .btn-group.btn-danger .btn:not(:last-child),
     .btn-group.btn-warning .btn:not(:last-child) {
         margin: 0 1px 0 0
     }
     .btn-group.btn-primary .dropdown-menu .btn,
     .btn-group.btn-success .dropdown-menu .btn,
     .btn-group.btn-danger .dropdown-menu .btn,
     .btn-group.btn-warning .dropdown-menu .btn {
         margin: 0
     }
     .btn-group>.btn-group-overflow {
         position: relative
     }
     .btn-group>.btn-group-overflow:last-child:not(:first-child)>.btn:first-child {
         border-radius: 0 3px 3px 0
     }
     .btn-group>.btn-group-overflow:last-child:first-child>.btn:first-child {
         border-radius: 3px
     }
     .btn-group .btn+.btn {
         border-left: none
     }
     .btn-group .btn+.btn-group-overflow .btn {
         border-left: none
     }
     .btn-group.btn-link .dropdown-toggle {
         min-width: 0
     }
     .btn-group.btn-icon-link.btn-link .btn {
         min-width: 0
     }
     .btn-group .clr-icon-title {
         display: none;
         text-transform: none
     }
     .btn-group .dropdown-toggle {
         display: block
     }
     .btn-group .dropdown-menu clr-icon {
         display: none
     }
     .btn-group .dropdown-menu .clr-icon-title {
         display: inline
     }
     .toggle-switch input[type="checkbox"] {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none
     }
     .toggle-switch {
         display: inline-block;
         height: 24px;
         margin-right: 24px;
         vertical-align: middle;
         position: relative
     }
     .toggle-switch label {
         display: inline-block;
         position: relative;
         cursor: pointer;
         height: 24px;
         margin-right: 48px
     }
     .toggle-switch input[type="checkbox"] {
         position: absolute;
         top: 6px;
         right: 6px;
         height: 16px;
         width: 16px;
         opacity: 0
     }
     .toggle-switch input[type="checkbox"]+label::before {
         position: absolute;
         display: inline-block;
         content: '';
         height: 18px;
         width: 33px;
         border: 2px solid;
         border-radius: 9px;
         border-color: #747474;
         background-color: #747474;
         top: 3px;
         right: -42px;
         transition: .15s ease-in;
         transition-property: border-color, background-color
     }
     .toggle-switch input[type="checkbox"]:focus+label::before {
         outline: 0;
         box-shadow: 0 0 2px 2px #6bc1e3
     }
     .toggle-switch input[type="checkbox"]:checked+label::before {
         border-color: #62a420;
         background-color: #62a420;
         transition: .15s ease-in;
         transition-property: border-color, background-color
     }
     .toggle-switch input[type="checkbox"]+label::after {
         position: absolute;
         display: inline-block;
         content: '';
         height: 14px;
         width: 14px;
         border: 1px solid #fff;
         border-radius: 50%;
         background-color: #fff;
         top: 5px;
         right: -25px;
         transition: right .15s ease-in
     }
     .toggle-switch input[type="checkbox"]:checked+label::after {
         right: -40px;
         transition: right .15s ease-in
     }
     .toggle-switch.disabled label {
         opacity: 0.4;
         cursor: not-allowed
     }
     .toggle-switch.disabled input[type="checkbox"]:checked+label::before {
         border-color: #ccc;
         background-color: #ccc
     }
     .toggle-switch input[type="checkbox"]:disabled+label {
         cursor: not-allowed
     }
     .toggle-switch input[type="checkbox"]:disabled+label::before {
         background-color: #fff;
         border-color: #ccc
     }
     .toggle-switch input[type="checkbox"]:disabled+label::after {
         background-color: #fff;
         border: 2px solid #ccc;
         width: 18px;
         height: 18px;
         top: 3px
     }
     .toggle-switch input[type="checkbox"]:checked:disabled+label::before {
         border-color: #ccc;
         background-color: #ccc
     }
     .toggle-switch input[type="checkbox"]:checked:disabled+label::after {
         border-color: #fff;
         width: 14px;
         height: 14px;
         top: 5px
     }
     .close {
         transition: color linear 0.2s;
         font-weight: 200;
         text-shadow: none;
         color: #747474;
         opacity: 1
     }
     .close clr-icon {
         fill: #747474
     }
     .close:focus,
     .close:hover,
     .close:active {
         opacity: 1;
         color: #000
     }
     .close:focus clr-icon,
     .close:hover clr-icon,
     .close:active clr-icon {
         fill: #000
     }
     .close:focus {
         outline: 0;
         box-shadow: 0 0 2px 2px #6bc1e3
     }
     .alert-icon {
         height: 24px;
         width: 24px;
         margin-left: -3px;
         margin-top: -4px
     }
     .alert-icon-wrapper {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 25px;
         flex: 0 0 25px;
         padding-top: 1px;
         height: 18px
     }
     .alert-item {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -ms-flex-wrap: nowrap;
         flex-wrap: nowrap;
         min-height: 18px;
         margin-bottom: 6px
     }
     .alert-item:last-child {
         margin-bottom: 0
     }
     .alert-items {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-flow: column nowrap;
         flex-flow: column nowrap;
         padding: 8px 11px;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex
     }
     .alert-item>span,
     .alert-text {
         display: inline-block;
         -webkit-box-flex: 1;
         -ms-flex-positive: 1;
         flex-grow: 1;
         -ms-flex-negative: 1;
         flex-shrink: 1;
         -ms-flex-preferred-size: 98%;
         flex-basis: 98%;
         max-width: 98%;
         margin-right: 12px;
         text-align: left
     }
     .alert {
         font-size: 13px;
         letter-spacing: normal;
         line-height: 18px;
         position: relative;
         box-sizing: border-box;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-direction: row;
         flex-direction: row;
         width: auto;
         border-radius: 3px;
         margin-top: 6px;
         background: #e1f1f6;
         color: #565656;
         border: 1px solid #49afd9
     }
     .alert .alert-icon {
         color: #007cbb
     }
     .alert.alert-info {
         background: #e1f1f6;
         color: #565656;
         border: 1px solid #49afd9
     }
     .alert.alert-info .alert-icon {
         color: #007cbb
     }
     .alert.alert-success {
         background: #dff0d0;
         color: #565656;
         border: 1px solid #60b515
     }
     .alert.alert-success .alert-icon {
         color: #318700
     }
     .alert.alert-warning {
         background: #feecb5;
         color: #565656;
         border: 1px solid #FFDC0B
     }
     .alert.alert-warning .alert-icon {
         color: #565656
     }
     .alert.alert-danger {
         background: #f5dbd9;
         color: #565656;
         border: 1px solid #ebafa6
     }
     .alert.alert-danger .alert-icon {
         color: #c92100
     }
     .alert .alert-item .clr-icon {
         height: 18px;
         width: 18px;
         margin-right: 6px
     }
     .alert .alert-item .clr-icon+.alert-text {
         padding-left: 0
     }
     .alert .alert-item .clr-icon+.alert-text::before {
         content: none
     }
     .alert .alert-actions {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         white-space: nowrap
     }
     .alert .alert-actions .dropdown:last-child {
         margin-right: -2px
     }
     .alert .alert-actions .dropdown-item {
         font-size: 14px;
         line-height: 24px;
         letter-spacing: normal
     }
     .alert .alert-action:not(:last-child) {
         margin-right: 12px
     }
     .alert .alert-action,
     .alert .dropdown-toggle {
         color: #565656;
         text-decoration: underline
     }
     .alert .alert-action:active,
     .alert .dropdown-toggle:active {
         color: #50266b
     }
     .alert .dropdown-toggle:not(.btn) {
         display: inline-block;
         background: transparent;
         border: none
     }
     .alert .close {
         width: 24px;
         display: block;
         height: 36px;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 28px;
         flex: 0 0 28px;
         -webkit-box-ordinal-group: 101;
         -ms-flex-order: 100;
         order: 100;
         padding-right: 4px
     }
     .alert .close clr-icon {
         margin-top: -5px;
         height: 20px;
         width: 20px
     }
     .alert .close ~ .alert-item>.alert-actions {
         padding-right: 12px
     }
     .alert .close ~ .alert-item>.alert-actions>.alert-action:last-child {
         margin-right: 12px
     }
     .alert-app-level {
         margin: 0;
         border: none;
         border-radius: 0;
         max-height: 96px;
         overflow-y: auto;
         background: #007cbb;
         color: #fff;
         border: none
     }
     .alert-app-level .alert-icon {
         color: #fff
     }
     .alert-app-level.alert-info {
         background: #007cbb;
         color: #fff;
         border: none
     }
     .alert-app-level.alert-info .alert-icon {
         color: #fff
     }
     .alert-app-level.alert-danger {
         background: #c92100;
         color: #fff;
         border: none
     }
     .alert-app-level.alert-danger .alert-icon {
         color: #fff
     }
     .alert-app-level.alert-warning {
         background: #c25400;
         color: #fff;
         border: none
     }
     .alert-app-level.alert-warning .alert-icon {
         color: #fff
     }
     .alert-app-level.alert-success {
         background: #62a420;
         color: #fff;
         border: none
     }
     .alert-app-level.alert-success .alert-icon {
         color: #fff
     }
     .alert-app-level .alert-items {
         padding-top: 6px;
         padding-bottom: 6px
     }
     .alert-app-level .alert-item {
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         min-height: 24px
     }
     .alert-app-level .alert-item .btn {
         margin: 0
     }
     .alert-app-level .alert-item>span,
     .alert-app-level .alert-text {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto
     }
     .alert-app-level .close {
         color: #fff;
         opacity: 0.8;
         height: 36px
     }
     .alert-app-level .close clr-icon {
         fill: #fff;
         margin-top: -3px
     }
     .alert-app-level .close:focus,
     .alert-app-level .close:hover,
     .alert-app-level .close:active {
         opacity: 1
     }
     .alert-app-level .alert-action,
     .alert-app-level .dropdown-toggle {
         text-decoration: none
     }
     .alert-sm {
         letter-spacing: normal;
         font-size: 11px;
         line-height: 16.008px
     }
     .alert-sm .alert-items {
         padding: 3px 5px
     }
     .alert-sm .alert-item {
         padding-top: 1px;
         margin-bottom: 4px
     }
     .alert-sm .alert-item:last-child {
         margin-bottom: 0
     }
     .alert-sm .alert-icon-wrapper {
         padding-top: 0;
         height: 16.008px
     }
     .alert-sm .alert-icon {
         margin-left: -4px;
         margin-top: -4px
     }
     .alert-sm .alert-item>span,
     .alert-sm .alert-text {
         margin-right: 6px
     }
     .alert-sm .close {
         padding-right: 0;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 24px;
         flex: 0 0 24px;
         height: 24px
     }
     .alert-sm .close clr-icon {
         margin-top: -3px;
         margin-right: -1px
     }
     @media screen and (max-width: 768px) {
         .alert .alert-item {
             -ms-flex-wrap: wrap;
             flex-wrap: wrap
         }
         .alert .alert-text {
             margin-right: 0;
             max-width: 90%;
             width: 90%;
             -ms-flex-preferred-size: 90%;
             flex-basis: 90%
         }
         .alert .alert-actions {
             -webkit-box-flex: 1;
             -ms-flex: 1 0 100%;
             flex: 1 0 100%;
             padding-top: 3px;
             padding-left: 24px
         }
         .alert-app-level .alert-actions {
             margin-left: 0
         }
     }
     .card .alert {
         margin: 6px 0
     }
     .modal .alert+.modal-header {
         margin-top: 12px
     }
     .card {
         box-shadow: 0 3px 0 0 #d7d7d7;
         border-radius: 3px;
         border: 1px solid #d7d7d7
     }
     .card.clickable:hover {
         box-shadow: 0 3px 0 0 #0094d2;
         border: 1px solid #0094d2;
         cursor: pointer;
         text-decoration: none;
         -webkit-transform: translate3d(0, -2px, 0);
         transform: translate3d(0, -2px, 0);
         transition: border 0.2s ease, -webkit-transform 0.2s ease;
         transition: border 0.2s ease, transform 0.2s ease;
         transition: border 0.2s ease, transform 0.2s ease, -webkit-transform 0.2s ease
     }
     .card.card-block .card-divider,
     .card .card-block .card-divider,
     .card .card-title,
     .card .card-text,
     .card .card-media-block,
     .card .list,
     .card .list-unstyled {
         margin-top: 0;
         margin-bottom: 12px
     }
     .card.card-block .card-divider:last-child,
     .card .card-block .card-divider:last-child,
     .card .card-title:last-child,
     .card .card-text:last-child,
     .card .card-media-block:last-child,
     .card .list:last-child,
     .card .list-unstyled:last-child {
         margin-bottom: 0
     }
     .card .card-img>img,
     .card.card-img>img,
     .card>.card-img:first-child:last-child>img {
         display: block;
         height: auto;
         width: 100%;
         max-width: 100%
     }
     .card {
         position: relative;
         display: block;
         background-color: #fff;
         width: 100%;
         margin-top: 24px
     }
     .card .card-header,
     .card.card-block,
     .card .card-block,
     .card .card-footer {
         padding: 12px 18px
     }
     .card .card-header,
     .card .card-title {
         color: #000;
         font-size: 18px;
         font-weight: 200;
         letter-spacing: normal
     }
     .card .card-text {
         font-size: 14px
     }
     .card .card-img:first-child>img {
         border-radius: 3px 3px 0 0
     }
     .card .card-img:last-child>img {
         border-radius: 0 0 3px 3px
     }
     .card.card-img>img,
     .card>.card-img:first-child:last-child>img {
         border-radius: 3px
     }
     .card .btn-link {
         min-width: 0;
         padding: 0
     }
     .card.card-block .btn,
     .card.card-block .btn.btn-link,
     .card.card-block .card-link,
     .card .card-block .btn,
     .card .card-block .btn.btn-link,
     .card .card-block .card-link,
     .card .card-footer .btn,
     .card .card-footer .btn.btn-link,
     .card .card-footer .card-link {
         margin: 0 12px 0 0
     }
     .card.card-block .btn-group .btn,
     .card .card-block .btn-group .btn,
     .card .card-footer .btn-group .btn {
         margin: 0
     }
     .card.clickable {
         color: inherit
     }
     .card .card-header,
     .card .card-block {
         border-bottom: 1px solid #eee
     }
     .card .card-header:last-child,
     .card .card-block:last-child {
         border-bottom: none
     }
     .card .card-divider {
         display: block;
         border-bottom: 1px solid #eee
     }
     .card.card-block .card-divider,
     .card .card-block .card-divider {
         margin-left: -18px;
         margin-right: -18px;
         width: auto
     }
     .card .card-header+.card-divider,
     .card .card-block+.card-divider {
         display: none
     }
     .card .card-media-block {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex
     }
     .card .card-media-block .card-media-image {
         display: inline-block;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         height: 60px;
         width: 60px;
         max-height: 60px;
         max-width: 60px
     }
     .card .card-media-block .card-media-description {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         margin: 0 0 0 12px
     }
     .card .card-media-block .card-media-title {
         display: inline-block
     }
     .card .card-media-block span,
     .card .card-media-block .card-media-text {
         display: inline-block
     }
     .card .card-media-block.wrap {
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column
     }
     .card .card-media-block.wrap .card-media-description {
         margin: 6px 0 0 0
     }
     .card>.list,
     .card>.list-unstyled {
         padding: 12px 18px
     }
     .card.card-block>.list,
     .card.card-block>.list-unstyled,
     .card .card-block>.list,
     .card .card-block>.list-unstyled {
         padding: 0
     }
     .card .list-group .list-group-item {
         font-size: 14px;
         border-left-width: 0;
         border-right-width: 0;
         border-color: #eee
     }
     .card .list-group .list-group-item:first-child {
         border-top-color: transparent
     }
     @supports (-ms-ime-align: auto) {
         .card .dropdown>.dropdown-toggle::after {
             display: inline-block;
             margin-top: -12px
         }
     }
     @media screen and (min-width: 544px) {
         .card-columns {
             -webkit-column-count: 3;
             -moz-column-count: 3;
             column-count: 3;
             -webkit-column-gap: 12px;
             -moz-column-gap: 12px;
             column-gap: 12px;
             -webkit-column-break-inside: avoid;
             page-break-inside: avoid;
             break-inside: avoid;
             -webkit-column-fill: balance;
             -moz-column-fill: balance;
             column-fill: balance;
             -webkit-perspective: 1
         }
         .card-columns.card-columns-2 {
             -webkit-column-count: 2;
             -moz-column-count: 2;
             column-count: 2
         }
         .card-columns.card-columns-4 {
             -webkit-column-count: 4;
             -moz-column-count: 4;
             column-count: 4
         }
         .card-columns .card {
             display: inline-block;
             margin: 6px
         }
         .card-columns .clickable {
             -webkit-backface-visibility: hidden;
             backface-visibility: hidden
         }
     }
     pre,
     pre[class*="language-"] {
         margin: 12px 0
     }
     pre {
         border: 1px solid #ccc;
         max-height: 360px;
         border-radius: 3px;
         overflow: auto
     }
     pre code {
         white-space: pre
     }
     :not(pre)>code[class*="language-"],
     pre[class*="language-"],
     pre,
     code[class*="language-"] {
         font-family: Consolas, Monaco, Courier, monospace !important;
         line-height: 24px;
         padding: 0
     }
     code.clr-code {
         color: #c92100;
         padding: 0;
         background: transparent
     }
     .dropdown-menu .dropdown-header,
     .dropdown-menu .btn,
     .dropdown-menu .btn-secondary,
     .dropdown-menu .btn-info,
     .dropdown-menu .btn-outline,
     .dropdown-menu .btn-outline-primary,
     .dropdown-menu .btn-outline-secondary,
     .dropdown-menu .btn-outline-warning,
     .dropdown-menu .btn-outline-danger,
     .dropdown-menu .btn-outline-success,
     .dropdown-menu .btn-danger,
     .dropdown-menu .btn-primary,
     .dropdown-menu .btn-warning,
     .dropdown-menu .btn-success,
     .dropdown-menu .btn-link,
     .dropdown-menu .dropdown-item {
         overflow: hidden;
         text-overflow: ellipsis;
         text-align: left
     }
     .dropdown {
         position: relative;
         display: inline-block
     }
     .dropdown .dropdown-toggle {
         display: inline-block;
         position: relative;
         margin: 0;
         white-space: nowrap;
         cursor: pointer
     }
     .dropdown .dropdown-toggle>* {
         margin: 0
     }
     .dropdown .dropdown-toggle clr-icon[shape^="caret"] {
         position: absolute;
         top: 50%;
         -webkit-transform: translateY(-50%);
         -ms-transform: translateY(-50%);
         transform: translateY(-50%);
         color: inherit;
         height: 10px;
         width: 10px
     }
     .dropdown .dropdown-toggle.btn {
         padding-right: 24px
     }
     .dropdown .dropdown-toggle.btn clr-icon[shape^="caret"] {
         right: 12px
     }
     .dropdown .dropdown-toggle:not(.btn) {
         padding: 0 12px 0 0
     }
     .dropdown .dropdown-toggle:not(.btn) clr-icon[shape^="caret"] {
         right: 0
     }
     .dropdown button.dropdown-toggle:not(.btn) {
         background: transparent;
         border: none;
         cursor: pointer
     }
     .dropdown-menu>* {
         display: block;
         white-space: nowrap
     }
     .dropdown-menu {
         position: absolute;
         top: 100%;
         left: 0;
         margin-top: 2px;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         background: #fff;
         padding: 12px 0;
         border: 1px solid #ccc;
         box-shadow: 0 1px 3px rgba(116, 116, 116, 0.25);
         min-width: 120px;
         max-width: 360px;
         border-radius: 3px;
         visibility: hidden;
         z-index: 1000
     }
     .dropdown-menu .dropdown-header {
         font-size: 12px;
         font-weight: 600;
         letter-spacing: normal;
         padding: 0 12px;
         line-height: 18px;
         margin: 0;
         color: #313131
     }
     .dropdown-menu .btn,
     .dropdown-menu .btn-secondary,
     .dropdown-menu .btn-info,
     .dropdown-menu .btn-outline,
     .dropdown-menu .btn-outline-primary,
     .dropdown-menu .btn-outline-secondary,
     .dropdown-menu .btn-outline-warning,
     .dropdown-menu .btn-outline-danger,
     .dropdown-menu .btn-outline-success,
     .dropdown-menu .btn-danger,
     .dropdown-menu .btn-primary,
     .dropdown-menu .btn-warning,
     .dropdown-menu .btn-success,
     .dropdown-menu .btn-link,
     .dropdown-menu .dropdown-item {
         font-size: 14px;
         letter-spacing: normal;
         font-weight: 400;
         background: transparent;
         border: 0;
         color: #565656;
         cursor: pointer;
         display: block;
         margin: 0;
         padding: 1px 24px 0;
         width: 100%;
         text-transform: none
     }
     .dropdown-menu .btn:hover,
     .dropdown-menu .btn:focus,
     .dropdown-menu .btn-secondary:hover,
     .dropdown-menu .btn-secondary:focus,
     .dropdown-menu .btn-info:hover,
     .dropdown-menu .btn-info:focus,
     .dropdown-menu .btn-outline:hover,
     .dropdown-menu .btn-outline:focus,
     .dropdown-menu .btn-outline-primary:hover,
     .dropdown-menu .btn-outline-primary:focus,
     .dropdown-menu .btn-outline-secondary:hover,
     .dropdown-menu .btn-outline-secondary:focus,
     .dropdown-menu .btn-outline-warning:hover,
     .dropdown-menu .btn-outline-warning:focus,
     .dropdown-menu .btn-outline-danger:hover,
     .dropdown-menu .btn-outline-danger:focus,
     .dropdown-menu .btn-outline-success:hover,
     .dropdown-menu .btn-outline-success:focus,
     .dropdown-menu .btn-danger:hover,
     .dropdown-menu .btn-danger:focus,
     .dropdown-menu .btn-primary:hover,
     .dropdown-menu .btn-primary:focus,
     .dropdown-menu .btn-warning:hover,
     .dropdown-menu .btn-warning:focus,
     .dropdown-menu .btn-success:hover,
     .dropdown-menu .btn-success:focus,
     .dropdown-menu .btn-link:hover,
     .dropdown-menu .btn-link:focus,
     .dropdown-menu .dropdown-item:hover,
     .dropdown-menu .dropdown-item:focus {
         background-color: #eee;
         color: #565656;
         text-decoration: none
     }
     .dropdown-menu .btn.expandable,
     .dropdown-menu .btn-secondary.expandable,
     .dropdown-menu .btn-info.expandable,
     .dropdown-menu .btn-outline.expandable,
     .dropdown-menu .btn-outline-primary.expandable,
     .dropdown-menu .btn-outline-secondary.expandable,
     .dropdown-menu .btn-outline-warning.expandable,
     .dropdown-menu .btn-outline-danger.expandable,
     .dropdown-menu .btn-outline-success.expandable,
     .dropdown-menu .btn-danger.expandable,
     .dropdown-menu .btn-primary.expandable,
     .dropdown-menu .btn-warning.expandable,
     .dropdown-menu .btn-success.expandable,
     .dropdown-menu .btn-link.expandable,
     .dropdown-menu .dropdown-item.expandable {
         margin-right: 24px;
         padding-right: 12px
     }
     .dropdown-menu .btn.expandable:before,
     .dropdown-menu .btn-secondary.expandable:before,
     .dropdown-menu .btn-info.expandable:before,
     .dropdown-menu .btn-outline.expandable:before,
     .dropdown-menu .btn-outline-primary.expandable:before,
     .dropdown-menu .btn-outline-secondary.expandable:before,
     .dropdown-menu .btn-outline-warning.expandable:before,
     .dropdown-menu .btn-outline-danger.expandable:before,
     .dropdown-menu .btn-outline-success.expandable:before,
     .dropdown-menu .btn-danger.expandable:before,
     .dropdown-menu .btn-primary.expandable:before,
     .dropdown-menu .btn-warning.expandable:before,
     .dropdown-menu .btn-success.expandable:before,
     .dropdown-menu .btn-link.expandable:before,
     .dropdown-menu .dropdown-item.expandable:before {
         content: '';
         float: right;
         height: 12px;
         width: 12px;
         -webkit-transform: rotate(-90deg) translateX(-8px);
         -ms-transform: rotate(-90deg) translateX(-8px);
         transform: rotate(-90deg) translateX(-8px);
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2012%2012%22%3E%0A%20%20%20%20%3Cdefs%3E%0A%20%20%20%20%20%20%20%20%3Cstyle%3E.cls-1%7Bfill%3A%239a9a9a%3B%7D%3C%2Fstyle%3E%0A%20%20%20%20%3C%2Fdefs%3E%0A%20%20%20%20%3Ctitle%3ECaret%3C%2Ftitle%3E%0A%20%20%20%20%3Cpath%20class%3D%22cls-1%22%20d%3D%22M6%2C9L1.2%2C4.2a0.68%2C0.68%2C0%2C0%2C1%2C1-1L6%2C7.08%2C9.84%2C3.24a0.68%2C0.68%2C0%2C1%2C1%2C1%2C1Z%22%2F%3E%0A%3C%2Fsvg%3E%0A");
         background-repeat: no-repeat;
         background-size: contain;
         vertical-align: middle;
         margin: 0
     }
     .dropdown-menu .btn.active,
     .dropdown-menu .btn-secondary.active,
     .dropdown-menu .btn-info.active,
     .dropdown-menu .btn-outline.active,
     .dropdown-menu .btn-outline-primary.active,
     .dropdown-menu .btn-outline-secondary.active,
     .dropdown-menu .btn-outline-warning.active,
     .dropdown-menu .btn-outline-danger.active,
     .dropdown-menu .btn-outline-success.active,
     .dropdown-menu .btn-danger.active,
     .dropdown-menu .btn-primary.active,
     .dropdown-menu .btn-warning.active,
     .dropdown-menu .btn-success.active,
     .dropdown-menu .btn-link.active,
     .dropdown-menu .dropdown-item.active {
         background: #D9E4EA;
         color: #000
     }
     .dropdown-menu .btn:active,
     .dropdown-menu .btn-secondary:active,
     .dropdown-menu .btn-info:active,
     .dropdown-menu .btn-outline:active,
     .dropdown-menu .btn-outline-primary:active,
     .dropdown-menu .btn-outline-secondary:active,
     .dropdown-menu .btn-outline-warning:active,
     .dropdown-menu .btn-outline-danger:active,
     .dropdown-menu .btn-outline-success:active,
     .dropdown-menu .btn-danger:active,
     .dropdown-menu .btn-primary:active,
     .dropdown-menu .btn-warning:active,
     .dropdown-menu .btn-success:active,
     .dropdown-menu .btn-link:active,
     .dropdown-menu .dropdown-item:active {
         box-shadow: none
     }
     .dropdown-menu .btn:focus,
     .dropdown-menu .btn-secondary:focus,
     .dropdown-menu .btn-info:focus,
     .dropdown-menu .btn-outline:focus,
     .dropdown-menu .btn-outline-primary:focus,
     .dropdown-menu .btn-outline-secondary:focus,
     .dropdown-menu .btn-outline-warning:focus,
     .dropdown-menu .btn-outline-danger:focus,
     .dropdown-menu .btn-outline-success:focus,
     .dropdown-menu .btn-danger:focus,
     .dropdown-menu .btn-primary:focus,
     .dropdown-menu .btn-warning:focus,
     .dropdown-menu .btn-success:focus,
     .dropdown-menu .btn-link:focus,
     .dropdown-menu .dropdown-item:focus {
         outline: 0
     }
     .dropdown-menu .btn.disabled,
     .dropdown-menu .btn-secondary.disabled,
     .dropdown-menu .btn-info.disabled,
     .dropdown-menu .btn-outline.disabled,
     .dropdown-menu .btn-outline-primary.disabled,
     .dropdown-menu .btn-outline-secondary.disabled,
     .dropdown-menu .btn-outline-warning.disabled,
     .dropdown-menu .btn-outline-danger.disabled,
     .dropdown-menu .btn-outline-success.disabled,
     .dropdown-menu .btn-danger.disabled,
     .dropdown-menu .btn-primary.disabled,
     .dropdown-menu .btn-warning.disabled,
     .dropdown-menu .btn-success.disabled,
     .dropdown-menu .btn-link.disabled,
     .dropdown-menu .dropdown-item.disabled {
         cursor: not-allowed;
         opacity: 0.4;
         -webkit-user-select: none;
         -moz-user-select: none;
         -ms-user-select: none;
         user-select: none
     }
     .dropdown-menu .btn.disabled:hover,
     .dropdown-menu .btn-secondary.disabled:hover,
     .dropdown-menu .btn-info.disabled:hover,
     .dropdown-menu .btn-outline.disabled:hover,
     .dropdown-menu .btn-outline-primary.disabled:hover,
     .dropdown-menu .btn-outline-secondary.disabled:hover,
     .dropdown-menu .btn-outline-warning.disabled:hover,
     .dropdown-menu .btn-outline-danger.disabled:hover,
     .dropdown-menu .btn-outline-success.disabled:hover,
     .dropdown-menu .btn-danger.disabled:hover,
     .dropdown-menu .btn-primary.disabled:hover,
     .dropdown-menu .btn-warning.disabled:hover,
     .dropdown-menu .btn-success.disabled:hover,
     .dropdown-menu .btn-link.disabled:hover,
     .dropdown-menu .dropdown-item.disabled:hover {
         background: none
     }
     .dropdown-menu .btn.disabled:active,
     .dropdown-menu .btn.disabled:focus,
     .dropdown-menu .btn-secondary.disabled:active,
     .dropdown-menu .btn-secondary.disabled:focus,
     .dropdown-menu .btn-info.disabled:active,
     .dropdown-menu .btn-info.disabled:focus,
     .dropdown-menu .btn-outline.disabled:active,
     .dropdown-menu .btn-outline.disabled:focus,
     .dropdown-menu .btn-outline-primary.disabled:active,
     .dropdown-menu .btn-outline-primary.disabled:focus,
     .dropdown-menu .btn-outline-secondary.disabled:active,
     .dropdown-menu .btn-outline-secondary.disabled:focus,
     .dropdown-menu .btn-outline-warning.disabled:active,
     .dropdown-menu .btn-outline-warning.disabled:focus,
     .dropdown-menu .btn-outline-danger.disabled:active,
     .dropdown-menu .btn-outline-danger.disabled:focus,
     .dropdown-menu .btn-outline-success.disabled:active,
     .dropdown-menu .btn-outline-success.disabled:focus,
     .dropdown-menu .btn-danger.disabled:active,
     .dropdown-menu .btn-danger.disabled:focus,
     .dropdown-menu .btn-primary.disabled:active,
     .dropdown-menu .btn-primary.disabled:focus,
     .dropdown-menu .btn-warning.disabled:active,
     .dropdown-menu .btn-warning.disabled:focus,
     .dropdown-menu .btn-success.disabled:active,
     .dropdown-menu .btn-success.disabled:focus,
     .dropdown-menu .btn-link.disabled:active,
     .dropdown-menu .btn-link.disabled:focus,
     .dropdown-menu .dropdown-item.disabled:active,
     .dropdown-menu .dropdown-item.disabled:focus {
         background: none;
         box-shadow: none
     }
     .dropdown-menu .btn,
     .dropdown-menu .dropdown-item {
         height: 30px;
         line-height: 30px
     }
     @media screen and (max-width: 544px) {
         .dropdown-menu .btn,
         .dropdown-menu .dropdown-item {
             height: 36px;
             line-height: 36px
         }
     }
     .dropdown-menu .dropdown-divider {
         border-bottom: 1px solid #eee;
         margin: 6px 0
     }
     .btn-group-overflow.open>.dropdown-menu,
     .btn-group-overflow.open>.dropdown-menu-wrapper>.dropdown-menu,
     .tabs-overflow.open>.dropdown-menu,
     .tabs-overflow.open>.dropdown-menu-wrapper>.dropdown-menu,
     .dropdown.open>.dropdown-menu,
     .dropdown.open>.dropdown-menu-wrapper>.dropdown-menu {
         visibility: visible
     }
     .btn-group-overflow.bottom-left>.dropdown-menu,
     .btn-group-overflow.bottom-right>.dropdown-menu,
     .tabs-overflow.bottom-left>.dropdown-menu,
     .tabs-overflow.bottom-right>.dropdown-menu,
     .dropdown.bottom-left>.dropdown-menu,
     .dropdown.bottom-right>.dropdown-menu {
         top: 100%;
         bottom: auto;
         margin: 2px 0 0 0
     }
     .btn-group-overflow.bottom-left>.dropdown-menu,
     .tabs-overflow.bottom-left>.dropdown-menu,
     .dropdown.bottom-left>.dropdown-menu {
         left: 0;
         right: auto
     }
     .btn-group-overflow.bottom-right>.dropdown-menu,
     .tabs-overflow.bottom-right>.dropdown-menu,
     .dropdown.bottom-right>.dropdown-menu {
         right: 0;
         left: auto
     }
     .btn-group-overflow.top-left>.dropdown-menu,
     .btn-group-overflow.top-right>.dropdown-menu,
     .tabs-overflow.top-left>.dropdown-menu,
     .tabs-overflow.top-right>.dropdown-menu,
     .dropdown.top-left>.dropdown-menu,
     .dropdown.top-right>.dropdown-menu {
         top: auto;
         bottom: 100%;
         margin: 0 0 2px 0
     }
     .btn-group-overflow.top-left>.dropdown-menu,
     .tabs-overflow.top-left>.dropdown-menu,
     .dropdown.top-left>.dropdown-menu {
         left: 0;
         right: auto
     }
     .btn-group-overflow.top-right>.dropdown-menu,
     .tabs-overflow.top-right>.dropdown-menu,
     .dropdown.top-right>.dropdown-menu {
         right: 0;
         left: auto
     }
     .btn-group-overflow.left-top>.dropdown-menu,
     .btn-group-overflow.left-bottom>.dropdown-menu,
     .tabs-overflow.left-top>.dropdown-menu,
     .tabs-overflow.left-bottom>.dropdown-menu,
     .dropdown.left-top>.dropdown-menu,
     .dropdown.left-bottom>.dropdown-menu {
         right: 100%;
         left: auto;
         margin: 0 2px 0 0
     }
     .btn-group-overflow.left-bottom>.dropdown-menu,
     .tabs-overflow.left-bottom>.dropdown-menu,
     .dropdown.left-bottom>.dropdown-menu {
         top: 0;
         bottom: auto
     }
     .btn-group-overflow.left-top>.dropdown-menu,
     .tabs-overflow.left-top>.dropdown-menu,
     .dropdown.left-top>.dropdown-menu {
         bottom: 0;
         top: auto
     }
     .btn-group-overflow.right-top>.dropdown-menu,
     .btn-group-overflow.right-bottom>.dropdown-menu,
     .tabs-overflow.right-top>.dropdown-menu,
     .tabs-overflow.right-bottom>.dropdown-menu,
     .dropdown.right-top>.dropdown-menu,
     .dropdown.right-bottom>.dropdown-menu {
         left: 100%;
         right: auto;
         margin: 0 0 0 2px
     }
     .btn-group-overflow.right-bottom>.dropdown-menu,
     .tabs-overflow.right-bottom>.dropdown-menu,
     .dropdown.right-bottom>.dropdown-menu {
         top: 0;
         bottom: auto
     }
     .btn-group-overflow.right-top>.dropdown-menu,
     .tabs-overflow.right-top>.dropdown-menu,
     .dropdown.right-top>.dropdown-menu {
         bottom: 0;
         top: auto
     }
     .btn-group-overflow .dropdown .dropdown-menu,
     .tabs-overflow .dropdown .dropdown-menu,
     .dropdown .dropdown .dropdown-menu {
         border-color: #9a9a9a;
         position: absolute
     }
     .btn-group-overflow .dropdown.left-top>.dropdown-menu,
     .btn-group-overflow .dropdown.left-top>.dropdown-menu-wrapper>.dropdown-menu,
     .tabs-overflow .dropdown.left-top>.dropdown-menu,
     .tabs-overflow .dropdown.left-top>.dropdown-menu-wrapper>.dropdown-menu,
     .dropdown .dropdown.left-top>.dropdown-menu,
     .dropdown .dropdown.left-top>.dropdown-menu-wrapper>.dropdown-menu {
         top: 0;
         bottom: auto;
         left: auto;
         right: 100%;
         margin-top: -19px;
         margin-right: -4px
     }
     .btn-group-overflow .dropdown.right-top>.dropdown-menu,
     .btn-group-overflow .dropdown.right-top>.dropdown-menu-wrapper>.dropdown-menu,
     .tabs-overflow .dropdown.right-top>.dropdown-menu,
     .tabs-overflow .dropdown.right-top>.dropdown-menu-wrapper>.dropdown-menu,
     .dropdown .dropdown.right-top>.dropdown-menu,
     .dropdown .dropdown.right-top>.dropdown-menu-wrapper>.dropdown-menu {
         top: 0;
         bottom: auto;
         left: 100%;
         right: auto;
         margin-top: -19px;
         margin-left: -4px
     }
     .btn-group-overflow .dropdown.left-bottom>.dropdown-menu,
     .btn-group-overflow .dropdown.left-bottom>.dropdown-menu-wrapper>.dropdown-menu,
     .tabs-overflow .dropdown.left-bottom>.dropdown-menu,
     .tabs-overflow .dropdown.left-bottom>.dropdown-menu-wrapper>.dropdown-menu,
     .dropdown .dropdown.left-bottom>.dropdown-menu,
     .dropdown .dropdown.left-bottom>.dropdown-menu-wrapper>.dropdown-menu {
         top: auto;
         bottom: 0;
         left: auto;
         right: 100%;
         margin-bottom: -19px;
         margin-right: -4px
     }
     .btn-group-overflow .dropdown.right-bottom>.dropdown-menu,
     .btn-group-overflow .dropdown.right-bottom>.dropdown-menu-wrapper>.dropdown-menu,
     .tabs-overflow .dropdown.right-bottom>.dropdown-menu,
     .tabs-overflow .dropdown.right-bottom>.dropdown-menu-wrapper>.dropdown-menu,
     .dropdown .dropdown.right-bottom>.dropdown-menu,
     .dropdown .dropdown.right-bottom>.dropdown-menu-wrapper>.dropdown-menu {
         top: auto;
         bottom: 0;
         left: 100%;
         right: auto;
         margin-bottom: -19px;
         margin-left: -4px
     }
     .label,
     a.label {
         font-size: 11px;
         font-weight: 400;
         letter-spacing: .03em;
         line-height: 11px;
         display: -webkit-inline-box;
         display: -ms-inline-flexbox;
         display: inline-flex;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         padding: 0 12px;
         border-radius: 12px;
         border: 1px solid #747474;
         height: 21px;
         margin: 0 6px 0 0;
         white-space: nowrap;
         color: #565656
     }
     .label:visited,
     a.label:visited {
         color: #565656
     }
     .label:focus,
     .label:hover,
     .label:active,
     a.label:focus,
     a.label:hover,
     a.label:active {
         text-decoration: none
     }
     .label.clickable:hover,
     .label.clickable:active,
     a.label.clickable:hover,
     a.label.clickable:active {
         background: #eee
     }
     .label.clickable:active,
     a.label.clickable:active {
         box-shadow: 0 1px 0 0 #747474 inset;
         -webkit-transform: translateY(0.5px);
         -ms-transform: translateY(0.5px);
         transform: translateY(0.5px)
     }
     .label.label-gray,
     .label.label-1,
     a.label.label-gray,
     a.label.label-1 {
         border: 1px solid #747474
     }
     .label.clickable.label-gray:hover,
     .label.clickable.label-gray:active,
     a.label.clickable.label-gray:hover,
     a.label.clickable.label-gray:active {
         text-decoration: none;
         background: #eee
     }
     .label.clickable.label-gray:active,
     a.label.clickable.label-gray:active {
         box-shadow: 0 1px 0 0 #747474 inset;
         -webkit-transform: translateY(0.5px);
         -ms-transform: translateY(0.5px);
         transform: translateY(0.5px)
     }
     .label.label-gray>.badge,
     a.label.label-gray>.badge {
         background: #747474;
         color: #fff
     }
     .label.label-purple,
     .label.label-2,
     a.label.label-purple,
     a.label.label-2 {
         border: 1px solid #9460b8
     }
     .label.clickable.label-purple:hover,
     .label.clickable.label-purple:active,
     a.label.clickable.label-purple:hover,
     a.label.clickable.label-purple:active {
         text-decoration: none;
         background: #eee
     }
     .label.clickable.label-purple:active,
     a.label.clickable.label-purple:active {
         box-shadow: 0 1px 0 0 #9460b8 inset;
         -webkit-transform: translateY(0.5px);
         -ms-transform: translateY(0.5px);
         transform: translateY(0.5px)
     }
     .label.label-purple>.badge,
     a.label.label-purple>.badge {
         background: #9460b8;
         color: #fff
     }
     .label.label-blue,
     .label.label-3,
     a.label.label-blue,
     a.label.label-3 {
         border: 1px solid #004a70
     }
     .label.clickable.label-blue:hover,
     .label.clickable.label-blue:active,
     a.label.clickable.label-blue:hover,
     a.label.clickable.label-blue:active {
         text-decoration: none;
         background: #eee
     }
     .label.clickable.label-blue:active,
     a.label.clickable.label-blue:active {
         box-shadow: 0 1px 0 0 #004a70 inset;
         -webkit-transform: translateY(0.5px);
         -ms-transform: translateY(0.5px);
         transform: translateY(0.5px)
     }
     .label.label-blue>.badge,
     a.label.label-blue>.badge {
         background: #004a70;
         color: #fff
     }
     .label.label-orange,
     .label.label-4,
     a.label.label-orange,
     a.label.label-4 {
         border: 1px solid #eb8d00
     }
     .label.clickable.label-orange:hover,
     .label.clickable.label-orange:active,
     a.label.clickable.label-orange:hover,
     a.label.clickable.label-orange:active {
         text-decoration: none;
         background: #eee
     }
     .label.clickable.label-orange:active,
     a.label.clickable.label-orange:active {
         box-shadow: 0 1px 0 0 #eb8d00 inset;
         -webkit-transform: translateY(0.5px);
         -ms-transform: translateY(0.5px);
         transform: translateY(0.5px)
     }
     .label.label-orange>.badge,
     a.label.label-orange>.badge {
         background: #eb8d00;
         color: #000
     }
     .label.label-light-blue,
     .label.label-5,
     a.label.label-light-blue,
     a.label.label-5 {
         border: 1px solid #89cbdf
     }
     .label.clickable.label-light-blue:hover,
     .label.clickable.label-light-blue:active,
     a.label.clickable.label-light-blue:hover,
     a.label.clickable.label-light-blue:active {
         text-decoration: none;
         background: #eee
     }
     .label.clickable.label-light-blue:active,
     a.label.clickable.label-light-blue:active {
         box-shadow: 0 1px 0 0 #89cbdf inset;
         -webkit-transform: translateY(0.5px);
         -ms-transform: translateY(0.5px);
         transform: translateY(0.5px)
     }
     .label.label-light-blue>.badge,
     a.label.label-light-blue>.badge {
         background: #89cbdf;
         color: #000
     }
     .label.label-info,
     a.label.label-info {
         background: #e1f1f6;
         color: #004a70;
         border: 1px solid #49afd9
     }
     .label.label-success,
     a.label.label-success {
         background: #dff0d0;
         color: #266900;
         border: 1px solid #60b515
     }
     .label.label-warning,
     a.label.label-warning {
         background: #feecb5;
         color: #313131;
         border: 1px solid #FFDC0B
     }
     .label.label-danger,
     a.label.label-danger {
         background: #f5dbd9;
         color: #a32100;
         border: 1px solid #ebafa6
     }
     .label>.badge,
     a.label>.badge {
         margin: 0 -9px 0 6px
     }
     .badge {
         display: -webkit-inline-box;
         display: -ms-inline-flexbox;
         display: inline-flex;
         vertical-align: middle;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center;
         min-width: 15px;
         background: #747474;
         height: 15px;
         line-height: normal;
         border-radius: 10px;
         font-size: 10px;
         padding: 0 4px;
         margin-right: 6px;
         white-space: nowrap;
         text-align: center;
         color: #fff
     }
     .badge:visited {
         color: #fff
     }
     .badge.badge-gray,
     .badge.badge-1 {
         background: #747474;
         color: #fff
     }
     .badge.badge-purple,
     .badge.badge-2 {
         background: #9460b8;
         color: #fff
     }
     .badge.badge-blue,
     .badge.badge-3 {
         background: #004a70;
         color: #fff
     }
     .badge.badge-orange,
     .badge.badge-4 {
         background: #eb8d00;
         color: #000
     }
     .badge.badge-light-blue,
     .badge.badge-5 {
         background: #89cbdf;
         color: #000
     }
     .badge.badge-info {
         background: #007cbb;
         color: #fff
     }
     .badge.badge-success {
         background: #62a420;
         color: #000
     }
     .badge.badge-danger {
         background: #c92100;
         color: #fff
     }
     .badge.badge-warning {
         background: #FFDC0B;
         color: #000
     }
     @-moz-document url-prefix() {
         .label, a.label {
             vertical-align: bottom
         }
     }
     .row.force-fit {
         margin-left: 0;
         margin-right: 0
     }
     ul.list-unstyled {
         padding-left: 0;
         margin-left: 0;
         list-style: none
     }
     ul,
     ol {
         list-style-position: inside;
         margin-left: 0;
         margin-top: 0;
         margin-bottom: 0;
         padding-left: 0
     }
     ul.list,
     ol.list {
         list-style-position: outside;
         margin-left: 1.1em
     }
     ul.list.compact,
     ol.list.compact {
         line-height: 18px
     }
     ul.list.compact>li,
     ol.list.compact>li {
         margin-bottom: 6px
     }
     ul.list.compact>li:last-child,
     ol.list.compact>li:last-child {
         margin-bottom: 0
     }
     ul:not(.list-unstyled)>li>ul.list-unstyled,
     ol>li>ul.list-unstyled {
         margin-left: 1.1em
     }
     li>ul {
         margin-top: 0;
         margin-left: 1.1em
     }
     ul.list-group {
         margin-top: 0
     }
     ul.list-spacer,
     ol.list-spacer {
         margin-top: 24px
     }
     .login-wrapper {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         background: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%20100%25%20100%25%22%20preserveAspectRatio%3D%22xMinYMin%20meet%22%3E%0A%20%20%20%20%3Cdesc%3ELogin%20Background%3C%2Fdesc%3E%0A%20%20%20%20%3Cg%20stroke%3D%22none%22%20stroke-width%3D%221%22%20fill%3D%22none%22%20fill-rule%3D%22evenodd%22%20transform%3D%22translate(0.000000%2C%20-4.000000)%22%3E%0A%20%20%20%20%20%20%20%20%3Cg%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cg%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20fill%3D%22%23FAFAFA%22%20x%3D%220%22%20y%3D%224%22%20width%3D%222055.55%22%20height%3D%221440%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23007CBB%22%20opacity%3D%220.4%22%20style%3D%22mix-blend-mode%3A%20multiply%3B%22%20points%3D%221108.43%201443.63%201109.08%201443.63%20443.44%20777.74%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2393D8CA%22%20opacity%3D%220.6%22%20style%3D%22mix-blend-mode%3A%20overlay%3B%22%20points%3D%220.79%20334.92%20443.44%20777.74%200.79%20334.49%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A0DEEA%22%20points%3D%220.79%20211.88%200.79%20329.6%2059.62%20270.77%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%22160.65%20169.74%200.79%209.73%200.79%20211.88%2090.27%20301.46%2059.62%20270.77%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23CDE3EE%22%20points%3D%22503.77%201443.63%20697.47%201443.63%20803.74%201337.36%20706.93%201240.43%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23CDE3EE%22%20points%3D%22158.33%20691.15%200.79%20848.72%200.79%201427.43%20447.52%20980.7%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23CEDDE0%22%20points%3D%22257.71%20591.75%200.79%20334.49%200.79%20533.42%20158.33%20691.15%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A9C9D5%22%20points%3D%220.79%20533.42%200.79%20848.72%20158.33%20691.15%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23AFD4E7%22%20points%3D%22806.46%201140.89%20546.94%20881.28%20447.52%20980.7%20706.93%201240.43%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%238FC4DF%22%20points%3D%22447.52%20980.7%200.79%201427.43%200.79%201443.63%20503.77%201443.63%20706.93%201240.43%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2370C0DC%22%20points%3D%22608.23%20819.99%20546.94%20881.28%20806.46%201140.89%20867.64%201079.7%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%22420.05%20429.39%20319.01%20530.45%20608.23%20819.99%20709.3%20718.91%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2369AFD4%22%20points%3D%22709.3%20718.91%20608.23%20819.99%20867.64%201079.7%20968.74%20978.6%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%238EB5BC%22%20points%3D%22619.59%20229.82%20393.42%203.12%20327.27%203.12%20160.65%20169.74%20420.05%20429.39%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%238EB5BC%22%20points%3D%22319.01%20530.45%20319.01%20530.45%2090.27%20301.46%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%237CB0C7%22%20points%3D%22160.65%20169.74%2059.62%20270.77%2090.27%20301.46%20319.01%20530.45%20420.05%20429.39%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2384C4D2%22%20points%3D%2259.62%20270.77%200.79%20329.6%200.79%20334.49%20257.71%20591.75%20319.01%20530.45%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%237CB0C7%22%20points%3D%22537.55%203.12%20393.42%203.12%20619.59%20229.82%20691.74%20157.66%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2387D1DB%22%20points%3D%22846.25%203.12%20537.55%203.12%20691.74%20157.66%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23CDE3EE%22%20points%3D%22909.87%201443.63%20850.19%201383.87%20790.43%201443.63%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A0DEEA%22%20points%3D%22319.01%20530.45%20257.71%20591.75%20443.44%20777.74%20546.94%20881.28%20608.23%20819.99%20867.64%201079.7%20867.64%201079.7%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A0DEEA%22%20points%3D%22867.64%201079.7%20806.46%201140.89%20903.31%201237.78%20964.46%201176.63%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%221065.57%201075.52%20968.74%20978.6%20867.64%201079.7%20964.46%201176.63%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%22964.46%201176.63%20867.64%201079.7%20867.64%201079.7%20964.46%201176.63%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%221010.92%201223.13%201231.16%201443.63%201010.92%201223.13%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%221240.08%20707.22%201167.9%20779.4%201264.68%20876.4%201336.87%20804.22%201240.08%20707.21%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%22980.83%20447.39%20691.74%20157.66%20619.59%20229.82%20908.66%20519.56%20980.83%20447.39%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23AFD4E7%22%20points%3D%22709.3%20718.91%20968.74%20978.6%201167.91%20779.4%20908.66%20519.55%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2369AFD4%22%20points%3D%22980.83%20447.39%20908.66%20519.55%201167.91%20779.4%201240.08%20707.21%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A0DEEA%22%20points%3D%221034.59%203.12%20846.25%203.12%20691.74%20157.66%20980.83%20447.39%201229.75%20198.47%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A0DEEA%22%20points%3D%221240.08%20707.21%201336.87%20804.22%201586.01%20555.08%201489.14%20458.12%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2370C0DC%22%20points%3D%221229.75%20198.47%20980.83%20447.39%201240.08%20707.21%201489.14%20458.12%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23B7CED2%22%20points%3D%221292.22%201302.38%201433.32%201443.63%201830.61%201443.63%201491.18%201103.42%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A0DEEA%22%20points%3D%221010.92%201223.13%20949.78%201284.27%201109.08%201443.63%201150.98%201443.63%201191.09%201403.51%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2375B8C5%22%20points%3D%221150.98%201443.63%201231.16%201443.63%201191.09%201403.51%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%221292.22%201302.38%201112.03%201122.02%201010.92%201223.13%201191.09%201403.51%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%236EA4BC%22%20points%3D%221191.09%201403.51%201231.16%201443.63%201433.32%201443.63%201292.22%201302.38%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23007CBB%22%20opacity%3D%220.4%22%20style%3D%22mix-blend-mode%3A%20multiply%3B%22%20points%3D%221383.3%20850.75%201311.12%20922.94%201491.18%201103.42%201563.37%201031.23%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23B7CED2%22%20points%3D%221491.18%201103.42%201830.61%201443.63%201974.86%201443.63%201563.37%201031.23%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%236EA4BC%22%20points%3D%221491.18%201103.42%201830.61%201443.63%201974.86%201443.63%201563.37%201031.23%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A0DEEA%22%20points%3D%221812.65%20781.95%201632.46%20601.59%201383.3%20850.75%201563.37%201031.23%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23B7CED2%22%20points%3D%221563.37%201031.23%201974.86%201443.63%202054.45%201443.63%202054.45%201023.99%201812.65%20781.95%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2378CAD4%22%20points%3D%221563.37%201031.23%201974.86%201443.63%202054.45%201443.63%202054.45%201023.99%201812.65%20781.95%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2391C5E0%22%20points%3D%22803.74%201337.36%20850.19%201383.87%20949.78%201284.27%20903.31%201237.78%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2391C5E0%22%20points%3D%221065.57%201075.52%201112.03%201122.02%201311.12%20922.94%201264.69%20876.4%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2377B8D9%22%20points%3D%22697.47%201443.63%20790.43%201443.63%20850.19%201383.87%20803.74%201337.36%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23A0DEEA%22%20points%3D%22964.46%201176.63%20903.31%201237.78%20949.78%201284.27%201010.92%201223.13%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%235DB5D6%22%20points%3D%22964.46%201176.63%20903.31%201237.78%20949.78%201284.27%201010.92%201223.13%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20fill%3D%22%2396C7DF%22%20transform%3D%22translate(1038.247297%2C%201149.275429)%20rotate(-44.970000)%20translate(-1038.247297%2C%20-1149.275429)%20%22%20x%3D%22966.752297%22%20y%3D%221116.41043%22%20width%3D%22142.99%22%20height%3D%2265.73%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20fill%3D%22%2357A8D0%22%20transform%3D%22translate(1038.247297%2C%201149.275429)%20rotate(-44.970000)%20translate(-1038.247297%2C%20-1149.275429)%20%22%20x%3D%22966.752297%22%20y%3D%221116.41043%22%20width%3D%22142.99%22%20height%3D%2265.73%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2396C7DF%22%20points%3D%221010.92%201223.13%201010.92%201223.13%20964.46%201176.63%20964.46%201176.63%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23000000%22%20opacity%3D%220.42%22%20points%3D%221010.92%201223.13%201010.92%201223.13%20964.46%201176.63%20964.46%201176.63%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23007CBB%22%20opacity%3D%220.4%22%20style%3D%22mix-blend-mode%3A%20multiply%3B%22%20points%3D%221336.87%20804.22%201264.69%20876.4%201311.12%20922.94%201383.3%20850.75%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2357A8D0%22%20points%3D%221336.87%20804.22%201264.69%20876.4%201311.12%20922.94%201383.3%20850.75%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2393D8CA%22%20opacity%3D%220.6%22%20style%3D%22mix-blend-mode%3A%20overlay%3B%22%20points%3D%221336.87%20804.22%201383.3%20850.75%201632.46%20601.59%201586.01%20555.08%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%235DB5D6%22%20points%3D%221336.87%20804.22%201383.3%20850.75%201632.46%20601.59%201586.01%20555.08%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23AFD3E6%22%20points%3D%222056%200.12%201645.49%200.12%201648.49%203.12%201944.07%203.12%201796.22%20150.99%201893.12%20247.97%202054.45%2086.64%202054.45%20179.6%201939.58%20294.47%202056%20411%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%237AB9D9%22%20points%3D%221648.49%203.12%201796.22%20150.99%201944.07%203.12%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2366AED4%22%20points%3D%222054.45%2086.64%201893.12%20247.97%201939.58%20294.47%202054.45%20179.6%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23B7CED2%22%20points%3D%221884.82%20709.78%202054.45%20879.57%202054.45%20540.15%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23AFD4E7%22%20points%3D%221489.14%20458.12%201489.14%20458.12%201371.13%20339.99%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23AFD4E7%22%20points%3D%221796.22%20150.99%201648.49%203.12%201425.1%203.12%201301.91%20126.31%201561.3%20385.95%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20fill%3D%22%2391C5E0%22%20transform%3D%22translate(1798.954066%2C%20388.798781)%20rotate(-44.970000)%20translate(-1798.954066%2C%20-388.798781)%20%22%20x%3D%221632.82407%22%20y%3D%22355.933781%22%20width%3D%22332.26%22%20height%3D%2265.73%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2391C5E0%22%20points%3D%221586.01%20555.08%201632.46%20601.59%201632.46%20601.59%201586.01%20555.08%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20fill%3D%22%23B3EAEE%22%20transform%3D%22translate(1573.711577%2C%20470.620263)%20rotate(-45.000000)%20translate(-1573.711577%2C%20-470.620263)%20%22%20x%3D%221522.68158%22%20y%3D%22402.085263%22%20width%3D%22102.06%22%20height%3D%22137.07%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20fill%3D%22%23B3EAEE%22%20transform%3D%22translate(1758.676758%2C%20655.767120)%20rotate(-44.970000)%20translate(-1758.676758%2C%20-655.767120)%20%22%20x%3D%221707.64676%22%20y%3D%22528.29212%22%20width%3D%22102.06%22%20height%3D%22254.95%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%23B3EAEE%22%20points%3D%221301.91%20126.31%201178.84%203.12%201034.59%203.12%201229.75%20198.47%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpolygon%20fill%3D%22%2383C0C8%22%20points%3D%221812.65%20781.95%202054.45%201023.99%202054.45%20879.57%201884.82%20709.78%22%3E%3C%2Fpolygon%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20fill%3D%22%237DC6DC%22%20transform%3D%22translate(1395.516901%2C%20292.206519)%20rotate(-45.000000)%20translate(-1395.516901%2C%20-292.206519)%20%22%20x%3D%221344.4919%22%20y%3D%22108.701519%22%20width%3D%22102.05%22%20height%3D%22367.01%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Crect%20fill%3D%22%2368B8D5%22%20transform%3D%22translate(1645.313619%2C%20542.249760)%20rotate(-45.000000)%20translate(-1645.313619%2C%20-542.249760)%20%22%20x%3D%221594.28362%22%20y%3D%22509.38476%22%20width%3D%22102.06%22%20height%3D%2265.73%22%3E%3C%2Frect%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fg%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cg%20transform%3D%22translate(0.000000%2C%203.000000)%22%20stroke%3D%22%23000000%22%20opacity%3D%220.15%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20d%3D%22M0.95%2C0.12%20L0.95%2C840.12%22%20id%3D%22Shape%22%3E%3C%2Fpath%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fg%3E%0A%20%20%20%20%20%20%20%20%3C%2Fg%3E%0A%20%20%20%20%3C%2Fg%3E%0A%3C%2Fsvg%3E");
         background-size: cover;
         background-position: 504px 0;
         background-repeat: no-repeat
     }
     .login-wrapper .login {
         background: #fff;
         position: relative;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center;
         padding: 24px 60px;
         height: auto;
         min-height: 100vh;
         width: 504px
     }
     .login-wrapper .login .title {
         color: #000;
         font-weight: 200;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 32px;
         letter-spacing: normal;
         line-height: 36px
     }
     .login-wrapper .login .title .welcome {
         line-height: 36px
     }
     .login-wrapper .login .title .hint {
         margin-top: 30px;
         font-size: 14px
     }
     .login-wrapper .login .trademark {
         color: #000;
         font-weight: 200;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 28px;
         letter-spacing: normal
     }
     .login-wrapper .login .subtitle {
         color: #000;
         font-weight: 200;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-size: 22px;
         letter-spacing: normal;
         line-height: 36px
     }
     .login-wrapper .login .login-group {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         padding: 48px 0 0 0
     }
     .login-wrapper .login .login-group .auth-source {
         margin: 6px 0 18px 0
     }
     .login-wrapper .login .login-group .username {
         margin: 6px 0 18px 0
     }
     .login-wrapper .login .login-group .password {
         margin: 6px 0 18px 0
     }
     .login-wrapper .login .login-group .checkbox {
         margin: 6px 0 18px 0
     }
     .login-wrapper .login .login-group .tooltip-validation {
         margin-top: 6px
     }
     .login-wrapper .login .login-group .tooltip-validation .username,
     .login-wrapper .login .login-group .tooltip-validation .password {
         width: 100%;
         margin-top: 0
     }
     .login-wrapper .login .login-group .error {
         display: none;
         margin: 6px 0 0 0;
         padding: 9px 12px;
         background: #c92100;
         color: #fff;
         border-radius: 3px;
         line-height: 18px
     }
     .login-wrapper .login .login-group .error:before {
         display: inline-block;
         content: '';
         background: url("data:image/svg+xml;charset=utf8,%3Csvg%20version%3D%221.1%22%20viewBox%3D%225%205%2026%2026%22%20preserveAspectRatio%3D%22xMidYMid%20meet%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%3E%3Cdefs%3E%3Cstyle%3E.clr-i-outline%7Bfill%3A%23fff%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Ctitle%3Eexclamation-circle-line%3C%2Ftitle%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20class%3D%22clr-i-outline%20clr-i-outline-path-1%22%20d%3D%22M18%2C6A12%2C12%2C0%2C1%2C0%2C30%2C18%2C12%2C12%2C0%2C0%2C0%2C18%2C6Zm0%2C22A10%2C10%2C0%2C1%2C1%2C28%2C18%2C10%2C10%2C0%2C0%2C1%2C18%2C28Z%22%3E%3C%2Fpath%3E%3Cpath%20class%3D%22clr-i-outline%20clr-i-outline-path-2%22%20d%3D%22M18%2C20.07a1.3%2C1.3%2C0%2C0%2C1-1.3-1.3v-6a1.3%2C1.3%2C0%2C1%2C1%2C2.6%2C0v6A1.3%2C1.3%2C0%2C0%2C1%2C18%2C20.07Z%22%3E%3C%2Fpath%3E%3Ccircle%20class%3D%22clr-i-outline%20clr-i-outline-path-3%22%20cx%3D%2217.95%22%20cy%3D%2223.02%22%20r%3D%221.5%22%3E%3C%2Fcircle%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fsvg%3E");
         margin: 1px 6px 0 0;
         height: 16px;
         width: 16px
     }
     .login-wrapper .login .login-group .error.active {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex
     }
     .login-wrapper .login .login-group .error.active:before {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 16px;
         flex: 0 0 16px
     }
     .login-wrapper .login .login-group .btn {
         margin: 72px 0 0 0;
         max-width: none
     }
     .login-wrapper .login .login-group .error+.btn {
         margin: 24px 0 0 0
     }
     .login-wrapper .login .login-group .signup {
         margin-top: 12px;
         font-size: 14px;
         text-align: center
     }
     .login-wrapper .login:after {
         position: absolute;
         content: '';
         display: block;
         width: 1px;
         height: 100%;
         background: rgba(0, 0, 0, 0.1);
         top: 0;
         right: -2px
     }
     @media screen and (max-width: 768px) {
         .login-wrapper {
             -webkit-box-pack: center;
             -ms-flex-pack: center;
             justify-content: center;
             background: #fff
         }
         .login-wrapper .login {
             width: 100%;
             margin-left: 0;
             padding: 24px 20%
         }
         .login-wrapper .login:after {
             content: none
         }
     }
     @media screen and (max-width: 544px) {
         .login-wrapper .login {
             padding: 24px 15%
         }
     }
     .main-container {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         height: 100vh;
         background: #fafafa
     }
     .main-container .alert.alert-app-level {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         overflow-x: hidden
     }
     .main-container header,
     .main-container .header {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 60px;
         flex: 0 0 60px
     }
     .main-container .sub-nav,
     .main-container .subnav {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 36px;
         flex: 0 0 36px
     }
     .main-container .u-main-container {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         overflow: hidden
     }
     .main-container .content-container {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         min-height: 1px
     }
     .main-container .content-container .content-area {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         overflow-y: auto;
         -webkit-overflow-scrolling: touch;
         padding: 24px 24px 24px 24px
     }
     .main-container .content-container .content-area>:first-child {
         margin-top: 0
     }
     .main-container .content-container .sidenav {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         -webkit-box-ordinal-group: 0;
         -ms-flex-order: -1;
         order: -1;
         overflow: hidden
     }
     .main-container .content-container .clr-vertical-nav {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         -webkit-box-ordinal-group: 0;
         -ms-flex-order: -1;
         order: -1
     }
     @media print {
         .main-container {
             height: auto
         }
     }
     body.no-scrolling .main-container .content-container .content-area {
         overflow: hidden
     }
     body.no-scrolling {
         overflow: hidden
     }
     .modal {
         position: fixed;
         top: 0;
         bottom: 0;
         right: 0;
         left: 0;
         z-index: 1050;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         padding: 48px
     }
     @media screen and (max-width: 544px) {
         .modal {
             padding: 12px
         }
     }
     .modal-dialog {
         position: relative;
         z-index: 1050;
         width: 576px;
         max-width: 100%
     }
     .modal-dialog.modal-sm {
         width: 288px
     }
     .modal-dialog.modal-lg {
         width: 864px
     }
     .modal-dialog.modal-xl {
         width: 1152px
     }
     .modal-dialog .modal-content {
         padding: 24px 24px 24px 24px;
         background-color: #fff;
         border-radius: 3px;
         box-shadow: 0 1px 2px 2px rgba(0, 0, 0, 0.2)
     }
     .modal-header {
         border-bottom: none;
         padding: 0 0 24px 0
     }
     .modal-header .modal-title {
         color: #000;
         font-size: 22px;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         font-weight: 200;
         line-height: 24px;
         letter-spacing: normal;
         margin: 0;
         padding: 0 3px
     }
     .modal-header .close {
         margin-top: 0;
         font-size: 26px;
         line-height: 24px
     }
     .modal-header .close clr-icon {
         width: 24px;
         height: 24px
     }
     .modal-body {
         max-height: 70vh;
         overflow-y: auto;
         overflow-x: hidden;
         padding: 0 3px
     }
     .modal-body>:first-child {
         margin-top: 0
     }
     .modal-body>:last-child {
         margin-bottom: 0
     }
     .modal-footer {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: end;
         -ms-flex-pack: end;
         justify-content: flex-end;
         padding: 24px 0 0 0
     }
     .modal-footer .btn {
         margin: 0 0 0 12px
     }
     @media screen and (max-width: 768px) and (orientation: landscape) {
         .modal-body {
             max-height: 55vh
         }
     }
     @media screen and (max-width: 544px) {
         .modal-content {
             padding: 12px 0 12px 24px
         }
         .modal-header {
             padding: 0 24px 12px 0
         }
         .modal-body {
             max-height: 55vh
         }
         .modal-footer {
             padding: 12px 24px 0 0
         }
     }
     .modal-backdrop {
         position: fixed;
         top: 0;
         bottom: 0;
         right: 0;
         left: 0;
         background-color: #313131;
         opacity: .85;
         z-index: 1040
     }
     .modal .modal-nav {
         display: none
     }
     .modal-outer-wrapper {
         height: 100%;
         width: 100%
     }
     .modal-ghost-wrapper {
         display: none
     }
     header,
     .header {
         background-color: #313131
     }
     header.header-1,
     .header.header-1 {
         background-color: #313131
     }
     header.header-2,
     .header.header-2 {
         background-color: #485969
     }
     header.header-3,
     .header.header-3 {
         background-color: #281336
     }
     header.header-4,
     .header.header-4 {
         background-color: #006a91
     }
     header.header-5,
     .header.header-5 {
         background-color: #004a70
     }
     header.header-6,
     .header.header-6 {
         background-color: #002538
     }
     header.header-7,
     .header.header-7 {
         background-color: #314351
     }
     header,
     .header {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         color: #fafafa;
         height: 60px;
         white-space: nowrap
     }
     header .branding,
     header .header-nav,
     header .search-box,
     header .search,
     header .settings,
     header .header-actions,
     header .divider,
     .header .branding,
     .header .header-nav,
     .header .search-box,
     .header .search,
     .header .settings,
     .header .header-actions,
     .header .divider {
         height: 60px
     }
     header .branding,
     .header .branding {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         min-width: 204px;
         padding: 0 24px
     }
     header .branding>a,
     header .branding>.nav-link,
     .header .branding>a,
     .header .branding>.nav-link {
         display: -webkit-inline-box;
         display: -ms-inline-flexbox;
         display: inline-flex;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         height: 60px
     }
     header .branding>a:hover,
     header .branding>a:active,
     header .branding>.nav-link:hover,
     header .branding>.nav-link:active,
     .header .branding>a:hover,
     .header .branding>a:active,
     .header .branding>.nav-link:hover,
     .header .branding>.nav-link:active {
         text-decoration: none
     }
     header .branding>a:focus,
     header .branding>.nav-link:focus,
     .header .branding>a:focus,
     .header .branding>.nav-link:focus {
         outline-offset: -5px
     }
     header .branding clr-icon,
     .header .branding clr-icon {
         -webkit-box-flex: 0;
         -ms-flex-positive: 0;
         flex-grow: 0;
         -ms-flex-negative: 0;
         flex-shrink: 0;
         height: 36px;
         width: 36px;
         margin-right: 9px
     }
     header .branding .title,
     .header .branding .title {
         font-size: 16px;
         font-weight: 400;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         letter-spacing: .01em;
         color: #fafafa;
         line-height: 60px;
         text-decoration: none
     }
     header .header-nav,
     .header .header-nav {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto
     }
     header .header-nav .nav-text,
     .header .header-nav .nav-text {
         padding: 0 24px;
         font-weight: 500
     }
     header .header-nav .nav-icon,
     .header .header-nav .nav-icon {
         height: 60px;
         width: 60px
     }
     header .header-nav .nav-link,
     .header .header-nav .nav-link {
         position: relative;
         display: inline-block;
         color: #fafafa;
         opacity: .65
     }
     header .header-nav .nav-link:hover,
     header .header-nav .nav-link:active,
     .header .header-nav .nav-link:hover,
     .header .header-nav .nav-link:active {
         text-decoration: none
     }
     header .header-nav .nav-link:hover,
     .header .header-nav .nav-link:hover {
         opacity: 1
     }
     header .header-nav .nav-link .fa,
     header .header-nav .nav-link .nav-icon,
     header .header-nav .nav-link .nav-text,
     header .header-nav .nav-link.nav-icon,
     header .header-nav .nav-link.nav-text,
     .header .header-nav .nav-link .fa,
     .header .header-nav .nav-link .nav-icon,
     .header .header-nav .nav-link .nav-text,
     .header .header-nav .nav-link.nav-icon,
     .header .header-nav .nav-link.nav-text {
         line-height: 60px
     }
     header .header-nav .nav-link .fa,
     header .header-nav .nav-link .nav-icon,
     .header .header-nav .nav-link .fa,
     .header .header-nav .nav-link .nav-icon {
         font-size: 22px;
         text-align: center
     }
     header .header-nav .nav-link clr-icon,
     .header .header-nav .nav-link clr-icon {
         position: absolute;
         top: 50%;
         left: 50%;
         -webkit-transform: translate(-50%, -50%);
         -ms-transform: translate(-50%, -50%);
         transform: translate(-50%, -50%);
         height: 24px;
         width: 24px
     }
     header .header-nav .nav-link .nav-icon+.nav-text,
     .header .header-nav .nav-link .nav-icon+.nav-text {
         display: none
     }
     header .header-nav .nav-link.active,
     .header .header-nav .nav-link.active {
         background: rgba(255, 255, 255, 0.15);
         opacity: 1
     }
     header .header-nav .nav-link.active.nav-icon,
     header .header-nav .nav-link.active.nav-text,
     header .header-nav .nav-link.active .nav-icon,
     header .header-nav .nav-link.active .nav-text,
     .header .header-nav .nav-link.active.nav-icon,
     .header .header-nav .nav-link.active.nav-text,
     .header .header-nav .nav-link.active .nav-icon,
     .header .header-nav .nav-link.active .nav-text {
         opacity: 1
     }
     header .header-nav .nav-link:focus,
     .header .header-nav .nav-link:focus {
         outline-offset: -5px
     }
     header .header-nav .nav-link:first-of-type,
     header .header-nav .nav-link:last-of-type,
     .header .header-nav .nav-link:first-of-type,
     .header .header-nav .nav-link:last-of-type {
         position: relative
     }
     header .header-nav .nav-link:first-of-type::before,
     header .header-nav .nav-link:last-of-type::after,
     .header .header-nav .nav-link:first-of-type::before,
     .header .header-nav .nav-link:last-of-type::after {
         position: absolute;
         content: '';
         display: inline-block;
         background: #fafafa;
         opacity: .15;
         height: 40px;
         width: 1px;
         top: 10px
     }
     header .header-nav .nav-link:first-of-type::before,
     .header .header-nav .nav-link:first-of-type::before {
         left: 0
     }
     header .header-nav .nav-link:last-of-type::after,
     .header .header-nav .nav-link:last-of-type::after {
         right: 0
     }
     header .header-nav .nav-link.active:first-of-type::before,
     header .header-nav .nav-link.active:last-of-type::after,
     .header .header-nav .nav-link.active:first-of-type::before,
     .header .header-nav .nav-link.active:last-of-type::after {
         content: none
     }
     header .search-box,
     header .search,
     .header .search-box,
     .header .search {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         max-width: 288px;
         padding: 0;
         color: #fafafa;
         opacity: .65
     }
     header .search-box:hover,
     header .search:hover,
     .header .search-box:hover,
     .header .search:hover {
         opacity: 1
     }
     header .search-box>.nav-icon,
     header .search>.nav-icon,
     .header .search-box>.nav-icon,
     .header .search>.nav-icon {
         margin: 0 6px 3px 24px
     }
     header .search-box label,
     header .search label,
     .header .search-box label,
     .header .search label {
         display: inline-block;
         height: 60px;
         line-height: 60px;
         padding-left: 24px;
         text-align: center
     }
     header .search-box label::before,
     header .search label::before,
     .header .search-box label::before,
     .header .search label::before {
         display: inline-block;
         content: '';
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2036%2036%22%3E%3Cdefs%3E%3Cstyle%3E.cls-1%7Bfill%3A%23fff%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Ctitle%3ESearch%3C%2Ftitle%3E%3Cg%20id%3D%22icons%22%3E%3Cpath%20class%3D%22cls-1%22%20d%3D%22M15%2C4.05A10.95%2C10.95%2C0%2C1%2C1%2C4.05%2C15%2C11%2C11%2C0%2C0%2C1%2C15%2C4.05M15%2C2A13%2C13%2C0%2C1%2C0%2C28%2C15%2C13%2C13%2C0%2C0%2C0%2C15%2C2Z%22%2F%3E%3Cpath%20class%3D%22cls-1%22%20%20d%3D%22M33.71%2C32.29l-7.37-7.42-1.42%2C1.41%2C7.37%2C7.42a1%2C1%2C0%2C1%2C0%2C1.42-1.41Z%22%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E");
         background-repeat: no-repeat;
         background-size: contain;
         cursor: pointer;
         height: 20px;
         width: 20px;
         margin: 20px 0 0 0;
         vertical-align: top
     }
     header .search-box label input,
     header .search label input,
     .header .search-box label input,
     .header .search label input {
         line-height: 24px
     }
     header .search-box input[type="text"],
     header .search input[type="text"],
     .header .search-box input[type="text"],
     .header .search input[type="text"] {
         border: none;
         background: none;
         color: #fafafa;
         padding: 0;
         vertical-align: middle
     }
     header .search-box input[type="text"]:focus,
     header .search-box input[type="text"]:active,
     header .search input[type="text"]:focus,
     header .search input[type="text"]:active,
     .header .search-box input[type="text"]:focus,
     .header .search-box input[type="text"]:active,
     .header .search input[type="text"]:focus,
     .header .search input[type="text"]:active {
         background: none
     }
     header .settings,
     header .header-actions,
     .header .settings,
     .header .header-actions {
         -webkit-box-flex: 1;
         -ms-flex: 1 0 auto;
         flex: 1 0 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: end;
         -ms-flex-pack: end;
         justify-content: flex-end
     }
     header .settings .nav-text,
     header .header-actions .nav-text,
     .header .settings .nav-text,
     .header .header-actions .nav-text {
         padding: 0 24px;
         font-weight: 500
     }
     header .settings .nav-icon,
     header .header-actions .nav-icon,
     .header .settings .nav-icon,
     .header .header-actions .nav-icon {
         height: 60px;
         width: 60px
     }
     header .settings .nav-link,
     header .header-actions .nav-link,
     .header .settings .nav-link,
     .header .header-actions .nav-link {
         position: relative;
         display: inline-block;
         color: #fafafa;
         opacity: .65
     }
     header .settings .nav-link:hover,
     header .settings .nav-link:active,
     header .header-actions .nav-link:hover,
     header .header-actions .nav-link:active,
     .header .settings .nav-link:hover,
     .header .settings .nav-link:active,
     .header .header-actions .nav-link:hover,
     .header .header-actions .nav-link:active {
         text-decoration: none
     }
     header .settings .nav-link:hover,
     header .header-actions .nav-link:hover,
     .header .settings .nav-link:hover,
     .header .header-actions .nav-link:hover {
         opacity: 1
     }
     header .settings .nav-link .fa,
     header .settings .nav-link .nav-icon,
     header .settings .nav-link .nav-text,
     header .settings .nav-link.nav-icon,
     header .settings .nav-link.nav-text,
     header .header-actions .nav-link .fa,
     header .header-actions .nav-link .nav-icon,
     header .header-actions .nav-link .nav-text,
     header .header-actions .nav-link.nav-icon,
     header .header-actions .nav-link.nav-text,
     .header .settings .nav-link .fa,
     .header .settings .nav-link .nav-icon,
     .header .settings .nav-link .nav-text,
     .header .settings .nav-link.nav-icon,
     .header .settings .nav-link.nav-text,
     .header .header-actions .nav-link .fa,
     .header .header-actions .nav-link .nav-icon,
     .header .header-actions .nav-link .nav-text,
     .header .header-actions .nav-link.nav-icon,
     .header .header-actions .nav-link.nav-text {
         line-height: 60px
     }
     header .settings .nav-link .fa,
     header .settings .nav-link .nav-icon,
     header .header-actions .nav-link .fa,
     header .header-actions .nav-link .nav-icon,
     .header .settings .nav-link .fa,
     .header .settings .nav-link .nav-icon,
     .header .header-actions .nav-link .fa,
     .header .header-actions .nav-link .nav-icon {
         font-size: 22px;
         text-align: center
     }
     header .settings .nav-link clr-icon,
     header .header-actions .nav-link clr-icon,
     .header .settings .nav-link clr-icon,
     .header .header-actions .nav-link clr-icon {
         position: absolute;
         top: 50%;
         left: 50%;
         -webkit-transform: translate(-50%, -50%);
         -ms-transform: translate(-50%, -50%);
         transform: translate(-50%, -50%);
         height: 24px;
         width: 24px
     }
     header .settings .nav-link .nav-icon+.nav-text,
     header .header-actions .nav-link .nav-icon+.nav-text,
     .header .settings .nav-link .nav-icon+.nav-text,
     .header .header-actions .nav-link .nav-icon+.nav-text {
         display: none
     }
     header .settings .nav-link.active,
     header .header-actions .nav-link.active,
     .header .settings .nav-link.active,
     .header .header-actions .nav-link.active {
         background: rgba(255, 255, 255, 0.15);
         opacity: 1
     }
     header .settings .nav-link.active.nav-icon,
     header .settings .nav-link.active.nav-text,
     header .settings .nav-link.active .nav-icon,
     header .settings .nav-link.active .nav-text,
     header .header-actions .nav-link.active.nav-icon,
     header .header-actions .nav-link.active.nav-text,
     header .header-actions .nav-link.active .nav-icon,
     header .header-actions .nav-link.active .nav-text,
     .header .settings .nav-link.active.nav-icon,
     .header .settings .nav-link.active.nav-text,
     .header .settings .nav-link.active .nav-icon,
     .header .settings .nav-link.active .nav-text,
     .header .header-actions .nav-link.active.nav-icon,
     .header .header-actions .nav-link.active.nav-text,
     .header .header-actions .nav-link.active .nav-icon,
     .header .header-actions .nav-link.active .nav-text {
         opacity: 1
     }
     header .settings .nav-link:focus,
     header .header-actions .nav-link:focus,
     .header .settings .nav-link:focus,
     .header .header-actions .nav-link:focus {
         outline-offset: -5px
     }
     header .settings>.dropdown>.dropdown-toggle,
     header .header-actions>.dropdown>.dropdown-toggle,
     .header .settings>.dropdown>.dropdown-toggle,
     .header .header-actions>.dropdown>.dropdown-toggle {
         position: relative;
         line-height: 60px;
         height: 60px;
         outline-offset: -5px;
         color: #fafafa;
         opacity: .65
     }
     header .settings>.dropdown>.dropdown-toggle:hover,
     header .header-actions>.dropdown>.dropdown-toggle:hover,
     .header .settings>.dropdown>.dropdown-toggle:hover,
     .header .header-actions>.dropdown>.dropdown-toggle:hover {
         opacity: 1
     }
     header .settings>.dropdown clr-icon:not([shape^="caret"]),
     header .header-actions>.dropdown clr-icon:not([shape^="caret"]),
     .header .settings>.dropdown clr-icon:not([shape^="caret"]),
     .header .header-actions>.dropdown clr-icon:not([shape^="caret"]) {
         position: absolute;
         top: 50%;
         -webkit-transform: translateY(-50%);
         -ms-transform: translateY(-50%);
         transform: translateY(-50%);
         height: 22px;
         width: 22px;
         right: 24px
     }
     header .settings>.dropdown .dropdown-toggle.nav-icon clr-icon[shape^="caret"],
     header .header-actions>.dropdown .dropdown-toggle.nav-icon clr-icon[shape^="caret"],
     .header .settings>.dropdown .dropdown-toggle.nav-icon clr-icon[shape^="caret"],
     .header .header-actions>.dropdown .dropdown-toggle.nav-icon clr-icon[shape^="caret"] {
         right: 12px
     }
     header .settings>.dropdown .dropdown-toggle.nav-text,
     header .header-actions>.dropdown .dropdown-toggle.nav-text,
     .header .settings>.dropdown .dropdown-toggle.nav-text,
     .header .header-actions>.dropdown .dropdown-toggle.nav-text {
         padding: 0 36px 0 24px
     }
     header .settings>.dropdown .dropdown-toggle.nav-text clr-icon[shape^="caret"],
     header .header-actions>.dropdown .dropdown-toggle.nav-text clr-icon[shape^="caret"],
     .header .settings>.dropdown .dropdown-toggle.nav-text clr-icon[shape^="caret"],
     .header .header-actions>.dropdown .dropdown-toggle.nav-text clr-icon[shape^="caret"] {
         right: 24px
     }
     header .settings>.dropdown .dropdown-toggle.nav-icon,
     header .header-actions>.dropdown .dropdown-toggle.nav-icon,
     .header .settings>.dropdown .dropdown-toggle.nav-icon,
     .header .header-actions>.dropdown .dropdown-toggle.nav-icon {
         width: 60px;
         padding-right: 0
     }
     header .settings>.dropdown.bottom-right>.dropdown-menu,
     header .settings>.dropdown.bottom-left>.dropdown-menu,
     header .header-actions>.dropdown.bottom-right>.dropdown-menu,
     header .header-actions>.dropdown.bottom-left>.dropdown-menu,
     .header .settings>.dropdown.bottom-right>.dropdown-menu,
     .header .settings>.dropdown.bottom-left>.dropdown-menu,
     .header .header-actions>.dropdown.bottom-right>.dropdown-menu,
     .header .header-actions>.dropdown.bottom-left>.dropdown-menu {
         top: 85%
     }
     header .settings>.dropdown:last-child.bottom-right>.dropdown-menu,
     header .header-actions>.dropdown:last-child.bottom-right>.dropdown-menu,
     .header .settings>.dropdown:last-child.bottom-right>.dropdown-menu,
     .header .header-actions>.dropdown:last-child.bottom-right>.dropdown-menu {
         right: 3px
     }
     header .settings>.dropdown .dropdown-menu,
     header .header-actions>.dropdown .dropdown-menu,
     .header .settings>.dropdown .dropdown-menu,
     .header .header-actions>.dropdown .dropdown-menu {
         margin-top: -4px;
         left: auto;
         right: 0
     }
     header .settings>.dropdown:last-child.dropdown-menu,
     header .header-actions>.dropdown:last-child.dropdown-menu,
     .header .settings>.dropdown:last-child.dropdown-menu,
     .header .header-actions>.dropdown:last-child.dropdown-menu {
         margin-right: 7.2px
     }
     header .branding+.search,
     header .branding+.search-box,
     .header .branding+.search,
     .header .branding+.search-box {
         position: relative
     }
     header .branding+.search::after,
     header .branding+.search-box::after,
     .header .branding+.search::after,
     .header .branding+.search-box::after {
         position: absolute;
         left: 0;
         content: '';
         display: inline-block;
         background: #fafafa;
         opacity: .15;
         height: 40px;
         width: 1px;
         top: 10px
     }
     header .header-nav:last-child>.nav-link:last-child::after,
     .header .header-nav:last-child>.nav-link:last-child::after {
         content: none
     }
     @media screen and (max-width: 768px) {
         header .search-box,
         header .search,
         .header .search-box,
         .header .search {
             -webkit-box-flex: 1;
             -ms-flex: 1 0 auto;
             flex: 1 0 auto;
             -webkit-box-pack: end;
             -ms-flex-pack: end;
             justify-content: flex-end;
             max-width: none
         }
         header .search-box label,
         header .search label,
         .header .search-box label,
         .header .search label {
             padding: 0;
             width: 60px
         }
         header .search-box label::before,
         header .search label::before,
         .header .search-box label::before,
         .header .search label::before {
             left: 20px
         }
         header .search-box label input,
         header .search label input,
         .header .search-box label input,
         .header .search label input {
             display: none
         }
         header .branding+.search::after,
         header .branding+.search-box::after,
         .header .branding+.search::after,
         .header .branding+.search-box::after {
             content: none
         }
         header .search-box+.settings,
         header .search-box+.header-actions,
         header .search+.settings,
         header .search+.header-actions,
         .header .search-box+.settings,
         .header .search-box+.header-actions,
         .header .search+.settings,
         .header .search+.header-actions {
             position: relative;
             -webkit-box-flex: 0;
             -ms-flex: 0 0 auto;
             flex: 0 0 auto
         }
         header .search-box+.settings::after,
         header .search-box+.header-actions::after,
         header .search+.settings::after,
         header .search+.header-actions::after,
         .header .search-box+.settings::after,
         .header .search-box+.header-actions::after,
         .header .search+.settings::after,
         .header .search+.header-actions::after {
             position: absolute;
             content: '';
             display: inline-block;
             background: #fafafa;
             opacity: .15;
             height: 40px;
             width: 1px;
             top: 10px;
             left: 0
         }
     }
     .nav {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         height: 36px;
         list-style-type: none;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         box-shadow: 0 -1px 0 #ccc inset;
         margin: 0;
         width: 100%;
         white-space: nowrap
     }
     .nav .nav-item {
         display: inline-block;
         margin-right: 24px
     }
     .nav .nav-item.active>.nav-link {
         color: #000;
         box-shadow: 0 -3px 0 #007cbb inset
     }
     .nav .nav-link {
         font-size: 14px;
         font-weight: 400;
         letter-spacing: normal;
         display: inline-block;
         color: #747474;
         padding: 0 3px;
         box-shadow: none;
         line-height: 36px
     }
     .nav .nav-link.btn {
         text-transform: none;
         margin: 0 0 -1px 0;
         border-radius: 0
     }
     .nav .nav-link:hover,
     .nav .nav-link:focus,
     .nav .nav-link:active {
         color: inherit
     }
     .nav .nav-link:hover,
     .nav .nav-link.active {
         box-shadow: 0 -3px 0 #007cbb inset;
         transition: box-shadow 0.2s ease-in
     }
     .nav .nav-link:hover,
     .nav .nav-link:focus,
     .nav .nav-link:active,
     .nav .nav-link.active {
         text-decoration: none
     }
     .nav .nav-link.active {
         color: #000
     }
     .nav .nav-link.nav-item {
         margin-right: 24px
     }
     .sub-nav,
     .subnav {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         box-shadow: 0 -1px 0 #ccc inset;
         -webkit-box-pack: justify;
         -ms-flex-pack: justify;
         justify-content: space-between;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         background-color: #fff;
         height: 36px
     }
     .sub-nav .nav,
     .subnav .nav {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         padding-left: 24px
     }
     .sub-nav aside,
     .subnav aside {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         height: 36px;
         padding: 0 24px
     }
     .sub-nav aside>:last-child,
     .subnav aside>:last-child {
         margin-right: 0;
         padding-right: 0
     }
     .sidenav {
         line-height: 24px;
         max-width: 312px;
         min-width: 216px;
         width: 18%;
         border-right: 1px solid #ccc;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column
     }
     .sidenav .sidenav-content {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         overflow-x: hidden;
         margin-bottom: 24px
     }
     .sidenav .sidenav-content .nav-link {
         display: inline-block;
         border-radius: 3px 0 0 3px;
         color: inherit;
         cursor: pointer;
         text-decoration: none;
         width: 100%
     }
     .sidenav .sidenav-content>.nav-link {
         color: #313131;
         font-size: 14px;
         font-weight: 500;
         line-height: 24px;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         letter-spacing: normal;
         margin: 24px 0 0 30px;
         padding-left: 12px
     }
     .sidenav .sidenav-content>.nav-link:hover {
         background: #eee
     }
     .sidenav .sidenav-content>.nav-link.active {
         background: #D9E4EA;
         color: #000
     }
     .sidenav .nav-group {
         font-size: 14px;
         font-weight: 400;
         letter-spacing: normal;
         margin-top: 24px;
         width: 100%
     }
     .sidenav .nav-group .nav-list,
     .sidenav .nav-group label {
         padding: 0 0 0 42px
     }
     .sidenav .nav-group .nav-list {
         list-style: none;
         margin-top: 0;
         overflow: hidden
     }
     .sidenav .nav-group .nav-list .nav-link {
         line-height: 16px;
         padding: 4px 0 4px 12px
     }
     .sidenav .nav-group .nav-list .nav-link:hover {
         background: #eee
     }
     .sidenav .nav-group .nav-list .nav-link.active {
         background: #D9E4EA;
         color: #000
     }
     .sidenav .nav-group label {
         color: #313131;
         font-size: 14px;
         font-weight: 500;
         line-height: 24px;
         font-family: Metropolis, "Avenir Next", "Helvetica Neue", Arial, sans-serif;
         letter-spacing: normal
     }
     .sidenav .nav-group input[type="checkbox"] {
         display: none
     }
     .sidenav .collapsible label {
         cursor: pointer;
         display: inline-block;
         width: 100%;
         padding: 0 0 0 32px
     }
     .sidenav .collapsible label:after {
         content: '';
         float: left;
         height: 10px;
         width: 10px;
         -webkit-transform: translateX(-8px) translateY(7px);
         -ms-transform: translateX(-8px) translateY(7px);
         transform: translateX(-8px) translateY(7px);
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2012%2012%22%3E%0A%20%20%20%20%3Cdefs%3E%0A%20%20%20%20%20%20%20%20%3Cstyle%3E.cls-1%7Bfill%3A%239a9a9a%3B%7D%3C%2Fstyle%3E%0A%20%20%20%20%3C%2Fdefs%3E%0A%20%20%20%20%3Ctitle%3ECaret%3C%2Ftitle%3E%0A%20%20%20%20%3Cpath%20class%3D%22cls-1%22%20d%3D%22M6%2C9L1.2%2C4.2a0.68%2C0.68%2C0%2C0%2C1%2C1-1L6%2C7.08%2C9.84%2C3.24a0.68%2C0.68%2C0%2C1%2C1%2C1%2C1Z%22%2F%3E%0A%3C%2Fsvg%3E%0A");
         background-repeat: no-repeat;
         background-size: contain;
         vertical-align: middle;
         margin: 0
     }
     .sidenav .collapsible .nav-list,
     .sidenav .collapsible ul {
         overflow: hidden
     }
     .sidenav .collapsible input[type="checkbox"]:checked ~ .nav-list,
     .sidenav .collapsible input[type="checkbox"]:checked ~ ul {
         height: 0
     }
     .sidenav .collapsible input[type="checkbox"] ~ .nav-list,
     .sidenav .collapsible input[type="checkbox"] ~ ul {
         height: auto
     }
     .sidenav .collapsible input[type="checkbox"]:checked ~ label:after {
         -webkit-transform: rotate(-90deg) translateX(-7px) translateY(-8px);
         -ms-transform: rotate(-90deg) translateX(-7px) translateY(-8px);
         transform: rotate(-90deg) translateX(-7px) translateY(-8px)
     }
     .clr-vertical-nav {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         padding-top: 24px;
         width: 240px;
         min-width: 48px;
         background-color: #eee;
         will-change: width;
         transition: width 0.2s ease-in-out
     }
     .clr-vertical-nav .nav-divider {
         border: 1px solid #565656;
         margin: 12px 0;
         opacity: 0.2
     }
     .clr-vertical-nav .nav-trigger+.nav-content {
         border-top: 1px solid rgba(86, 86, 86, 0.2);
         padding-top: 12px
     }
     .clr-vertical-nav .nav-content {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         overflow-y: auto;
         overflow-x: hidden
     }
     .clr-vertical-nav .nav-trigger,
     .clr-vertical-nav .nav-group-trigger {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 36px;
         flex: 0 0 36px;
         border: none;
         height: 36px;
         padding: 0;
         background-color: transparent;
         cursor: pointer;
         outline-offset: -5px
     }
     .clr-vertical-nav .nav-trigger {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 36px;
         flex: 0 0 36px;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         -webkit-box-pack: start;
         -ms-flex-pack: start;
         justify-content: flex-start;
         margin-top: -24px;
         height: 36px
     }
     .clr-vertical-nav .nav-trigger-icon {
         margin-left: auto;
         margin-right: 10px;
         transition: all 0.2s ease-in-out
     }
     .clr-vertical-nav .nav-group {
         display: block;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         height: auto;
         min-height: 36px
     }
     .clr-vertical-nav .nav-group-trigger {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 36px;
         flex: 0 0 36px;
         color: inherit
     }
     .clr-vertical-nav .nav-group-trigger clr-icon {
         transition: all 0.2s ease-in-out
     }
     .clr-vertical-nav .nav-group-content {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         color: #565656
     }
     .clr-vertical-nav .nav-group-content:hover,
     .clr-vertical-nav .nav-group-content.active {
         background-color: #fff
     }
     .clr-vertical-nav .nav-group-content:hover {
         text-decoration: none
     }
     .clr-vertical-nav .nav-group-content .nav-link {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         padding-left: 0;
         min-width: 0
     }
     .clr-vertical-nav .nav-group-content .nav-icon {
         margin-left: 24px
     }
     .clr-vertical-nav .nav-group-content .nav-text {
         padding-left: 24px
     }
     .clr-vertical-nav .nav-group-content .nav-icon+.nav-text {
         padding-left: 0
     }
     .clr-vertical-nav .nav-group-content .nav-link+.nav-group-text {
         display: none
     }
     .clr-vertical-nav .nav-group-text,
     .clr-vertical-nav .nav-link {
         height: 36px;
         padding: 0 12px 0 24px;
         line-height: 36px;
         outline-offset: -5px
     }
     .clr-vertical-nav .nav-link {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         color: #565656
     }
     .clr-vertical-nav .nav-link:hover,
     .clr-vertical-nav .nav-link.active {
         background-color: #fff
     }
     .clr-vertical-nav .nav-link:hover {
         text-decoration: none
     }
     .clr-vertical-nav .nav-link:hover .nav-icon {
         fill: #007cbb
     }
     .clr-vertical-nav>.nav-link,
     .clr-vertical-nav .nav-content>.nav-link {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 36px;
         flex: 0 0 36px
     }
     .clr-vertical-nav .nav-icon+.nav-group-text {
         padding-left: 0
     }
     .clr-vertical-nav .nav-header {
         padding: 0 12px 0 24px;
         font-size: 12px;
         font-weight: 600;
         letter-spacing: normal;
         line-height: 36px
     }
     .clr-vertical-nav .nav-group-text,
     .clr-vertical-nav .nav-text {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         white-space: nowrap;
         overflow: hidden;
         text-overflow: ellipsis
     }
     .clr-vertical-nav .nav-icon {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 16px;
         flex: 0 0 16px;
         -ms-flex-item-align: center;
         -ms-grid-row-align: center;
         align-self: center;
         height: 16px;
         width: 16px;
         margin-right: 6px;
         vertical-align: middle
     }
     .clr-vertical-nav clr-vertical-nav-group-children {
         display: block
     }
     .clr-vertical-nav .nav-btn {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         padding: 0;
         margin: 0;
         background: transparent;
         border: none;
         cursor: pointer;
         outline-offset: -5px
     }
     .clr-vertical-nav.has-nav-groups .nav-link,
     .clr-vertical-nav.has-nav-groups .nav-group .nav-group-text,
     .clr-vertical-nav.has-nav-groups .nav-group .nav-group-trigger {
         font-weight: 600
     }
     .clr-vertical-nav.has-nav-groups .nav-group-children .nav-link {
         font-weight: normal
     }
     .clr-vertical-nav.has-icons .nav-group-children .nav-link {
         padding-left: 46px
     }
     .clr-vertical-nav .nav-group.active:not(.is-expanded) .nav-group-content {
         background-color: #fff
     }
     .clr-vertical-nav .nav-group-content .nav-link.active ~ .nav-group-trigger {
         background-color: #fff
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed {
         width: 48px;
         min-width: 48px;
         cursor: pointer
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-trigger {
         margin-right: 3px
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-icon {
         margin: 0 0 0 16px
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-group-trigger {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 16px;
         flex: 0 0 16px;
         padding-left: 0
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-group-trigger clr-icon {
         height: 10px;
         width: 10px
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-link,
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-group-trigger {
         padding: 0
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-group-content .nav-link {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 48px;
         flex: 0 0 48px
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-group-content .nav-link ~ .nav-group-trigger {
         -webkit-transform: translateX(-16px);
         -ms-transform: translateX(-16px);
         transform: translateX(-16px);
         pointer-events: none
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-group,
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed .nav-link {
         display: none
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed.has-icons .nav-group {
         display: block
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed.has-icons .nav-link {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex
     }
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed.has-icons .nav-group-text,
     .main-container:not([class*="open-overflow-menu"]):not([class*="open-hamburger-menu"]) .clr-vertical-nav.is-collapsed.has-icons .nav-text {
         display: none
     }
     .header-hamburger-trigger,
     .header-overflow-trigger {
         display: none
     }
     .header-hamburger-trigger>span,
     .header-hamburger-trigger>span::before,
     .header-hamburger-trigger>span::after {
         display: inline-block;
         height: 2px;
         width: 24px;
         background: #fff;
         border-radius: 3px
     }
     .header-hamburger-trigger>span {
         position: relative;
         vertical-align: middle
     }
     .header-hamburger-trigger>span::before,
     .header-hamburger-trigger>span::after {
         content: '';
         position: absolute;
         left: 0
     }
     .header-hamburger-trigger>span::before {
         top: -7px
     }
     .header-hamburger-trigger>span::after {
         bottom: -7px
     }
     .header-hamburger-trigger.active>span {
         background: transparent
     }
     .header-hamburger-trigger.active>span::before,
     .header-hamburger-trigger.active>span::after {
         left: 3px;
         -webkit-transform-origin: 9%;
         -ms-transform-origin: 9%;
         transform-origin: 9%;
         transition: -webkit-transform .6s ease;
         transition: transform .6s ease;
         transition: transform .6s ease, -webkit-transform .6s ease
     }
     .header-hamburger-trigger.active>span::before {
         -webkit-transform: rotate(45deg);
         -ms-transform: rotate(45deg);
         transform: rotate(45deg)
     }
     .header-hamburger-trigger.active>span::after {
         -webkit-transform: rotate(-45deg);
         -ms-transform: rotate(-45deg);
         transform: rotate(-45deg)
     }
     .header-overflow-trigger>span,
     .header-overflow-trigger>span::before,
     .header-overflow-trigger>span::after {
         display: inline-block;
         height: 4px;
         width: 4px;
         background: #fff;
         border-radius: 4px
     }
     .header-overflow-trigger>span {
         position: relative;
         vertical-align: middle
     }
     .header-overflow-trigger>span::before,
     .header-overflow-trigger>span::after {
         content: '';
         position: absolute;
         left: 0
     }
     .header-overflow-trigger>span::before {
         top: -8px
     }
     .header-overflow-trigger>span::after {
         bottom: -8px
     }
     .header-overflow-trigger.active>span {
         background: transparent
     }
     .header-overflow-trigger.active>span::before,
     .header-overflow-trigger.active>span::after {
         height: 2px;
         width: 24px;
         left: -6px;
         -webkit-transform-origin: -3%;
         -ms-transform-origin: -3%;
         transform-origin: -3%;
         transition: -webkit-transform .6s ease;
         transition: transform .6s ease;
         transition: transform .6s ease, -webkit-transform .6s ease
     }
     .header-overflow-trigger.active>span::before {
         -webkit-transform: rotate(45deg);
         -ms-transform: rotate(45deg);
         transform: rotate(45deg)
     }
     .header-overflow-trigger.active>span::after {
         -webkit-transform: rotate(-45deg);
         -ms-transform: rotate(-45deg);
         transform: rotate(-45deg)
     }
     @media screen and (max-width: 768px) {
         .main-container .header-hamburger-trigger,
         .main-container .header-overflow-trigger {
             display: inline-block;
             border: none;
             background: none;
             cursor: pointer;
             font-size: 24px;
             height: 60px;
             width: 60px;
             padding: 0 0 4px 0;
             text-align: center;
             white-space: nowrap;
             color: #fafafa;
             opacity: .65
         }
         .main-container .header-hamburger-trigger:focus,
         .main-container .header-overflow-trigger:focus {
             outline-offset: -5px
         }
         .main-container .header-hamburger-trigger:hover,
         .main-container .header-overflow-trigger:hover {
             opacity: 1
         }
         .main-container .header-nav.clr-nav-level-1,
         .main-container .subnav.clr-nav-level-1,
         .main-container .sub-nav.clr-nav-level-1,
         .main-container .sidenav.clr-nav-level-1,
         .main-container .clr-vertical-nav.clr-nav-level-1 {
             display: -webkit-box;
             display: -ms-flexbox;
             display: flex;
             -webkit-box-orient: vertical;
             -webkit-box-direction: normal;
             -ms-flex-direction: column;
             flex-direction: column;
             position: fixed;
             top: 0;
             right: auto;
             bottom: 0;
             left: 0;
             background: #eee;
             z-index: 1039;
             height: 100vh;
             -webkit-transform: translateX(-360px);
             -ms-transform: translateX(-360px);
             transform: translateX(-360px);
             transition: -webkit-transform .3s ease;
             transition: transform .3s ease;
             transition: transform .3s ease, -webkit-transform .3s ease
         }
         .main-container .header-nav.clr-nav-level-2,
         .main-container .subnav.clr-nav-level-2,
         .main-container .sub-nav.clr-nav-level-2,
         .main-container .sidenav.clr-nav-level-2,
         .main-container .clr-vertical-nav.clr-nav-level-2 {
             display: -webkit-box;
             display: -ms-flexbox;
             display: flex;
             -webkit-box-orient: vertical;
             -webkit-box-direction: normal;
             -ms-flex-direction: column;
             flex-direction: column;
             position: fixed;
             top: 0;
             right: 0;
             bottom: 0;
             left: auto;
             background: #eee;
             z-index: 1039;
             height: 100vh;
             -webkit-transform: translateX(360px);
             -ms-transform: translateX(360px);
             transform: translateX(360px);
             transition: -webkit-transform .3s ease;
             transition: transform .3s ease;
             transition: transform .3s ease, -webkit-transform .3s ease
         }
         .main-container .subnav.clr-nav-level-1 .nav,
         .main-container .subnav.clr-nav-level-1 aside,
         .main-container .sub-nav.clr-nav-level-1 .nav,
         .main-container .sub-nav.clr-nav-level-1 aside,
         .main-container .subnav.clr-nav-level-2 .nav,
         .main-container .subnav.clr-nav-level-2 aside,
         .main-container .sub-nav.clr-nav-level-2 .nav,
         .main-container .sub-nav.clr-nav-level-2 aside {
             -webkit-box-orient: vertical;
             -webkit-box-direction: normal;
             -ms-flex-direction: column;
             flex-direction: column;
             -webkit-box-align: stretch;
             -ms-flex-align: stretch;
             align-items: stretch
         }
         .main-container .subnav.clr-nav-level-1 aside,
         .main-container .sub-nav.clr-nav-level-1 aside,
         .main-container .subnav.clr-nav-level-2 aside,
         .main-container .sub-nav.clr-nav-level-2 aside {
             -webkit-box-pack: center;
             -ms-flex-pack: center;
             justify-content: center;
             width: 100%
         }
         .main-container .subnav.clr-nav-level-1 .nav,
         .main-container .sub-nav.clr-nav-level-1 .nav,
         .main-container .subnav.clr-nav-level-2 .nav,
         .main-container .sub-nav.clr-nav-level-2 .nav {
             padding-left: 0
         }
         .main-container .subnav.clr-nav-level-1 .nav .nav-item,
         .main-container .sub-nav.clr-nav-level-1 .nav .nav-item,
         .main-container .subnav.clr-nav-level-2 .nav .nav-item,
         .main-container .sub-nav.clr-nav-level-2 .nav .nav-item {
             height: 36px;
             margin-right: 0
         }
         .main-container .subnav.clr-nav-level-1 .nav .nav-link,
         .main-container .sub-nav.clr-nav-level-1 .nav .nav-link,
         .main-container .subnav.clr-nav-level-2 .nav .nav-link,
         .main-container .sub-nav.clr-nav-level-2 .nav .nav-link {
             padding: 0 12px 0 24px;
             width: 100%;
             max-width: 100%;
             overflow: hidden;
             text-overflow: ellipsis;
             border-radius: 3px 0 0 3px;
             color: #565656
         }
         .main-container .subnav.clr-nav-level-1 .nav .nav-link:hover,
         .main-container .subnav.clr-nav-level-1 .nav .nav-link.active,
         .main-container .sub-nav.clr-nav-level-1 .nav .nav-link:hover,
         .main-container .sub-nav.clr-nav-level-1 .nav .nav-link.active,
         .main-container .subnav.clr-nav-level-2 .nav .nav-link:hover,
         .main-container .subnav.clr-nav-level-2 .nav .nav-link.active,
         .main-container .sub-nav.clr-nav-level-2 .nav .nav-link:hover,
         .main-container .sub-nav.clr-nav-level-2 .nav .nav-link.active {
             background-color: #fff
         }
         .main-container .subnav.clr-nav-level-1 .nav .nav-link:hover,
         .main-container .sub-nav.clr-nav-level-1 .nav .nav-link:hover,
         .main-container .subnav.clr-nav-level-2 .nav .nav-link:hover,
         .main-container .sub-nav.clr-nav-level-2 .nav .nav-link:hover {
             text-decoration: none
         }
         .main-container .subnav.clr-nav-level-1 .nav .nav-link:hover,
         .main-container .subnav.clr-nav-level-1 .nav .nav-link.active,
         .main-container .sub-nav.clr-nav-level-1 .nav .nav-link:hover,
         .main-container .sub-nav.clr-nav-level-1 .nav .nav-link.active,
         .main-container .subnav.clr-nav-level-2 .nav .nav-link:hover,
         .main-container .subnav.clr-nav-level-2 .nav .nav-link.active,
         .main-container .sub-nav.clr-nav-level-2 .nav .nav-link:hover,
         .main-container .sub-nav.clr-nav-level-2 .nav .nav-link.active {
             box-shadow: none
         }
         .main-container .sidenav.clr-nav-level-1 .nav-link:hover,
         .main-container .sidenav.clr-nav-level-1 .nav-link.active,
         .main-container .sidenav.clr-nav-level-2 .nav-link:hover,
         .main-container .sidenav.clr-nav-level-2 .nav-link.active {
             color: inherit;
             background: #fff
         }
         .main-container .sidenav.clr-nav-level-1,
         .main-container .sidenav.clr-nav-level-2,
         .main-container .clr-vertical-nav.clr-nav-level-1,
         .main-container .clr-vertical-nav.clr-nav-level-2 {
             border-right: none
         }
         .main-container .header-overflow-trigger {
             position: relative
         }
         .main-container .header-overflow-trigger::after {
             position: absolute;
             content: '';
             display: inline-block;
             background: #fafafa;
             opacity: .15;
             height: 40px;
             width: 1px;
             top: 10px;
             left: 0
         }
         .main-container .header .branding {
             max-width: 240px;
             min-width: 0;
             overflow: hidden
         }
         .main-container .header .header-hamburger-trigger+.branding {
             padding-left: 0
         }
         .main-container .header .header-hamburger-trigger+.branding .clr-icon,
         .main-container .header .header-hamburger-trigger+.branding .logo,
         .main-container .header .header-hamburger-trigger+.branding clr-icon {
             display: none
         }
         .main-container .header .branding+.header-overflow-trigger,
         .main-container .header .header-nav+.header-overflow-trigger {
             margin-left: auto
         }
         .main-container.open-hamburger-menu .header .header-backdrop,
         .main-container.open-overflow-menu .header .header-backdrop {
             position: fixed;
             top: 0;
             bottom: 0;
             left: 0;
             right: 0;
             background: rgba(0, 0, 0, 0.85);
             cursor: pointer;
             z-index: 1038
         }
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link {
             -webkit-box-flex: 0;
             -ms-flex: 0 0 auto;
             flex: 0 0 auto;
             opacity: 1;
             color: #565656
         }
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link .nav-icon,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link .fa,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link .nav-icon,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link .fa,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link .nav-icon,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link .fa,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link .nav-icon,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link .fa {
             display: none
         }
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link .nav-text,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link .nav-text,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link .nav-text,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link .nav-text {
             display: inline-block;
             color: #565656;
             line-height: 24px;
             padding: 6px 0 6px 24px;
             white-space: normal;
             font-weight: normal
         }
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link .nav-icon+.nav-text,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link .nav-icon+.nav-text,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link .nav-icon+.nav-text,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link .nav-icon+.nav-text {
             display: inline-block
         }
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link:hover,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link.active,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link:hover,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link.active,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link:hover,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link.active,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link:hover,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link.active {
             background-color: #fff
         }
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link:hover,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link:hover,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link:hover,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link:hover {
             text-decoration: none
         }
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-1 .nav-link.active>.nav-text,
         .main-container.open-hamburger-menu .header .header-nav.clr-nav-level-2 .nav-link.active>.nav-text,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-1 .nav-link.active>.nav-text,
         .main-container.open-overflow-menu .header .header-nav.clr-nav-level-2 .nav-link.active>.nav-text {
             color: inherit
         }
         .main-container.open-hamburger-menu .clr-vertical-nav .nav-trigger,
         .main-container.open-overflow-menu .clr-vertical-nav .nav-trigger {
             display: none
         }
         .main-container.open-hamburger-menu .header .branding {
             position: fixed;
             top: 0;
             left: 0;
             overflow: hidden;
             width: 360px;
             max-width: 360px;
             z-index: 1040;
             padding-left: 24px
         }
         .main-container.open-hamburger-menu .header .branding>.nav-link {
             overflow: hidden
         }
         .main-container.open-hamburger-menu .header .branding .clr-icon,
         .main-container.open-hamburger-menu .header .branding .logo,
         .main-container.open-hamburger-menu .header .branding clr-icon {
             display: inline-block
         }
         .main-container.open-hamburger-menu .header .branding clr-icon[shape="vm-bug"],
         .main-container.open-hamburger-menu .header .branding .clr-vmw-logo {
             background-color: #747474;
             border-radius: 3px
         }
         .main-container.open-hamburger-menu .header .branding .title {
             color: #565656;
             text-overflow: ellipsis;
             overflow: hidden
         }
         .main-container.open-hamburger-menu .header-hamburger-trigger {
             position: fixed;
             top: 0;
             right: auto;
             left: 0;
             z-index: 1039;
             -webkit-transform: translateX(372px);
             -ms-transform: translateX(372px);
             transform: translateX(372px);
             transition: -webkit-transform .3s ease;
             transition: transform .3s ease;
             transition: transform .3s ease, -webkit-transform .3s ease
         }
         .main-container.open-hamburger-menu .header-hamburger-trigger::after {
             content: none
         }
         .main-container.open-hamburger-menu .header-hamburger-trigger>span {
             background: transparent
         }
         .main-container.open-hamburger-menu .header-hamburger-trigger>span::before,
         .main-container.open-hamburger-menu .header-hamburger-trigger>span::after {
             left: 3px;
             -webkit-transform-origin: 9%;
             -ms-transform-origin: 9%;
             transform-origin: 9%;
             transition: -webkit-transform .6s ease;
             transition: transform .6s ease;
             transition: transform .6s ease, -webkit-transform .6s ease
         }
         .main-container.open-hamburger-menu .header-hamburger-trigger>span::before {
             -webkit-transform: rotate(45deg);
             -ms-transform: rotate(45deg);
             transform: rotate(45deg)
         }
         .main-container.open-hamburger-menu .header-hamburger-trigger>span::after {
             -webkit-transform: rotate(-45deg);
             -ms-transform: rotate(-45deg);
             transform: rotate(-45deg)
         }
         .main-container.open-hamburger-menu .header-nav.clr-nav-level-1,
         .main-container.open-hamburger-menu .subnav.clr-nav-level-1,
         .main-container.open-hamburger-menu .sub-nav.clr-nav-level-1,
         .main-container.open-hamburger-menu .sidenav.clr-nav-level-1,
         .main-container.open-hamburger-menu .clr-vertical-nav.clr-nav-level-1 {
             padding-top: 84px;
             -webkit-transform: translateX(0);
             -ms-transform: translateX(0);
             transform: translateX(0);
             transition: -webkit-transform .3s ease;
             transition: transform .3s ease;
             transition: transform .3s ease, -webkit-transform .3s ease
         }
         .main-container.open-hamburger-menu .header-nav.clr-nav-level-1 .sidenav-content,
         .main-container.open-hamburger-menu .subnav.clr-nav-level-1 .sidenav-content,
         .main-container.open-hamburger-menu .sub-nav.clr-nav-level-1 .sidenav-content,
         .main-container.open-hamburger-menu .sidenav.clr-nav-level-1 .sidenav-content,
         .main-container.open-hamburger-menu .clr-vertical-nav.clr-nav-level-1 .sidenav-content {
             margin-bottom: 24px
         }
         .main-container.open-overflow-menu .header-nav.clr-nav-level-2,
         .main-container.open-overflow-menu .subnav.clr-nav-level-2,
         .main-container.open-overflow-menu .sub-nav.clr-nav-level-2,
         .main-container.open-overflow-menu .sidenav.clr-nav-level-2,
         .main-container.open-overflow-menu .clr-vertical-nav.clr-nav-level-2 {
             -webkit-transform: translateX(0);
             -ms-transform: translateX(0);
             transform: translateX(0);
             transition: -webkit-transform .3s ease;
             transition: transform .3s ease;
             transition: transform .3s ease, -webkit-transform .3s ease
         }
         .main-container.open-overflow-menu .header-nav.clr-nav-level-2,
         .main-container.open-overflow-menu .subnav.clr-nav-level-2,
         .main-container.open-overflow-menu .sub-nav.clr-nav-level-2 {
             padding-top: 24px
         }
         .main-container.open-overflow-menu .header-overflow-trigger {
             position: fixed;
             top: 0;
             right: 0;
             left: auto;
             z-index: 1039;
             -webkit-transform: translateX(-372px);
             -ms-transform: translateX(-372px);
             transform: translateX(-372px);
             transition: -webkit-transform .3s ease;
             transition: transform .3s ease;
             transition: transform .3s ease, -webkit-transform .3s ease
         }
         .main-container.open-overflow-menu .header-overflow-trigger::after {
             content: none
         }
         .main-container.open-overflow-menu .header-overflow-trigger>span {
             background: transparent
         }
         .main-container.open-overflow-menu .header-overflow-trigger>span::before,
         .main-container.open-overflow-menu .header-overflow-trigger>span::after {
             height: 2px;
             width: 24px;
             left: -6px;
             -webkit-transform-origin: -3%;
             -ms-transform-origin: -3%;
             transform-origin: -3%;
             transition: -webkit-transform .6s ease;
             transition: transform .6s ease;
             transition: transform .6s ease, -webkit-transform .6s ease
         }
         .main-container.open-overflow-menu .header-overflow-trigger>span::before {
             -webkit-transform: rotate(45deg);
             -ms-transform: rotate(45deg);
             transform: rotate(45deg)
         }
         .main-container.open-overflow-menu .header-overflow-trigger>span::after {
             -webkit-transform: rotate(-45deg);
             -ms-transform: rotate(-45deg);
             transform: rotate(-45deg)
         }
         .main-container.open-hamburger-menu .header-nav.clr-nav-level-1,
         .main-container.open-hamburger-menu .subnav.clr-nav-level-1,
         .main-container.open-hamburger-menu .sub-nav.clr-nav-level-1,
         .main-container.open-hamburger-menu .sidenav.clr-nav-level-1,
         .main-container.open-hamburger-menu .clr-vertical-nav.clr-nav-level-1 {
             width: 360px;
             max-width: 360px
         }
         .main-container.open-overflow-menu .header-nav.clr-nav-level-2,
         .main-container.open-overflow-menu .subnav.clr-nav-level-2,
         .main-container.open-overflow-menu .sub-nav.clr-nav-level-2,
         .main-container.open-overflow-menu .sidenav.clr-nav-level-2,
         .main-container.open-overflow-menu .clr-vertical-nav.clr-nav-level-2 {
             width: 360px;
             max-width: 360px
         }
     }
     @media screen and (max-width: 544px) {
         .main-container .header .branding {
             max-width: 144px;
             min-width: 0;
             overflow: hidden
         }
         .main-container .header-nav.clr-nav-level-1,
         .main-container .subnav.clr-nav-level-1,
         .main-container .sub-nav.clr-nav-level-1,
         .main-container .sidenav.clr-nav-level-1,
         .main-container .clr-vertical-nav.clr-nav-level-1 {
             -webkit-transform: translateX(-288px);
             -ms-transform: translateX(-288px);
             transform: translateX(-288px)
         }
         .main-container .header-nav.clr-nav-level-2,
         .main-container .subnav.clr-nav-level-2,
         .main-container .sub-nav.clr-nav-level-2,
         .main-container .sidenav.clr-nav-level-2,
         .main-container .clr-vertical-nav.clr-nav-level-2 {
             -webkit-transform: translateX(288px);
             -ms-transform: translateX(288px);
             transform: translateX(288px)
         }
         .main-container.open-hamburger-menu .header .branding {
             width: 288px;
             max-width: 288px
         }
         .main-container.open-hamburger-menu .header-nav.clr-nav-level-1,
         .main-container.open-hamburger-menu .subnav.clr-nav-level-1,
         .main-container.open-hamburger-menu .sub-nav.clr-nav-level-1,
         .main-container.open-hamburger-menu .sidenav.clr-nav-level-1,
         .main-container.open-hamburger-menu .clr-vertical-nav.clr-nav-level-1 {
             width: 288px;
             max-width: 288px
         }
         .main-container.open-hamburger-menu .header-hamburger-trigger {
             position: fixed;
             top: 0;
             right: auto;
             left: 0;
             z-index: 1039;
             -webkit-transform: translateX(300px);
             -ms-transform: translateX(300px);
             transform: translateX(300px);
             transition: -webkit-transform .3s ease;
             transition: transform .3s ease;
             transition: transform .3s ease, -webkit-transform .3s ease
         }
         .main-container.open-hamburger-menu .header-hamburger-trigger::after {
             content: none
         }
         .main-container.open-overflow-menu .header-nav.clr-nav-level-2,
         .main-container.open-overflow-menu .subnav.clr-nav-level-2,
         .main-container.open-overflow-menu .sub-nav.clr-nav-level-2,
         .main-container.open-overflow-menu .sidenav.clr-nav-level-2,
         .main-container.open-overflow-menu .clr-vertical-nav.clr-nav-level-2 {
             width: 288px;
             max-width: 288px
         }
         .main-container.open-overflow-menu .header-overflow-trigger {
             position: fixed;
             top: 0;
             right: 0;
             left: auto;
             z-index: 1039;
             -webkit-transform: translateX(-300px);
             -ms-transform: translateX(-300px);
             transform: translateX(-300px);
             transition: -webkit-transform .3s ease;
             transition: transform .3s ease;
             transition: transform .3s ease, -webkit-transform .3s ease
         }
         .main-container.open-overflow-menu .header-overflow-trigger::after {
             content: none
         }
     }
     .progress,
     .progress-static {
         background-color: transparent;
         border-radius: 0;
         font-size: inherit;
         height: 2em;
         margin: 0;
         max-height: 14px;
         min-height: 4.2px;
         overflow: hidden;
         display: block;
         width: 100%
     }
     .progress>progress {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         background-color: #eee;
         border: none;
         color: #007cbb;
         height: 100%;
         width: 100%
     }
     .progress>progress::-moz-progress-bar {
         background-color: #007cbb
     }
     .progress>progress[value="0"]::-moz-progress-bar {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         color: #eee;
         min-width: 2rem;
         background-color: transparent;
         background-image: none
     }
     .progress>progress[value="0"]::-webkit-progress-value {
         transition: none
     }
     .progress>progress::-webkit-progress-bar {
         background-color: #eee;
         border-radius: 0
     }
     .progress>progress::-webkit-progress-inner-element {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none
     }
     .progress>progress::-webkit-progress-value {
         background-color: #007cbb;
         transition: width 0.23s ease-in;
         border-radius: 0
     }
     .progress.success>progress {
         color: #60b515
     }
     .progress.success>progress::-webkit-progress-value {
         background-color: #60b515
     }
     .progress.success>progress::-moz-progress-bar {
         background-color: #60b515
     }
     .progress.warning>progress {
         color: #c92100
     }
     .progress.warning>progress::-webkit-progress-value {
         background-color: #c92100
     }
     .progress.warning>progress::-moz-progress-bar {
         background-color: #c92100
     }
     .progress.danger>progress {
         color: #c92100
     }
     .progress.danger>progress::-webkit-progress-value {
         background-color: #c92100
     }
     .progress.danger>progress::-moz-progress-bar {
         background-color: #c92100
     }
     .progress.labeled,
     .progress-static.labeled {
         position: relative;
         padding-right: 3em
     }
     .progress.labeled>span,
     .progress-static.labeled>span {
         display: block;
         font-size: 1em;
         position: absolute;
         top: 50%;
         right: 0;
         line-height: 1em;
         margin-top: -0.5em;
         color: #565656
     }
     @-webkit-keyframes clr-progress-fade {
         from {
             opacity: 1
         }
         to {
             opacity: 0
         }
     }
     @keyframes clr-progress-fade {
         from {
             opacity: 1
         }
         to {
             opacity: 0
         }
     }
     .progress.progress-fade>progress[value="100"],
     .progress.progress-fade>progress[value="100"]+span {
         -webkit-animation: clr-progress-fade 0.3s linear 0.5s forwards;
         animation: clr-progress-fade 0.3s linear 0.5s forwards
     }
     .progress.flash>progress,
     .progress.flash-danger>progress {
         transition: color .1s ease-out 1s
     }
     .progress.flash>progress::-webkit-progress-value,
     .progress.flash-danger>progress::-webkit-progress-value {
         transition: width 0.23s ease-in, background-color .1s ease-out 0.3s
     }
     .progress.flash>progress[value="0"]::-webkit-progress-value,
     .progress.flash-danger>progress[value="0"]::-webkit-progress-value {
         transition: none
     }
     .progress.flash>progress::-moz-progress-bar,
     .progress.flash-danger>progress::-moz-progress-bar {
         transition: width 0.23s ease-in, background-color .1s ease-out 0.3s
     }
     .progress.flash>progress[value="100"] {
         color: #60b515
     }
     .progress.flash>progress[value="100"]::-webkit-progress-value {
         background-color: #60b515
     }
     .progress.flash>progress[value="100"]::-moz-progress-bar {
         background-color: #60b515
     }
     .progress.progress-fade.flash>progress[value="100"],
     .progress.progress-fade.flash>progress[value="100"]+span {
         -webkit-animation: clr-progress-fade 0.6s linear 1s forwards;
         animation: clr-progress-fade 0.6s linear 1s forwards
     }
     .progress.flash-danger>progress[value="100"] {
         color: #c92100
     }
     .progress.flash-danger>progress[value="100"]::-webkit-progress-value {
         background-color: #c92100
     }
     .progress.flash-danger>progress[value="100"]::-moz-progress-bar {
         background-color: #c92100
     }
     @-webkit-keyframes clr-progress-looper {
         from {
             left: -100%
         }
         to {
             left: 100%
         }
     }
     @keyframes clr-progress-looper {
         from {
             left: -100%
         }
         to {
             left: 100%
         }
     }
     .progress.loop {
         position: relative
     }
     .progress.loop>progress {
         overflow: hidden;
         color: transparent
     }
     .progress.loop>progress::-webkit-progress-value {
         background-color: transparent
     }
     .progress.loop>progress::-moz-progress-bar {
         background-color: transparent
     }
     .progress.loop::after {
         -webkit-animation: clr-progress-looper 2s ease-in-out infinite;
         animation: clr-progress-looper 2s ease-in-out infinite;
         content: ' ';
         top: 0;
         bottom: 0;
         left: 0;
         position: absolute;
         display: block;
         background-color: #007cbb;
         width: 75%
     }
     .progress-static {
         position: relative;
         border: none;
         width: 100%
     }
     .progress-static>.progress-meter {
         background-color: #eee;
         display: block;
         position: absolute;
         top: 0;
         left: 0;
         bottom: 0;
         right: 0
     }
     .progress-static>.progress-meter::before {
         background-color: #007cbb;
         top: 0;
         bottom: 0;
         left: 0;
         position: absolute;
         display: block;
         width: 0%;
         content: ' '
     }
     .progress-static>.progress-meter[data-value="1"]::before,
     .progress-static>.progress-meter[data-value="2"]::before,
     .progress-static>.progress-meter[data-value="3"]::before {
         width: 2%
     }
     .progress-static>.progress-meter[data-value="4"]::before,
     .progress-static>.progress-meter[data-value="5"]::before,
     .progress-static>.progress-meter[data-value="6"]::before,
     .progress-static>.progress-meter[data-value="7"]::before {
         width: 5%
     }
     .progress-static>.progress-meter[data-value="8"]::before,
     .progress-static>.progress-meter[data-value="9"]::before,
     .progress-static>.progress-meter[data-value="10"]::before,
     .progress-static>.progress-meter[data-value="11"]::before,
     .progress-static>.progress-meter[data-value="12"]::before {
         width: 10%
     }
     .progress-static>.progress-meter[data-value="13"]::before,
     .progress-static>.progress-meter[data-value="14"]::before,
     .progress-static>.progress-meter[data-value="15"]::before,
     .progress-static>.progress-meter[data-value="16"]::before,
     .progress-static>.progress-meter[data-value="17"]::before {
         width: 15%
     }
     .progress-static>.progress-meter[data-value="18"]::before,
     .progress-static>.progress-meter[data-value="19"]::before,
     .progress-static>.progress-meter[data-value="20"]::before,
     .progress-static>.progress-meter[data-value="21"]::before,
     .progress-static>.progress-meter[data-value="22"]::before {
         width: 20%
     }
     .progress-static>.progress-meter[data-value="23"]::before,
     .progress-static>.progress-meter[data-value="24"]::before,
     .progress-static>.progress-meter[data-value="25"]::before,
     .progress-static>.progress-meter[data-value="26"]::before,
     .progress-static>.progress-meter[data-value="27"]::before {
         width: 25%
     }
     .progress-static>.progress-meter[data-value="28"]::before,
     .progress-static>.progress-meter[data-value="29"]::before,
     .progress-static>.progress-meter[data-value="30"]::before,
     .progress-static>.progress-meter[data-value="31"]::before,
     .progress-static>.progress-meter[data-value="32"]::before {
         width: 30%
     }
     .progress-static>.progress-meter[data-value="33"]::before,
     .progress-static>.progress-meter[data-value="34"]::before,
     .progress-static>.progress-meter[data-value="35"]::before,
     .progress-static>.progress-meter[data-value="36"]::before,
     .progress-static>.progress-meter[data-value="37"]::before {
         width: 35%
     }
     .progress-static>.progress-meter[data-value="38"]::before,
     .progress-static>.progress-meter[data-value="39"]::before,
     .progress-static>.progress-meter[data-value="40"]::before,
     .progress-static>.progress-meter[data-value="41"]::before,
     .progress-static>.progress-meter[data-value="42"]::before {
         width: 40%
     }
     .progress-static>.progress-meter[data-value="43"]::before,
     .progress-static>.progress-meter[data-value="44"]::before,
     .progress-static>.progress-meter[data-value="45"]::before,
     .progress-static>.progress-meter[data-value="46"]::before,
     .progress-static>.progress-meter[data-value="47"]::before {
         width: 45%
     }
     .progress-static>.progress-meter[data-value="48"]::before,
     .progress-static>.progress-meter[data-value="49"]::before,
     .progress-static>.progress-meter[data-value="50"]::before,
     .progress-static>.progress-meter[data-value="51"]::before,
     .progress-static>.progress-meter[data-value="52"]::before {
         width: 50%
     }
     .progress-static>.progress-meter[data-value="53"]::before,
     .progress-static>.progress-meter[data-value="54"]::before,
     .progress-static>.progress-meter[data-value="55"]::before,
     .progress-static>.progress-meter[data-value="56"]::before,
     .progress-static>.progress-meter[data-value="57"]::before {
         width: 55%
     }
     .progress-static>.progress-meter[data-value="58"]::before,
     .progress-static>.progress-meter[data-value="59"]::before,
     .progress-static>.progress-meter[data-value="60"]::before,
     .progress-static>.progress-meter[data-value="61"]::before,
     .progress-static>.progress-meter[data-value="62"]::before {
         width: 60%
     }
     .progress-static>.progress-meter[data-value="63"]::before,
     .progress-static>.progress-meter[data-value="64"]::before,
     .progress-static>.progress-meter[data-value="65"]::before,
     .progress-static>.progress-meter[data-value="66"]::before,
     .progress-static>.progress-meter[data-value="67"]::before {
         width: 65%
     }
     .progress-static>.progress-meter[data-value="68"]::before,
     .progress-static>.progress-meter[data-value="69"]::before,
     .progress-static>.progress-meter[data-value="70"]::before,
     .progress-static>.progress-meter[data-value="71"]::before,
     .progress-static>.progress-meter[data-value="72"]::before {
         width: 70%
     }
     .progress-static>.progress-meter[data-value="73"]::before,
     .progress-static>.progress-meter[data-value="74"]::before,
     .progress-static>.progress-meter[data-value="75"]::before,
     .progress-static>.progress-meter[data-value="76"]::before,
     .progress-static>.progress-meter[data-value="77"]::before {
         width: 75%
     }
     .progress-static>.progress-meter[data-value="78"]::before,
     .progress-static>.progress-meter[data-value="79"]::before,
     .progress-static>.progress-meter[data-value="80"]::before,
     .progress-static>.progress-meter[data-value="81"]::before,
     .progress-static>.progress-meter[data-value="82"]::before {
         width: 80%
     }
     .progress-static>.progress-meter[data-value="83"]::before,
     .progress-static>.progress-meter[data-value="84"]::before,
     .progress-static>.progress-meter[data-value="85"]::before,
     .progress-static>.progress-meter[data-value="86"]::before,
     .progress-static>.progress-meter[data-value="87"]::before {
         width: 85%
     }
     .progress-static>.progress-meter[data-value="88"]::before,
     .progress-static>.progress-meter[data-value="89"]::before,
     .progress-static>.progress-meter[data-value="90"]::before,
     .progress-static>.progress-meter[data-value="91"]::before,
     .progress-static>.progress-meter[data-value="92"]::before {
         width: 90%
     }
     .progress-static>.progress-meter[data-value="93"]::before,
     .progress-static>.progress-meter[data-value="94"]::before,
     .progress-static>.progress-meter[data-value="95"]::before,
     .progress-static>.progress-meter[data-value="96"]::before {
         width: 95%
     }
     .progress-static>.progress-meter[data-value="97"]::before,
     .progress-static>.progress-meter[data-value="98"]::before,
     .progress-static>.progress-meter[data-value="99"]::before {
         width: 98%
     }
     .progress-static>.progress-meter[data-value="100"]::before {
         width: 100%
     }
     .progress-static.labeled>.progress-meter {
         right: 3em
     }
     .progress-static.success>.progress-meter::before {
         background-color: #60b515
     }
     .progress-static.warning>.progress-meter::before {
         background-color: #c92100
     }
     .progress-static.danger>.progress-meter::before {
         background-color: #c92100
     }
     .card-block .progress,
     .card-block .progress-static,
     .card-footer .progress,
     .card-footer .progress-static {
         margin: 0;
         margin-top: -13px;
         height: 3.73333px;
         position: absolute;
         left: 0
     }
     .card-block .progress>progress,
     .card-block .progress-static>.progress-meter,
     .card-footer .progress>progress,
     .card-footer .progress-static>.progress-meter {
         height: 3.73333px;
         position: absolute
     }
     .card-block .progress.top,
     .card-block .progress-static.top,
     .card-footer .progress.top,
     .card-footer .progress-static.top {
         margin-top: 0;
         top: 0
     }
     .nav-item .progress,
     .nav-item .progress-static {
         margin: 0;
         height: 2.8px;
         min-height: 2.8px;
         max-height: 2.8px;
         position: absolute;
         left: 0
     }
     .nav-item .progress>progress,
     .nav-item .progress-static>.progress-meter {
         height: 2.8px;
         min-height: 2.8px;
         max-height: 2.8px;
         position: absolute
     }
     .progress-block {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         width: 100%;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center
     }
     .progress-block>* {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         padding-right: 12px
     }
     .progress-block>*:first-child {
         padding-right: 18px
     }
     .progress-block>*:last-child {
         padding-right: 0
     }
     .progress-block>label {
         font-weight: 600
     }
     .progress-block>.progress,
     .progress-block>.progress-static {
         -webkit-box-flex: 0;
         -ms-flex: 0 1 auto;
         flex: 0 1 auto
     }
     .progress-block>.progress-group {
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         height: auto;
         -webkit-box-flex: 0;
         -ms-flex: 0 1 auto;
         flex: 0 1 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         width: 100%
     }
     .progress-block>.progress-group .row {
         margin-left: 0;
         margin-right: 0
     }
     .progress-block>.progress-group .row>[class*="col-"] {
         padding-left: 0;
         padding-right: 0
     }
     .card-block .progress-block {
         margin-bottom: 12px;
         padding: 0
     }
     .card-block .progress-block:last-child {
         margin-bottom: 0
     }
     .card-block .progress-block>label {
         max-width: 33%;
         line-height: 18px
     }
     .card-block .progress-block .progress,
     .card-block .progress-block .progress-static {
         position: relative;
         height: 7.46667px;
         margin-top: 0
     }
     .card-block .progress-block .progress>progress,
     .card-block .progress-block .progress>.progress-meter,
     .card-block .progress-block .progress-static>progress,
     .card-block .progress-block .progress-static>.progress-meter {
         height: 7.46667px
     }
     _:-ms-input-placeholder .progress-block>label,
     :root .progress-block>label {
         display: inline-block
     }
     .spinner {
         position: relative;
         display: inline-block;
         min-height: 72px;
         min-width: 72px;
         height: 72px;
         width: 72px;
         -webkit-animation: spin 1s linear infinite;
         animation: spin 1s linear infinite;
         margin: 0;
         padding: 0;
         background: url("data:image/svg+xml;charset=utf8,%3Csvg%20id%3D%22Layer_2%22%20data-name%3D%22Layer%202%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2072%2072%22%3E%0A%20%20%20%20%3Cdefs%3E%0A%20%20%20%20%20%20%20%20%3Cstyle%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20.cls-1%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20.cls-2%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20fill%3A%20none%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke-miterlimit%3A%2010%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke-width%3A%205px%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%20%20%20%20.cls-1%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke%3A%20%23000%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke-opacity%3A%20.15%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%20%20%20%20.cls-2%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke%3A%20%23007cbb%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%3C%2Fstyle%3E%0A%20%20%20%20%3C%2Fdefs%3E%0A%20%20%20%20%3Ctitle%3EPreloader_72x2%3C%2Ftitle%3E%0A%20%20%20%20%3Ccircle%20class%3D%22cls-1%22%20cx%3D%2236%22%20cy%3D%2236%22%20r%3D%2233%22%2F%3E%0A%20%20%20%20%3Cpath%20class%3D%22cls-2%22%20d%3D%22M14.3%2C60.9A33%2C33%2C0%2C0%2C1%2C36%2C3%22%3E%0A%20%20%20%20%3C%2Fpath%3E%0A%3C%2Fsvg%3E%0A");
         text-indent: 100%;
         overflow: hidden
     }
     .spinner.spinner-md {
         min-height: 36px;
         min-width: 36px;
         height: 36px;
         width: 36px
     }
     .spinner.spinner-inline,
     .spinner.spinner-sm {
         min-height: 18px;
         min-width: 18px;
         height: 18px;
         width: 18px
     }
     .spinner.spinner-inline {
         vertical-align: text-bottom
     }
     .spinner.spinner-inverse {
         background: url("data:image/svg+xml;charset=utf8,%3Csvg%20id%3D%22Layer_2%22%20data-name%3D%22Layer%202%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2072%2072%22%3E%0A%20%20%20%20%3Cdefs%3E%0A%20%20%20%20%20%20%20%20%3Cstyle%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20.cls-1%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20.cls-2%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20fill%3A%20none%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke-miterlimit%3A%2010%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke-width%3A%205px%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%20%20%20%20.cls-1%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke%3A%20%23fff%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke-opacity%3A%20.15%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%20%20%20%20.cls-2%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20stroke%3A%20%23007cbb%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%3C%2Fstyle%3E%0A%20%20%20%20%3C%2Fdefs%3E%0A%20%20%20%20%3Ctitle%3EPreloader_72x2%3C%2Ftitle%3E%0A%20%20%20%20%3Ccircle%20class%3D%22cls-1%22%20cx%3D%2236%22%20cy%3D%2236%22%20r%3D%2233%22%2F%3E%0A%20%20%20%20%3Cpath%20class%3D%22cls-2%22%20d%3D%22M14.3%2C60.9A33%2C33%2C0%2C0%2C1%2C36%2C3%22%3E%0A%20%20%20%20%3C%2Fpath%3E%0A%3C%2Fsvg%3E%0A")
     }
     @-webkit-keyframes spin {
         0% {
             -webkit-transform: rotate(0deg);
             transform: rotate(0deg)
         }
         100% {
             -webkit-transform: rotate(360deg);
             transform: rotate(360deg)
         }
     }
     @keyframes spin {
         0% {
             -webkit-transform: rotate(0deg);
             transform: rotate(0deg)
         }
         100% {
             -webkit-transform: rotate(360deg);
             transform: rotate(360deg)
         }
     }
     .table {
         border-collapse: separate;
         border: 1px solid #ccc;
         border-radius: 3px;
         background-color: #fff;
         color: #565656;
         margin: 24px 0 0 0;
         max-width: 100%;
         width: 100%
     }
     .table th,
     .table td {
         font-size: 13px;
         line-height: 14px;
         border-top: 1px solid #eee;
         padding: 10px 12px 11px;
         text-align: left;
         vertical-align: top
     }
     .table th.left,
     .table td.left {
         text-align: left
     }
     .table th.left:first-child,
     .table td.left:first-child {
         padding-left: 6px
     }
     .table th {
         font-size: 11px;
         font-weight: 600;
         letter-spacing: .03em;
         background-color: #fafafa;
         vertical-align: bottom;
         border-bottom: 1px solid #ccc;
         border-top: 0 none
     }
     .table tbody tr:first-child td {
         border-top: 0 none
     }
     .table tbody+tbody {
         border-top: 1px solid #ccc
     }
     .table thead th:first-child {
         border-radius: 2px 0 0 0
     }
     .table thead th:last-child {
         border-radius: 0 2px 0 0
     }
     .table tbody:last-child tr:last-child td:first-child {
         border-radius: 0 0 0 2px
     }
     .table tbody:last-child tr:last-child td:last-child {
         border-radius: 0 0 2px 0
     }
     .table.table-vertical thead th {
         border: 0 none;
         border-radius: 0;
         display: none
     }
     .table.table-vertical th {
         border-bottom: 0;
         border-top: 1px solid #ccc;
         vertical-align: top
     }
     .table.table-vertical td,
     .table.table-vertical th {
         text-align: left;
         border-color: #ccc
     }
     .table.table-vertical td:first-child,
     .table.table-vertical th:first-child {
         border-right: 1px solid #ccc;
         background-color: #fafafa;
         font-weight: 600
     }
     .table.table-vertical tbody:first-of-type tr:first-child th,
     .table.table-vertical tbody:first-of-type tr:first-child td {
         border-top: 0 none
     }
     .table.table-vertical tbody:first-of-type tr:first-child th:first-child,
     .table.table-vertical tbody:first-of-type tr:first-child td:first-child {
         border-radius: 2px 0 0 0
     }
     .table.table-vertical tbody:first-of-type tr:first-child th:last-child,
     .table.table-vertical tbody:first-of-type tr:first-child td:last-child {
         border-radius: 0 2px 0 0
     }
     .table.table-vertical tbody:last-child tr:last-child th:first-child,
     .table.table-vertical tbody:last-child tr:last-child td:first-child {
         border-radius: 0 0 0 2px
     }
     .table.table-vertical tbody:last-child tr:last-child th:last-child,
     .table.table-vertical tbody:last-child tr:last-child td:last-child {
         border-radius: 0 0 2px 0
     }
     .table.table-noborder {
         border-radius: 0;
         box-shadow: none;
         background-color: transparent;
         border: 0
     }
     .table.table-noborder th {
         background-color: transparent;
         border-bottom-color: #ddd;
         border-top: 0 none
     }
     .table.table-noborder th:first-child {
         border-right: 0 none
     }
     .table.table-noborder td {
         border-top: 0 none;
         padding-top: 11px
     }
     .table.table-noborder td:first-child {
         border-right: 0 none
     }
     .table.table-noborder thead th:first-child,
     .table.table-noborder thead th:last-child {
         border-radius: 0
     }
     .table.table-noborder th,
     .table.table-noborder td {
         border-radius: 0 !important
     }
     .table.table-noborder th:first-child,
     .table.table-noborder td:first-child {
         padding-left: 0
     }
     .table.table-compact th,
     .table.table-compact td {
         padding-top: 4px;
         padding-bottom: 5px
     }
     .table.table-compact.table-noborder th,
     .table.table-compact.table-noborder td {
         padding-top: 5px;
         padding-bottom: 5px
     }
     .tooltip {
         display: inline-block;
         position: relative;
         text-align: left;
         overflow: visible
     }
     .tooltip>.tooltip-content {
         visibility: hidden;
         opacity: 0;
         transition: opacity 0.3s linear;
         z-index: 1070
     }
     .tooltip:hover {
         background: url("data:image/svg+xml;charset=UTF-8,%3Csvg+xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22+width%3D%221%22+height%3D%221%22+viewBox%3D%220+0+1+1%22%3E%3Ctitle%3Etransparent+bcg%3C%2Ftitle%3E%3C%2Fsvg%3E")
     }
     .tooltip:hover>.tooltip-content,
     .tooltip:focus>.tooltip-content {
         visibility: visible;
         opacity: 1
     }
     .tooltip:hover>.tooltip-content:empty,
     .tooltip:focus>.tooltip-content:empty {
         visibility: hidden;
         opacity: 0
     }
     .tooltip:focus {
         outline: 0
     }
     .tooltip:focus>:first-child {
         outline-offset: 1px;
         outline-width: 1px;
         outline-color: #3b99fc;
         outline-style: solid
     }
     .tooltip>.tooltip-content,
     .tooltip.tooltip-top-right>.tooltip-content,
     .tooltip .tooltip-content.tooltip-top-right {
         font-size: 13px;
         font-weight: 400;
         letter-spacing: normal;
         background: #000;
         border-radius: 3px;
         color: #fff;
         line-height: 18px;
         margin: 0;
         padding: 9px 12px;
         width: 240px;
         position: absolute;
         top: auto;
         bottom: 100%;
         left: 50%;
         right: auto;
         border-bottom-left-radius: 0;
         margin-bottom: 16px
     }
     .tooltip>.tooltip-content::before,
     .tooltip.tooltip-top-right>.tooltip-content::before,
     .tooltip .tooltip-content.tooltip-top-right::before {
         position: absolute;
         bottom: -9px;
         left: 0;
         top: auto;
         right: auto;
         content: '';
         border-left: 6px solid #000;
         border-top: 5px solid #000;
         border-right: 6px solid transparent;
         border-bottom: 5px solid transparent
     }
     .tooltip.tooltip-top-left>.tooltip-content,
     .tooltip .tooltip-content.tooltip-top-left {
         font-size: 13px;
         font-weight: 400;
         letter-spacing: normal;
         background: #000;
         border-radius: 3px;
         color: #fff;
         line-height: 18px;
         margin: 0;
         padding: 9px 12px;
         width: 240px;
         position: absolute;
         top: auto;
         bottom: 100%;
         right: 50%;
         left: auto;
         border-bottom-right-radius: 0;
         margin-bottom: 16px
     }
     .tooltip.tooltip-top-left>.tooltip-content::before,
     .tooltip .tooltip-content.tooltip-top-left::before {
         position: absolute;
         bottom: -9px;
         right: 0;
         top: auto;
         left: auto;
         content: '';
         border-right: 6px solid #000;
         border-top: 5px solid #000;
         border-left: 6px solid transparent;
         border-bottom: 5px solid transparent
     }
     .tooltip.tooltip-bottom-right>.tooltip-content,
     .tooltip .tooltip-content.tooltip-bottom-right {
         font-size: 13px;
         font-weight: 400;
         letter-spacing: normal;
         background: #000;
         border-radius: 3px;
         color: #fff;
         line-height: 18px;
         margin: 0;
         padding: 9px 12px;
         width: 240px;
         position: absolute;
         bottom: auto;
         top: 100%;
         left: 50%;
         right: auto;
         border-top-left-radius: 0;
         margin-top: 16px
     }
     .tooltip.tooltip-bottom-right>.tooltip-content::before,
     .tooltip .tooltip-content.tooltip-bottom-right::before {
         position: absolute;
         top: -9px;
         left: 0;
         bottom: auto;
         right: auto;
         content: '';
         border-left: 6px solid #000;
         border-bottom: 5px solid #000;
         border-right: 6px solid transparent;
         border-top: 5px solid transparent
     }
     .tooltip.tooltip-bottom-left>.tooltip-content,
     .tooltip .tooltip-content.tooltip-bottom-left {
         font-size: 13px;
         font-weight: 400;
         letter-spacing: normal;
         background: #000;
         border-radius: 3px;
         color: #fff;
         line-height: 18px;
         margin: 0;
         padding: 9px 12px;
         width: 240px;
         position: absolute;
         bottom: auto;
         top: 100%;
         right: 50%;
         left: auto;
         border-top-right-radius: 0;
         margin-top: 16px
     }
     .tooltip.tooltip-bottom-left>.tooltip-content::before,
     .tooltip .tooltip-content.tooltip-bottom-left::before {
         position: absolute;
         top: -9px;
         right: 0;
         bottom: auto;
         left: auto;
         content: '';
         border-right: 6px solid #000;
         border-bottom: 5px solid #000;
         border-left: 6px solid transparent;
         border-top: 5px solid transparent
     }
     .tooltip.tooltip-right>.tooltip-content,
     .tooltip .tooltip-content.tooltip-right {
         position: absolute;
         right: auto;
         left: 100%;
         top: 50%;
         bottom: auto;
         font-size: 13px;
         font-weight: 400;
         letter-spacing: normal;
         background: #000;
         border-radius: 3px;
         color: #fff;
         line-height: 18px;
         margin: 0;
         padding: 9px 12px;
         width: 240px;
         border-top-left-radius: 0;
         margin-left: 16px
     }
     .tooltip.tooltip-right>.tooltip-content::before,
     .tooltip .tooltip-content.tooltip-right::before {
         position: absolute;
         top: 0;
         left: -9px;
         bottom: auto;
         right: auto;
         content: '';
         border-top: 6px solid #000;
         border-right: 5px solid #000;
         border-bottom: 6px solid transparent;
         border-left: 5px solid transparent
     }
     .tooltip.tooltip-left>.tooltip-content,
     .tooltip .tooltip-content.tooltip-left {
         position: absolute;
         left: auto;
         right: 100%;
         top: 50%;
         bottom: auto;
         font-size: 13px;
         font-weight: 400;
         letter-spacing: normal;
         background: #000;
         border-radius: 3px;
         color: #fff;
         line-height: 18px;
         margin: 0;
         padding: 9px 12px;
         width: 240px;
         border-top-right-radius: 0;
         margin-right: 16px
     }
     .tooltip.tooltip-left>.tooltip-content::before,
     .tooltip .tooltip-content.tooltip-left::before {
         position: absolute;
         top: 0;
         right: -9px;
         bottom: auto;
         left: auto;
         content: '';
         border-top: 6px solid #000;
         border-left: 5px solid #000;
         border-bottom: 6px solid transparent;
         border-right: 5px solid transparent
     }
     .tooltip.tooltip-xs>.tooltip-content,
     .tooltip .tooltip-content.tooltip-xs {
         width: 72px
     }
     .tooltip.tooltip-sm>.tooltip-content,
     .tooltip .tooltip-content.tooltip-sm {
         width: 120px
     }
     .tooltip.tooltip-md>.tooltip-content,
     .tooltip .tooltip-content.tooltip-md {
         width: 240px
     }
     .tooltip.tooltip-lg>.tooltip-content,
     .tooltip .tooltip-content.tooltip-lg {
         width: 360px
     }
     .tooltip>.btn+.tooltip-content,
     .tooltip.tooltip-top-right>.btn+.tooltip-content,
     .tooltip.tooltip-top-left>.btn+.tooltip-content {
         margin-bottom: 10px
     }
     .tooltip.tooltip-bottom-right>.btn+.tooltip-content,
     .tooltip.tooltip-bottom-left>.btn+.tooltip-content {
         margin-top: 10px
     }
     .tooltip.tooltip-right>.btn+.tooltip-content {
         margin-left: 4px
     }
     .tooltip>.clr-icon {
         margin-right: 0
     }
     .tooltip clr-icon>svg {
         pointer-events: none
     }
     input[type=text],
     input[type=password],
     input[type=number],
     input[type=email],
     input[type=url],
     input[type=tel],
     input[type=date],
     input[type=time],
     input[type=datetime-local] {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         margin: 0;
         padding: 0;
         border: none;
         border-radius: 0;
         box-shadow: none;
         background: none;
         height: 24px;
         display: inline-block;
         min-width: 60px;
         border-bottom: 1px solid #9a9a9a;
         padding: 0 6px
     }
     input[type=text]:focus,
     input[type=password]:focus,
     input[type=number]:focus,
     input[type=email]:focus,
     input[type=url]:focus,
     input[type=tel]:focus,
     input[type=date]:focus,
     input[type=time]:focus,
     input[type=datetime-local]:focus {
         outline: 0
     }
     input[type=text]:not([readonly]),
     input[type=password]:not([readonly]),
     input[type=number]:not([readonly]),
     input[type=email]:not([readonly]),
     input[type=url]:not([readonly]),
     input[type=tel]:not([readonly]),
     input[type=date]:not([readonly]),
     input[type=time]:not([readonly]),
     input[type=datetime-local]:not([readonly]) {
         background: linear-gradient(to bottom, transparent 95%, #0094d2 95%) no-repeat;
         background-size: 0% 100%;
         transition: background-size 0.2s ease
     }
     input[type=text]:not([readonly]):focus,
     input[type=password]:not([readonly]):focus,
     input[type=number]:not([readonly]):focus,
     input[type=email]:not([readonly]):focus,
     input[type=url]:not([readonly]):focus,
     input[type=tel]:not([readonly]):focus,
     input[type=date]:not([readonly]):focus,
     input[type=time]:not([readonly]):focus,
     input[type=datetime-local]:not([readonly]):focus {
         border-bottom: 1px solid #0094d2;
         background-size: 100% 100%
     }
     input[type=text][readonly],
     input[type=password][readonly],
     input[type=number][readonly],
     input[type=email][readonly],
     input[type=url][readonly],
     input[type=tel][readonly],
     input[type=date][readonly],
     input[type=time][readonly],
     input[type=datetime-local][readonly] {
         border: none
     }
     input[type=text]:disabled,
     input[type=password]:disabled,
     input[type=number]:disabled,
     input[type=email]:disabled,
     input[type=url]:disabled,
     input[type=tel]:disabled,
     input[type=date]:disabled,
     input[type=time]:disabled,
     input[type=datetime-local]:disabled,
     input[type=button]:disabled,
     input[type=submit]:disabled,
     textarea:disabled {
         opacity: 0.5;
         cursor: not-allowed
     }
     textarea {
         resize: vertical;
         width: 100%;
         border: 1px solid #ccc;
         border-radius: 3px;
         padding: 12px 6px
     }
     textarea:focus {
         outline: 0;
         box-shadow: 0 0 2px 2px #6bc1e3
     }
     .checkbox {
         display: block
     }
     .checkbox-inline {
         display: inline-block
     }
     .checkbox,
     .checkbox-inline {
         position: relative
     }
     .checkbox input[type="checkbox"],
     .checkbox-inline input[type="checkbox"] {
         position: absolute;
         top: 4px;
         left: 0;
         opacity: 0;
         height: 16px;
         width: 16px
     }
     .checkbox label,
     .checkbox-inline label {
         position: relative;
         display: inline-block;
         min-height: 24px;
         padding-left: 22px;
         cursor: pointer;
         line-height: 24px
     }
     .checkbox input[type="checkbox"]+label::before,
     .checkbox-inline input[type="checkbox"]+label::before {
         position: absolute;
         top: 4px;
         left: 0;
         content: '';
         display: inline-block;
         height: 16px;
         width: 16px;
         border: 1px solid #9a9a9a;
         border-radius: 3px
     }
     .checkbox input[type="checkbox"]:focus+label::before,
     .checkbox-inline input[type="checkbox"]:focus+label::before {
         outline: 0;
         box-shadow: 0 0 2px 2px #6bc1e3
     }
     .checkbox input[type="checkbox"]+label::after,
     .checkbox-inline input[type="checkbox"]+label::after {
         position: absolute;
         content: '';
         display: none;
         height: 5px;
         width: 8px;
         border-left: 2px solid white;
         border-bottom: 2px solid white;
         top: 4px;
         left: 4px;
         -webkit-transform: translate(0, 4px) rotate(-45deg);
         -ms-transform: translate(0, 4px) rotate(-45deg);
         transform: translate(0, 4px) rotate(-45deg)
     }
     .checkbox input[type="checkbox"]:checked+label::before,
     .checkbox-inline input[type="checkbox"]:checked+label::before {
         background: #0094d2;
         border: none
     }
     .checkbox input[type="checkbox"]:checked+label::after,
     .checkbox-inline input[type="checkbox"]:checked+label::after {
         display: inline-block
     }
     .checkbox input[type="checkbox"]:indeterminate+label::before,
     .checkbox-inline input[type="checkbox"]:indeterminate+label::before {
         border: 1px solid #0094d2
     }
     .checkbox input[type="checkbox"]:indeterminate+label::after,
     .checkbox-inline input[type="checkbox"]:indeterminate+label::after {
         border-left: none;
         border-bottom-color: #0094d2;
         display: inline-block;
         -webkit-transform: translate(0, 4px);
         -ms-transform: translate(0, 4px);
         transform: translate(0, 4px)
     }
     .checkbox.disabled label,
     .checkbox-inline.disabled label {
         opacity: 0.5;
         cursor: not-allowed
     }
     .checkbox.disabled input[type="checkbox"]:checked+label::before,
     .checkbox-inline.disabled input[type="checkbox"]:checked+label::before {
         background-color: #ccc
     }
     .checkbox.disabled input[type="checkbox"]:checked+label::after,
     .checkbox-inline.disabled input[type="checkbox"]:checked+label::after {
         border-left: 2px solid #747474;
         border-bottom: 2px solid #747474
     }
     .radio {
         display: block
     }
     .radio-inline {
         display: inline-block
     }
     .radio,
     .radio-inline {
         position: relative
     }
     .radio input[type="radio"],
     .radio-inline input[type="radio"] {
         position: absolute;
         top: 4px;
         left: 0;
         opacity: 0;
         height: 16px;
         width: 16px
     }
     .radio label,
     .radio-inline label {
         position: relative;
         display: inline-block;
         min-height: 24px;
         padding-left: 22px;
         cursor: pointer;
         line-height: 24px
     }
     .radio label:empty,
     .radio-inline label:empty {
         padding-left: 0
     }
     .radio input[type="radio"]+label::before,
     .radio-inline input[type="radio"]+label::before {
         position: absolute;
         top: 4px;
         left: 0;
         content: '';
         display: inline-block;
         height: 16px;
         width: 16px;
         border: 1px solid #9a9a9a;
         border-radius: 50%
     }
     .radio input[type="radio"]:checked+label::before,
     .radio-inline input[type="radio"]:checked+label::before {
         box-shadow: inset 0 0 0 6px #0094d2;
         border: none
     }
     .radio input[type="radio"]:focus+label::before,
     .radio-inline input[type="radio"]:focus+label::before {
         outline: 0;
         box-shadow: 0 0 2px 2px #6bc1e3
     }
     .radio input[type="radio"]:focus:checked+label::before,
     .radio-inline input[type="radio"]:focus:checked+label::before {
         outline: 0;
         box-shadow: inset 0 0 0 6px #0094d2, 0 0 2px 2px #6bc1e3
     }
     .radio.disabled label,
     .radio-inline.disabled label {
         opacity: 0.5;
         cursor: not-allowed
     }
     .radio.disabled input[type="radio"]:checked+label::before,
     .radio-inline.disabled input[type="radio"]:checked+label::before {
         background-color: #ccc;
         box-shadow: inset 0 0 0 6px #747474
     }
     .select {
         position: relative
     }
     .select select {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         margin: 0;
         padding: 0;
         border: none;
         border-radius: 0;
         box-shadow: none;
         background: none;
         height: 24px;
         display: inline-block;
         min-width: 60px;
         border-bottom: 1px solid #9a9a9a;
         background: linear-gradient(to bottom, transparent 95%, #0094d2 95%) no-repeat;
         background-size: 0% 100%;
         transition: background-size 0.2s ease;
         position: relative;
         padding: 0 22px 0 6px;
         cursor: pointer;
         width: 100%;
         z-index: 2
     }
     .select select:focus {
         outline: 0
     }
     .select select:focus {
         border-bottom: 1px solid #0094d2;
         background-size: 100% 100%
     }
     .select select:hover,
     .select select:active {
         border-color: rgba(221, 221, 221, 0.5);
         background: rgba(221, 221, 221, 0.5)
     }
     .select select:disabled {
         opacity: 0.5;
         cursor: not-allowed
     }
     .select select::-ms-expand {
         display: none
     }
     .select::after {
         position: absolute;
         content: '';
         height: 10px;
         width: 10px;
         top: 7px;
         right: 6px;
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2012%2012%22%3E%0A%20%20%20%20%3Cdefs%3E%0A%20%20%20%20%20%20%20%20%3Cstyle%3E.cls-1%7Bfill%3A%239a9a9a%3B%7D%3C%2Fstyle%3E%0A%20%20%20%20%3C%2Fdefs%3E%0A%20%20%20%20%3Ctitle%3ECaret%3C%2Ftitle%3E%0A%20%20%20%20%3Cpath%20class%3D%22cls-1%22%20d%3D%22M6%2C9L1.2%2C4.2a0.68%2C0.68%2C0%2C0%2C1%2C1-1L6%2C7.08%2C9.84%2C3.24a0.68%2C0.68%2C0%2C1%2C1%2C1%2C1Z%22%2F%3E%0A%3C%2Fsvg%3E%0A");
         background-repeat: no-repeat;
         background-size: contain;
         vertical-align: middle;
         margin: 0
     }
     .select:hover::after {
         color: #747474
     }
     .select.disabled {
         opacity: 0.5;
         cursor: not-allowed
     }
     .select.disabled:hover::after {
         color: #9a9a9a
     }
     .select.disabled>select,
     .select select:disabled {
         opacity: 0.5;
         cursor: not-allowed
     }
     .select.disabled>select:hover,
     .select select:disabled:hover {
         background: none;
         border-color: #9a9a9a
     }
     .select.multiple::after {
         content: none
     }
     select[multiple],
     select[size] {
         padding: 0;
         background: #fff;
         border: 1px solid #ccc;
         border-radius: 3px;
         height: auto;
         min-width: 120px
     }
     select[multiple]:hover,
     select[multiple]:active,
     select[size]:hover,
     select[size]:active {
         background: #fff;
         border-color: #ccc
     }
     select[multiple] option,
     select[size] option {
         padding: 3px 6px
     }
     form,
     .form {
         padding-top: 12px
     }
     form label,
     form span,
     .form label,
     .form span {
         display: inline-block
     }
     form .form-block,
     .form .form-block {
         margin: 12px 0 36px 0
     }
     form .form-block>label,
     .form .form-block>label {
         font-size: 16px;
         letter-spacing: .01em;
         font-weight: 400;
         color: #000;
         margin-bottom: 6px
     }
     form .form-group,
     .form .form-group {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -ms-flex-wrap: wrap;
         flex-wrap: wrap;
         position: relative;
         padding-left: 228px;
         margin-bottom: 12px;
         font-size: 13px;
         letter-spacing: normal;
         line-height: 24px
     }
     form .form-group.row,
     .form .form-group.row {
         padding-left: 0;
         position: static
     }
     form .form-group>label:first-child,
     form .form-group>span:first-child,
     .form .form-group>label:first-child,
     .form .form-group>span:first-child {
         position: absolute;
         width: 204px;
         left: 0;
         top: 6px;
         margin: 0
     }
     form .form-group.row>[class*='col-']:first-child>label,
     form .form-group.row>[class*='col-']:first-child>span,
     .form .form-group.row>[class*='col-']:first-child>label,
     .form .form-group.row>[class*='col-']:first-child>span {
         position: static
     }
     form .form-group>label:first-child,
     form .form-group>span:first-child,
     form .form-group.row>[class*='col-']>label,
     form .form-group.row>[class*='col-']>span,
     .form .form-group>label:first-child,
     .form .form-group>span:first-child,
     .form .form-group.row>[class*='col-']>label,
     .form .form-group.row>[class*='col-']>span {
         color: #000
     }
     form .form-group>label:first-child.required:after,
     form .form-group>span:first-child.required:after,
     form .form-group.row>[class*='col-']>label.required:after,
     form .form-group.row>[class*='col-']>span.required:after,
     .form .form-group>label:first-child.required:after,
     .form .form-group>span:first-child.required:after,
     .form .form-group.row>[class*='col-']>label.required:after,
     .form .form-group.row>[class*='col-']>span.required:after {
         content: '*';
         font-size: 1.1em;
         color: #c92100;
         margin-left: 6px
     }
     form .form-group .form-control,
     .form .form-group .form-control {
         width: 100%
     }
     form .form-group>label:not(:first-child),
     form .form-group>span:not(:first-child),
     form .form-group>input[type=text],
     form .form-group input[type=password],
     form .form-group input[type=number],
     form .form-group input[type=email],
     form .form-group input[type=url],
     form .form-group input[type=tel],
     form .form-group input[type=date],
     form .form-group input[type=time],
     form .form-group input[type=datetime-local],
     form .form-group>.tooltip-validation,
     form .form-group>.select,
     form .form-group>.checkbox-inline,
     form .form-group>.radio-inline,
     form .form-group>button,
     form .form-group>a,
     form .form-group>input[type=button],
     form .form-group input[type=submit],
     form .form-group>.btn,
     .form .form-group>label:not(:first-child),
     .form .form-group>span:not(:first-child),
     .form .form-group>input[type=text],
     .form .form-group input[type=password],
     .form .form-group input[type=number],
     .form .form-group input[type=email],
     .form .form-group input[type=url],
     .form .form-group input[type=tel],
     .form .form-group input[type=date],
     .form .form-group input[type=time],
     .form .form-group input[type=datetime-local],
     .form .form-group>.tooltip-validation,
     .form .form-group>.select,
     .form .form-group>.checkbox-inline,
     .form .form-group>.radio-inline,
     .form .form-group>button,
     .form .form-group>a,
     .form .form-group>input[type=button],
     .form .form-group input[type=submit],
     .form .form-group>.btn {
         -webkit-box-flex: 0;
         -ms-flex: 0 1 auto;
         flex: 0 1 auto;
         margin-left: 0;
         margin-right: 12px
     }
     form .form-group>.btn.btn-link,
     .form .form-group>.btn.btn-link {
         margin-right: 0
     }
     form .form-group>.checkbox,
     form .form-group>.radio,
     .form .form-group>.checkbox,
     .form .form-group>.radio {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 100%;
         flex: 1 1 100%;
         margin-left: 0;
         margin-right: 24px
     }
     form .form-group>.toggle-switch,
     .form .form-group>.toggle-switch {
         -webkit-box-flex: 0;
         -ms-flex: 0 1 auto;
         flex: 0 1 auto;
         margin-left: 0;
         margin-right: 24px
     }
     form .form-group>textarea,
     .form .form-group>textarea {
         margin-left: 0;
         margin-right: 12px
     }
     form .form-group label,
     form .form-group span,
     form .form-group input[type=text],
     form .form-group input[type=password],
     form .form-group input[type=number],
     form .form-group input[type=email],
     form .form-group input[type=url],
     form .form-group input[type=tel],
     form .form-group input[type=date],
     form .form-group input[type=time],
     form .form-group input[type=datetime-local],
     form .form-group .tooltip-validation,
     form .form-group textarea,
     form .form-group .select,
     form .form-group .checkbox-inline,
     form .form-group .radio-inline,
     form .form-group .checkbox,
     form .form-group .radio,
     form .form-group .toggle-switch,
     form .form-group button,
     form .form-group a,
     form .form-group input[type=button],
     form .form-group input[type=submit],
     form .form-group .btn,
     .form .form-group label,
     .form .form-group span,
     .form .form-group input[type=text],
     .form .form-group input[type=password],
     .form .form-group input[type=number],
     .form .form-group input[type=email],
     .form .form-group input[type=url],
     .form .form-group input[type=tel],
     .form .form-group input[type=date],
     .form .form-group input[type=time],
     .form .form-group input[type=datetime-local],
     .form .form-group .tooltip-validation,
     .form .form-group textarea,
     .form .form-group .select,
     .form .form-group .checkbox-inline,
     .form .form-group .radio-inline,
     .form .form-group .checkbox,
     .form .form-group .radio,
     .form .form-group .toggle-switch,
     .form .form-group button,
     .form .form-group a,
     .form .form-group input[type=button],
     .form .form-group input[type=submit],
     .form .form-group .btn {
         margin-top: 6px;
         margin-bottom: 6px
     }
     form .form-group .btn-sm,
     form .form-group .alert-app-level .alert-item .btn,
     .alert-app-level .alert-item form .form-group .btn,
     .form .form-group .btn-sm,
     .form .form-group .alert-app-level .alert-item .btn,
     .alert-app-level .alert-item .form .form-group .btn {
         margin-top: 12px;
         margin-bottom: 12px
     }
     form .form-group .tooltip-validation,
     .form .form-group .tooltip-validation {
         height: 24px
     }
     form .form-group .tooltip-validation input,
     .form .form-group .tooltip-validation input {
         margin: 0
     }
     form .form-group .radio label,
     form .form-group .checkbox label,
     form .form-group .radio-inline label,
     form .form-group .checkbox-inline label,
     form .form-group .toggle-switch label,
     .form .form-group .radio label,
     .form .form-group .checkbox label,
     .form .form-group .radio-inline label,
     .form .form-group .checkbox-inline label,
     .form .form-group .toggle-switch label {
         margin-top: 0;
         margin-bottom: 0
     }
     @media screen and (max-width: 544px) {
         form .form-group,
         .form .form-group {
             padding-left: 0;
             margin-bottom: 24px
         }
         form .form-group>label:first-child,
         form .form-group>label:not(:first-child),
         form .form-group input[type=text],
         form .form-group input[type=password],
         form .form-group input[type=number],
         form .form-group input[type=email],
         form .form-group input[type=url],
         form .form-group input[type=tel],
         form .form-group input[type=date],
         form .form-group input[type=time],
         form .form-group input[type=datetime-local],
         form .form-group .tooltip-validation,
         form .form-group .select,
         form .form-group .toggle-switch,
         form .form-group .checkbox,
         form .form-group .radio,
         form .form-group .checkbox-inline,
         form .form-group .radio-inline,
         .form .form-group>label:first-child,
         .form .form-group>label:not(:first-child),
         .form .form-group input[type=text],
         .form .form-group input[type=password],
         .form .form-group input[type=number],
         .form .form-group input[type=email],
         .form .form-group input[type=url],
         .form .form-group input[type=tel],
         .form .form-group input[type=date],
         .form .form-group input[type=time],
         .form .form-group input[type=datetime-local],
         .form .form-group .tooltip-validation,
         .form .form-group .select,
         .form .form-group .toggle-switch,
         .form .form-group .checkbox,
         .form .form-group .radio,
         .form .form-group .checkbox-inline,
         .form .form-group .radio-inline {
             -webkit-box-flex: 1;
             -ms-flex: 1 1 100%;
             flex: 1 1 100%
         }
         form .form-group>label:first-child,
         .form .form-group>label:first-child {
             position: relative;
             margin: 0 0 12px 0
         }
         form .form-group>label:not(:first-child),
         form .form-group span,
         .form .form-group>label:not(:first-child),
         .form .form-group span {
             margin: 12px 12px 0 0
         }
         form .form-group .tooltip-validation input,
         .form .form-group .tooltip-validation input {
             margin: 0;
             width: 100%
         }
     }
     .tooltip.tooltip-validation>input {
         padding-right: 28px
     }
     .tooltip.tooltip-validation:hover>.tooltip-content {
         visibility: hidden;
         opacity: 0
     }
     .tooltip.tooltip-validation.invalid>input {
         border-bottom: 1px solid #c92100;
         background: linear-gradient(to bottom, transparent 95%, #c92100 95%);
         transition: none
     }
     .tooltip.tooltip-validation.invalid>input:focus+.tooltip-content {
         background: #c92100;
         visibility: visible;
         opacity: 1
     }
     .tooltip.tooltip-validation.invalid>input:focus+.tooltip-content,
     .tooltip.tooltip-validation.invalid.tooltip-top-right>input:focus+.tooltip-content,
     .tooltip.tooltip-validation.invalid.tooltip-bottom-right>input:focus+.tooltip-content {
         left: 100%;
         right: auto;
         margin-left: -14px
     }
     .tooltip.tooltip-validation.invalid.tooltip-top-left>input:focus+.tooltip-content,
     .tooltip.tooltip-validation.invalid.tooltip-bottom-left>input:focus+.tooltip-content {
         right: 0;
         left: auto;
         margin-right: 14px
     }
     .tooltip.tooltip-validation.invalid>.tooltip-content::before,
     .tooltip.tooltip-validation.invalid.tooltip-top-right>.tooltip-content::before {
         border-left-color: #c92100;
         border-top-color: #c92100;
         border-right-color: transparent;
         border-bottom-color: transparent
     }
     .tooltip.tooltip-validation.invalid.tooltip-top-left>.tooltip-content::before {
         border-right-color: #c92100;
         border-top-color: #c92100;
         border-left-color: transparent;
         border-bottom-color: transparent
     }
     .tooltip.tooltip-validation.invalid.tooltip-bottom-right>.tooltip-content::before {
         border-left-color: #c92100;
         border-bottom-color: #c92100;
         border-right-color: transparent;
         border-top-color: transparent
     }
     .tooltip.tooltip-validation.invalid.tooltip-bottom-left>.tooltip-content::before {
         border-right-color: #c92100;
         border-bottom-color: #c92100;
         border-left-color: transparent;
         border-top-color: transparent
     }
     .tooltip.tooltip-validation.invalid.tooltip-left>input:focus+.tooltip-content {
         right: 100%;
         left: auto;
         margin: 0 14px 0 0
     }
     .tooltip.tooltip-validation.invalid.tooltip-left>input:focus+.tooltip-content::before {
         border-top-color: #c92100;
         border-left-color: #c92100;
         border-bottom-color: transparent;
         border-right-color: transparent
     }
     .tooltip.tooltip-validation.invalid.tooltip-right>input:focus+.tooltip-content {
         left: 100%;
         right: auto;
         margin: 0 0 0 14px
     }
     .tooltip.tooltip-validation.invalid.tooltip-right>input:focus+.tooltip-content::before {
         border-top-color: #c92100;
         border-right-color: #c92100;
         border-bottom-color: transparent;
         border-left-color: transparent
     }
     .tooltip.tooltip-validation.invalid::before {
         position: absolute;
         content: '';
         height: 16px;
         width: 16px;
         top: 3px;
         right: 6px;
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20version%3D%221.1%22%20viewBox%3D%225%205%2026%2026%22%20preserveAspectRatio%3D%22xMidYMid%20meet%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%3E%3Cdefs%3E%3Cstyle%3E.clr-i-outline%7Bfill%3A%23a32100%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Ctitle%3Eexclamation-circle-line%3C%2Ftitle%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20class%3D%22clr-i-outline%20clr-i-outline-path-1%22%20d%3D%22M18%2C6A12%2C12%2C0%2C1%2C0%2C30%2C18%2C12%2C12%2C0%2C0%2C0%2C18%2C6Zm0%2C22A10%2C10%2C0%2C1%2C1%2C28%2C18%2C10%2C10%2C0%2C0%2C1%2C18%2C28Z%22%3E%3C%2Fpath%3E%3Cpath%20class%3D%22clr-i-outline%20clr-i-outline-path-2%22%20d%3D%22M18%2C20.07a1.3%2C1.3%2C0%2C0%2C1-1.3-1.3v-6a1.3%2C1.3%2C0%2C1%2C1%2C2.6%2C0v6A1.3%2C1.3%2C0%2C0%2C1%2C18%2C20.07Z%22%3E%3C%2Fpath%3E%3Ccircle%20class%3D%22clr-i-outline%20clr-i-outline-path-3%22%20cx%3D%2217.95%22%20cy%3D%2223.02%22%20r%3D%221.5%22%3E%3C%2Fcircle%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2Fsvg%3E");
         background-repeat: no-repeat;
         background-size: contain;
         vertical-align: middle;
         margin: 0
     }
     form.compact .form-block,
     .form.compact .form-block {
         margin: 12px 0 24px 0
     }
     form.compact .form-block>label,
     .form.compact .form-block>label {
         margin-bottom: 0
     }
     form.compact .form-group,
     .form.compact .form-group {
         margin-bottom: 0
     }
     _:-ms-input-placeholder input[type=text],
     _:-ms-input-placeholder input[type=password],
     _:-ms-input-placeholder input[type=number],
     _:-ms-input-placeholder input[type=email],
     _:-ms-input-placeholder input[type=url],
     _:-ms-input-placeholder input[type=tel],
     _:-ms-input-placeholder input[type=date],
     _:-ms-input-placeholder input[type=time],
     _:-ms-input-placeholder input[type=datetime-local],
     :root input[type=text],
     :root input[type=password],
     :root input[type=number],
     :root input[type=email],
     :root input[type=url],
     :root input[type=tel],
     :root input[type=date],
     :root input[type=time],
     :root input[type=datetime-local] {
         padding-bottom: 3px
     }
     @supports (-ms-ime-align: auto) {
         input[type=text],
         input[type=password],
         input[type=number],
         input[type=email],
         input[type=url],
         input[type=tel],
         input[type=date],
         input[type=time],
         input[type=datetime-local] {
             padding-bottom: 0
         }
     }
     .stack-header {
         font-weight: 400;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-align: end;
         -ms-flex-align: end;
         align-items: flex-end
     }
     .stack-header .stack-title {
         display: block;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         padding: 6px 0
     }
     .stack-header .stack-actions {
         display: block;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto
     }
     .stack-header .stack-actions .stack-action {
         margin: 0 0 6px 12px
     }
     .stack-header .stack-actions .stack-action.btn {
         min-width: 0;
         padding: 0 12px
     }
     .stack-header .stack-actions .stack-action.btn-link {
         margin-right: -12px
     }
     .stack-view {
         font-size: 13px;
         font-weight: 400;
         line-height: 24px;
         letter-spacing: normal;
         margin-top: 0;
         border: 1px solid #ccc;
         border-radius: 3px;
         overflow-y: auto;
         background-color: #fafafa;
         word-wrap: break-word;
         -webkit-mask-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAA5JREFUeNpiYGBgAAgwAAAEAAGbA+oJAAAAAElFTkSuQmCC)
     }
     .stack-view dd,
     .stack-view dt {
         -webkit-margin-start: 0;
         -moz-margin-start: 0;
         margin-inline-start: 0;
         margin-left: 0
     }
     .stack-view .stack-block {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-flow: row wrap;
         flex-flow: row wrap;
         border-bottom: 1px solid #ddd
     }
     .stack-view>.stack-block:last-child,
     .stack-view>:last-child .stack-block:last-of-type {
         border-bottom: none;
         box-shadow: 0 1px 0 #ddd
     }
     .stack-view .stack-block-changed>.stack-block-label {
         margin-left: -9px
     }
     .stack-view .stack-block-changed::before {
         content: " ";
         position: relative;
         width: 0;
         height: 0;
         border-top: 9px solid #006a91;
         border-right: 9px solid transparent
     }
     .stack-view .stack-block-label,
     .stack-view .stack-block-content {
         padding: 6px 12px;
         background-color: #fafafa
     }
     .stack-view .stack-block-label {
         font-size: 13px;
         font-weight: 500;
         line-height: 24px;
         letter-spacing: normal;
         color: #313131;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 40%;
         flex: 0 0 40%;
         max-width: 40%
     }
     .stack-view .stack-block-label::before {
         display: inline-block;
         content: "";
         float: left;
         height: 10px;
         width: 10px;
         margin: 7px 6px 0 0;
         text-align: center
     }
     .stack-view .stack-block-content {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         width: 60%;
         margin-bottom: 0;
         font-weight: 400
     }
     .stack-view .stack-block-content>:first-child {
         margin-top: 0
     }
     .stack-view .stack-block-content>:last-child {
         margin-bottom: 0
     }
     .stack-view .stack-children {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         width: 100%
     }
     .stack-view .stack-children .stack-block {
         border-bottom-color: #eee
     }
     .stack-view .stack-children>.stack-block:last-child,
     .stack-view .stack-children>:last-child .stack-block:last-of-type {
         border-bottom: none;
         box-shadow: 0 1px 0 #ddd
     }
     .stack-view .stack-children .stack-block-label,
     .stack-view .stack-children .stack-block-content {
         background-color: #fff
     }
     .stack-view .stack-children .stack-block-label {
         padding-left: 24px
     }
     .stack-view .stack-block-expandable>.stack-block-label {
         cursor: pointer
     }
     .stack-view .stack-block-expandable>.stack-block-label::before {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2012%2012%22%3E%0A%20%20%20%20%3Cdefs%3E%0A%20%20%20%20%20%20%20%20%3Cstyle%3E.cls-1%7Bfill%3A%239a9a9a%3B%7D%3C%2Fstyle%3E%0A%20%20%20%20%3C%2Fdefs%3E%0A%20%20%20%20%3Ctitle%3ECaret%3C%2Ftitle%3E%0A%20%20%20%20%3Cpath%20class%3D%22cls-1%22%20d%3D%22M6%2C9L1.2%2C4.2a0.68%2C0.68%2C0%2C0%2C1%2C1-1L6%2C7.08%2C9.84%2C3.24a0.68%2C0.68%2C0%2C1%2C1%2C1%2C1Z%22%2F%3E%0A%3C%2Fsvg%3E%0A");
         background-repeat: no-repeat;
         background-size: contain;
         vertical-align: middle;
         -webkit-transform: rotate(-90deg);
         -ms-transform: rotate(-90deg);
         transform: rotate(-90deg)
     }
     .stack-view .stack-block-expandable>.stack-block-label,
     .stack-view .stack-block-expandable>.stack-block-content {
         transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out
     }
     .stack-view .stack-block-expandable:hover:not(.stack-block-expanded)>.stack-block-label,
     .stack-view .stack-block-expandable:hover:not(.stack-block-expanded)>.stack-block-content {
         background-color: #eee
     }
     .stack-view .stack-block-expanded>.stack-block-label::before {
         -webkit-transform: rotate(0deg);
         -ms-transform: rotate(0deg);
         transform: rotate(0deg)
     }
     .stack-view .stack-block-expanded>.stack-block-label,
     .stack-view .stack-block-expanded>.stack-block-content {
         background-color: #D9E4EA;
         color: #000
     }
     .stack-view input[type=text],
     .stack-view input[type=password],
     .stack-view input[type=number],
     .stack-view input[type=email],
     .stack-view input[type=url],
     .stack-view input[type=tel],
     .stack-view input[type=date],
     .stack-view input[type=time],
     .stack-view input[type=datetime-local],
     .stack-view .select {
         display: inline-block;
         vertical-align: top;
         margin-right: 12px;
         margin-bottom: -1px
     }
     .stack-view input[type=text],
     .stack-view input[type=password],
     .stack-view input[type=number],
     .stack-view input[type=email],
     .stack-view input[type=url],
     .stack-view input[type=tel],
     .stack-view input[type=date],
     .stack-view input[type=time],
     .stack-view input[type=datetime-local],
     .stack-view .select select {
         height: 24px
     }
     .stack-view .stack-block-expandable>.stack-block-content input[type=text],
     .stack-view .stack-block-expandable>.stack-block-content input[type=password],
     .stack-view .stack-block-expandable>.stack-block-content input[type=number],
     .stack-view .stack-block-expandable>.stack-block-content input[type=email],
     .stack-view .stack-block-expandable>.stack-block-content input[type=url],
     .stack-view .stack-block-expandable>.stack-block-content input[type=tel],
     .stack-view .stack-block-expandable>.stack-block-content input[type=date],
     .stack-view .stack-block-expandable>.stack-block-content input[type=time],
     .stack-view .stack-block-expandable>.stack-block-content input[type=datetime-local] {
         transition: background-size 0.2s ease, border-bottom-color 0.2s ease-in-out
     }
     .stack-view .stack-block-expandable>.stack-block-content .select select {
         transition: border-bottom-color 0.2s ease-in-out
     }
     .stack-view .stack-block-expandable>.stack-block-content .select::after {
         transition: color 0.2s ease-in-out
     }
     .stack-view .stack-block-expanded>.stack-block-content input[type=text],
     .stack-view .stack-block-expanded>.stack-block-content input[type=password],
     .stack-view .stack-block-expanded>.stack-block-content input[type=number],
     .stack-view .stack-block-expanded>.stack-block-content input[type=email],
     .stack-view .stack-block-expanded>.stack-block-content input[type=url],
     .stack-view .stack-block-expanded>.stack-block-content input[type=tel],
     .stack-view .stack-block-expanded>.stack-block-content input[type=date],
     .stack-view .stack-block-expanded>.stack-block-content input[type=time],
     .stack-view .stack-block-expanded>.stack-block-content input[type=datetime-local] {
         border-bottom-color: #747474;
         background: linear-gradient(to bottom, transparent 95%, #007cbb 95%) no-repeat;
         background-size: 0% 100%;
         transition: background-size 0.2s ease
     }
     .stack-view .stack-block-expanded>.stack-block-content input[type=text]:focus,
     .stack-view .stack-block-expanded>.stack-block-content input[type=password]:focus,
     .stack-view .stack-block-expanded>.stack-block-content input[type=number]:focus,
     .stack-view .stack-block-expanded>.stack-block-content input[type=email]:focus,
     .stack-view .stack-block-expanded>.stack-block-content input[type=url]:focus,
     .stack-view .stack-block-expanded>.stack-block-content input[type=tel]:focus,
     .stack-view .stack-block-expanded>.stack-block-content input[type=date]:focus,
     .stack-view .stack-block-expanded>.stack-block-content input[type=time]:focus,
     .stack-view .stack-block-expanded>.stack-block-content input[type=datetime-local]:focus {
         border-bottom: 1px solid #007cbb;
         background-size: 100% 100%
     }
     .stack-view .stack-block-expanded>.stack-block-content .select select {
         border-bottom-color: #747474
     }
     .stack-view .stack-block-expanded>.stack-block-content .select::after {
         color: #747474
     }
     .modal .stack-view {
         height: 55vh;
         margin-bottom: 0
     }
     clr-tree-node {
         position: relative;
         display: block
     }
     @-moz-document url-prefix() {
         clr-tree-node {
             overflow-y: hidden
         }
     }
     clr-tree-node>clr-checkbox,
     clr-tree-node>.checkbox {
         position: absolute;
         display: inline-block
     }
     clr-tree-node>clr-checkbox,
     clr-tree-node>.checkbox {
         left: 30px;
         height: 30px
     }
     clr-tree-node>clr-checkbox>label,
     clr-tree-node>.checkbox>label {
         height: 30px;
         padding-left: 30px
     }
     clr-tree-node>clr-checkbox input[type="checkbox"]+label::before,
     clr-tree-node>.checkbox input[type="checkbox"]+label::before {
         top: 7px;
         left: 7px
     }
     clr-tree-node>clr-checkbox input[type="checkbox"]+label::after,
     clr-tree-node>.checkbox input[type="checkbox"]+label::after {
         top: 7px;
         left: 11px
     }
     .clr-treenode-caret {
         position: absolute;
         left: 0;
         top: 0;
         display: inline-block;
         margin: 0;
         padding: 0;
         height: 30px;
         width: 30px;
         border: 1px solid transparent;
         background: transparent;
         color: #9a9a9a;
         cursor: pointer;
         outline-offset: -5px
     }
     .clr-treenode-caret clr-icon {
         vertical-align: middle;
         height: 16px;
         width: 16px
     }
     .clr-treenode-caret:hover {
         color: #000
     }
     .clr-treenode-spinner {
         position: absolute;
         left: 7px;
         top: 7px;
         min-height: 16px;
         min-width: 16px;
         height: 16px;
         width: 16px
     }
     .clr-treenode-content {
         line-height: 30px;
         padding-left: 30px;
         border-radius: 3px 0 0 3px
     }
     clr-checkbox+.clr-treenode-content {
         padding-left: 60px
     }
     .clr-treenode-children {
         margin-left: 21px
     }
     .clr-tree--compact.clr-treenode>clr-checkbox,
     .clr-tree--compact.clr-treenode>.checkbox,
     .clr-tree--compact clr-tree-node>clr-checkbox,
     .clr-tree--compact clr-tree-node>.checkbox {
         left: 24px;
         height: 24px
     }
     .clr-tree--compact.clr-treenode>clr-checkbox>label,
     .clr-tree--compact.clr-treenode>.checkbox>label,
     .clr-tree--compact clr-tree-node>clr-checkbox>label,
     .clr-tree--compact clr-tree-node>.checkbox>label {
         height: 24px;
         padding-left: 24px
     }
     .clr-tree--compact.clr-treenode>clr-checkbox input[type="checkbox"]+label::before,
     .clr-tree--compact.clr-treenode>.checkbox input[type="checkbox"]+label::before,
     .clr-tree--compact clr-tree-node>clr-checkbox input[type="checkbox"]+label::before,
     .clr-tree--compact clr-tree-node>.checkbox input[type="checkbox"]+label::before {
         top: 4px;
         left: 4px
     }
     .clr-tree--compact.clr-treenode>clr-checkbox input[type="checkbox"]+label::after,
     .clr-tree--compact.clr-treenode>.checkbox input[type="checkbox"]+label::after,
     .clr-tree--compact clr-tree-node>clr-checkbox input[type="checkbox"]+label::after,
     .clr-tree--compact clr-tree-node>.checkbox input[type="checkbox"]+label::after {
         top: 4px;
         left: 8px
     }
     .clr-tree--compact.clr-treenode .clr-treenode-caret,
     .clr-tree--compact clr-tree-node .clr-treenode-caret {
         height: 24px;
         width: 24px
     }
     .clr-tree--compact.clr-treenode .clr-treenode-caret clr-icon,
     .clr-tree--compact clr-tree-node .clr-treenode-caret clr-icon {
         vertical-align: text-top
     }
     .clr-tree--compact.clr-treenode .clr-treenode-spinner,
     .clr-tree--compact clr-tree-node .clr-treenode-spinner {
         left: 4px;
         top: 4px
     }
     .clr-tree--compact.clr-treenode .clr-treenode-content,
     .clr-tree--compact clr-tree-node .clr-treenode-content {
         line-height: 24px;
         padding-left: 24px;
         border-radius: 3px 0 0 3px
     }
     .clr-tree--compact.clr-treenode clr-checkbox+.clr-treenode-content,
     .clr-tree--compact clr-tree-node clr-checkbox+.clr-treenode-content {
         padding-left: 48px
     }
     .clr-tree--compact.clr-treenode .clr-treenode-children,
     .clr-tree--compact clr-tree-node .clr-treenode-children {
         margin-left: 15px
     }
     .clr-treenode-link {
         display: inline-block;
         line-height: inherit;
         height: 100%;
         width: 100%;
         padding: 0 0 0 4px;
         margin: 0;
         background: transparent;
         border-radius: 3px 0 0 3px;
         border-color: transparent;
         color: #565656;
         cursor: pointer;
         text-align: left
     }
     .clr-treenode-link:link,
     .clr-treenode-link:visited,
     .clr-treenode-link:active,
     .clr-treenode-link:hover {
         color: inherit
     }
     .clr-treenode-link:hover,
     .clr-treenode-link:focus {
         text-decoration: none;
         background: #EEEEEE
     }
     .clr-treenode-link:focus {
         outline: 0
     }
     .clr-treenode-link.active {
         background: #D9E4EA;
         color: #000
     }
     .clr-treenode-content {
         white-space: nowrap;
         overflow: hidden;
         text-overflow: ellipsis
     }
     .clr-treenode-content clr-icon {
         height: 16px;
         width: 16px;
         margin-right: 6px;
         vertical-align: middle
     }
     .datagrid {
         border-collapse: separate;
         border: 1px solid #ccc;
         border-radius: 3px;
         background-color: #fff;
         color: #565656;
         margin: 24px 0 0 0;
         max-width: 100%;
         width: 100%
     }
     .datagrid .datagrid-column,
     .datagrid .datagrid-cell {
         font-size: 13px;
         line-height: 14px;
         border-top: 1px solid #eee;
         padding: 10px 12px 11px;
         text-align: center;
         vertical-align: top
     }
     .datagrid .datagrid-column.left,
     .datagrid .datagrid-cell.left {
         text-align: left
     }
     .datagrid .datagrid-column.left:first-child,
     .datagrid .datagrid-cell.left:first-child {
         padding-left: 6px
     }
     .datagrid .datagrid-column {
         font-size: 11px;
         font-weight: 600;
         letter-spacing: .03em;
         background-color: #fafafa;
         vertical-align: bottom;
         border-bottom: 1px solid #ccc;
         border-top: 0 none
     }
     .datagrid .datagrid-body .datagrid-row:first-child .datagrid-cell {
         border-top: 0 none
     }
     .datagrid .datagrid-body+.datagrid-body {
         border-top: 1px solid #ccc
     }
     .datagrid .datagrid-head .datagrid-column:first-child {
         border-radius: 2px 0 0 0
     }
     .datagrid .datagrid-head .datagrid-column:last-child {
         border-radius: 0 2px 0 0
     }
     .datagrid .datagrid-body:last-child .datagrid-row:last-child .datagrid-cell:first-child {
         border-radius: 0 0 0 2px
     }
     .datagrid .datagrid-body:last-child .datagrid-row:last-child .datagrid-cell:last-child {
         border-radius: 0 0 2px 0
     }
     .datagrid-host {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-flow: column nowrap;
         flex-flow: column nowrap
     }
     .datagrid-overlay-wrapper {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-direction: row;
         flex-direction: row;
         -webkit-box-flex: 0;
         -ms-flex: 0 auto;
         flex: 0 auto;
         width: 100%;
         min-height: 100%;
         overflow-x: auto;
         overflow-y: hidden
     }
     .datagrid-overlay-wrapper .datagrid-spinner {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 100%;
         flex: 0 0 100%;
         margin-left: -100%;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         background: rgba(255, 255, 255, 0.6)
     }
     .datagrid-scroll-wrapper {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-direction: row;
         flex-direction: row;
         min-width: 100%
     }
     .datagrid {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-flow: column nowrap;
         flex-flow: column nowrap;
         min-height: 1px
     }
     .datagrid-head,
     .datagrid-body,
     .datagrid-row,
     .datagrid-column,
     .datagrid-cell {
         display: block
     }
     .datagrid-table-wrapper {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-flow: column nowrap;
         flex-flow: column nowrap;
         min-height: 1px
     }
     .datagrid-body {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         overflow-y: auto;
         -ms-overflow-style: -ms-autohiding-scrollbar;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         min-height: 72px
     }
     .datagrid-head {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto
     }
     .datagrid-row-flex {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-flow: row nowrap;
         flex-flow: row nowrap
     }
     .datagrid-column {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto
     }
     .datagrid-column.datagrid-fixed-width {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto
     }
     .datagrid-column--hidden {
         display: none
     }
     .datagrid-cell {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto
     }
     .datagrid-cell.datagrid-fixed-width {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto
     }
     .datagrid-cell--hidden {
         display: none
     }
     .datagrid-computing-columns-width {
         display: table
     }
     .datagrid-computing-columns-width .datagrid-head {
         display: table-header-group
     }
     .datagrid-computing-columns-width .datagrid-body {
         display: table-row-group
     }
     .datagrid-computing-columns-width .datagrid-row {
         display: table-row
     }
     .datagrid-computing-columns-width .datagrid-row-master {
         display: none
     }
     .datagrid-computing-columns-width .datagrid-column,
     .datagrid-computing-columns-width .datagrid-cell {
         display: table-cell
     }
     .datagrid-computing-columns-width .datagrid-column-separator {
         display: none
     }
     .datagrid-computing-columns-width .datagrid-placeholder-container {
         display: none
     }
     .datagrid {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         width: auto;
         max-width: none
     }
     .datagrid .datagrid-body .datagrid-row:last-child .datagrid-cell:first-child {
         border-radius: 0
     }
     .datagrid .datagrid-body .datagrid-row:last-child .datagrid-cell:last-child {
         border-radius: 0
     }
     .datagrid .datagrid-head {
         background-color: #fafafa;
         border-bottom: 2px solid #ccc
     }
     .datagrid .datagrid-column,
     .datagrid .datagrid-cell {
         text-align: left;
         min-width: 96px
     }
     .datagrid .datagrid-column {
         vertical-align: top;
         background: none;
         border-bottom: 0
     }
     .datagrid .datagrid-column .datagrid-column-title {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         margin: 0;
         padding: 0;
         border: none;
         border-radius: 0;
         box-shadow: none;
         background: none;
         color: #565656;
         text-align: left;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         -ms-flex-item-align: start;
         align-self: flex-start
     }
     .datagrid .datagrid-column button.datagrid-column-title:hover {
         text-decoration: underline;
         cursor: pointer
     }
     .datagrid .datagrid-column .datagrid-column-separator {
         position: relative;
         left: 12px;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         width: 1px;
         -webkit-box-ordinal-group: 101;
         -ms-flex-order: 100;
         order: 100;
         margin-left: auto
     }
     .datagrid .datagrid-column .datagrid-column-separator::after {
         content: "";
         position: absolute;
         height: calc(100% + 11px);
         width: 1px;
         top: -5px;
         left: 0;
         background-color: #ddd
     }
     .datagrid .datagrid-column .datagrid-column-separator .datagrid-column-handle {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         margin: 0;
         padding: 0;
         border: none;
         border-radius: 0;
         box-shadow: none;
         background: none;
         display: block;
         position: absolute;
         width: 13px;
         right: -6px;
         top: -6px;
         cursor: col-resize;
         height: calc(100% + 11px);
         z-index: 1000
     }
     .datagrid .datagrid-column .datagrid-column-separator .datagrid-column-handle-tracker {
         position: absolute;
         right: 0;
         top: -12px;
         display: none;
         width: 0;
         height: 100vh;
         border-right: 1px dotted #89cbdf
     }
     .datagrid .datagrid-column .datagrid-column-separator .exceeded-max {
         border-right: 1px dotted rgba(230, 39, 0, 0.3)
     }
     .datagrid .datagrid-column:last-child .datagrid-column-separator {
         display: none
     }
     .datagrid .datagrid-column .datagrid-column-flex {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto
     }
     .datagrid .datagrid-column clr-dg-filter,
     .datagrid .datagrid-column clr-dg-string-filter {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-ordinal-group: 100;
         -ms-flex-order: 99;
         order: 99;
         margin-left: auto
     }
     .datagrid .datagrid-column.asc,
     .datagrid .datagrid-column.desc {
         font-weight: 600
     }
     .datagrid .datagrid-column.asc .datagrid-column-flex::after,
     .datagrid .datagrid-column.desc .datagrid-column-flex::after {
         content: "";
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         vertical-align: middle;
         width: 14px;
         height: 14px;
         margin-left: 3.5px;
         background-repeat: no-repeat;
         background-size: contain
     }
     .datagrid .datagrid-column.asc .datagrid-column-flex::after {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20id%3D%22Layer_1%22%20data-name%3D%22Layer%201%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cdefs%3E%3Cstyle%3E.cls-1%7Bfill%3A%23007cbb%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Ctitle%3Eicon%20artboards%20patch%202%20strokecenter%3C%2Ftitle%3E%3Cpath%20class%3D%22cls-1%22%20d%3D%22M8.5%2C3a0.5%2C0.5%2C0%2C0%2C0-.35.15l-3.5%2C3.5a0.5%2C0.5%2C0%2C0%2C0%2C.71.71L8.5%2C4.21l3.15%2C3.15a0.5%2C0.5%2C0%2C0%2C0%2C.71-0.71l-3.5-3.5A0.5%2C0.5%2C0%2C0%2C0%2C8.5%2C3Z%22%2F%3E%3Crect%20class%3D%22cls-1%22%20x%3D%228%22%20y%3D%224%22%20width%3D%221%22%20height%3D%2210%22%2F%3E%3C%2Fsvg%3E")
     }
     .datagrid .datagrid-column.desc .datagrid-column-flex::after {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20version%3D%221.1%22%20id%3D%22Layer_1%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%20x%3D%220px%22%20y%3D%220px%22%0A%09%20viewBox%3D%220%200%2016%2016%22%20style%3D%22enable-background%3Anew%200%200%2016%2016%3B%22%20xml%3Aspace%3D%22preserve%22%3E%0A%3Cstyle%20type%3D%22text%2Fcss%22%3E%0A%09.st0%7Bfill%3A%23007cbb%3B%7D%0A%3C%2Fstyle%3E%0A%3Ctitle%3Eicon%20artboards%20patch%202%20strokecenter%3C%2Ftitle%3E%0A%3Cpath%20class%3D%22st0%22%20d%3D%22M8.5%2C13c-0.1%2C0.1-0.3%2C0-0.4-0.1L4.6%2C9.4c-0.2-0.2-0.2-0.5%2C0-0.7s0.5-0.2%2C0.7%2C0l3.1%2C3.1l3.1-3.2%0A%09c0.2-0.2%2C0.5-0.2%2C0.7%2C0s0.2%2C0.5%2C0%2C0.7C12.2%2C9.3%2C8.6%2C12.9%2C8.5%2C13z%22%2F%3E%0A%3Crect%20x%3D%228%22%20y%3D%223%22%20class%3D%22st0%22%20width%3D%221%22%20height%3D%229.3%22%2F%3E%0A%3C%2Fsvg%3E")
     }
     .datagrid .datagrid-column .datagrid-filter-toggle {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         margin: 0;
         padding: 0;
         border: none;
         border-radius: 0;
         box-shadow: none;
         background: none;
         cursor: pointer;
         float: right;
         vertical-align: middle;
         width: 14px;
         height: 14px;
         margin: 0 3.5px;
         background-repeat: no-repeat;
         background-size: contain;
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cdefs%3E%3Cstyle%3E.cls-1%7Bfill%3A%239a9a9a%3Bfill-rule%3Aevenodd%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cpolygon%20class%3D%22cls-1%22%20points%3D%227%209.32%203%205.38%203%205%2013%205%2013%205.38%209%209.32%209%2012.21%207%2013.29%207%209.32%22%2F%3E%3C%2Fsvg%3E")
     }
     .datagrid .datagrid-column .datagrid-filter-toggle:hover {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cdefs%3E%3Cstyle%3E.cls-1%7Bfill%3A%23007cbb%3Bfill-rule%3Aevenodd%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cpolygon%20class%3D%22cls-1%22%20points%3D%227%209.32%203%205.38%203%205%2013%205%2013%205.38%209%209.32%209%2012.21%207%2013.29%207%209.32%22%2F%3E%3C%2Fsvg%3E")
     }
     .datagrid .datagrid-column .datagrid-filter-toggle.datagrid-filter-open {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cdefs%3E%3Cstyle%3E.cls-1%7Bfill%3A%23007cbb%3Bfill-rule%3Aevenodd%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cpolygon%20class%3D%22cls-1%22%20points%3D%227%209.32%203%205.38%203%205%2013%205%2013%205.38%209%209.32%209%2012.21%207%2013.29%207%209.32%22%2F%3E%3C%2Fsvg%3E")
     }
     .datagrid .datagrid-column .datagrid-filter-toggle.datagrid-filtered {
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cdefs%3E%3Cstyle%3E.cls-1%7Bfill%3A%23007cbb%3Bfill-rule%3Aevenodd%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cpolygon%20class%3D%22cls-1%22%20points%3D%227%209.32%203%205.38%203%205%2013%205%2013%205.38%209%209.32%209%2012.21%207%2013.29%207%209.32%22%2F%3E%3C%2Fsvg%3E"), url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cdefs%3E%3Cstyle%3E.cls-1%7Bfill%3Anone%3Bstroke%3A%23007cbb%3Bstroke-miterlimit%3A10%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Ccircle%20class%3D%22cls-1%22%20cx%3D%228%22%20cy%3D%228%22%20r%3D%227.5%22%2F%3E%3C%2Fsvg%3E")
     }
     .datagrid .datagrid-column .datagrid-filter {
         position: absolute;
         top: 100%;
         right: 0;
         margin-top: 4.8px;
         background: #fff;
         padding: 18px;
         border: 1px solid #ccc;
         box-shadow: 0 1px 3px rgba(116, 116, 116, 0.25);
         border-radius: 3px;
         font-weight: normal;
         z-index: 1000
     }
     .datagrid .datagrid-column .datagrid-filter .datagrid-filter-close-wrapper {
         text-align: right
     }
     .datagrid .datagrid-column .datagrid-filter .datagrid-filter-close-wrapper .close {
         float: none
     }
     .datagrid .datagrid-column .datagrid-filter .datagrid-filter-apply {
         margin-bottom: 0
     }
     .datagrid .datagrid-fixed-column {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 38px;
         flex: 0 0 38px;
         max-width: 38px;
         min-width: 38px
     }
     .datagrid .datagrid-select .radio label,
     .datagrid .datagrid-select .checkbox label {
         display: block;
         min-height: 14px;
         padding-left: 14px
     }
     .datagrid .datagrid-select .radio label::before,
     .datagrid .datagrid-select .radio label::after,
     .datagrid .datagrid-select .checkbox label::before,
     .datagrid .datagrid-select .checkbox label::after {
         top: 0
     }
     .datagrid .datagrid-foot-select.checkbox {
         display: block;
         line-height: inherit;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 34px;
         flex: 1 1 34px
     }
     .datagrid .datagrid-foot-select.checkbox+.column-switch-wrapper {
         margin-left: 2px
     }
     .datagrid .datagrid-foot-select.checkbox label {
         color: unset;
         cursor: default;
         opacity: 1;
         line-height: inherit
     }
     .datagrid .datagrid-foot-select.checkbox input[type="checkbox"]+label::before,
     .datagrid .datagrid-foot-select.checkbox input[type="checkbox"]+label::after {
         top: 8px
     }
     .datagrid .datagrid-foot-select.checkbox input[type="checkbox"]+label::after {
         border-left-color: #fff;
         border-bottom-color: #fff
     }
     .datagrid .datagrid-row-actions clr-icon {
         height: 14px;
         vertical-align: bottom
     }
     .datagrid .datagrid-signpost-trigger {
         height: 35px;
         padding: 0 12px 0
     }
     .datagrid .datagrid-expandable-caret {
         padding: 2px 4px 3px;
         text-align: center
     }
     .datagrid .datagrid-expandable-caret button {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         margin: 0;
         padding: 0;
         border: none;
         border-radius: 0;
         box-shadow: none;
         background: none;
         cursor: pointer;
         height: 30px;
         width: 30px
     }
     .datagrid .datagrid-expandable-caret clr-icon {
         color: #747474
     }
     .datagrid .datagrid-expandable-caret clr-icon svg {
         transition: -webkit-transform 0.2s ease-in-out;
         transition: transform 0.2s ease-in-out;
         transition: transform 0.2s ease-in-out, -webkit-transform 0.2s ease-in-out
     }
     .datagrid .datagrid-expandable-caret .spinner {
         margin-top: 6px
     }
     .datagrid .datagrid-expandable-caret.datagrid-column {
         padding: 10px 12px 11px
     }
     .datagrid .datagrid-body .datagrid-row {
         border-top: 1px solid #ddd;
         -ms-flex-negative: 0;
         flex-shrink: 0
     }
     .datagrid .datagrid-body .datagrid-row:first-child {
         border-top: 0
     }
     .datagrid .datagrid-body .datagrid-row:hover {
         background-color: #eee
     }
     .datagrid .datagrid-body .datagrid-row.datagrid-selected {
         color: #000;
         background-color: #D9E4EA
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow {
         position: absolute;
         background: #fff;
         padding: 6px 6px;
         margin-left: 6px;
         border: 1px solid #ccc;
         box-shadow: 0 1px 3px rgba(116, 116, 116, 0.25);
         border-radius: 3px;
         font-weight: normal;
         z-index: 1000;
         white-space: nowrap
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow::before {
         content: '';
         position: absolute;
         top: 50%;
         right: 100%;
         width: 0;
         height: 0;
         margin-top: -6px;
         border-right: 6px solid #ccc;
         border-top: 6px solid transparent;
         border-bottom: 6px solid transparent
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow::after {
         content: '';
         position: absolute;
         top: 50%;
         right: 100%;
         width: 0;
         height: 0;
         margin-top: -5px;
         border-right: 5px solid #fff;
         border-top: 5px solid transparent;
         border-bottom: 5px solid transparent
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item {
         font-size: 14px;
         letter-spacing: normal;
         background: transparent;
         border: 0;
         color: #565656;
         cursor: pointer;
         display: block;
         line-height: 23px;
         margin: 0;
         padding: 1px 24px 0;
         text-align: left;
         width: 100%
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item:hover,
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item:focus {
         text-decoration: none;
         background-color: #eee
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item.active {
         background: #D9E4EA;
         color: #000
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item:focus {
         outline: 0
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item.disabled,
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item:disabled {
         cursor: not-allowed;
         opacity: 0.4;
         -webkit-user-select: none;
         -moz-user-select: none;
         -ms-user-select: none;
         user-select: none
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item.disabled:hover {
         background: none
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item.disabled:active,
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item.disabled:focus {
         background: none;
         box-shadow: none
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-overflow .action-item clr-icon {
         vertical-align: middle;
         -webkit-transform: translate3d(0px, -1px, 0);
         transform: translate3d(0px, -1px, 0)
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-action-toggle {
         cursor: pointer;
         color: #565656;
         border: none;
         background: none;
         padding: 0
     }
     .datagrid .datagrid-body .datagrid-row.datagrid-selected .datagrid-action-toggle {
         color: #000
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-row-detail.datagrid-container {
         padding-top: 0
     }
     .datagrid .datagrid-body .datagrid-row .datagrid-row-detail .datagrid-cell {
         padding-top: 0
     }
     .datagrid .datagrid-cell {
         border-top: 0
     }
     .datagrid .datagrid-container {
         font-size: 13px;
         padding: 10px 12px 11px
     }
     .datagrid-placeholder-container {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center
     }
     .datagrid-placeholder {
         background: #fff;
         border-top: 1px solid #ddd;
         width: 100%
     }
     .datagrid-placeholder.datagrid-empty {
         border-top: 0;
         padding: 12px;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-flow: column nowrap;
         flex-flow: column nowrap;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center;
         font-size: 16px;
         color: #9a9a9a
     }
     .datagrid-placeholder.datagrid-empty .datagrid-placeholder-image {
         width: 60px;
         height: 60px;
         margin-bottom: 12px;
         background-repeat: no-repeat;
         background-size: contain;
         background-position: center;
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20viewBox%3D%220%200%2060%2072%22%20version%3D%221.1%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%3E%0A%20%20%20%20%3Cdefs%3E%0A%20%20%20%20%20%20%20%20%3Cellipse%20id%3D%22path-1%22%20cx%3D%2230%22%20cy%3D%2261.7666667%22%20rx%3D%2215.4512904%22%20ry%3D%224.73333333%22%3E%3C%2Fellipse%3E%0A%20%20%20%20%20%20%20%20%3Cmask%20id%3D%22mask-2%22%20maskContentUnits%3D%22userSpaceOnUse%22%20maskUnits%3D%22objectBoundingBox%22%20x%3D%220%22%20y%3D%220%22%20width%3D%2230.9025808%22%20height%3D%229.46666667%22%20fill%3D%22white%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cuse%20xlink%3Ahref%3D%22%23path-1%22%3E%3C%2Fuse%3E%0A%20%20%20%20%20%20%20%20%3C%2Fmask%3E%0A%20%20%20%20%3C%2Fdefs%3E%0A%20%20%20%20%3Cg%20id%3D%22Page-1%22%20stroke%3D%22none%22%20stroke-width%3D%221%22%20fill%3D%22none%22%20fill-rule%3D%22evenodd%22%3E%0A%20%20%20%20%20%20%20%20%3Cg%20id%3D%22Artboard%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cuse%20id%3D%22Oval-10%22%20stroke%3D%22%23C1DFEF%22%20mask%3D%22url(%23mask-2)%22%20stroke-width%3D%222.8%22%20stroke-linecap%3D%22square%22%20stroke-dasharray%3D%223%2C6%2C3%2C5%22%20xlink%3Ahref%3D%22%23path-1%22%3E%3C%2Fuse%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20d%3D%22M38.4613647%2C18.1642456%20L30.9890137%2C34.9141846%20L31%2C47%20L32.5977783%2C46.5167236%20L32.5977783%2C34.9141846%20L51.0673218%2C15.7560425%20C51.0673218%2C15.7560425%2048.6295166%2C16.6542969%2044.9628906%2C17.3392334%20C41.2962646%2C18.0241699%2038.4613647%2C18.1642456%2038.4613647%2C18.1642456%20Z%22%20id%3D%22Path-195%22%20fill%3D%22%23C1DFEF%22%3E%3C%2Fpath%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20d%3D%22M4.74639226%2C12.5661855%20L4.62065726%2C12.1605348%20L5.3515414%2C11.1625044%20L5.77622385%2C11.159939%20L6.20936309%2C12.5573481%20L4.74639226%2C12.5661855%20Z%20M6.20936309%2C12.5573481%20L6.32542632%2C12.9317954%20L28.4963855%2C34.8796718%20L28.4963855%2C47.8096691%20L32.6%2C46.4836513%20L32.6%2C34.8992365%20L53.973494%2C12.7035813%20L53.973494%2C12.2688201%20L6.20936309%2C12.5573481%20Z%20M55.373494%2C10.8603376%20L55.373494%2C13.2680664%20L34%2C35.4637216%20L34%2C47.5025401%20L27.0963855%2C49.7333333%20L27.0963855%2C35.4637219%20L5.09179688%2C13.680542%20L4.31325301%2C11.1687764%20L55.373494%2C10.8603376%20Z%22%20id%3D%22Path-149%22%20fill%3D%22%237FBDDD%22%3E%3C%2Fpath%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cellipse%20id%3D%22Oval-9%22%20fill%3D%22%23FFFFFF%22%20cx%3D%2230%22%20cy%3D%2211.785654%22%20rx%3D%2226%22%20ry%3D%226.78565401%22%3E%3C%2Fellipse%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20d%3D%22M30%2C17.171308%20C36.8772177%2C17.171308%2043.3112282%2C16.4610701%2048.0312371%2C15.2292106%20C50.2777611%2C14.6428977%2052.0507619%2C13.9579677%2053.2216231%2C13.2354973%20C54.1938565%2C12.6355886%2054.6%2C12.1175891%2054.6%2C11.785654%20C54.6%2C11.4537189%2054.1938565%2C10.9357194%2053.2216231%2C10.3358107%20C52.0507619%2C9.61334032%2050.2777611%2C8.92841034%2048.0312371%2C8.34209746%20C43.3112282%2C7.11023795%2036.8772177%2C6.4%2030%2C6.4%20C23.1227823%2C6.4%2016.6887718%2C7.11023795%2011.9687629%2C8.34209746%20C9.72223886%2C8.92841034%207.94923814%2C9.61334032%206.77837689%2C10.3358107%20C5.8061435%2C10.9357194%205.4%2C11.4537189%205.4%2C11.785654%20C5.4%2C12.1175891%205.8061435%2C12.6355886%206.77837689%2C13.2354973%20C7.94923814%2C13.9579677%209.72223886%2C14.6428977%2011.9687629%2C15.2292106%20C16.6887718%2C16.4610701%2023.1227823%2C17.171308%2030%2C17.171308%20Z%20M30%2C18.571308%20C15.6405965%2C18.571308%204%2C15.5332672%204%2C11.785654%20C4%2C8.03804078%2015.6405965%2C5%2030%2C5%20C44.3594035%2C5%2056%2C8.03804078%2056%2C11.785654%20C56%2C15.5332672%2044.3594035%2C18.571308%2030%2C18.571308%20Z%22%20id%3D%22Oval-9-Copy%22%20fill%3D%22%237FBDDD%22%3E%3C%2Fpath%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Cpath%20d%3D%22M18.2608643%2C7.14562988%20L22.727356%2C16.9047241%20C22.727356%2C16.9047241%2015.3006592%2C16.3911743%2010.276001%2C14.7511597%20C5.25134277%2C13.111145%205.38031006%2C11.8284302%205.38031006%2C11.6882935%20C5.38031006%2C10.4832831%208.16633152%2C9.41877716%2011.114563%2C8.57324219%20C14.549319%2C7.58817492%2018.2608643%2C7.14562988%2018.2608643%2C7.14562988%20Z%22%20id%3D%22Path-196%22%20fill%3D%22%23C1DFEF%22%3E%3C%2Fpath%3E%0A%20%20%20%20%20%20%20%20%3C%2Fg%3E%0A%20%20%20%20%3C%2Fg%3E%0A%3C%2Fsvg%3E")
     }
     .datagrid-action-bar {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-flow: row nowrap;
         flex-flow: row nowrap;
         -webkit-box-align: stretch;
         -ms-flex-align: stretch;
         align-items: stretch;
         -webkit-transform: translateY(12px);
         -ms-transform: translateY(12px);
         transform: translateY(12px)
     }
     .datagrid-foot {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-flow: row nowrap;
         flex-flow: row nowrap;
         -webkit-box-pack: end;
         -ms-flex-pack: end;
         justify-content: flex-end;
         -webkit-box-align: stretch;
         -ms-flex-align: stretch;
         align-items: stretch;
         height: 36px;
         padding: 0 12px;
         line-height: 33px;
         font-size: 11px;
         background-color: #fafafa;
         border-top: 2px solid #ccc;
         border-radius: 0 0 3px 3px
     }
     .datagrid-foot .pagination {
         margin-left: 36px;
         height: 34px
     }
     .datagrid-foot .column-switch-wrapper {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 24px;
         flex: 1 1 24px
     }
     .datagrid-foot .column-switch-wrapper .column-toggle--action {
         min-width: 18px;
         padding-left: 0;
         padding-right: 0
     }
     .datagrid-foot .column-switch-wrapper .column-toggle--action clr-icon {
         color: #9a9a9a
     }
     .datagrid-foot .column-switch-wrapper .column-toggle--action clr-icon:hover {
         color: #007cbb
     }
     .datagrid-foot .column-switch-wrapper .column-toggle--action clr-icon--active,
     .datagrid-foot .column-switch-wrapper .column-toggle--action clr-icon .active {
         color: #007cbb
     }
     .datagrid-foot .column-switch-wrapper .column-switch {
         border-radius: 3px;
         padding: 18px;
         background-color: #fff;
         border: 1px solid #ccc;
         box-shadow: 0 1px 3px rgba(116, 116, 116, 0.25);
         width: 250px;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column
     }
     .datagrid-foot .column-switch-wrapper .column-switch .switch-header {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: justify;
         -ms-flex-pack: justify;
         justify-content: space-between;
         font-weight: 400;
         font-size: 16px;
         padding-bottom: 12px
     }
     .datagrid-foot .column-switch-wrapper .column-switch .switch-header button {
         min-width: 18px;
         margin: 0;
         padding: 0;
         color: #9a9a9a
     }
     .datagrid-foot .column-switch-wrapper .column-switch .switch-header button:hover {
         color: #007cbb
     }
     .datagrid-foot .column-switch-wrapper .column-switch .switch-content {
         max-height: 300px;
         overflow-y: auto;
         min-height: 25px
     }
     .datagrid-foot .column-switch-wrapper .column-switch .switch-content li {
         line-height: 24px;
         padding-left: 2px
     }
     .datagrid-foot .column-switch-wrapper .column-switch .switch-footer .btn {
         margin: 0;
         padding: 0
     }
     .datagrid-foot .column-switch-wrapper .column-switch .switch-footer .action-right {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: end;
         -ms-flex-pack: end;
         justify-content: flex-end
     }
     .datagrid-foot-description {
         display: block;
         white-space: nowrap
     }
     .pagination {
         list-style: none;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-flow: row nowrap;
         flex-flow: row nowrap;
         -webkit-box-pack: center;
         -ms-flex-pack: center;
         justify-content: center;
         -webkit-box-align: stretch;
         -ms-flex-align: stretch;
         align-items: stretch
     }
     .pagination>* {
         padding: 0 2.4px;
         margin-left: 7.2px
     }
     .pagination>*:first-child {
         margin-left: 0
     }
     .pagination .pagination-current {
         font-weight: 600;
         border-bottom: 2px solid #007cbb
     }
     .pagination .pagination-previous,
     .pagination .pagination-next {
         display: inline-block;
         vertical-align: middle;
         width: 14px;
         height: 14px;
         background-repeat: no-repeat;
         background-size: contain
     }
     .pagination .pagination-previous {
         margin-right: 6px;
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cdefs%3E%3Cstyle%3E.cls-3%7Bfill%3A%23747474%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cg%3E%3Cpolygon%20class%3D%22cls-3%22%20points%3D%2210.15%2014.72%203.44%208%2010.15%201.28%2011%202.13%205.14%208%2011%2013.87%2010.15%2014.72%22%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E")
     }
     .pagination .pagination-next {
         margin-left: 6px;
         background-image: url("data:image/svg+xml;charset=utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20xmlns%3Axlink%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cdefs%3E%3Cstyle%3E.cls-1%7Bfill%3A%23747474%3B%7D%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cg%3E%3Cpolygon%20class%3D%22cls-1%22%20points%3D%225.85%2014.72%2012.56%208%205.85%201.28%205%202.13%2010.86%208%205%2013.87%205.85%2014.72%22%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E")
     }
     .pagination button {
         -webkit-appearance: none;
         -moz-appearance: none;
         -ms-appearance: none;
         -o-appearance: none;
         margin: 0;
         padding: 0;
         border: none;
         border-radius: 0;
         box-shadow: none;
         background: none;
         color: #747474;
         cursor: pointer
     }
     .datagrid-cell-width-zero {
         border: 0 !important;
         padding: 0 !important;
         width: 0;
         -webkit-box-flex: 0 !important;
         -ms-flex: 0 0 auto !important;
         flex: 0 0 auto !important;
         min-width: 0 !important
     }
     .fade {
         opacity: 0;
         transition: opacity .2s ease-in-out;
         will-change: opacity
     }
     .fade.in {
         opacity: 1
     }
     .fadeDown {
         opacity: 0;
         -webkit-transform: translate(0, -25%);
         -ms-transform: translate(0, -25%);
         transform: translate(0, -25%);
         transition: opacity .2s ease-in-out, -webkit-transform .2s ease-in-out;
         transition: opacity .2s ease-in-out, transform .2s ease-in-out;
         transition: opacity .2s ease-in-out, transform .2s ease-in-out, -webkit-transform .2s ease-in-out;
         will-change: opacity, transform
     }
     .fadeDown.in {
         opacity: 1;
         -webkit-transform: translate(0, 0);
         -ms-transform: translate(0, 0);
         transform: translate(0, 0)
     }
     @media screen {
         section[aria-hidden="true"] {
             display: none
         }
     }
     [data-hidden="true"] {
         display: none
     }
     button.nav-link {
         border-radius: 0;
         text-transform: capitalize;
         min-width: 0
     }
     .tabs-overflow {
         position: relative
     }
     .tabs-overflow .nav-item {
         margin-right: 0
     }
     .clr-wizard .modal-dialog {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         -webkit-box-pack: justify;
         -ms-flex-pack: justify;
         justify-content: space-between;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         box-shadow: 0 1px 2px 2px rgba(0, 0, 0, 0.2);
         height: 50%;
         max-height: 100%
     }
     .clr-wizard .modal-content {
         border-radius: 0 3px 3px 0;
         box-shadow: none;
         padding: 0;
         -webkit-box-flex: 2;
         -ms-flex: 2 2 auto;
         flex: 2 2 auto;
         width: 66%;
         height: 100%;
         overflow: hidden;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: justify;
         -ms-flex-pack: justify;
         justify-content: space-between;
         -webkit-box-align: start;
         -ms-flex-align: start;
         align-items: flex-start;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column
     }
     .clr-wizard .modal-header {
         -webkit-box-flex: 0;
         -ms-flex: 0 0 auto;
         flex: 0 0 auto;
         width: 100%;
         padding: 24px 19px 6px 24px;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: reverse;
         -ms-flex-direction: row-reverse;
         flex-direction: row-reverse;
         -webkit-box-pack: justify;
         -ms-flex-pack: justify;
         justify-content: space-between;
         -webkit-box-align: start;
         -ms-flex-align: start;
         align-items: flex-start
     }
     .clr-wizard .modal-title {
         color: #313131;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-direction: row;
         flex-direction: row;
         width: 100%
     }
     .clr-wizard .modal-body {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         color: #565656;
         width: 100%
     }
     .clr-wizard .modal-footer {
         padding: 0;
         display: block;
         padding-top: 24px;
         height: 84px;
         min-height: 84px;
         max-height: 84px;
         width: 100%;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 84px;
         flex: 0 0 84px
     }
     .clr-wizard .clr-wizard-btn {
         margin: 0;
         max-width: 100%;
         display: block
     }
     .clr-wizard .modal-title-text {
         display: inline-block;
         -webkit-box-flex: 0;
         -ms-flex: 0 1 auto;
         flex: 0 1 auto;
         width: 100%
     }
     .clr-wizard .modal-header-actions-wrapper {
         -webkit-box-flex: 1;
         -ms-flex: 1 0 auto;
         flex: 1 0 auto;
         padding-left: 12px;
         padding-right: 4px
     }
     .clr-wizard .clr-wizard-header-action {
         width: 24px;
         height: 24px;
         padding: 0;
         margin: 0;
         min-width: 24px;
         line-height: 24px;
         font-size: 26px;
         color: #747474;
         transition: color linear 0.2s
     }
     .clr-wizard .clr-wizard-header-action a {
         color: #747474
     }
     .clr-wizard .clr-wizard-header-action:hover,
     .clr-wizard .clr-wizard-header-action:active,
     .clr-wizard .clr-wizard-header-action:focus {
         color: #313131
     }
     .clr-wizard .clr-wizard-header-action clr-icon {
         height: 22px;
         width: 22px
     }
     .clr-wizard .clr-wizard-stepnav-wrapper {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         width: 34%;
         max-width: 34%;
         display: block;
         -webkit-box-ordinal-group: 0;
         -ms-flex-order: -1;
         order: -1;
         overflow: hidden;
         overflow-y: auto;
         padding-bottom: 24px;
         line-height: 24px;
         border-right: 1px solid #e4e4e4;
         height: 100%;
         background-color: #fafafa;
         border-radius: 3px 0 0 3px
     }
     .clr-wizard .clr-wizard-stepnav {
         padding-left: 24px;
         display: block;
         font-size: 14px;
         color: #565656;
         width: 100%
     }
     .clr-wizard .clr-wizard-stepnav-list {
         display: block;
         box-shadow: none;
         counter-reset: a;
         white-space: nowrap;
         height: auto;
         list-style-type: none;
         margin: 0;
         width: 100%
     }
     .clr-wizard .clr-wizard-stepnav-item {
         display: block;
         box-shadow: 4px 0 0 #eee inset;
         margin: 0 0 -1px 0;
         padding: 6px 0;
         padding-left: 8px;
         color: #565656;
         font-weight: 400
     }
     .clr-wizard .clr-wizard-stepnav-item.active {
         color: #313131;
         font-weight: 500
     }
     .clr-wizard .clr-wizard-stepnav-item.active .clr-wizard-stepnav-link {
         background-color: #D9E4EA;
         border-radius: 3px 0 0 3px
     }
     .clr-wizard .clr-wizard-stepnav-item.complete {
         box-shadow: 4px 0 0 #60b515 inset;
         transition: box-shadow 0.2s ease-in
     }
     .clr-wizard .clr-wizard-stepnav-item.no-click button {
         pointer-events: none
     }
     .clr-wizard .clr-wizard-stepnav-link {
         width: 100%;
         display: inline-block;
         color: inherit;
         line-height: 16px;
         padding: 10px 3px 10px 10px;
         font-size: 14px;
         font-weight: inherit;
         letter-spacing: normal;
         text-align: left;
         text-transform: none;
         margin: 0
     }
     .clr-wizard .clr-wizard-stepnav-link::before {
         content: counter(a);
         counter-increment: a;
         padding-right: 7px;
         min-width: 15px
     }
     .clr-wizard .clr-wizard-title {
         color: #313131;
         margin-top: 0;
         padding-top: 24px;
         padding-left: 24px;
         padding-right: 12px;
         padding-bottom: 24px
     }
     .clr-wizard .modal-content-wrapper {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-direction: row;
         flex-direction: row;
         -webkit-box-flex: 1;
         -ms-flex: 1 1 100%;
         flex: 1 1 100%;
         width: 100%;
         height: 100%
     }
     .clr-wizard .clr-wizard-footer-buttons {
         text-align: right;
         padding-right: 24px;
         margin: 0
     }
     .clr-wizard .clr-wizard-footer-buttons-wrapper {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-direction: row;
         flex-direction: row;
         -ms-flex-wrap: nowrap;
         flex-wrap: nowrap;
         -webkit-box-pack: end;
         -ms-flex-pack: end;
         justify-content: flex-end
     }
     .clr-wizard .clr-wizard-btn-wrapper {
         -webkit-box-flex: 0;
         -ms-flex: 0 1 auto;
         flex: 0 1 auto;
         min-width: 84px;
         padding-left: 12px
     }
     .clr-wizard .clr-wizard-btn-wrapper[aria-hidden="true"] {
         display: none
     }
     .clr-wizard .clr-wizard-btn.btn-link {
         padding: 0
     }
     .clr-wizard .clr-wizard-content {
         display: block
     }
     .clr-wizard .clr-wizard-page:not([aria-hidden="true"]) {
         padding: 24px;
         padding-top: 18px;
         display: block
     }
     .clr-wizard .modal-dialog {
         height: 75vh
     }
     .clr-wizard .modal-body {
         max-height: 100%
     }
     .clr-wizard.wizard-md .modal-dialog {
         min-height: 420px;
         max-height: 504px
     }
     .clr-wizard.wizard-md .modal-content,
     .clr-wizard.wizard-md .clr-wizard-stepnav-wrapper {
         max-height: 504px
     }
     .clr-wizard.wizard-md .clr-wizard-stepnav-wrapper {
         min-width: 216px;
         max-width: 240px
     }
     .clr-wizard.wizard-lg .modal-dialog {
         min-height: 420px;
         max-height: 720px
     }
     .clr-wizard.wizard-lg .modal-content,
     .clr-wizard.wizard-lg .clr-wizard-stepnav-wrapper {
         max-height: 720px
     }
     .clr-wizard.wizard-lg .nav-panel,
     .clr-wizard.wizard-lg .clr-wizard-stepnav-wrapper {
         min-width: 240px;
         max-width: 288px
     }
     .clr-wizard.wizard-xl .modal-dialog {
         height: 75vh
     }
     .clr-wizard.wizard-xl .modal-content,
     .clr-wizard.wizard-xl .clr-wizard-stepnav-wrapper {
         max-height: 75vh
     }
     .clr-wizard.wizard-xl .nav-panel,
     .clr-wizard.wizard-xl .clr-wizard-stepnav-wrapper {
         min-width: 240px;
         max-width: 312px
     }
     .clr-wizard .spinner:not(.spinner-inline) {
         left: calc(50% + 115px);
         position: absolute;
         top: 40%
     }
     .clr-wizard-page>*:first-child {
         margin-top: 0
     }
     .clr-wizard-page>*:first-child>*:first-child {
         margin-top: 0
     }
     .clr-wizard-page>form:first-child {
         padding-top: 0
     }
     .clr-wizard-page>form:first-child>.form-block:first-child {
         margin-top: 0
     }
     .clr-wizard--ghosted .modal-dialog {
         display: block;
         box-shadow: none
     }
     .clr-wizard--ghosted .modal-outer-wrapper {
         position: static;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: justify;
         -ms-flex-pack: justify;
         justify-content: space-between;
         -webkit-box-align: center;
         -ms-flex-align: center;
         align-items: center;
         height: 100%;
         max-height: 100%;
         box-shadow: none;
         -webkit-box-orient: horizontal;
         -webkit-box-direction: normal;
         -ms-flex-direction: row;
         flex-direction: row
     }
     .clr-wizard--ghosted .modal-content-wrapper {
         box-shadow: 0 1px 2px 2px rgba(0, 0, 0, 0.2)
     }
     .clr-wizard--ghosted .modal-ghost-wrapper {
         display: block;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 48px;
         flex: 0 0 48px;
         height: 100%;
         position: relative
     }
     .clr-wizard--ghosted .modal-ghost {
         position: absolute;
         top: 24px;
         bottom: 24px;
         background: #bbb;
         width: 24px;
         border-radius: 0 3px 3px 0;
         left: -24px;
         box-shadow: 0 1px 2px 2px rgba(0, 0, 0, 0.2);
         z-index: -1
     }
     .clr-wizard--ghosted .modal-ghost-2 {
         top: 48px;
         bottom: 48px;
         background: #9a9a9a;
         z-index: -2
     }
     .clr-wizard--ghosted .modal-dialog,
     .clr-wizard--ghosted .modal-outer-wrapper {
         width: 624px
     }
     .clr-wizard--ghosted .modal-content-wrapper {
         width: 576px
     }
     .clr-wizard--ghosted.wizard-md .modal-dialog,
     .clr-wizard--ghosted.wizard-md .modal-outer-wrapper {
         width: 624px
     }
     .clr-wizard--ghosted.wizard-md .modal-outer-wrapper {
         min-height: 420px
     }
     .clr-wizard--ghosted.wizard-md .modal-content-wrapper {
         width: 576px
     }
     .clr-wizard--ghosted.wizard-lg .modal-dialog,
     .clr-wizard--ghosted.wizard-lg .modal-outer-wrapper {
         width: 912px
     }
     .clr-wizard--ghosted.wizard-lg .modal-outer-wrapper {
         min-height: 420px
     }
     .clr-wizard--ghosted.wizard-lg .modal-content-wrapper {
         width: 864px
     }
     .clr-wizard--ghosted.wizard-xl .modal-dialog,
     .clr-wizard--ghosted.wizard-xl .modal-outer-wrapper {
         width: 1200px
     }
     .clr-wizard--ghosted.wizard-xl .modal-outer-wrapper {
         max-height: 75vh
     }
     .clr-wizard--ghosted.wizard-xl .modal-content-wrapper {
         width: 1152px
     }
     .clr-wizard--inline {
         display: block;
         width: 100%
     }
     .clr-wizard--inline clr-modal {
         height: 100%;
         width: 100%;
         display: block
     }
     .clr-wizard--inline .modal {
         padding: 0;
         position: static;
         height: 100%;
         max-height: 100%
     }
     .clr-wizard--inline .modal .content-container {
         height: 100%
     }
     .clr-wizard--inline .modal .content-container .nav-panel {
         width: 99%;
         height: 99%
     }
     .clr-wizard--inline .modal .modal-outer-wrapper {
         -webkit-box-align: stretch;
         -ms-flex-align: stretch;
         align-items: stretch;
         width: 100%
     }
     .clr-wizard--inline .modal .modal-content {
         box-shadow: none
     }
     .clr-wizard--inline .modal .modal-dialog {
         min-height: 100%;
         height: 100%;
         width: 100%;
         z-index: auto
     }
     .clr-wizard--inline .modal-body {
         height: 100%
     }
     .clr-wizard--inline .modal-header .close {
         display: none
     }
     .clr-wizard--inline .nav.navList {
         padding-top: 0
     }
     .clr-wizard--inline .modal-dialog .modal-content .modal-body .content-area {
         overflow-y: auto
     }
     .clr-wizard--inline .modal-backdrop {
         height: 0;
         width: 0;
         display: none
     }
     .clr-wizard--inline .modal-content-wrapper {
         -webkit-box-align: stretch;
         -ms-flex-align: stretch;
         align-items: stretch;
         height: 100%
     }
     .clr-wizard--inline .modal-ghost-wrapper {
         display: none
     }
     .clr-wizard--inline .clr-wizard-stepnav-wrapper,
     .clr-wizard--inline.clr-wizard .modal-content {
         min-height: 100%;
         height: auto;
         max-height: 100%
     }
     .clr-wizard--no-shadow .modal-content-wrapper,
     .clr-wizard--no-shadow .modal-dialog {
         box-shadow: none
     }
     .clr-wizard--no-title .clr-wizard-title {
         display: none
     }
     .clr-wizard--no-title .clr-wizard-stepnav {
         padding-top: 24px
     }
     @media screen {
         .clr-wizard-page[aria-hidden="true"] {
             display: none
         }
     }
     @font-face {
         font-family: 'Metropolis';
         src: url(data:application/font-woff;charset=utf-8;base64,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) format("woff");
         font-weight: 200;
         font-style: normal
     }
     @font-face {
         font-family: 'Metropolis';
         src: url(data:application/font-woff;charset=utf-8;base64,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) format("woff");
         font-weight: 400;
         font-style: normal
     }
     @font-face {
         font-family: 'Metropolis';
         src: url(data:application/font-woff;charset=utf-8;base64,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) format("woff");
         font-weight: 500;
         font-style: normal
     }
     @font-face {
         font-family: 'Metropolis';
         src: url(data:application/font-woff;charset=utf-8;base64,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) format("woff");
         font-weight: 600;
         font-style: normal
     }
     .signpost .signpost-content.top-left .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.top-middle .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.top-right .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.bottom-left .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.bottom-middle .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.bottom-right .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.left-top .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.left-middle .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.left-bottom .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.right-top .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.right-middle .signpost-flex-wrap .popover-pointer,
     .signpost .signpost-content.right-bottom .signpost-flex-wrap .popover-pointer {
         width: 0;
         height: 0;
         position: absolute
     }
     .signpost {
         display: inline-block
     }
     .signpost:hover {
         cursor: pointer
     }
     .signpost .signpost-action {
         min-width: 24px;
         margin: 0;
         padding: 0;
         color: #9a9a9a;
         outline: none
     }
     .signpost .signpost-action clr-icon {
         width: 24px;
         height: 24px
     }
     .signpost .signpost-action:hover,
     .signpost .signpost-action.active {
         color: #007cbb
     }
     .signpost .signpost-content.top-left .signpost-flex-wrap {
         position: relative;
         border-bottom-right-radius: 0
     }
     .signpost .signpost-content.top-left .signpost-flex-wrap .popover-pointer {
         border-left: 12px solid transparent;
         border-top: 12px solid #9a9a9a;
         right: -1px;
         bottom: -12px
     }
     .signpost .signpost-content.top-left .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-left: 12px solid transparent;
         border-top: 12px solid #fff;
         position: absolute;
         right: 1px;
         bottom: 2px
     }
     .signpost .signpost-content.top-middle .signpost-flex-wrap {
         position: relative
     }
     .signpost .signpost-content.top-middle .signpost-flex-wrap .popover-pointer {
         border-right: 12px solid transparent;
         border-top: 12px solid #9a9a9a;
         left: 50%;
         bottom: -12px
     }
     .signpost .signpost-content.top-middle .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-right: 12px solid transparent;
         border-top: 12px solid #fff;
         position: absolute;
         left: 1px;
         bottom: 2px
     }
     .signpost .signpost-content.top-right .signpost-flex-wrap {
         position: relative;
         border-bottom-left-radius: 0
     }
     .signpost .signpost-content.top-right .signpost-flex-wrap .popover-pointer {
         border-right: 12px solid transparent;
         border-top: 12px solid #9a9a9a;
         left: -1px;
         bottom: -12px
     }
     .signpost .signpost-content.top-right .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-right: 12px solid transparent;
         border-top: 12px solid #fff;
         position: absolute;
         left: 1px;
         bottom: 2px
     }
     .signpost .signpost-content.bottom-left .signpost-flex-wrap {
         border-top-right-radius: 0;
         position: relative
     }
     .signpost .signpost-content.bottom-left .signpost-flex-wrap .popover-pointer {
         border-left: 12px solid transparent;
         border-bottom: 12px solid #9a9a9a;
         right: -1px;
         top: -12px
     }
     .signpost .signpost-content.bottom-left .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-left: 12px solid transparent;
         border-bottom: 12px solid #fff;
         position: absolute;
         right: 1px;
         top: 2px
     }
     .signpost .signpost-content.bottom-middle .signpost-flex-wrap {
         position: relative
     }
     .signpost .signpost-content.bottom-middle .signpost-flex-wrap .popover-pointer {
         border-right: 12px solid transparent;
         border-bottom: 12px solid #9a9a9a;
         right: 50%;
         top: -12px
     }
     .signpost .signpost-content.bottom-middle .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-right: 12px solid transparent;
         border-bottom: 12px solid #fff;
         position: absolute;
         right: -13px;
         top: 2px
     }
     .signpost .signpost-content.bottom-right .signpost-flex-wrap {
         position: relative;
         border-top-left-radius: 0
     }
     .signpost .signpost-content.bottom-right .signpost-flex-wrap .popover-pointer {
         border-right: 12px solid transparent;
         border-bottom: 12px solid #9a9a9a;
         left: -1px;
         top: -12px
     }
     .signpost .signpost-content.bottom-right .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-right: 12px solid transparent;
         border-bottom: 12px solid #fff;
         position: absolute;
         left: 1px;
         top: 2px
     }
     .signpost .signpost-content.left-top .signpost-flex-wrap {
         position: relative;
         border-bottom-right-radius: 0
     }
     .signpost .signpost-content.left-top .signpost-flex-wrap .popover-pointer {
         border-top: 12px solid transparent;
         border-left: 12px solid #9a9a9a;
         right: -12px;
         bottom: -1px
     }
     .signpost .signpost-content.left-top .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-top: 12px solid transparent;
         border-left: 12px solid #ffffff;
         position: absolute;
         top: -13px;
         right: 2px
     }
     .signpost .signpost-content.left-middle .signpost-flex-wrap {
         position: relative
     }
     .signpost .signpost-content.left-middle .signpost-flex-wrap .popover-pointer {
         border-bottom: 12px solid transparent;
         border-left: 12px solid #9a9a9a;
         right: -12px;
         top: 50%;
         -webkit-transform: translateY(-50%);
         -ms-transform: translateY(-50%);
         transform: translateY(-50%)
     }
     .signpost .signpost-content.left-middle .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-bottom: 12px solid transparent;
         border-left: 12px solid #ffffff;
         position: absolute;
         top: 1px;
         left: -14px
     }
     .signpost .signpost-content.left-bottom .signpost-flex-wrap {
         border-top-right-radius: 0;
         position: relative
     }
     .signpost .signpost-content.left-bottom .signpost-flex-wrap .popover-pointer {
         border-bottom: 12px solid transparent;
         border-left: 12px solid #9a9a9a;
         right: -12px;
         top: -1px
     }
     .signpost .signpost-content.left-bottom .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-bottom: 12px solid transparent;
         border-left: 12px solid #ffffff;
         position: absolute;
         top: 1px;
         left: -14px
     }
     .signpost .signpost-content.right-top .signpost-flex-wrap {
         position: relative;
         border-bottom-left-radius: 0
     }
     .signpost .signpost-content.right-top .signpost-flex-wrap .popover-pointer {
         border-top: 12px solid transparent;
         border-right: 12px solid #9a9a9a;
         left: -12px;
         bottom: -1px
     }
     .signpost .signpost-content.right-top .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-top: 12px solid transparent;
         border-right: 12px solid #ffffff;
         position: absolute;
         top: -13px;
         left: 2px
     }
     .signpost .signpost-content.right-middle .signpost-flex-wrap {
         position: relative
     }
     .signpost .signpost-content.right-middle .signpost-flex-wrap .popover-pointer {
         border-bottom: 12px solid transparent;
         border-right: 12px solid #9a9a9a;
         left: -12px;
         top: 50%;
         -webkit-transform: translateY(-50%);
         -ms-transform: translateY(-50%);
         transform: translateY(-50%)
     }
     .signpost .signpost-content.right-middle .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-bottom: 12px solid transparent;
         border-right: 12px solid #ffffff;
         position: absolute;
         top: 1px;
         left: 2px
     }
     .signpost .signpost-content.right-bottom .signpost-flex-wrap {
         position: relative;
         border-top-left-radius: 0
     }
     .signpost .signpost-content.right-bottom .signpost-flex-wrap .popover-pointer {
         border-bottom: 12px solid transparent;
         border-right: 12px solid #9a9a9a;
         left: -12px;
         top: -1px
     }
     .signpost .signpost-content.right-bottom .signpost-flex-wrap .popover-pointer:before {
         content: '';
         width: 0;
         height: 0;
         border-bottom: 12px solid transparent;
         border-right: 12px solid #ffffff;
         position: absolute;
         top: 1px;
         left: 2px
     }
     .signpost-trigger {
         margin: 0;
         padding: 0;
         display: inline-block
     }
     .signpost-content {
         background-color: transparent;
         min-width: 216px;
         max-width: 360px;
         min-height: 84px;
         max-height: 504px;
         display: inline-block;
         z-index: 1070
     }
     .signpost-content .signpost-flex-wrap {
         border: 1px solid #9a9a9a;
         border-radius: 3px;
         background-color: #fff;
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-orient: vertical;
         -webkit-box-direction: normal;
         -ms-flex-direction: column;
         flex-direction: column;
         z-index: 1070
     }
     .signpost-content .signpost-flex-wrap .signpost-content-header {
         display: -webkit-box;
         display: -ms-flexbox;
         display: flex;
         -webkit-box-pack: end;
         -ms-flex-pack: end;
         justify-content: flex-end;
         -webkit-box-flex: 0;
         -ms-flex: 0 0 24px;
         flex: 0 0 24px
     }
     .signpost-content .signpost-flex-wrap .signpost-content-header button clr-icon {
         width: 16px;
         height: 16px
     }
     .signpost-content .signpost-flex-wrap .signpost-content-body {
         -webkit-box-flex: 1;
         -ms-flex: 1 1 auto;
         flex: 1 1 auto;
         padding: 0 24px 24px;
         max-height: 480px;
         overflow-y: auto
     }
     </style>
      <script>
        _SCRIPT_
      </script>
   </head>
   <body>
      <div class="main-container">
      <header class="header header-6">
            <div class="branding"><span class="title">_HEADER_</span></div>
      </header>
      <div class="content-container">
      <div class="content-area">
      <table width='100%' style='background-color: #002438; border-collapse: collapse; border: 0px; margin: 0; padding: 0;'>
      <tr>
         <td>
            <img src='cid:Header-vCheck' alt='vCheck' />
         </td>
         <td style='width: 171px'>
            <img src='cid:Header-VMware' alt='VMware' />
         </td>
      </tr>
   </table>
   _CONTENT_
      _CONFIGEXPORT_
      </div>
      _TOC_
      </div>
   <!-- CustomHTMLClose -->
   <div>&nbsp;</div>
   <footer>
      <p>vCheck v$($vCheckVersion) by <a href='http://virtu-al.net'>Alan Renouf</a> generated on $($ENV:Computername) on $($Date.ToLongDateString()) at $($Date.ToLongTimeString())</p>
   </footer>
   </div>
   </body>
</html>
"@

# Structure of each Plugin
$PluginHTML = @"
   <!-- Plugin Start - _TITLE_ -->
      <div style='height: 10px;'>&nbsp;</div>
      <a name="_PLUGINID_" /></a>
      <table class="table"><tr><td class="left"><b>_TITLE_</b></td></tr>
         <tr><td class="left" style='background-color: #f4f7fc; color: #000000; font-style: italic'>_COMMENTS_</td></tr>
         <tr><td class="left">_PLUGINCONTENT_</td></tr>
      </table>
   <!-- Plugin End -->
"@
