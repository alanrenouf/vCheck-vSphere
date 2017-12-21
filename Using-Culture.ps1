<#
.NOTES
  Use-Culture.ps1

  This script allows you to test your internationalisation files.
  With this script there is no need to switch your complete OS to another language.
  Run the script from the folder where the vCheck.ps1 file is located.

  The script is based on following blog posts:

  Using-Culture -Culture culture -Script {scriptblock}
  https://blogs.msdn.microsoft.com/powershell/2006/04/25/using-culture-culture-culture-script-scriptblock/

  Windows PowerShell 2.0 String Localization
  https://rkeithhill.wordpress.com/2009/10/21/windows-powershell-2-0-string-localization/

  Use a language code from https://msdn.microsoft.com/en-us/library/ee825488(v=cs.20).aspx

  Examples:    # Run vCheck with the French language code
    Using-Culture -culture fr-FR -script {.\vCheck.ps1}

    # Run vCheck with the Spanish language code
    Using-Culture -culture es-ES -script {.\vCheck.ps1}

  Changelog
  ============================
  1.0 - Luc Dekens
    - initial version
#>

function Using-Culture ([System.Globalization.CultureInfo]$culture =(throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"),
                        [ScriptBlock]$script=(throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"))
{    
    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    $OldUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
    try {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture        
        Invoke-Command $script    
    }    
    finally {        
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture        
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $OldUICulture    
    }    
}

Using-Culture -culture en-US -script {.\vCheck.ps1}

#Using-Culture -culture af-ZA -script {.\vCheck.ps1}
#Using-Culture -culture de-DE -script {.\vCheck.ps1}
#Using-Culture -culture fr-FR -script {.\vCheck.ps1}
