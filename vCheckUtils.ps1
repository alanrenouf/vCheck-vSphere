$global:vCheckPath = $MyInvocation.MyCommand.Definition | Split-Path
$global:pluginXMLURL = "https://vcheck.report/plugins.xml"
$global:pluginURL = "https://raw.github.com/alanrenouf/vCheck-{0}/master/Plugins/{1}/{2}"

 <#
.SYNOPSIS
   Retrieves installed vCheck plugins and available plugins from the Virtu-Al.net repository.

.DESCRIPTION
   Get-vCheckPlugin parses your vCheck plugins folder, as well as searches the online plugin respository in Virtu-Al.net.
   After finding the plugin you are looking for, you can download and install it with Add-vCheckPlugin. Get-vCheckPlugins
   also supports finding a plugin by name. Future version will support categories (e.g. Datastore, Security, vCloud)
     
.PARAMETER name
   Name of the plugin.

.PARAMETER proxy
   URL for proxy usage.
   
.PARAMETER proxy_user
   username for proxy auth.
   
.PARAMETER proxy_password
   password for proxy auth.
   
.PARAMETER proxy_domain
   domain for proxy auth.

.EXAMPLE
   Get list of all vCheck Plugins
   Get-vCheckPlugin

.EXAMPLE
   Get plugin by name
   Get-vCheckPlugin PluginName

.EXAMPLE
   Get plugin by name using proxy
   Get-vCheckPlugin PluginName -proxy "http://127.0.0.1:3128"

.EXAMPLE
   Get plugin by name using proxy with auth (domain optional depending on your proxy auth)
   Get-vCheckPlugin PluginName -proxy "http://127.0.0.1:3128" -proxy_user "username" -proxy_pass "password -proxy_domain "domain"
   
.EXAMPLE
   Get plugin information
   Get-vCheckPlugins PluginName
 #>
function Get-vCheckPlugin
{
    [CmdletBinding()]
    Param
    (
        [Parameter(mandatory=$false)] [String]$name,
        [Parameter(mandatory=$false)] [String]$proxy,
	[Parameter(mandatory=$false)] [String]$proxy_user,
	[Parameter(mandatory=$false)] [String]$proxy_pass,
	[Parameter(mandatory=$false)] [String]$proxy_domain,
        [Parameter(mandatory=$false)] [Switch]$installed,
        [Parameter(mandatory=$false)] [Switch]$notinstalled,
	[Parameter(mandatory=$false)] [Switch]$pendingupdate,
        [Parameter(mandatory=$false)] [String]$category
    )
    Process
    {
        $pluginObjectList = @()
		
        foreach ($localPluginFile in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse))
        {
            $localPluginContent = Get-Content $localPluginFile
            
            if ($localPluginContent | Select-String -SimpleMatch "title")
            {
                $localPluginName = ($localPluginContent | Select-String -SimpleMatch "Title").toString().split("`"")[1]
            }
            if($localPluginContent | Select-String -SimpleMatch "description")
            {
                $localPluginDesc = ($localPluginContent | Select-String -SimpleMatch "description").toString().split("`"")[1]
            }
            elseif ($localPluginContent | Select-String -SimpleMatch "comments")
            {
                $localPluginDesc = ($localPluginContent | Select-String -SimpleMatch "comments").toString().split("`"")[1]
            }
            if ($localPluginContent | Select-String -SimpleMatch "author")
            {
                $localPluginAuthor = ($localPluginContent | Select-String -SimpleMatch "author").toString().split("`"")[1]
            }
            if ($localPluginContent | Select-String -SimpleMatch "PluginVersion")
            {
                $localPluginVersion = @($localPluginContent | Select-String -SimpleMatch "PluginVersion")[0].toString().split(" ")[-1]
            }
			 if ($localPluginContent | Select-String -SimpleMatch "PluginCategory")
            {
                $localPluginCategory = @($localPluginContent | Select-String -SimpleMatch "PluginCategory")[0].toString().split("`"")[1]
            }
          
            $pluginObject = New-Object PSObject
            $pluginObject | Add-Member -MemberType NoteProperty -Name name -value $localPluginName
            $pluginObject | Add-Member -MemberType NoteProperty -Name description -value $localPluginDesc
            $pluginObject | Add-Member -MemberType NoteProperty -Name author -value $localPluginAuthor
            $pluginObject | Add-Member -MemberType NoteProperty -Name version -value $localPluginVersion
	    $pluginObject | Add-Member -MemberType NoteProperty -Name category -Value $localPluginCategory
            $pluginObject | Add-Member -MemberType NoteProperty -Name status -value "Installed"
            $pluginObject | Add-Member -MemberType NoteProperty -Name location -Value $LocalpluginFile.FullName
            $pluginObjectList += $pluginObject
        }

        if (!$installed)
        {
            try
            {
                $webClient = new-object system.net.webclient
				if ($proxy)
				{
					$proxyURL = new-object System.Net.WebProxy $proxy
					if (($proxy_user) -and ($proxy_pass))
					{
						$proxyURL.UseDefaultCredentials = $false
						$proxyURL.Credentials = New-Object Net.NetworkCredential("$proxy_user","$proxy_pass")
					}
					elseif (($proxy_user) -and ($proxy_pass) -and ($proxy_domain))
					{
						$proxyURL.UseDefaultCredentials = $false
						$proxyURL.Credentials = New-Object Net.NetworkCredential("$proxy_user","$proxy_pass","$proxy_domain")
					}
					else
					{
						$proxyURL.UseDefaultCredentials = $true
					}
					$webclient.proxy = $proxyURL
				}
                $response = $webClient.openread($pluginXMLURL)
                $streamReader = new-object system.io.streamreader $response
                [xml]$plugins = $streamReader.ReadToEnd()

                foreach ($plugin in $plugins.pluginlist.plugin)
                {
                    $pluginObjectList | Where-Object {$_.name -eq $plugin.name -and [double]$_.version -lt [double]$plugin.version}|	
					Foreach-Object {
						$_.status = "New Version Available - " + $plugin.version						
					}
					if (!($pluginObjectList | Where-Object {$_.name -eq $plugin.name}))
                    {
                        $pluginObject = New-Object PSObject
                        $pluginObject | Add-Member -MemberType NoteProperty -Name name -value $plugin.name
                        $pluginObject | Add-Member -MemberType NoteProperty -Name description -value $plugin.description
                        $pluginObject | Add-Member -MemberType NoteProperty -Name author -value $plugin.author
                        $pluginObject | Add-Member -MemberType NoteProperty -Name version -value $plugin.version
						$pluginObject | Add-Member -MemberType NoteProperty -Name category -Value $plugin.category
                        $pluginObject | Add-Member -MemberType NoteProperty -Name status -value "Not Installed"
                        $pluginObject | Add-Member -MemberType NoteProperty -name location -value $plugin.href
                        $pluginObjectList += $pluginObject
                    }
                }
            }
            catch [System.Net.WebException]
            {
                write-error $_.Exception.ToString()
                return
            }

        }

        if ($name){
            $pluginObjectList | Where-Object {$_.name -eq $name}
        } Else {
			if ($category){
				$pluginObjectList | Where-Object {$_.Category -eq $category}
			} Else {
	            if($notinstalled){
	                $pluginObjectList | Where-Object {$_.status -eq "Not Installed"}
	            } elseif($pendingupdate) {
					$pluginObjectList | Where-Object {$_.status -like "New Version Available*"}
				}
				Else {
	                $pluginObjectList
	            }
	        }
		}
    }

}

<#
.SYNOPSIS
   Installs a vCheck plugin from the Virtu-Al.net repository.

.DESCRIPTION
   Add-vCheckPlugin downloads and installs a vCheck Plugin (currently by name) from the Virtu-Al.net repository. 

   The downloaded file is saved in your vCheck plugins folder, which automatically adds it to your vCheck report. vCheck plugins may require
   configuration prior to use, so be sure to open the ps1 file of the plugin prior to running your next report. 

.PARAMETER name
   Name of the plugin.

.EXAMPLE
   Install via pipeline from Get-vCheckPlugins
   Get-vCheckPlugin "Plugin name" | Add-vCheckPlugin

.EXAMPLE
   Install Plugin by name
   Add-vCheckPlugin "Plugin name"
#>
function Add-vCheckPlugin
{
    [CmdletBinding(DefaultParametersetName="name")]
    Param
    (
        [Parameter(parameterSetName="name",Position=0,mandatory=$true)] [String]$name,
        [Parameter(parameterSetName="object",Position=0,mandatory=$true,ValueFromPipeline=$true)] [PSObject]$pluginobject
    )
    Process
    {
        if($name)
        {
            Get-vCheckPlugin $name | Add-vCheckPlugin
        }
        elseif ($pluginObject)
        {
            Add-Type -AssemblyName System.Web
            $filename = $pluginObject.location.split("/")[-2,-1] -join "/"
            $filename = [System.Web.HttpUtility]::UrlDecode($filename)
            try
            {
                Write-Warning "Downloading File..."
                $webClient = new-object system.net.webclient
                $webClient.DownloadFile($pluginObject.location,"$vCheckPath\Plugins\$filename")
                Write-Warning "The plugin `"$($pluginObject.name)`" has been installed to $vCheckPath\Plugins\$filename"
                Write-Warning "Be sure to check the plugin for additional configuration options."

            }
            catch [System.Net.WebException]
            {
                write-error $_.Exception.ToString()
                return
            }
        }
    }
}

<#
.SYNOPSIS
   Removes a vCheck plugin.

.DESCRIPTION
   Remove-vCheckPlugin Uninstalls a vCheck Plugin.

   Basically, just looks for the plugin name and deletes the file. Sure, you could just delete the ps1 file from the plugins folder, but what fun is that?

.PARAMETER name
   Name of the plugin.

.EXAMPLE
   Remove via pipeline
   Get-vCheckPlugin "Plugin name" | Remove-vCheckPlugin

.EXAMPLE
   Remove Plugin by name
   Remove-vCheckPlugin "Plugin name"
#>
function Remove-vCheckPlugin
{
    [CmdletBinding(DefaultParametersetName="name",SupportsShouldProcess=$true,ConfirmImpact="High")]
    Param
    (
        [Parameter(parameterSetName="name",Position=0,mandatory=$true)] [String]$name,
        [Parameter(parameterSetName="object",Position=0,mandatory=$true,ValueFromPipeline=$true)] [PSObject]$pluginobject
    )
    Process
    {
        if($name)
        {
            Get-vCheckPlugin $name | Remove-vCheckPlugin
        }
        elseif ($pluginObject)
        {
           Remove-Item -path $pluginObject.location -confirm:$false
        }
    }
}

<#
.SYNOPSIS
   Geberates plugins XML file from local plugins

.DESCRIPTION
   Designed to be run after plugin changes are commited, in order to generate 
   the plugin.xml file that the plugin update check uses.

.PARAMETER outputFile
   Path to the xml file. Defaults to temp directory
#>
function Get-vCheckPluginXML
{
   param 
   (
      $outputFile = "$($env:temp)\plugins.xml"
   )
   # create XML and root node
   $xml = New-Object xml
   $root = $xml.CreateElement("pluginlist")
   [void]$xml.AppendChild($root)

	   foreach ($localPluginFile in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1 -Recurse))
	   {
		  $localPluginContent = Get-Content $localPluginFile
		  
		  if ($localPluginContent | Select-String -SimpleMatch "title")
		  {
			  $localPluginName = ($localPluginContent | Select-String -SimpleMatch "Title").toString().split("`"")[1]
		  }
		  if($localPluginContent | Select-String -SimpleMatch "description")
		  {
			  $localPluginDesc = ($localPluginContent | Select-String -SimpleMatch "description").toString().split("`"")[1]
		  }
		  elseif ($localPluginContent | Select-String -SimpleMatch "comments")
		  {
			  $localPluginDesc = ($localPluginContent | Select-String -SimpleMatch "comments").toString().split("`"")[1]
		  }
		  if ($localPluginContent | Select-String -SimpleMatch "author")
		  {
			  $localPluginAuthor = ($localPluginContent | Select-String -SimpleMatch "author").toString().split("`"")[1]
		  }
		  if ($localPluginContent | Select-String -SimpleMatch "PluginVersion")
		  {
			  $localPluginVersion = @($localPluginContent | Select-String -SimpleMatch "PluginVersion")[0].toString().split(" ")[-1]
		  }
		  if ($localPluginContent | Select-String -SimpleMatch "PluginCategory")
		  {
			  $localPluginCategory = @($localPluginContent | Select-String -SimpleMatch "PluginCategory")[0].toString().split("`"")[1]
		  }

		  $pluginXML = $xml.CreateElement("plugin")
		  $elem=$xml.CreateElement("name")
		  $elem.InnerText=$localPluginName
		  [void]$pluginXML.AppendChild($elem)
		  
		  $elem=$xml.CreateElement("description")
		  $elem.InnerText=$localPluginDesc
		  [void]$pluginXML.AppendChild($elem)
		  
		  $elem=$xml.CreateElement("author")
		  $elem.InnerText=$localPluginAuthor
		  [void]$pluginXML.AppendChild($elem)
		  
		  $elem=$xml.CreateElement("version")
		  $elem.InnerText=$localPluginVersion
		  [void]$pluginXML.AppendChild($elem)
		  
		  $elem=$xml.CreateElement("category")
		  $elem.InnerText=$localPluginCategory
		  [void]$pluginXML.AppendChild($elem)
		  
		  $elem=$xml.CreateElement("href")
		  $elem.InnerText= ($pluginURL -f $localPluginCategory, $localPluginFile.Directory.Name, $localPluginFile.Name)
		  [void]$pluginXML.AppendChild($elem)
		  
		  [void]$root.AppendChild($pluginXML)
	   }
   
   $xml.save($outputFile)
}

<#
.SYNOPSIS
   Returns settings from vCheck plugins.

.DESCRIPTION
   Get-PluginSettings will return an array of settings contained
   within a supplied plugin. Used by Export-vCheckSettings.
     
.PARAMETER filename
   Full path to plugin file
 #>
Function Get-PluginSettings {
	Param
    (
        [Parameter(mandatory=$true)] [String]$filename
    )
	$psettings = @()
	$file = Get-Content $filename
	$OriginalLine = ($file | Select-String -SimpleMatch "# Start of Settings").LineNumber
	$EndLine = ($file | Select-String -SimpleMatch "# End of Settings").LineNumber
	if (!(($OriginalLine +1) -eq $EndLine)) {		
		$Line = $OriginalLine		
		do {
			$Question = $file[$Line]
			$Line++
			$Split = ($file[$Line]).Split("=")
			$Var = $Split[0]
			$CurSet = $Split[1]			
			$settings = @{}
			$settings.filename = $filename
			$settings.question = $Question
            $settings.varname = $Var.Trim()
			$settings.var = $CurSet.Trim()
			$currentsetting = New-Object -TypeName PSObject -Prop $settings
			$psettings += $currentsetting
			$Line++ 
		} Until ( $Line -ge ($EndLine -1) )
	}
	$psettings
}

 <#
.SYNOPSIS
   Applies settings to vCheck plugins.

.DESCRIPTION
   Set-PluginSettings will apply settings supplied to a given vCheck plugin.
   Used by Export-vCheckSettings.
     
.PARAMETER filename
   Full path to plugin file

.PARAMETER settings
   Array of settings to apply to plugin

.PARAMETER GB
   Switch to disable Setup Wizard when processing GlobalVariables.ps1
 #>
Function Set-PluginSettings {	
	Param
    (
        [Parameter(mandatory=$true)] [String]$filename,
		[Parameter(mandatory=$false)] [Array]$settings,
		[Parameter(mandatory=$false)] [Switch]$GB
    )
	$file = Get-Content $filename
	$OriginalLine = ($file | Select-String -SimpleMatch "# Start of Settings").LineNumber
	$EndLine = ($file | Select-String -SimpleMatch "# End of Settings").LineNumber
	$PluginName = ($filename.split("\")[-1]).split(".")[0]
	Write-Warning "`nProcessing - $PluginName"
	if (!(($OriginalLine +1) -eq $EndLine)) {
		$Array = @()
		$Line = $OriginalLine
		do {
			$Question = $file[$Line].Trim()
			$Found = $false
			$Line ++
			$Split= ($file[$Line]).Split("=")
			$Var = $Split[0].Trim()
			$CurSet = $Split[1].Trim()
			Foreach ($setting in $settings) {
				If ($question -eq $setting.question.Trim()) {	
					$NewSet = $setting.var
					$Found = $true
				}
			}
			If (!$Found) {
				# Check if the current setting is in speech marks
				$String = $false
				if ($CurSet -match '"') {
					$String = $true
					$CurSet = $CurSet.Replace('"', '').Trim()
				}
				$NewSet = Read-Host "$Question [$CurSet]"
				If (-not $NewSet) {
					$NewSet = $CurSet
				}
				If ($String) {
					$NewSet = "`"$NewSet`""
				}
			}
            if ($NewSet -ne $CurSet) {
                Write-Warning "Plugin setting changed:"
                Write-Warning "    Plugin:    $PluginName"
                Write-Warning "    Question:  $Question"
                Write-Warning "    Variable:  $Var"
                Write-Warning "    Old Value: $CurSet"
                Write-Warning "    New Value: $NewSet"
            }
			$Array += $Question
			$Array += "$Var = $NewSet"
			$Line ++ 
		} Until ( $Line -ge ($EndLine -1) )
		$Array += "# End of Settings"

		$out = @()
		$out = $File[0..($OriginalLine -1)]
		$out += $Array
		$out += $File[$Endline..($file.count -1)]
		If ($GB) {
			$Setup = ($file | Select-String -SimpleMatch '# Set the following to true to enable the setup wizard for first time run').LineNumber
			$SetupLine = $Setup ++
			$out[$SetupLine] = '$SetupWizard = $False'
		}
		$out | Out-File -Encoding ASCII $filename
	}
}

 <#
.SYNOPSIS
   Retrieves configured vCheck plugin settings and exports them to CSV.

.DESCRIPTION
   Export-vCheckSettings will retrieve the settings from each plugin and export them to a CSV file.
   By default, the CSV file will be created in the vCheck folder named vCheckSettings.csv.
   You can also specify a custom path using -outfile.
   Once the export has been created the settings can then be imported via Import-vCheckSettings.
     
.PARAMETER outfile
   Full path to CSV file

.EXAMPLE
   Export-vCheckSettings
   Creates vCheckSettings.csv file in default location (vCheck folder)

.EXAMPLE
   Export-vCheckSettings -outfile "E:\vCheck-vCenter01.csv"
   Creates CSV file in custom location E:\vCheck-vCenter01.csv
 #>
Function Export-vCheckSettings {
	Param
    (
        [Parameter(mandatory=$false)] [String]$outfile = "$vCheckPath\vCheckSettings.csv"
    )
	
	$Export = @()
	$GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
	$Export = Get-PluginSettings -Filename $GlobalVariables
	Foreach ($plugin in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse)) { 
		$Export += Get-PluginSettings -Filename $plugin.Fullname
	}
	$Export | Select-Object filename, question, var | Export-Csv -NoTypeInformation $outfile
}



 <#
.SYNOPSIS
   Retrieves configured vCheck plugin settings and exports them to XML.

.DESCRIPTION
   Export-vCheckSettings will retrieve the settings from each plugin and export them to a XML file.
   By default, the XML file will be created in the vCheck folder named vCheckSettings.xml.
   You can also specify a custom path using -outfile.
   Once the export has been created the settings can then be imported via Import-vCheckSettingsXML.
     
.PARAMETER outfile
   Full path to XML file

.EXAMPLE
   Export-vCheckSettings
   Creates vCheckSettings.xml file in default location (vCheck folder)

.EXAMPLE
   Export-vCheckSettingsXML -outfile "E:\vCheck-vCenter01.xml"
   Creates XML file in custom location E:\vCheck-vCenter01.xml
 #>
Function Export-vCheckSettingsXML {
	Param
    (
        [Parameter(mandatory=$false)] [String]$outfile = "$vCheckPath\vCheckSettings.xml"
    )
	
	$Export = @()
	$GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
	$Export = Get-PluginSettings -Filename $GlobalVariables
	Foreach ($plugin in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1 -Recurse)) { 
		$Export += Get-PluginSettings -Filename $plugin.Fullname
	}

    $xml = "<vCheck>`n"
    foreach ($e in $Export) {
        $xml += "`t<setting>`n"
        $xml += "`t`t<filename>$($e.Filename)</filename>`n"
        $xml += "`t`t<question>$($e.Question)</question>`n"
        $xml += "`t`t<varname>$($e.VarName)</varname>`n"
        $xml += "`t`t<var>$($e.Var)</var>`n"
        $xml += "`t</setting>`n"
    }
    $xml += "</vCheck>"
    $xml | Out-File -FilePath $outfile -Encoding utf8
}

 <#
.SYNOPSIS
   Retreives settings from CSV and applies them to vCheck.

.DESCRIPTION
   Import-vCheckSettings will retrieve the settings exported via Export-vCheckSettings and apply them to the
   current vCheck folder.
   By default, the CSV file is expected to be located in the vCheck folder named vCheckSettings.csv.
   You can also specify a custom path using -csvfile.
   If the CSV file is not found you will be asked to provide the path.
   The Setup Wizard will be disabled.
   You will be asked any questions not found in the export. This would occur for new settings introduced
   enabling a quick update between versions.
     
.PARAMETER csvfile
   Full path to CSV file

.EXAMPLE
   Import-vCheckSettings
   Imports settings from vCheckSettings.csv file in default location (vCheck folder)

.EXAMPLE
   Import-vCheckSettings -outfile "E:\vCheck-vCenter01.csv"
   Imports settings from CSV file in custom location E:\vCheck-vCenter01.csv
 #>
Function Import-vCheckSettings {
	Param
    (
        [Parameter(mandatory=$false)] [String]$csvfile = "$vCheckPath\vCheckSettings.csv"
    )
	
	If (!(Test-Path $csvfile)) {
		$csvfile = Read-Host "Enter full path to settings CSV file you want to import"
	}
	$Import = Import-Csv $csvfile
	$GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
	$settings = $Import | Where-Object {($_.filename).Split("\")[-1] -eq ($GlobalVariables).Split("\")[-1]}
	Set-PluginSettings -Filename $GlobalVariables -Settings $settings -GB
	Foreach ($plugin in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse)) { 
		$settings = $Import | Where-Object {($_.filename).Split("\")[-1] -eq ($plugin.Fullname).Split("\")[-1]}
		Set-PluginSettings -Filename $plugin.Fullname -Settings $settings
	}
	Write-Warning "`nImport Complete!`n"
}

 <#
.SYNOPSIS
   Retreives settings from XML and applies them to vCheck.

.DESCRIPTION
   Import-vCheckSettingsXML will retrieve the settings exported via Export-vCheckSettingsXML, or via .\vCheck.ps1 -GUIConfig
   and apply them to the current vCheck folder.
   By default, the XML file is expected to be located in the vCheck folder named vCheckSettings.csv.
   You can also specify a custom path using -xmlfile.
   If the XML file is not found you will be asked to provide the path.
   The Setup Wizard will be disabled.
   You will be asked any questions not found in the export. This would occur for new settings introduced
   enabling a quick update between versions.
     
.PARAMETER csvfile
   Full path to XML file

.EXAMPLE
   Import-vCheckSettingsXML
   Imports settings from vCheckSettings.xml file in default location (vCheck folder)

.EXAMPLE
   Import-vCheckSettingsXML -xmlfile "E:\vCheck-vCenter01.xml"
   Imports settings from XML file in custom location E:\vCheck-vCenter01.xml
 #>
Function Import-vCheckSettingsXML {
	Param
    (
        [Parameter(mandatory=$false)] [String]$xmlFile = "$vCheckPath\vCheckSettings.xml"
    )
	
	If (!(Test-Path $xmlFile)) {
		$xmlFile = Read-Host "Enter full path to settings XML file you want to import"
	}
	$Import = [xml](Get-Content $xmlFile)
	$GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
	$settings = $Import.vCheck.Setting | Where-Object {($_.filename).Split("\")[-1] -eq ($GlobalVariables).Split("\")[-1]}
	Set-PluginSettings -Filename $GlobalVariables -Settings $settings -GB
	Foreach ($plugin in (Get-ChildItem -Path "$vCheckPath\Plugins\" -Filter "*.ps1" -Recurse)) { 
		$settings = $Import.vCheck.Setting | Where-Object {($_.filename).Split("\")[-1] -eq ($plugin.Fullname).Split("\")[-1]}
		Set-PluginSettings -Filename $plugin.Fullname -Settings $settings
	}
	Write-Warning "`nImport Complete!`n"
}

Function Get-vCheckCommand {
	Get-Command *vCheck*
}

Get-vCheckCommand

function Schedule-vCheck {
    $vCheckJobName = Read-Host -Prompt "Enter the name of the vCheck job to create"
    $TriggerTime = Read-Host -Prompt "Enter the time $vCheckJobName should run at, in the format 'H:MM AM/PM' (e.g. '2:00 AM')"
    $Location = Read-Host -Prompt "Enter the fully qualified location where the vCheck script resides"
    $sb = [scriptblock]::Create($Location)

    $dailyTrigger = New-JobTrigger -Daily -At $TriggerTime
    $option = New-ScheduledJobOption -StartIfOnBattery -StartIfIdle
    Register-ScheduledJob -Name $vCheckJobName -Trigger $dailyTrigger -ScheduledJobOption $option `
        -ScriptBlock $sb
}

# Below is a set of functions to make upgrading a vCheck directory easier

<#
    .SYNOPSIS
        Lists the variables in vCheck plugin files.

    .DESCRIPTION
        Plugin file will be scanned as a text file and any variables in between the "Start of Settings"
		and "End of Settings" section markers will be sent out the pipeline.  Files can be sent in
		via the pipeline or individually with a loop.  If using the "-Verbose" option for troubleshooting
		then using a loop is recommended.

    .PARAMETER  PluginFile
        The file to be processed.  Can be passed as text, a file object, or a set of files, such as 
		"Get-ChildItem *.ps1".

    .EXAMPLE
        Simple
		Get-vCheckVariablesSettings -PluginFile "c:\scripts\vcheck6\vcenter\Plugins\20 Cluster\75 DRS Rules.ps1"

		Recursed
		Get-ChildItem -Path E:\vCheckLatestTesting -File -Filter *.ps1 -Recurse | % { Get-vCheckVariablesSettings -PluginFile $_.FullName }

    .INPUTS
        System.IO.FileInfo

    .OUTPUTS
        File		Selected.System.Management.Automation.PSCustomObject	The 'Fullname' property from the plugin file.
		Variable	Selected.System.Management.Automation.PSCustomObject	The text of the variable assignment from the plugin file.

    .NOTES
        With multiple vCheck directories to upgrade I needed an easy to pull the variables used 
		in the old vCheck installation to go into the new version.

    .LINK
        https://github.com/alanrenouf/vCheck-vSphere

Recent Comment History
20150127	cmonahan	Initial release.

#>

Function Get-vCheckVariablesSettings {

[CmdletBinding()]
param (
[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)] $PluginFile
)

#begin {
	Write-Verbose "Started $PluginFile"
	
	if (Test-Path $PluginFile) {
		$PluginFile = Get-ChildItem $PluginFile
		$contents = Get-Content $PluginFile
		$end = $contents.length }
	else { throw "Value passed to File parameter is not a file."  }
	
	$i=0
	
#} # end begin block

#process {

	while ( ($i -lt $end) -and ($contents[$i] -notmatch "Start of Settings") ) { $i++ }
	
	while ( ($i -lt $end) -and ($contents[$i] -notmatch "End of Settings")   ) { 
		if ($contents[$i] -match "`=") { "" | Select-Object @{n='File';e={$PluginFile.fullname}},@{n='Variable';e={$contents[$i]}}; $i++ }
		else { $i++ }
	}

#} #end process block

#end {
	Write-Verbose "Ended $PluginFile"
#} #end end block

<#
Recent Comment History
20150127	cmonahan	Initial release.
#>

} # end function

<#
    .SYNOPSIS
        Matches the disabled plugins in a target directory with those in a source directory.

    .DESCRIPTION
        I wrote it for when I'm upgrading vCheck.  This will go through the old directory and
		any plugin marked as disabled there will be marked as disabled in the new directory.

    .PARAMETER  OldVcheckDir
        What you you think it is.

    .PARAMETER  NewVcheckDir
        No tricks here.

	.EXAMPLE
        Sync-vCheckDisabledPlugins -OldVcheckDir c:\scripts\vcheck6\vccenter_old_20150218_163057 -NewVcheckDir c:\scripts\vcheck6\vcenter

    .LINK
         https://github.com/alanrenouf/vCheck-vSphere


Recent Comment History
20150128	cmonahan	Initial release.

#>

function Sync-vCheckDisabledPlugins {
[cmdletbinding(SupportsShouldProcess=$True)]

param (
[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false)] $OldVcheckDir,
[Parameter(Position=1,Mandatory=$true,ValueFromPipeline=$false)] $NewVcheckDir
)

# $WhatIfPreference

$OldVcheckPluginsDir = (Get-ChildItem "$($OldVcheckDir)\Plugins").PsParentPath
$NewVcheckPluginsDir = (Get-ChildItem "$($NewVcheckDir)\Plugins").PsParentPath

$OldDisabled = Get-ChildItem $OldVcheckDir -Recurse | ? { $_ -like "*.disabled" } #| select -First 1
$OldDisabled

foreach ($file in $OldDisabled) {
	Get-ChildItem $NewVcheckDir -Recurse | Where-Object { $_ -match $file.Name } | Select-Object FullName
	Get-ChildItem $NewVcheckDir -Recurse -Filter $file.BaseName | ForEach-Object { Move-Item -Path $_.FullName -Destination ($_.FullName -replace("ps1","ps1.disabled")) }
}

<# Comment History
20150128	cmonahan	Initial release.
#>

} # end function


<#
    .SYNOPSIS
        Lists the disabled plugins in a target directory.

    .DESCRIPTION
        Essentially a stripped down version of Sync-vCheckDisabledPlugins I threw it in
		in case	someone found it useful.

    .PARAMETER  VcheckDir
        What you you think it is.

	.EXAMPLE
        Get-vCheckDisabledPlugins -VcheckDir c:\scripts\vcheck6\vcenter

    .LINK
         https://github.com/alanrenouf/vCheck-vSphere


Recent Comment History
20150128	cmonahan	Initial release.

#>

function Get-vCheckDisabledPlugins {

param ( [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)] $vCheckDir )

Get-ChildItem (Get-ChildItem "$($vCheckDir)\Plugins").PsParentPath -Recurse | ? { $_ -like "*.disabled" } #| select -First 1

<# Comment History
20150128	cmonahan	Initial release.
#>

} # end function

<#
    .SYNOPSIS
        Does most of the work upgrading to a new version of vCheck.

    .DESCRIPTION
        This function will:
		  -Backup the current directory by renaming it with the current date
		  -Copy in the new version from a directory you've specified
		  -Save all the variable settings to a text file
		  -Set the same disabled plugins in the new version
		  -Opens the saved variable settings in Notepad
		  
		Then run vCheck.ps1 for the first time to configure it using the 
		variables listing open in Notepad as a reference.

    .PARAMETER  CurrentvCheckPath
        Directory to be upgraded.

    .PARAMETER  NewvCheckSource
		Location of the new version downloaded from GitHub.
	
    .EXAMPLE
        Upgrade-vCheckDirectory -CurrentvCheckPath c:\scripts\vcheck6\vcenter -NewvCheckSource c:\scripts\vcheck6\vcenter\vCheck-vSphere-master

    .NOTES
        If you have multiple directories and some settings like smtp server
	are the same for them all you could upgrade the file(s) in the new
	vCheck version directory and they'll be copied out with each upgrade.
	
	This is my process for upgrading vCheck with this function.
	  1.  Extract a new, unmodified version of the vCheck to a directory.  For this example "C:\Scripts\vCheck\vCheck-vSphere-master".
	  2.  Load the utility - ". C:\Scripts\vCheck\vCheck-vSphere-master\vCheckUtils.ps1" .
	  3.  Upgrade-vCheckDirectory âCurrentvCheckPath C:\Scripts\vcheck\vcenterprod -NewvCheckSource C:\Scripts\vcheck6\vCheck-vSphere-master
	  4.  The list of plugin variable values is automatically opened in Notepad.
	  5.  Change directory to C:\Scripts\vcheck\vcenterprod .
	  6.  Run vCheck.ps1 .  Input all the prompts for variable values with the ones in the file opened by Notepad.  For the global variable â $EmailFrom = "vcheck-vcenter@monster.com" â I use my own email address until after I done a test run.  Then I change it back to the group email address.
	  7.  After all the variable have been entered vCheck will run.
	  8.  Review the PowerShell console for script errors and the vCheck email report for any problems.  
	  9.  If there are not problems set the âEmailFromâ variable in âGlobalVariables.ps1â back to itâs original value.

    .LINK
        https://github.com/alanrenouf/vCheck-vSphere

Recent Comment History
20150127	cmonahan	Initial release.

#>

Function Upgrade-vCheckDirectory {

param (
[Parameter(Position=0,Mandatory=$true)] $CurrentvCheckPath,
[Parameter(Position=1,Mandatory=$true)] $NewvCheckSource
)

function Get-Now { (get-date -uformat %Y%m%d) + "_" + (get-date -uformat %H%M%S) }
$TS = Get-Now  # TS means time stamp

# Test that directories exist
if ( !(Test-Path -Path $CurrentvCheckPath) ) { break }
if ( !(Test-Path -Path $NewvCheckSource) )   { break }
$OldvCheckPath = "$($CurrentvCheckPath)_old_$($TS)"
$OldvCheckVariables = "$($OldvCheckPath)\vCheckVariables_$($TS).txt"

# Backup current directory and setup new directory
Move-Item -Path $CurrentvCheckPath -Destination $OldvCheckPath
mkdir $CurrentvCheckPath
robocopy $NewvCheckSource $CurrentvCheckPath /s /e /z /xj /r:2 /w:5 /np 

# Save variable settings
Get-ChildItem -Path $OldvCheckPath -Filter *.ps1 -Recurse | % { Get-vCheckVariablesSettings -PluginFile $_.FullName } | Format-Table -AutoSize | Out-File -FilePath $OldvCheckVariables

# Make the disabled plugins match
Sync-vCheckDisabledPlugins -OldVcheckDir $OldvCheckPath -NewVcheckDir $CurrentvCheckPath

# Configure it
notepad $OldvCheckVariables
Write-Output "Locally on the server hosting the vCheck script run vCheck.ps1"

<# Comment History
20150128	cmonahan	Initial release.
#>

} # end function

Function Get-vCheckLogData {
	param(
		[string] $vCheckFile,
		[string] $Section
	)

	# Find the comment above the specified section table and grab the Post context for 6 lines beyond the comment
	# The HTML is stored within the next 6 lines.
	# line 1: <div style='height: 10px; font-size: 10px;'>&nbsp;</div>
	# line 2: <a name="plugin-#" />
	$ContextInfo = Select-String "Plugin Start - $Section" $vCheckFile -context 0,6

	# lines 3-6 are the data we want.
	$table = $ContextInfo.Context.PostContext | Select-Object -last 4

	# The table actually ends on line 7.  But line 6 looks like this:
	# <tr><td style="text-align: right; background: #FFFFFF"><a href="#top" style="color: black">Back To Top</a>
	# There is no ending </td></tr>
	# Line 7: </table>
	# So add these missing tags back in.
	$table += "</td></tr></table>"
	try {
		# Convert to XML for easier parsing
		$xmlObj = [xml]$table
	} catch {
		# This catches any instances where there are no matches in the file, and then the only data is the ending tags.
		# just in case you want to see it, Write-Verbose
		Write-Verbose "$vCheckFile : $table"
	}

	# There is a sub table with the data - so get the TR that contains a sub table
	$ParentTR = $xmlObj.table.tr | ? { $_.td.table }
	# Get the TD
	$ParentTD = $ParentTR.td
	# Get the table
	$SubTable = $ParentTD.Table

	# Use the TH to get the header names
	$th = $subTable.tr.th

	# Create a hash table that stores all the header names, and use the index as the key.  We'll use this as a lookup when we get to the TD
	$thHash = @{}
	for ($i=0;$i -lt $th.count; $i++) {
		$thHash.Add($i,$th[$i])
	}

	# Loop through each TR containing the log data
	for ($i=1; $i -lt $subTable.tr.count; $i++) {
		# Get the TDs under the TR, and loop through those
		$td = $subTable.tr[$i].td
		
		# build a hash table pulling the column name from the TH hash table, and the value from the TD
		$tdHash = @{}
		for ($j=0; $j -lt $td.count;$j++) {
			$tdHash.Add($thHash[$j],$td[$j])
		}
		# Return this as an object
		New-Object -Type PSObject -Prop $tdHash
	}
}

# SIG # Begin signature block
# MIIaIwYJKoZIhvcNAQcCoIIaFDCCGhACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuleOhXyt89LLtBj0fYJVzQXd
# L+2gghTdMIIG3jCCBMagAwIBAgITLAAACIZKKD9KFQrLmwAAAAAIhjANBgkqhkiG
# 9w0BAQ0FADBlMRMwEQYKCZImiZPyLGQBGRYDY29tMR0wGwYKCZImiZPyLGQBGRYN
# Y29ybmVyc3RvbmVudzEYMBYGCgmSJomT8ixkARkWCGludGVybmFsMRUwEwYDVQQD
# EwxDU05XIFJvb3QgQ0EwHhcNMjEwNTAzMjI0MDA1WhcNMjIwNTAzMjI0MDA1WjB7
# MRMwEQYKCZImiZPyLGQBGRYDY29tMR0wGwYKCZImiZPyLGQBGRYNY29ybmVyc3Rv
# bmVudzEYMBYGCgmSJomT8ixkARkWCGludGVybmFsMREwDwYDVQQLDAhPVV91c2Vy
# czEYMBYGA1UEAxMPVGhvbWFzLkZyZWFyc29uMFkwEwYHKoZIzj0CAQYIKoZIzj0D
# AQcDQgAE/PoIlU91LMGtwMi0ry9sKeeRq0TyOzWDZSW7N1XrLa+6mAdgUDciVp8J
# 1fqcyWMHFh4kRnuNq2+/zb92wWL99aOCAzowggM2MDwGCSsGAQQBgjcVBwQvMC0G
# JSsGAQQBgjcVCIX31ziG/ox0htmRD4bVkEqCuvg/XYfyuz+is2ECAWQCAQgwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsGCSsGAQQBgjcVCgQO
# MAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFKguBJKXvZckUGfMS1UGRjg1A8EQMB8G
# A1UdIwQYMBaAFFNLHk1vGE692PjWZ1QEcop+y1wOMIIBsQYDVR0fBIIBqDCCAaQw
# ggGgoIIBnKCCAZiGRWh0dHA6Ly9kYzEuaW50ZXJuYWwuY29ybmVyc3RvbmVudy5j
# b20vQ2VydEVucm9sbC9DU05XJTIwUm9vdCUyMENBLmNybIaBxWxkYXA6Ly8vQ049
# Q1NOVyUyMFJvb3QlMjBDQSxDTj1kYzEsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUy
# MFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9aW50ZXJu
# YWwsREM9Y29ybmVyc3RvbmVudyxEQz1jb20/Y2VydGlmaWNhdGVSZXZvY2F0aW9u
# TGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50hkdmaWxl
# Oi8vLy9kYzEuaW50ZXJuYWwuY29ybmVyc3RvbmVudy5jb20vQ2VydEVucm9sbC9D
# U05XJTIwUm9vdCUyMENBLmNybIY+aHR0cDovL3BraS5pbnRlcm5hbC5jb3JuZXJz
# dG9uZW53LmNvbS9wa2kvQ1NOVyUyMFJvb3QlMjBDQS5jcmwwgYAGCCsGAQUFBwEB
# BHQwcjBwBggrBgEFBQcwAYZkaHR0cDovL2RjMS5pbnRlcm5hbC5jb3JuZXJzdG9u
# ZW53LmNvbS9DZXJ0RW5yb2xsL2RjMS5pbnRlcm5hbC5jb3JuZXJzdG9uZW53LmNv
# bV9DU05XJTIwUm9vdCUyMENBLmNydDA8BgNVHREENTAzoDEGCisGAQQBgjcUAgOg
# IwwhdGhvbWFzLmZyZWFyc29uQGNvcm5lcnN0b25lbncuY29tMA0GCSqGSIb3DQEB
# DQUAA4ICAQBZn8FwZAJPkVZXMRL0gRu0HZmeBwXA/6B+RxABPMwdlPpm844MNCeg
# DF4C5Bu0LeePT5Ab1i0NtGecog58xF69Dbd6uvw72QdVbc9vndF1vqSmY3wJsqY/
# HCFaC0sJmvZf+HWxY+vI9ji96juPGJnQekpoChtQP5Ne/7AlGhYC6Vk4x6GIMmsI
# NvIK533hT7JYmivCmG0EupVJkzKnOe1HtDmFXFTIjznXB6lmU/f9ODSkGc8/3kN9
# 9QsL9hBoAtpltPYZ51raqGh8HDBK26BzvAFR46uM/r+Bn5tadrNph7zjC15Y4TpT
# dx4/zKXC98lcdXcWHez4yM8qB/lQmdb1QSlEErD2Jg3hWI31t9J29bnK5fKFS+4B
# lg+EIDPkniEOILPfDXX2ctsDebwsYGLvdI0fVg52ApaWjCTwt0K22CH26pvTMQsL
# KDnQFyZy5c8xqmPGgxtTzGY/80DKhO3u65TF9ouPr07tjcwejyJjt/4uj8O/pVML
# +bRU/m1krkIZ6cDkezT/xb36N9psESlQuhnaRaF8u1OxmvzR98yzI1mox/6vT6EJ
# ttw0pGF7hN0LT5vPNTcJOTlouWLgKBv/tdV1watycAvx84HOvreWIhE5ulhnQHdN
# u/vGgZUHyTnE4ohwTl3rnRUA4CNs+Y+AaUKnNx94O8PHKjMxZLV8EjCCBuwwggTU
# oAMCAQICEDAPb6zdZph0fKlGNqd4LbkwDQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0
# eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VS
# VHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTE5MDUwMjAwMDAw
# MFoXDTM4MDExODIzNTk1OVowfTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0
# ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSUwIwYDVQQDExxTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIENB
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyBsBr9ksfoiZfQGYPyCQ
# vZyAIVSTuc+gPlPvs1rAdtYaBKXOR4O168TMSTTL80VlufmnZBYmCfvVMlJ5Lslj
# whObtoY/AQWSZm8hq9VxEHmH9EYqzcRaydvXXUlNclYP3MnjU5g6Kh78zlhJ07/z
# Obu5pCNCrNAVw3+eolzXOPEWsnDTo8Tfs8VyrC4Kd/wNlFK3/B+VcyQ9ASi8Dw1P
# s5EBjm6dJ3VV0Rc7NCF7lwGUr3+Az9ERCleEyX9W4L1GnIK+lJ2/tCCwYH64TfUN
# P9vQ6oWMilZx0S2UTMiMPNMUopy9Jv/TUyDHYGmbWApU9AXn/TGs+ciFF8e4KRmk
# KS9G493bkV+fPzY+DjBnK0a3Na+WvtpMYMyou58NFNQYxDCYdIIhz2JWtSFzEh79
# qsoIWId3pBXrGVX/0DlULSbuRRo6b83XhPDX8CjFT2SDAtT74t7xvAIo9G3aJ4oG
# 0paH3uhrDvBbfel2aZMgHEqXLHcZK5OVmJyXnuuOwXhWxkQl3wYSmgYtnwNe/YOi
# U2fKsfqNoWTJiJJZy6hGwMnypv99V9sSdvqKQSTUG/xypRSi1K1DHKRJi0E5FAMe
# KfobpSKupcNNgtCN2mu32/cYQFdz8HGj+0p9RTbB942C+rnJDVOAffq2OVgy728Y
# UInXT50zvRq1naHelUF6p4MCAwEAAaOCAVowggFWMB8GA1UdIwQYMBaAFFN5v1qq
# K0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQWBBQaofhhGSAPw0F3RSiO0TVfBhIEVTAO
# BgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggr
# BgEFBQcDCDARBgNVHSAECjAIMAYGBFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0
# cDovL2NybC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25B
# dXRob3JpdHkuY3JsMHYGCCsGAQUFBwEBBGowaDA/BggrBgEFBQcwAoYzaHR0cDov
# L2NydC51c2VydHJ1c3QuY29tL1VTRVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUG
# CCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEB
# DAUAA4ICAQBtVIGlM10W4bVTgZF13wN6MgstJYQRsrDbKn0qBfW8Oyf0WqC5SVmQ
# KWxhy7VQ2+J9+Z8A70DDrdPi5Fb5WEHP8ULlEH3/sHQfj8ZcCfkzXuqgHCZYXPO0
# EQ/V1cPivNVYeL9IduFEZ22PsEMQD43k+ThivxMBxYWjTMXMslMwlaTW9JZWCLjN
# XH8Blr5yUmo7Qjd8Fng5k5OUm7Hcsm1BbWfNyW+QPX9FcsEbI9bCVYRm5LPFZgb2
# 89ZLXq2jK0KKIZL+qG9aJXBigXNjXqC72NzXStM9r4MGOBIdJIct5PwC1j53BLwE
# NrXnd8ucLo0jGLmjwkcd8F3WoXNXBWiap8k3ZR2+6rzYQoNDBaWLpgn/0aGUpk6q
# PQn1BWy30mRa2Coiwkud8TleTN5IPZs0lpoJX47997FSkc4/ifYcobWpdR9xv1tD
# XWU9UIFuq/DQ0/yysx+2mZYm9Dx5i1xkzM3uJ5rloMAMcofBbk1a0x7q8ETmMm8c
# 6xdOlMN4ZSA7D0GqH+mhQZ3+sbigZSo04N6o+TzmwTC7wKBjLPxcFgCo0MR/6hGd
# HgbGpm0yXbQ4CStJB6r97DDa8acvz7f9+tCjhNknnvsBZne5VhDhIG7GrrH5trrI
# NV0zdo7xfCAMKneutaIChrop7rRaALGMq+P5CslUXdS5anSevUiumDCCBwcwggTv
# oAMCAQICEQCMd6AAj/TRsMY9nzpIg41rMA0GCSqGSIb3DQEBDAUAMH0xCzAJBgNV
# BAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1Nh
# bGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGln
# byBSU0EgVGltZSBTdGFtcGluZyBDQTAeFw0yMDEwMjMwMDAwMDBaFw0zMjAxMjIy
# MzU5NTlaMIGEMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVz
# dGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQx
# LDAqBgNVBAMMI1NlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgU2lnbmVyICMyMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAkYdLLIvB8R6gntMHxgHKUrC+
# eXldCWYGLS81fbvA+yfaQmpZGyVM6u9A1pp+MshqgX20XD5WEIE1OiI2jPv4ICmH
# rHTQG2K8P2SHAl/vxYDvBhzcXk6Th7ia3kwHToXMcMUNe+zD2eOX6csZ21ZFbO5L
# IGzJPmz98JvxKPiRmar8WsGagiA6t+/n1rglScI5G4eBOcvDtzrNn1AEHxqZpIAC
# TR0FqFXTbVKAg+ZuSKVfwYlYYIrv8azNh2MYjnTLhIdBaWOBvPYfqnzXwUHOrat2
# iyCA1C2VB43H9QsXHprl1plpUcdOpp0pb+d5kw0yY1OuzMYpiiDBYMbyAizE+cgi
# 3/kngqGDUcK8yYIaIYSyl7zUr0QcloIilSqFVK7x/T5JdHT8jq4/pXL0w1oBqlCl
# i3aVG2br79rflC7ZGutMJ31MBff4I13EV8gmBXr8gSNfVAk4KmLVqsrf7c9Tqx/2
# RJzVmVnFVmRb945SD2b8mD9EBhNkbunhFWBQpbHsz7joyQu+xYT33Qqd2rwpbD1W
# 7b94Z7ZbyF4UHLmvhC13ovc5lTdvTn8cxjwE1jHFfu896FF+ca0kdBss3Pl8qu/C
# dkloYtWL9QPfvn2ODzZ1RluTdsSD7oK+LK43EvG8VsPkrUPDt2aWXpQy+qD2q4lQ
# +s6g8wiBGtFEp8z3uDECAwEAAaOCAXgwggF0MB8GA1UdIwQYMBaAFBqh+GEZIA/D
# QXdFKI7RNV8GEgRVMB0GA1UdDgQWBBRpdTd7u501Qk6/V9Oa258B0a7e0DAOBgNV
# HQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDBABgNVHSAEOTA3MDUGDCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRw
# czovL3NlY3RpZ28uY29tL0NQUzBEBgNVHR8EPTA7MDmgN6A1hjNodHRwOi8vY3Js
# LnNlY3RpZ28uY29tL1NlY3RpZ29SU0FUaW1lU3RhbXBpbmdDQS5jcmwwdAYIKwYB
# BQUHAQEEaDBmMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
# Y3RpZ29SU0FUaW1lU3RhbXBpbmdDQS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9v
# Y3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQBKA3iQQjPsexqDCTYz
# mFW7nUAGMGtFavGUDhlQ/1slXjvhOcRbuumVkDc3vd/7ZOzlgreVzFdVcEtO9KiH
# 3SKFple7uCEn1KAqMZSKByGeir2nGvUCFctEUJmM7D66A3emggKQwi6Tqb4hNHVj
# ueAtD88BN8uNovq4WpquoXqeE5MZVY8JkC7f6ogXFutp1uElvUUIl4DXVCAoT8p7
# s7Ol0gCwYDRlxOPFw6XkuoWqemnbdaQ+eWiaNotDrjbUYXI8DoViDaBecNtkLwHH
# waHHJJSjsjxusl6i0Pqo0bglHBbmwNV/aBrEZSk1Ki2IvOqudNaC58CIuOFPePBc
# ysBAXMKf1TIcLNo8rDb3BlKao0AwF7ApFpnJqreISffoCyUztT9tr59fClbfErHD
# 7s6Rd+ggE+lcJMfqRAtK5hOEHE3rDbW4hqAwp4uhn7QszMAWI8mR5UIDS4DO5E3m
# KgE+wF6FoCShF0DV29vnmBCk8eoZG4BU+keJ6JiBqXXADt/QaJR5oaCejra3QmbL
# 2dlrL03Y3j4yHiDk7JxNQo2dxzOZgjdE1CYpJkCOeC+57vov8fGP/lC4eN0Ult4c
# DnCwKoVqsWxo6SrkECtuIf3TfJ035CoG1sPx12jjTwd5gQgT/rJkXumxPObQeCOy
# CSziJmK/O6mXUczHRDKBsq/P3zGCBLAwggSsAgEBMHwwZTETMBEGCgmSJomT8ixk
# ARkWA2NvbTEdMBsGCgmSJomT8ixkARkWDWNvcm5lcnN0b25lbncxGDAWBgoJkiaJ
# k/IsZAEZFghpbnRlcm5hbDEVMBMGA1UEAxMMQ1NOVyBSb290IENBAhMsAAAIhkoo
# P0oVCsubAAAAAAiGMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR0eims222XFRymZS5QhUWCj6zI
# qTALBgcqhkjOPQIBBQAERzBFAiBwHxUomxwoAaSvE3jCq/KBCBraQPo/nUlgj5sk
# 1RIb6gIhAN356VTQ2XvWN/mOm7m75iSEnOJ2/lL9Y4n5BSUn7yaKoYIDTDCCA0gG
# CSqGSIb3DQEJBjGCAzkwggM1AgEBMIGSMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQI
# ExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoT
# D1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0EgVGltZSBTdGFt
# cGluZyBDQQIRAIx3oACP9NGwxj2fOkiDjWswDQYJYIZIAWUDBAICBQCgeTAYBgkq
# hkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMTA2MDQyMzU2
# MDFaMD8GCSqGSIb3DQEJBDEyBDBSkotnqwUkUco5sB1Tc1MBhWsXhwI16319o0BS
# +1N19/gP4P1kWCV6QLJA9i1kAFEwDQYJKoZIhvcNAQEBBQAEggIAgzSZ25ulgLsV
# Y1toK4db80W+itCtHSnBlZIMezpfX6TJzJoIX4oI4+1fC/O/g9e2tqrECh45PHO7
# WnW4vF1/KSmxq1mw7SY7eMRJ9JqYlIfHeR0e+Ed2Aj4wsKRuzL1mQMYL0UJh0vq7
# ITbt2r8NEY/P+pJC3vgjj0Uu421V7C5nbYXI7gCUsA5HYTzUEDcFVipex7ekDu5V
# fKajyFTpnSWnjF9XPvmJlU47ofCdZ4Z70H5tUtMmzD4ictu7agl7U1FpITWQm53K
# RH65gec/lSJK8KqVCRqEdDv9hZSz+aVp4HyhV4aB6YvtY98o/JU19W9gQMsv5MD4
# oB+s0f+ONZro0Z4DLdpgvzmEByPwLuq3ge7IYpFc0nE+D86BLxhYEinGpvgq/IK7
# dj2QsDzjeIE/N1IX6E9F++f7Msil5FqYtg6UucSsnM0ikDmJurx6ZsVfeV1rISW9
# Mf1Y8VVTL3ql7dWZPp4nUEk7xx94R3Me2bX9AqFsnxY4LMp3y3tYP1JVAlXRlB/W
# ivduAMYqpR/XTCVPBoXCAe/nb2n8hWnJOU+5ve7Y5WYg7BmsY4/ORD10Uvtph8eV
# 5mMsBZ65gGb3XATgRwra58LgHCkO9Yy48WubFFnWbtzeM/PLZu6yHmuZNaLuozOk
# A7jwroDmKpfr85N1iykHcxmjSXtRuzI=
# SIG # End signature block
