' Minimal app flow: Login -> Live TV only.
sub Init()
    m.loginScreen = m.top.FindNode("loginScreen")
    m.liveTVScreen = m.top.FindNode("liveTVScreen")
    m.xtreamService = m.top.FindNode("xtreamService")

    m.account = invalid
    m.pendingRequest = ""
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
    else
        openLogin(invalid)
    end if
end sub

sub openLogin(account as Dynamic)
    m.pendingRequest = ""
    m.liveTVScreen.callFunc("hide")
    m.loginScreen.callFunc("show", account)
    m.loginScreen.SetFocus(true)
end sub

sub openLiveTv()
    m.loginScreen.callFunc("hide")
    m.liveTVScreen.callFunc("setAccount", m.account)
    m.liveTVScreen.callFunc("resetSelection")
    m.liveTVScreen.callFunc("show", invalid)
    loadLiveCategories()
end sub

sub onLoginSubmit()
    account = m.loginScreen.submit
    if not isValidAccount(account) then
        m.loginScreen.callFunc("showError", "Informe DNS, usuário e senha.")
        return
    end if

    m.account = normalizeAccount(account)
    m.loginScreen.callFunc("setLoading", true)
    runXtreamRequest("connect", "")
end sub

sub loadLiveCategories()
    m.liveTVScreen.callFunc("setCategories", [])
    m.liveTVScreen.callFunc("setLoading", false)
    m.liveTVScreen.callFunc("showMessage", "Carregando categorias de TV ao vivo...")
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
    ' Keep saved-account users in Live TV. Manual logout is intentionally absent in this reset.
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
        showRequestFailure(request, "Nao foi possivel carregar TV ao vivo." + Chr(10) + "Pressione OK para tentar novamente.")
        return
    end if

    if request = "connect" then
        if result.success = true then
            SavePlaylist(m.account)
            openLiveTv()
        else
            m.loginScreen.callFunc("showError", getResultMessage(result, "Login inválido. Verifique DNS, usuário e senha."))
        end if
    else if request = "getLiveCategories" then
        if result.success = true then
            categories = normalizeArray(result.data)
            m.liveTVScreen.callFunc("setCategories", categories)
            if categories.Count() > 0 then
                m.selectedCategory = categories[0]
                m.liveTVScreen.callFunc("showMessage", "Selecione uma categoria e pressione OK.")
            else
                m.liveTVScreen.callFunc("showMessage", "Nao foi possivel carregar TV ao vivo." + Chr(10) + "Pressione OK para tentar novamente.")
            end if
        else
            showRequestFailure(request, "Nao foi possivel carregar TV ao vivo." + Chr(10) + "Pressione OK para tentar novamente.")
        end if
    else if request = "getLiveStreams" then
        if result.success = true then
            m.liveTVScreen.callFunc("setChannels", normalizeArray(result.data))
            m.liveTVScreen.callFunc("focusChannels")
        else
            showRequestFailure(request, "Nao foi possivel carregar TV ao vivo." + Chr(10) + "Pressione OK para tentar novamente.")
        end if
    end if
end sub

sub showRequestFailure(request as String, message as String)
    if request = "getLiveStreams" then
        m.liveTVScreen.callFunc("setLoading", false)
    end if
    m.liveTVScreen.callFunc("showMessage", message)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "OK" and m.liveTVScreen.visible = true and m.pendingRequest = "" then
        if m.selectedCategory <> invalid then
            m.liveTVScreen.callFunc("setLoading", true)
            runXtreamRequest("getLiveStreams", getCategoryId(m.selectedCategory))
            return true
        end if
    end if
    return false
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
