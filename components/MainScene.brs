' Minimal app flow: Login -> Live TV only.
sub Init()
    m.background = m.top.FindNode("globalBackground")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.liveChannelsScreen = m.top.FindNode("liveChannelsScreen")
    m.livePlayerScreen = m.top.FindNode("livePlayerScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.requestTimeoutTimer = m.top.FindNode("requestTimeoutTimer")

    m.account = invalid
    m.pendingRequest = ""
    m.selectedCategory = invalid
    m.selectedChannel = invalid

    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.liveChannelsScreen.ObserveField("categorySelected", "onLiveCategorySelected")
    m.liveChannelsScreen.ObserveField("channelSelected", "onLiveChannelSelected")
    m.liveChannelsScreen.ObserveField("backRequested", "onLiveBackRequested")
    m.livePlayerScreen.ObserveField("backRequested", "onLivePlayerBack")
    m.xtreamService.ObserveField("result", "onXtreamResult")
    m.requestTimeoutTimer.ObserveField("fire", "onRequestTimeout")

    configureLayout()
    startInitialFlow()
end sub

sub configureLayout()
    size = getDisplayResolution()
    m.background.width = size.width
    m.background.height = size.height
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
    m.requestTimeoutTimer.control = "stop"
    m.pendingRequest = ""
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.loginScreen.callFunc("show", account)
    m.loginScreen.SetFocus(true)
end sub

sub openLiveTv()
    m.loginScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("setAccount", m.account)
    m.liveChannelsScreen.callFunc("resetSelection")
    m.liveChannelsScreen.callFunc("show", invalid)
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
    m.liveChannelsScreen.callFunc("setCategories", [])
    m.liveChannelsScreen.callFunc("setLoading", false)
    m.liveChannelsScreen.callFunc("showMessage", "Carregando categorias de TV ao vivo...")
    runXtreamRequest("getLiveCategories", "")
end sub

sub onLiveCategorySelected()
    category = m.liveChannelsScreen.categorySelected
    if category = invalid then return
    m.selectedCategory = category
    m.liveChannelsScreen.callFunc("setLoading", true)
    runXtreamRequest("getLiveStreams", getCategoryId(category))
end sub

sub onLiveChannelSelected()
    channel = m.liveChannelsScreen.channelSelected
    if channel = invalid then return
    m.selectedChannel = channel
    m.livePlayerScreen.callFunc("show", channel)
    runXtreamRequestWithStream("buildLiveStreamUrl", getChannelId(channel), getStreamExtension(channel))
end sub

sub onLiveBackRequested()
    ' Keep saved-account users in Live TV. Manual logout is intentionally absent in this reset.
    if m.account = invalid then openLogin(invalid)
end sub

sub onLivePlayerBack()
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("show", m.selectedCategory)
    m.liveChannelsScreen.callFunc("restoreSelectedChannel", m.selectedChannel)
end sub

sub runXtreamRequest(action as String, categoryId as String)
    runXtreamRequestInternal(action, categoryId, "", "")
end sub

sub runXtreamRequestWithStream(action as String, streamId as String, extension as String)
    runXtreamRequestInternal(action, "", streamId, extension)
end sub

sub runXtreamRequestInternal(action as String, categoryId as String, streamId as String, extension as String)
    if not isValidAccount(m.account) then
        openLogin(m.account)
        m.loginScreen.callFunc("showError", "Informe DNS, usuário e senha.")
        return
    end if

    m.pendingRequest = action
    m.requestTimeoutTimer.control = "stop"
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.categoryId = categoryId
    m.xtreamService.streamId = streamId
    m.xtreamService.streamExtension = extension
    m.xtreamService.action = action
    m.requestTimeoutTimer.control = "start"
    m.xtreamService.control = "RUN"
end sub

sub onXtreamResult()
    m.requestTimeoutTimer.control = "stop"
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
            m.liveChannelsScreen.callFunc("setCategories", categories)
            if categories.Count() > 0 then
                m.selectedCategory = categories[0]
                m.liveChannelsScreen.callFunc("showMessage", "Selecione uma categoria e pressione OK.")
            else
                m.liveChannelsScreen.callFunc("showMessage", "Nao foi possivel carregar TV ao vivo." + Chr(10) + "Pressione OK para tentar novamente.")
            end if
        else
            showRequestFailure(request, "Nao foi possivel carregar TV ao vivo." + Chr(10) + "Pressione OK para tentar novamente.")
        end if
    else if request = "getLiveStreams" then
        if result.success = true then
            m.liveChannelsScreen.callFunc("setChannels", normalizeArray(result.data))
            m.liveChannelsScreen.callFunc("focusChannels")
        else
            showRequestFailure(request, "Nao foi possivel carregar TV ao vivo." + Chr(10) + "Pressione OK para tentar novamente.")
        end if
    else if request = "buildLiveStreamUrl" then
        if result.success = true and result.data <> invalid and result.data.url <> invalid then
            m.livePlayerScreen.callFunc("play", result.data.url)
        else
            m.livePlayerScreen.callFunc("showError", getResultMessage(result, "Não foi possível abrir o player ao vivo."))
        end if
    end if
end sub

sub onRequestTimeout()
    request = m.pendingRequest
    m.pendingRequest = ""
    if request = "connect" then
        m.loginScreen.callFunc("showError", "Tempo esgotado. Verifique DNS, usuário e senha.")
    else
        showRequestFailure(request, "Tempo esgotado." + Chr(10) + "Pressione OK para tentar novamente.")
    end if
end sub

sub showRequestFailure(request as String, message as String)
    if request = "getLiveStreams" then
        m.liveChannelsScreen.callFunc("setLoading", false)
    end if
    m.liveChannelsScreen.callFunc("showMessage", message)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "OK" and m.liveChannelsScreen.visible = true and m.pendingRequest = "" then
        if m.selectedCategory <> invalid then
            m.liveChannelsScreen.callFunc("setLoading", true)
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

function getChannelId(channel as Dynamic) as String
    if channel = invalid then return ""
    if channel.stream_id <> invalid then return channel.stream_id.ToStr()
    if channel.id <> invalid then return channel.id.ToStr()
    return ""
end function

function getStreamExtension(channel as Dynamic) as String
    if channel <> invalid and channel.container_extension <> invalid and channel.container_extension.ToStr().Trim() <> "" then return channel.container_extension.ToStr()
    return "ts"
end function

function getResultMessage(result as Dynamic, fallback as String) as String
    if result <> invalid and result.message <> invalid and result.message.ToStr().Trim() <> "" then return result.message.ToStr()
    return fallback
end function

function safeText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr().Trim()
end function

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()
    return { width: displaySize.w, height: displaySize.h }
end function
