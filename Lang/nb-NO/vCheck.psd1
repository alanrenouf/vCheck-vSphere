# culture="nb-NO"
ConvertFrom-StringData @' 
    setupMsg01  = 
    setupMsg02  = Velkommen til vCheck, utviklet av Virtu-Al http://virtu-al.net
    setupMsg03  = =================================================
    setupMsg04  = Enten er dette første gangen du kjører scriptet, eller så må du reaktivere oppstartsinstillingene.
    setupMsg05  =
    setupMsg06  = For å sette oppe scriptet på nytt, start scriptet med følgende opsjon: vCheck.ps1 -Config
	setupMsg07  = For brukerveilednin: Get-Help vCheck.ps1
    setupMsg08  =
	setupMsg09  = Besvar følgende spørsmål eller trykk Entertasten for å for å akseptere innstillingen.
	setupMsg10  = En oppsummering av innstillinger vil presenteres etter at du har angitt alle innstillinger.
	setupMsg11  =
	configMsg01 = Etter at alle innstillinger er endret, importer konfigurasjonen med kommandoen:
    configMsg02  =   Import-vCheckSettings -csvfile C:\\sti\\to\\vCheckSettings.csv
    configMsg03  = MERK: Hvis vCheckSettings.csv er lagret i vCheck katalogen, trenger du bare kjøre Import-vCheckSettings
    resFileWarn = Finner ingen fil for {0}!
    pluginInvalid = Tillegg finns ikke: {0}
    pluginpathInvalid = Tilleggslokasjon "{0}" er ikke gyldig, prøver {1}
    gvInvalid   = Globale sti til variable er ikke rikig i innstillinger for kjøringen, prøver {0}
    varUndefined = Variabelen `${0} er ikke definert i GlobalVariables.ps1
    pluginActivity = Sjekker tilegg
    pluginStatus = [{0} sv {1}] {2}
    Complete = Fullført
    pluginBegin = \nBegin Behandler tillegg
    pluginStart  = ..kalkulerer {0}  {1} skrevet av {2} [{3} av {4}]
    pluginEnd    = ..kalkulert {0} skrevet av {1} v{2} [{3} av {4}]
    repTime     = Rapporten kjørte på {0} minutter, avsluttet {1} {2}
    repPRTitle = Tillegsapport
    repTTRTitle = Kjøretid
	slowPlugins = Følgende tillegg to lengre tid enn {0} sekunder, det kan finnen en metode for å optimalisere kjøring eller fjerne disse
    emailSend   = ..Sender epost
	emailAtch   = vCheck er ved denne eposten
'@

