# culture="it-IT"
ConvertFrom-StringData @' 
    setupMsg01  = 
    setupMsg02  = Benvenuto su vCheck by Virtu-Al http://virtu-al.net
    setupMsg03  = =================================================
    setupMsg04  = Questa è la prima volta che lanci lo script oppure devi rifare la procedura di Setup guidata
    setupMsg05  =
    setupMsg06  = Per ripetere la procedura di configurazione digita vCheck.ps1 -Config
    setupMsg07  = Per informazioni sull'uso dello script digita Get-Help vCheck.ps1
    setupMsg08  =
    setupMsg09  = Prego completa le seguenti domande o premi Invio per accettare le impostazioni correnti
    setupMsg10  = Dopo il completamento di questa procedura guidata, verrà visualizzato un report
    setupMsg11  =
    configMsg01 = Dopo l'esportazione delle configurazioni dall'interfaccia
    configMsg02  = importa il file CSV delle configurazioni tramite il comando Import-vCheckSettings -csvfile C:\\path\\to\\vCheckSettings.csv
    configMsg03  = NB: Se il file vCheckSettings.csv è presente nella cartella vCheck allora semplicemente lancia il comando Import-vCheckSettings
    resFileWarn = File immagine non trovato per {0}!
    pluginInvalid = Plugin inesistente: {0}
    pluginpathInvalid = Il percorso del plugin "{0}" non è valido, verrà utilizzato {1}
    gvInvalid   = Il percorso per le variabili globali non è valido, verrà utilizzato {0}
    varUndefined = La variable `${0} non è definita nel file GlobalVariables.ps1
    pluginActivity = Valutando il plugin...
    pluginStatus = [{0} of {1}] {2}
    Complete = Completo
    pluginBegin = \nInizio processo plugin
    pluginStart  = ..inizio calcolo {0} by {1} v{2} [{3} of {4}]
    pluginEnd    = ..calcolo terminato {0} by {1} v{2} [{3} of {4}]
    repTime     = Questo report ha impiegato {0} minuti per eseguire tutti i check, completando {1} a {2}
    repPRTitle = Report del Plugin
    repTTRTitle = Tempo di esecuzuone
    slowPlugins = l'esecuzione del seguente plugin ha impiegato più di {0} secondi, potrebbe essistere un modo per ottimizzarli o rimuoverli se non servono
    emailSend   = ..Invio mail in corso
    emailAtch   = vCheck allegato a questo email
    HTMLdisp    = .._Visualizzazione dei risultato in formato HTML
'@
