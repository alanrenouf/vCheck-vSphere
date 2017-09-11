# culture="de-DE"
ConvertFrom-StringData @' 
    setupMsg01  = 
    setupMsg02  = Willkommen  zu vCheck by Virtu-Al http://virtu-al.net
    setupMsg03  = =================================================
    setupMsg04  = Dies ist das erste mal, das Sie dieses Script starten, oder der Setupo-Wizard wurde neu gestarted.
    setupMsg05  =
    setupMsg06  = Um den Wizard neu zu starten, benutzen Sie vCheck.ps1 -Config
    setupMsg07  = Um Hilfe zu erhalten, benutzen Sie Get-Help vCheck.ps1
    setupMsg08  =
    setupMsg09  = Bitte beantworten Sie die folgenden Fragen, oder drücken Sie enter, um mit den aktuellen Einstellungen fortzufahren.
    setupMsg10  = Nach dem Beenden des Wizards wird der vCheck Report in diesem Fenster angezeigt.
    setupMsg11  =
    configMsg01 = Nachdem neue Einstellungen vom Konfigurationsinterface exportiert wurden,
    configMsg02  = importieren Sie die settings CSV Datei mit Import-vCheckSettings -csvfile C:\\Pfad\\zu\\vCheckSettings.csv
    configMsg03  = HINWEIS: Wenn die Datei vCheckSettings.csv im vCheck Ordner gespeichert ist, benutzen Sie Import-vCheckSettings
    resFileWarn = Image Datei wurde für {0} nich gefunden!
    pluginInvalid = Das folgende Plugin existiert nicht: {0}
    pluginpathInvalid = Der Plugin Pfad "{0}" ist ungültig, es wird {1} verwendet
    gvInvalid   = Der Pfad zu den Globalen Variablen in der Job Spezifikation ist inkorrekt, {0} wird jetzt verwendet
    varUndefined = Die Variable `${0} ist in der Datei GlobalVariables.ps1 nicht definiert
    pluginActivity = Auswählen der Plugins
    pluginStatus = [{0} von {1}] {2}
    Complete = Fertig!
    pluginBegin = \nStart der Plugins
    pluginStart  = ..Start der Berechnung {0} by {1} v{2} [{3} of {4}]
    pluginEnd    = ..fertig mit der Berechnung {0} by {1} v{2} [{3} of {4}]
    repTime     = Der Report  benötigte {0} Minuten um den Check auszuführen, beenden {1} um {2}
    repPRTitle = Plugin Report
    repTTRTitle = Dauer der Ausführung 
    slowPlugins = Die folgenden Plugins benötigten länger als {0} Secunden für die Ausführung, diese sollten optimiert oder entfernt werden
    emailSend   = ..Sende Email
    emailAtch   = vCheck wurde an die email angehängt
    HTMLdisp    = ..Zeige die HTML ERgebnisse an
'@
