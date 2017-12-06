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
