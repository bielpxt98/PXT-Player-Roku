' Main scene for the PXT Player application.
' It coordinates feature screens and authenticates playlist credentials through
' XtreamService without loading channels, categories, or playback resources.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.account = LoadSavedPlaylist()
    m.pendingAccount = invalid

    configureScene()

    m.homeScreen.ObserveField("openPlaylist", "onOpenPlaylistRequested")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")
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
    m.homeScreen.callFunc("show")
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("show", m.account)
end sub

sub onOpenPlaylistRequested()
    showLogin()
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

sub connectXtream(account as Object)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "connect"
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub onXtreamConnectionResult()
    result = m.xtreamService.result
    if result = invalid then return

    if result.success = true and result.connected = true then
        m.account = m.pendingAccount
        SavePlaylist(m.account)
        SavePlaylistConnectionStatus("Conectado")
        updateConnectionStatus(true, "Conectado")
        m.pendingAccount = invalid
        showHome()
    else
        SavePlaylistConnectionStatus("Desconectado")
        m.pendingAccount = invalid
        m.loginScreen.callFunc("showError", "Não foi possível conectar ao servidor.")
    end if
end sub

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
