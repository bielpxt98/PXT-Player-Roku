' Main scene for the PXT Player application.
' It coordinates feature screens and starts the basic Xtream connection check
' when locally saved login data is available.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.account = loadSavedAccount()

    configureScene()

    m.homeScreen.ObserveField("openLogin", "onOpenLogin")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")
    m.xtreamService.ObserveField("result", "onXtreamConnectionResult")

    showHome()

    if hasAccount(m.account) then
        updateConnectionStatus(false, "Conectando ao servidor salvo...")
        testXtreamConnection(m.account)
    end if
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

sub onOpenLogin()
    showLogin()
end sub

sub onLoginSubmit()
    m.account = m.loginScreen.submit
    saveAccount(m.account)
    updateConnectionStatus(false, "Conectando ao servidor...")
    showHome()
    testXtreamConnection(m.account)
end sub

sub onLoginBack()
    showHome()
end sub

sub testXtreamConnection(account as Object)
    if not hasAccount(account) then
        updateConnectionStatus(false, "Informe DNS, usuário e senha para conectar.")
        return
    end if

    m.xtreamService.control = "STOP"
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub onXtreamConnectionResult()
    result = m.xtreamService.result
    if result = invalid then return

    saveConnectionStatus(result.connected = true)
    updateConnectionStatus(result.connected = true, result.message)
end sub

sub updateConnectionStatus(connected as Boolean, message as String)
    m.homeScreen.callFunc("updateConnectionStatus", {
        connected: connected,
        message: message
    })
end sub

function loadSavedAccount() as Dynamic
    section = CreateObject("roRegistrySection", "pxt_player_account")
    if not section.Exists("dns") or not section.Exists("username") or not section.Exists("password") then
        return invalid
    end if

    return {
        dns: section.Read("dns"),
        username: section.Read("username"),
        password: section.Read("password")
    }
end function

sub saveAccount(account as Object)
    if account = invalid then return

    section = CreateObject("roRegistrySection", "pxt_player_account")
    section.Write("dns", account.dns)
    section.Write("username", account.username)
    section.Write("password", account.password)
    section.Flush()
end sub

sub saveConnectionStatus(connected as Boolean)
    section = CreateObject("roRegistrySection", "pxt_player_connection")
    if connected then
        section.Write("status", "connected")
    else
        section.Write("status", "disconnected")
    end if
    section.Flush()
end sub

function hasAccount(account as Dynamic) as Boolean
    if account = invalid then return false
    return account.dns.Trim() <> "" and account.username.Trim() <> "" and account.password.Trim() <> ""
end function
