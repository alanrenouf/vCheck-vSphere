# culture="pt-BR"
ConvertFrom-StringData @'
    setupMsg01  =
    setupMsg02  = Bem vindo ao vCheck desenvolvido por Virtu-Al http://virtu-al.net
    setupMsg03  = =================================================
    setupMsg04  = Esta é a primeira vez que você executa esse script ou você reiniciou o wizard de configuração
    setupMsg05  =
    setupMsg06  = Para executar o wizard novamente, por favor use o comando vCheck.ps1 -Config
    setupMsg07  = Para ter acesso as instrução de uso desse script, por favor execute o comando Get-Help vCheck.ps1
    setupMsg08  =
    setupMsg09  = Por favor, respondas as perguntas a seguir. Use ENTER para aceitar o valor padrão ou atual
    setupMsg10  = Após completar esse wizard o relatório do vCheck será mostrado na tela
    setupMsg11  =
    configMsg01 = Após exportar as novas configuração da interface de configuração,
    configMsg02  = importe as configuração do arquivo CSV usando o comando Import-vCheckSettings -csvfile C:\\caminho\\do\\vCheckSettings.csv
    configMsg03  = NOTA: Se o arquivo vCheckSettings.csv estiver salvo no mesmo diretório do vCheck, simplesmente execute o comando Import-vCheckSettings
    resFileWarn = Arquivo de imagem não encontrado {0}!
    pluginInvalid = O Plugin não existe: {0}
    pluginpathInvalid = O caminho do Plugin "{0}" é inválido, será utilizado o padrão {1}
    gvInvalid   = O caminho das variáveis globais é inválido para esse job, será utilizado o padrão {0}
    varUndefined = A variável `${0} não foi definida no arquivo GlobalVariables.ps1
    pluginActivity = Verificando plugins
    pluginStatus = [{0} de {1}] {2}
    Complete = Finalizado
    pluginBegin = \nInicializando o processo do plugin
    pluginStart  = ..iniciando o cálculo {0} de {1} v{2} [{3} até {4}]
    pluginEnd    = ..terminando o cálculo {0} de {1} v{2} [{3} até {4}]
    repTime     = Esse relatório levou {0} minutos para executar todos os testes, finalizando *of* {1} *de* {2}
    repPRTitle = Relatório de Plugin
    repTTRTitle = Tempo para executar
    slowPlugins = Os seguintes plugins demoraram mais de {0} segundos para serem execuados, **there may be a way to optimize these** ou remove-los se não foram necessários
    emailSend   = ..Enviando email
    emailAtch   = vCheck anexado ao email
    HTMLdisp    = ..Mostrando o resultado no formato HTML
    '@
