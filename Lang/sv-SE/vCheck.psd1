# culture="se-SV"
ConvertFrom-StringData @' 
    setupMsg01  = 
    setupMsg02  = Välkomen till vCheck skapat av Virtu-Al http://virtu-al.net
    setupMsg03  = =================================================
	setupMsg04  = Detta är första gången du kör scriptet eller så har du ändrat till konfiguration wizarden.
    setupMsg05  =
	setupMsg06  = För att starta denna wizard i framtiden kör vCheck.ps1 -Config
    setupMsg07  = För att visa hjälpen, skriv kommandot Get-Help vCheck.ps1
    setupMsg09  = Besvara följande frågor eller tryck Enter för att acceptera nuvarade inställning
    setupMsg10  = Efter att denna wizard är slutförd kommer vCheck rapporten att visas på skärmen  
	setupMsg11  =
    configMsg01 = Efter att du exporterat de nya inställningarna från konfigurations delen
    configMsg02  = importera dessa inställningarna från CSV filen genom att ge kommandot 
	configMsg03  = Import-vCheckSettings -csvfile C:\\path\\to\\vCheckSettings.csv
	configMsg04  = Notera: Om vChecksettings.csv sparades i Vcheck foldern, behöber du bara köra Import-vCheckSettings
	resFileWarn = Filen hittades inte {0}!
	pluginInvalid = Plugin hittades inte: {0}!
	pluginpathInvalid = Sökvägen för pluginen "{0}" är felaktig, sätter default till {1}
	gvInvalid   = Sökvägen för Globala Variabler är felaktig i job specifikationen, sätter sökvägen till {0}
	varUndefined = Variabel '${0} är inte definerad i GlobalVariables.ps1
	pluginActivity = Evaluerar plugins
	pluginStatus = [{0} av {1}} {2}
	Complete = Slutförd
	pluginBegin = \nBegin Plugin körs
	pluginStart  = ..startar beräkning {0} av {1} v{2} [{3} av {4}]
	pluginEnd    = ..slutfört beräkning {0} av {1} v{2} [{3} av {4}]
	repTime     = Denna rapport tog {0} minuter för att köra alla kontroller, slutfördes på {1} klockan {2}repTime
	repPRTitle = Plugin rapport
	repTTRTitle = Tid för körning
	slowPlugins = Följande plugins kördes längre än {0} sekunder, det kan finnas en möjlighet att optimera dessa eller ta bort dem om de inte behövs
	emailSend   = ..Skickar email
	emailAtch   = vCheck rapporten finns som en bifogad fil i dett a email
	HTMLdisp    = ..Visar resultat i HTML
'@

