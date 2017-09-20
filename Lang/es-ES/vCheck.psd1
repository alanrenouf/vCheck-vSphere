# culture="es-ES"
ConvertFrom-StringData @' 
    setupMsg01  = 
    setupMsg02  = Bienvenido a vCheck desarrollado por Virtu-Al http://virtu-al.net
    setupMsg03  = =================================================================
    setupMsg04  = Esta es la primera vez que has ejecutado este script, o has re-activado el asistente de configuración.
    setupMsg05  =
    setupMsg06  = Para volver a ejecutar este asistente en el futuro, utiliza vCheck.ps1 -Config
    setupMsg07  = Para obtener ayuda, por favor, utiliza Get-Help vCheck.ps1
    setupMsg08  =
    setupMsg09  = Contesta a las siguientes preguntas o pulsa Enter para aceptar la configuración actual
    setupMsg10  = Despues de completar este asistente, el informe de vCheck se mostrará en la pantalla.
    setupMsg11  =
    configMsg01 = Despues de haber exportado los nuevos ajustes desde el interfaz de configuración,
    configMsg02  = importa el fichero CSV con los ajustes utilizando Import-vCheckSettings -csvfile c:\\path\\to\\vCehckSettings.csv
    configMsg03  = NOTA: Si vCheckSettings.csv está almacenado en la carpeta vCheck, simplemente ejecuta Import-vCheckSettings    
    resFileWarn = Fichero Imagen no encontrado para {0}!
    pluginInvalid = El plugin no existe: {0}
    pluginpathInvalid = El Plugin path "{0}" no es válido. Utilizando {1} por defecto.
    gvInvalid   = El Path de las Variables Globales no es válido en la especificación del trabajo, utilizando {0} por defecto
    varUndefined = La variable `${0} no está definida en GlobalVariables.ps1
    pluginActivity = Evaluando plugins
    pluginStatus = [{0} de {1}] {2}
    Complete = Finalizado
    pluginBegin = \nIniciando ejecución de Plugins
    pluginStart  = ..empezando cálculo {0} por {1} v{2} [{3} de {4}]
    pluginEnd    = ..finalizado cálculo {0} por {1} v{2} [{3} de {4}]
    repTime     = Este informe tardó {0} minutos en ejecutar todos los checks, completado el {1} a las {2}
    repPRTitle = Informe de Plugins
    repTTRTitle = Tiempo de Ejecución
    slowPlugins = Los siguientes plugins tardaron más de {0} segundos en ejecturase, quizá haya una forma de optimizarlos o desactívalos si no son necesarios
    emailSend   = ..Enviando Email
    emailAtch   = vCheck adjunto a este email
    HTMLdisp    = ..Mostrando resultados HTML
'@
