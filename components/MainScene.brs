' Minimal app flow: Login -> Live TV only.
sub Init()
    m.loginScreen = m.top.FindNode("loginScreen")
    m.liveTVScreen = m.top.FindNode("liveTVScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.debugPanel = m.top.FindNode("debugPanel")
    m.debugBackground = m.top.FindNode("debugBackground")
    m.debugTitle = m.top.FindNode("debugTitle")
    m.debugText = m.top.FindNode("debugText")

    m.account = invalid
    m.pendingRequest = ""
    m.lastFailedRequest = ""
    m.lastFailedCategoryId = ""
    m.selectedCategory = invalid
    m.selectedChannel = invalid
    m.debugState = { screen: "Inicializando", dns: "", username: "", action: "", url: "", status: "", error: "", key: "", categories: 0, channels: 0, time: "" }

    configureDebugPanel()
    updateDebug("INIT", {})

    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.liveTVScreen.ObserveField("categorySelected", "onLiveCategorySelected")
    m.liveTVScreen.ObserveField("channelSelected", "onLiveChannelSelected")
    m.liveTVScreen.ObserveField("backRequested", "onLiveBackRequested")
    m.xtreamService.ObserveField("result", "onXtreamResult")

    startInitialFlow()
end sub

sub configureDebugPanel()
    r = getDisplayResolution() : w = r.width : h = r.height
    panelW = 360 : panelH = h
    if w <= 1280 then panelW = 300
    m.debugPanel.translation = [w - panelW, 0]
    m.debugBackground.width = panelW : m.debugBackground.height = panelH
    m.debugTitle.translation = [14, 14] : m.debugTitle.width = panelW - 28 : m.debugTitle.font = "font:SmallBoldSystemFont"
    m.debugText.translation = [14, 48] : m.debugText.width = panelW - 28 : m.debugText.height = panelH - 60 : m.debugText.font = "font:SmallSystemFont"
end sub

sub startInitialFlow()
    savedAccount = LoadSavedPlaylist()
    if isValidAccount(savedAccount) then
        m.account = savedAccount
        openLiveTv()
        startConnectFromHome()
    else
        openLogin(invalid)
    end if
end sub

sub openLogin(account as Dynamic)
    m.pendingRequest = ""
    m.lastFailedRequest = ""
    m.liveTVScreen.callFunc("hide")
    m.loginScreen.callFunc("show", account)
    m.loginScreen.SetFocus(true)
    updateDebug("OPEN_LOGIN", { screen: "Login" })
end sub

sub openLiveTv()
    m.loginScreen.callFunc("hide")
    m.liveTVScreen.callFunc("setAccount", m.account)
    m.liveTVScreen.callFunc("resetSelection")
    m.liveTVScreen.callFunc("show", invalid)
    m.liveTVScreen.SetFocus(true)
    updateDebug("OPEN_HOME", { screen: "Home / TV AO VIVO", error: "" })
end sub

sub onLoginSubmit()
    account = m.loginScreen.submit
    updateDebug("LOGIN_SUBMIT", { screen: "Login", dns: safeText(account.dns), username: safeText(account.username), action: "connect" })
    if not isValidAccount(account) then
        m.loginScreen.callFunc("showError", "Informe DNS, usuário e senha.")
        updateDebug("LOGIN_SUBMIT", { error: "Informe DNS, usuário e senha." })
        return
    end if

    m.account = normalizeAccount(account)
    openLiveTv()
    startConnectFromHome()
end sub

sub startConnectFromHome()
    m.liveTVScreen.callFunc("setCategories", [])
    m.liveTVScreen.callFunc("setLoading", false)
    m.liveTVScreen.callFunc("showMessage", "Conectando...")
    updateDebug("CONNECT_START", { action: "connect", status: "", error: "", categories: 0, channels: 0 })
    runXtreamRequest("connect", "")
end sub

sub loadLiveCategories()
    m.liveTVScreen.callFunc("setCategories", [])
    m.liveTVScreen.callFunc("setLoading", false)
    m.liveTVScreen.callFunc("showMessage", "Carregando categorias de TV ao vivo...")
    updateDebug("CATEGORIES_START", { action: "get_live_categories", status: "", error: "", categories: 0, channels: 0 })
    runXtreamRequest("getLiveCategories", "")
end sub

sub onLiveCategorySelected()
    category = m.liveTVScreen.categorySelected
    if category = invalid then return
    m.selectedCategory = category
    m.liveTVScreen.callFunc("setLoading", true)
    updateDebug("STREAMS_START", { action: "get_live_streams", status: "", error: "", channels: 0 })
    runXtreamRequest("getLiveStreams", getCategoryId(category))
end sub

sub onLiveChannelSelected()
    channel = m.liveTVScreen.channelSelected
    if channel = invalid then return
    m.selectedChannel = channel
    m.liveTVScreen.callFunc("showMessage", "Reproducao ao vivo indisponivel nesta versao.")
end sub

sub onLiveBackRequested()
    if m.account = invalid then openLogin(invalid)
end sub

sub runXtreamRequest(action as String, categoryId as String)
    if not isValidAccount(m.account) then
        openLogin(m.account)
        m.loginScreen.callFunc("showError", "Informe DNS, usuário e senha.")
        return
    end if

    m.pendingRequest = action
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.categoryId = categoryId
    m.xtreamService.action = action
    m.xtreamService.control = "RUN"
    updateDebug(action + "_REQUEST", { dns: m.account.dns, username: m.account.username, action: actionToApiAction(action), url: buildDebugUrl(action, categoryId) })
end sub

sub onXtreamResult()
    result = m.xtreamService.result
    request = m.pendingRequest
    m.pendingRequest = ""

    if result = invalid then
        markFailure(request, "Nao foi possivel carregar TV ao vivo.", invalid)
        return
    end if

    updateDebugFromResult(result)
    if request = "connect" then
        if result.success = true then
            SavePlaylist(m.account)
            m.lastFailedRequest = ""
            updateDebug("CONNECT_SUCCESS", { error: "" })
            loadLiveCategories()
        else
            markFailure(request, getResultMessage(result, "Login inválido. Verifique DNS, usuário e senha."), result)
        end if
    else if request = "getLiveCategories" then
        if result.success = true then
            categories = normalizeArray(result.data)
            m.liveTVScreen.callFunc("setCategories", categories)
            m.lastFailedRequest = ""
            updateDebug("CATEGORIES_SUCCESS", { categories: categories.Count(), error: "" })
            if categories.Count() > 0 then
                m.selectedCategory = categories[0]
                m.liveTVScreen.callFunc("showMessage", "Selecione uma categoria e pressione OK.")
            else
                markFailure(request, "Nenhuma categoria encontrada. Pressione OK para tentar novamente.", result)
            end if
        else
            markFailure(request, "Nao foi possivel carregar TV ao vivo.", result)
        end if
    else if request = "getLiveStreams" then
        if result.success = true then
            channels = normalizeArray(result.data)
            m.liveTVScreen.callFunc("setChannels", channels)
            m.liveTVScreen.callFunc("focusChannels")
            m.lastFailedRequest = ""
            updateDebug("STREAMS_SUCCESS", { channels: channels.Count(), error: "" })
        else
            markFailure(request, "Nao foi possivel carregar TV ao vivo.", result)
        end if
    end if
end sub

sub markFailure(request as String, message as String, result as Dynamic)
    m.lastFailedRequest = request
    if request = "getLiveStreams" and m.selectedCategory <> invalid then m.lastFailedCategoryId = getCategoryId(m.selectedCategory)
    detail = message
    if result <> invalid then detail = getResultMessage(result, message)
    suffix = Chr(10) + "Pressione OK para tentar novamente."
    if request = "connect" then updateDebug("CONNECT_ERROR", { error: detail })
    if request = "getLiveCategories" then updateDebug("CATEGORIES_ERROR", { error: detail })
    if request = "getLiveStreams" then updateDebug("STREAMS_ERROR", { error: detail })
    m.liveTVScreen.callFunc("setLoading", false)
    m.liveTVScreen.callFunc("showMessage", detail + suffix)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    normalizedKey = normalizeKey(key)
    updateDebug("KEY", { key: key })
    if normalizedKey = "OK" and m.liveTVScreen.visible = true and m.pendingRequest = "" then
        if m.lastFailedRequest <> "" then
            retryLastFailure()
            return true
        else if m.selectedCategory <> invalid then
            m.liveTVScreen.callFunc("setLoading", true)
            updateDebug("STREAMS_START", { action: "get_live_streams", error: "", channels: 0 })
            runXtreamRequest("getLiveStreams", getCategoryId(m.selectedCategory))
            return true
        end if
    end if
    return false
end function

sub retryLastFailure()
    request = m.lastFailedRequest
    m.lastFailedRequest = ""
    if request = "connect" then
        startConnectFromHome()
    else if request = "getLiveCategories" then
        loadLiveCategories()
    else if request = "getLiveStreams" then
        m.liveTVScreen.callFunc("setLoading", true)
        updateDebug("STREAMS_START", { action: "get_live_streams", status: "", error: "", channels: 0 })
        runXtreamRequest("getLiveStreams", m.lastFailedCategoryId)
    end if
end sub

sub updateDebug(eventName as String, values as Object)
    if m.debugState = invalid then return
    if values <> invalid then
        for each k in values
            m.debugState[k] = values[k]
        end for
    end if
    if m.account <> invalid then
        m.debugState.dns = m.account.dns
        m.debugState.username = m.account.username
    end if
    text = "Tela atual: " + safeText(m.debugState.screen) + Chr(10)
    text = text + "DNS usado: " + safeText(m.debugState.dns) + Chr(10)
    text = text + "Usuário: " + safeText(m.debugState.username) + Chr(10)
    text = text + "senha: ***" + Chr(10)
    text = text + "Ação atual: " + safeText(m.debugState.action) + Chr(10)
    text = text + "URL: " + safeText(m.debugState.url) + Chr(10)
    text = text + "HTTP: " + safeText(m.debugState.status) + Chr(10)
    text = text + "Erro: " + safeText(m.debugState.error) + Chr(10)
    text = text + "Última tecla: " + safeText(m.debugState.key) + Chr(10)
    text = text + "Categorias: " + m.debugState.categories.ToStr() + Chr(10)
    text = text + "Canais: " + m.debugState.channels.ToStr() + Chr(10)
    text = text + "Tempo req.: " + safeText(m.debugState.time) + Chr(10)
    text = text + "Evento: " + eventName
    m.debugText.text = text
end sub

sub updateDebugFromResult(result as Dynamic)
    values = {}
    if result.statusCode <> invalid then values.status = result.statusCode.ToStr()
    if result.elapsedMs <> invalid then values.time = result.elapsedMs.ToStr() + " ms"
    if result.url <> invalid then values.url = result.url
    if result.message <> invalid and result.success <> true then values.error = result.message
    updateDebug("XTREAM_RESULT", values)
end sub

function actionToApiAction(action as String) as String
    if action = "getLiveCategories" then return "get_live_categories"
    if action = "getLiveStreams" then return "get_live_streams"
    return "connect"
end function

function buildDebugUrl(action as String, categoryId as String) as String
    if m.account = invalid then return ""
    url = m.account.dns + "/player_api.php?username=" + escapeDebugValue(m.account.username) + "&password=***"
    apiAction = actionToApiAction(action)
    if apiAction <> "connect" then url = url + "&action=" + apiAction
    if apiAction = "get_live_streams" and categoryId <> "" then url = url + "&category_id=" + categoryId
    return url
end function

function escapeDebugValue(value as Dynamic) as String
    transfer = CreateObject("roUrlTransfer")
    return transfer.Escape(safeText(value))
end function

function isValidAccount(account as Dynamic) as Boolean
    if account = invalid then return false
    return safeText(account.dns) <> "" and safeText(account.username) <> "" and safeText(account.password) <> ""
end function

function normalizeAccount(account as Object) as Object
    dns = safeText(account.dns)
    lowerDns = LCase(dns)
    if Left(lowerDns, 7) <> "http://" and Left(lowerDns, 8) <> "https://" then dns = "http://" + dns
    while Right(dns, 1) = "/"
        dns = Left(dns, Len(dns) - 1)
    end while
    return { dns: dns, username: safeText(account.username), password: safeText(account.password) }
end function

function normalizeArray(items as Dynamic) as Object
    if items = invalid then return []
    if Type(items) = "roArray" then return items
    return []
end function

function getCategoryId(category as Dynamic) as String
    if category = invalid then return ""
    if category.category_id <> invalid then return category.category_id.ToStr()
    if category.id <> invalid then return category.id.ToStr()
    return ""
end function

function getResultMessage(result as Dynamic, fallback as String) as String
    if result <> invalid and result.message <> invalid and result.message.ToStr().Trim() <> "" then return result.message.ToStr()
    return fallback
end function

function safeText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr().Trim()
end function
