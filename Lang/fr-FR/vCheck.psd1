# culture="fr-FR"
ConvertFrom-StringData @' 
    setupMsg01  = 
    setupMsg02  = Bienvenue dans vCheck par Virtu-Al http://virtu-al.net
    setupMsg03  = =================================================
    setupMsg04  = C'est la premiere fois que ce script s'execute ou vous avez relancé l'assistant.
    setupMsg05  =
    setupMsg06  = La prochaine fois que vous relancez l'assistant, merci d'utiliser la commande vCheck.ps1 -Config
    setupMsg07  = Pour avoir des informations d'usage, merci d'utiliser Get-Help vCheck.ps1
    setupMsg08  =
    setupMsg09  = complétez les questions suivantes ou appuiez sur entrée pour accepter les paramètres courants
    setupMsg10  = après avoir terminé l'assistant le raport vCheck s'affichera sur l'écran.
    setupMsg11  =
    configMsg01 = après avoir exporté les nouveaux paramètres depuis l'interface de configuration,
    configMsg02  = importez le fichier CSV des paramètres en utilisant la commande Import-vCheckSettings -csvfile C:\\path\\to\\vCheckSettings.csv
    configMsg03  = NOTE: Si le fichier vCheckSettings.csv est stocké dans le repertoire de vCheck, exécutez simplement Import-vCheckSettings
    resFileWarn = fichier image introuvable pour {0}!
    pluginInvalid = Plugin n'existe pas: {0}
    pluginpathInvalid = le chemin du Plugin "{0}" est invalide, bascule sur le parametre par défaut {1}
    gvInvalid   = le chemin des variables Globales est invalide dans les specifications, bascule sur le parametre par défaut {0}
    varUndefined = Variable `${0} n'est pas défini dans le fichier GlobalVariables.ps1
    pluginActivity = evaluation des plugins
    pluginStatus = [{0} of {1}] {2}
    Complete = terminé
    pluginBegin = \ndémarrage du process des Plugins
    pluginStart  = ..début du calcul {0} by {1} v{2} [{3} of {4}]
    pluginEnd    = ..fin du calcul {0} by {1} v{2} [{3} of {4}]
    repTime     = ce rapport a pris {0} pour executer tous les composants, terminé le {1} à {2}
    repPRTitle = Plugin Report
    repTTRTitle = temps d'execution
    slowPlugins = les plugins suivants ont pris plus de {0} secondes à s'executer, il doit y avoir moyen d'améliorer cela...
    emailSend   = ..envoi d'Email
    emailAtch   = vCheck en pièce jointe à cet email
    HTMLdisp    = ..affichage des resultats HTML
'@

