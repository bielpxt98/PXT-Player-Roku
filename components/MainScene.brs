' Main scene for the PXT Player application.
' It coordinates feature screens and authenticates playlist credentials through
' XtreamService, including live TV categories and channel lists.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.liveCategoriesScreen = m.top.FindNode("liveCategoriesScreen")
    m.liveChannelsScreen = m.top.FindNode("liveChannelsScreen")
    m.livePlayerScreen = m.top.FindNode("livePlayerScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.loginTimeoutTimer = m.top.FindNode("loginTimeoutTimer")
    m.account = LoadSavedPlaylist()
    m.pendingAccount = invalid
    m.liveCategories = []
    m.liveCategoriesLoading = false
    m.liveChannels = []
    m.liveChannelsLoading = false
    m.selectedLiveCategory = invalid
    m.selectedLiveChannel = invalid

    configureScene()

    m.homeScreen.ObserveField("openPlaylist", "onOpenPlaylistRequested")
    m.homeScreen.ObserveField("openLiveCategories", "onOpenLiveCategoriesRequested")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")
    m.liveCategoriesScreen.ObserveField("backRequested", "onLiveCategoriesBack")
    m.liveCategoriesScreen.ObserveField("categorySelected", "onLiveCategorySelected")
    m.liveChannelsScreen.ObserveField("backRequested", "onLiveChannelsBack")
    m.liveChannelsScreen.ObserveField("channelSelected", "onLiveChannelSelected")
    m.livePlayerScreen.ObserveField("backRequested", "onLivePlayerBack")
    m.xtreamService.ObserveField("result", "onXtreamConnectionResult")
    m.loginTimeoutTimer.ObserveField("fire", "onLoginTimeout")

    if hasAccount(m.account) then
        updateConnectionStatus(true, "Conectado")
    else
        updateConnectionStatus(false, "Nenhuma playlist conectada")
    end if

    showHome()
end sub

sub configureScene()
    m.top.backgroundColor = "#000000"
    m.top.backgroundURI = ""
    m.homeScreen.SetFocus(true)
end sub

sub showHome()
    m.loginScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.homeScreen.callFunc("show")
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.loginScreen.callFunc("show", m.account)
end sub

sub onOpenPlaylistRequested()
    showLogin()
end sub

sub onOpenLiveCategoriesRequested()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("show")

    if not hasAccount(m.account) then
        m.liveCategoriesScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as categorias de TV ao vivo.")
    else if m.liveCategoriesLoading then
        m.liveCategoriesScreen.callFunc("setLoading", true)
    else if m.liveCategories <> invalid and m.liveCategories.Count() > 0 then
        m.liveCategoriesScreen.callFunc("setCategories", m.liveCategories)
    else
        m.liveCategoriesScreen.callFunc("setLoading", true)
        loadLiveCategories(m.account)
    end if
end sub

sub onLoginSubmit()
    account = m.loginScreen.submit
    if not hasAccount(account) then
        m.loginScreen.callFunc("showError", "Informe DNS, usuário e senha para conectar.")
        return
    end if

    m.pendingAccount = account
    print "DEBUG Login: início da autenticação Xtream"
    m.loginScreen.callFunc("setLoading", true)
    startLoginTimeout()
    connectXtream(account)
end sub

sub onLoginBack()
    stopLoginTimeout()
    showHome()
end sub

sub onLiveCategoriesBack()
    showHome()
end sub

sub onLiveChannelsBack()
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("show")
end sub

sub onLiveCategorySelected()
    category = m.liveCategoriesScreen.categorySelected
    if category = invalid then return

    m.selectedLiveCategory = category
    m.liveChannels = []
    m.liveChannelsLoading = true
    m.liveCategoriesScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("show", category)
    m.liveChannelsScreen.callFunc("setLoading", true)
    loadLiveChannels(category)
end sub


sub onLiveChannelSelected()
    channel = m.liveChannelsScreen.channelSelected
    if channel = invalid then return

    if not hasAccount(m.account) then
        m.liveChannelsScreen.callFunc("showMessage", "Conecte uma lista Xtream para reproduzir canais de TV ao vivo.")
        return
    end if

    m.selectedLiveChannel = channel
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("show", channel)
    buildLiveStreamUrl(channel)
end sub

sub onLivePlayerBack()
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("show", m.selectedLiveCategory)
end sub

sub buildLiveStreamUrl(channel as Object)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "buildLiveStreamUrl"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.streamId = getStreamId(channel)
    m.xtreamService.streamExtension = getStreamExtension(channel)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub connectXtream(account as Object)
    print "DEBUG Login: enviando requisição de conexão Xtream"
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "connect"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub loadLiveChannels(category as Object)
    if not hasAccount(m.account) then
        m.liveChannelsLoading = false
        m.liveChannelsScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar os canais de TV ao vivo.")
        return
    end if

    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveStreams"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.categoryId = getCategoryId(category)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadLiveCategories(account as Object)
    m.liveCategoriesLoading = true
    if m.liveCategoriesScreen.visible = true then
        m.liveCategoriesScreen.callFunc("setLoading", true)
    else
        m.homeScreen.callFunc("setLiveCategoriesLoading", true)
    end if
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveCategories"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub onXtreamConnectionResult()
    result = m.xtreamService.result
    if result = invalid then return

    if result.request = "getLiveCategories" then
        onLiveCategoriesResult(result)
        return
    else if result.request = "buildLiveStreamUrl" then
        onLiveStreamUrlResult(result)
        return
    else if Left(result.request, 14) = "getLiveStreams" then
        onLiveChannelsResult(result)
        return
    end if

    stopLoginTimeout()
    m.loginScreen.callFunc("setLoading", false)

    if m.pendingAccount = invalid then
        print "DEBUG Login: resposta ignorada porque não há login pendente"
        return
    end if

    if isValidXtreamConnectionResult(result) then
        print "DEBUG Login: autenticação Xtream concluída com sucesso"
        m.account = m.pendingAccount
        SavePlaylist(m.account)
        SavePlaylistConnectionStatus("Conectado")
        updateConnectionStatus(true, "Conectado")
        m.pendingAccount = invalid
        m.liveCategories = []
        m.liveChannels = []
        m.liveCategoriesLoading = false
        m.liveChannelsLoading = false
        showHome()
    else
        print "DEBUG Login: erro na autenticação Xtream - " + getResultMessage(result)
        SavePlaylistConnectionStatus("Desconectado")
        m.pendingAccount = invalid
        m.liveCategories = []
        m.liveChannels = []
        m.liveCategoriesLoading = false
        m.liveChannelsLoading = false
        m.loginScreen.callFunc("showError", getResultMessage(result))
    end if
end sub

sub startLoginTimeout()
    if m.loginTimeoutTimer = invalid then return
    m.loginTimeoutTimer.control = "stop"
    m.loginTimeoutTimer.duration = 15
    m.loginTimeoutTimer.control = "start"
end sub

sub stopLoginTimeout()
    if m.loginTimeoutTimer = invalid then return
    m.loginTimeoutTimer.control = "stop"
end sub

sub onLoginTimeout()
    if m.pendingAccount = invalid then return

    print "DEBUG Login: timeout ao aguardar resposta Xtream"
    m.xtreamService.control = "STOP"
    m.pendingAccount = invalid
    m.liveCategoriesLoading = false
    m.liveChannelsLoading = false
    SavePlaylistConnectionStatus("Desconectado")
    m.loginScreen.callFunc("showError", "Servidor não respondeu. Verifique DNS, usuário e senha.")
end sub

sub onLiveCategoriesResult(result as Object)
    m.liveCategoriesLoading = false

    if result.success = true then
        m.liveCategories = normalizeLiveCategories(result.data)
        if m.liveCategories.Count() > 0 then
            updateConnectionStatus(true, "Conectado • Categorias de TV ao vivo carregadas")
            if m.liveCategoriesScreen.visible = true then
                m.liveCategoriesScreen.callFunc("setCategories", m.liveCategories)
            end if
        else
            updateConnectionStatus(true, "Conectado • Nenhuma categoria de TV ao vivo encontrada")
            if m.liveCategoriesScreen.visible = true then
                m.liveCategoriesScreen.callFunc("showMessage", "Nenhuma categoria de TV ao vivo foi encontrada.")
            end if
        end if
    else
        updateConnectionStatus(true, "Conectado • Não foi possível carregar categorias de TV ao vivo")
        if m.liveCategoriesScreen.visible = true then
            m.liveCategoriesScreen.callFunc("showMessage", "Não foi possível carregar as categorias de TV ao vivo. Tente novamente mais tarde.")
        end if
    end if
end sub

sub onLiveChannelsResult(result as Object)
    m.liveChannelsLoading = false

    if result.success = true then
        m.liveChannels = normalizeLiveChannels(result.data)
        if m.liveChannels.Count() > 0 then
            if m.liveChannelsScreen.visible = true then
                m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
            end if
        else
            if m.liveChannelsScreen.visible = true then
                m.liveChannelsScreen.callFunc("showMessage", "Nenhum canal foi encontrado nesta categoria.")
            end if
        end if
    else
        if m.liveChannelsScreen.visible = true then
            m.liveChannelsScreen.callFunc("showMessage", "Não foi possível carregar os canais desta categoria. Tente novamente mais tarde.")
        end if
    end if
end sub


sub onLiveStreamUrlResult(result as Object)
    if m.livePlayerScreen.visible <> true then return

    if result.success = true and result.data <> invalid and result.data.url <> invalid then
        m.livePlayerScreen.callFunc("play", result.data.url)
    else
        m.livePlayerScreen.callFunc("showError", "Não foi possível preparar a reprodução deste canal.")
    end if
end sub

function isValidXtreamConnectionResult(result as Dynamic) as Boolean
    if result = invalid then return false
    if result.success <> true or result.connected <> true then return false
    if result.data = invalid then return false
    if Type(result.data) <> "roAssociativeArray" then return false
    userInfo = result.data.user_info
    if userInfo = invalid then return false
    if Type(userInfo) <> "roAssociativeArray" then return false
    return true
end function

function getResultMessage(result as Dynamic) as String
    if result <> invalid and result.message <> invalid and result.message.ToStr().Trim() <> "" then
        return result.message.ToStr()
    end if
    return "Não foi possível conectar ao servidor."
end function

function getStreamId(channel as Dynamic) as String
    if channel = invalid then return ""
    if channel.stream_id <> invalid then return channel.stream_id.ToStr()
    if channel.id <> invalid then return channel.id.ToStr()
    return ""
end function

function getStreamExtension(channel as Dynamic) as String
    if channel = invalid then return "ts"
    if channel.container_extension <> invalid and channel.container_extension.ToStr().Trim() <> "" then return channel.container_extension.ToStr()
    if channel.stream_type <> invalid and LCase(channel.stream_type.ToStr()) = "m3u8" then return "m3u8"
    return "ts"
end function

function normalizeLiveChannels(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

function getCategoryId(category as Dynamic) as String
    if category = invalid then return ""
    if category.category_id <> invalid then return category.category_id.ToStr()
    if category.id <> invalid then return category.id.ToStr()
    return ""
end function

function normalizeLiveCategories(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

sub updateConnectionStatus(connected as Boolean, message as String)
    m.homeScreen.callFunc("updateConnectionStatus", {
        connected: connected,
        message: message
    })
end sub

function hasAccount(account as Dynamic) as Boolean
    if account = invalid then return false
    return safeText(account.dns) <> "" and safeText(account.username) <> "" and safeText(account.password) <> ""
end function

function safeText(value as Dynamic) as String
    if value = invalid then return ""
    return value.Trim()
end function
