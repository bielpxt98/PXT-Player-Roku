' Main scene for the PXT Player application.
' It coordinates feature screens and authenticates playlist credentials through
' XtreamService without loading channels or playback resources.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.liveCategoriesScreen = m.top.FindNode("liveCategoriesScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.account = LoadSavedPlaylist()
    m.pendingAccount = invalid
    m.liveCategories = []
    m.liveCategoriesLoading = false

    configureScene()

    m.homeScreen.ObserveField("openPlaylist", "onOpenPlaylistRequested")
    m.homeScreen.ObserveField("openLiveCategories", "onOpenLiveCategoriesRequested")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")
    m.liveCategoriesScreen.ObserveField("backRequested", "onLiveCategoriesBack")
    m.xtreamService.ObserveField("result", "onXtreamConnectionResult")

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
    m.homeScreen.callFunc("show")
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.loginScreen.callFunc("show", m.account)
end sub

sub onOpenPlaylistRequested()
    showLogin()
end sub

sub onOpenLiveCategoriesRequested()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("show")

    if m.liveCategoriesLoading then
        m.liveCategoriesScreen.callFunc("setLoading", true)
    else if m.liveCategories <> invalid and m.liveCategories.Count() > 0 then
        m.liveCategoriesScreen.callFunc("setCategories", m.liveCategories)
    else
        m.liveCategoriesScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as categorias de TV ao vivo.")
    end if
end sub

sub onLoginSubmit()
    account = m.loginScreen.submit
    if not hasAccount(account) then
        m.loginScreen.callFunc("showError", "Informe DNS, usuário e senha para conectar.")
        return
    end if

    m.pendingAccount = account
    m.loginScreen.callFunc("setLoading", true)
    connectXtream(account)
end sub

sub onLoginBack()
    showHome()
end sub

sub onLiveCategoriesBack()
    showHome()
end sub

sub connectXtream(account as Object)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "connect"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub loadLiveCategories(account as Object)
    m.liveCategoriesLoading = true
    m.homeScreen.callFunc("setLiveCategoriesLoading", true)
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
    end if

    if result.success = true and result.connected = true then
        m.account = m.pendingAccount
        SavePlaylist(m.account)
        SavePlaylistConnectionStatus("Conectado")
        updateConnectionStatus(true, "Conectado")
        m.pendingAccount = invalid
        m.liveCategories = []
        m.liveCategoriesLoading = false
        showHome()
        loadLiveCategories(m.account)
    else
        SavePlaylistConnectionStatus("Desconectado")
        m.pendingAccount = invalid
        m.liveCategories = []
        m.liveCategoriesLoading = false
        m.loginScreen.callFunc("showError", "Não foi possível conectar ao servidor.")
    end if
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
