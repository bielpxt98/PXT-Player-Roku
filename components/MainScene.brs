' Minimal app flow: Login -> Live TV only.
sub Init()
    print "PXT DEBUG: INIT"
    m.loginScreen = m.top.FindNode("loginScreen")
    m.liveTVScreen = m.top.FindNode("liveTVScreen")
    m.xtreamService = m.top.FindNode("xtreamService")

    m.account = invalid
    m.pendingRequest = ""
    m.lastFailedRequest = ""
    m.lastFailedCategoryId = ""
    m.selectedCategory = invalid
    m.selectedChannel = invalid

    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.liveTVScreen.ObserveField("categorySelected", "onLiveCategorySelected")
    m.liveTVScreen.ObserveField("channelSelected", "onLiveChannelSelected")
    m.liveTVScreen.ObserveField("backRequested", "onLiveBackRequested")
    m.xtreamService.ObserveField("result", "onXtreamResult")

    startInitialFlow()
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
end sub

sub openLiveTv()
    m.loginScreen.callFunc("hide")
    m.liveTVScreen.callFunc("setAccount", m.account)
    m.liveTVScreen.callFunc("resetSelection")
    m.liveTVScreen.callFunc("show", invalid)
    m.liveTVScreen.SetFocus(true)
    print "PXT DEBUG: OPEN_HOME"
end sub

sub onLoginSubmit()
    account = m.loginScreen.submit
    print "PXT DEBUG: LOGIN_SUBMIT"
    if not isValidAccount(account) then
        m.loginScreen.callFunc("showError", "Informe DNS, usuário e senha.")
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
    print "PXT DEBUG: CONNECT_START"
    runXtreamRequest("connect", "")
end sub

sub loadLiveCategories()
    m.liveTVScreen.callFunc("setCategories", [])
    m.liveTVScreen.callFunc("setLoading", false)
    m.liveTVScreen.callFunc("showMessage", "Carregando categorias de TV ao vivo...")
    print "PXT DEBUG: CATEGORIES_START"
    runXtreamRequest("getLiveCategories", "")
end sub

sub onLiveCategorySelected()
    category = m.liveTVScreen.categorySelected
    if category = invalid then return
    m.selectedCategory = category
    m.liveTVScreen.callFunc("setLoading", true)
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
end sub

sub onXtreamResult()
    result = m.xtreamService.result
    request = m.pendingRequest
    m.pendingRequest = ""

    if result = invalid then
        markFailure(request, "Nao foi possivel carregar TV ao vivo.", invalid)
        return
    end if

    print "PXT DEBUG: CONNECT_RESULT "; result.success
    if request = "connect" then
        if result.success = true then
            SavePlaylist(m.account)
            m.lastFailedRequest = ""
            loadLiveCategories()
        else
            markFailure(request, getResultMessage(result, "Login inválido. Verifique DNS, usuário e senha."), result)
        end if
    else if request = "getLiveCategories" then
        if result.success = true then
            categories = normalizeArray(result.data)
            m.liveTVScreen.callFunc("setCategories", categories)
            m.lastFailedRequest = ""
            print "PXT DEBUG: CATEGORIES_COUNT "; categories.Count()
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
    m.liveTVScreen.callFunc("setLoading", false)
    m.liveTVScreen.callFunc("showMessage", detail + suffix)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    normalizedKey = normalizeKey(key)
    if normalizedKey = "OK" and m.liveTVScreen.visible = true and m.pendingRequest = "" then
        if m.lastFailedRequest <> "" then
            retryLastFailure()
            return true
        else if m.selectedCategory <> invalid then
            m.liveTVScreen.callFunc("setLoading", true)
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
        runXtreamRequest("getLiveStreams", m.lastFailedCategoryId)
    end if
end sub

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
