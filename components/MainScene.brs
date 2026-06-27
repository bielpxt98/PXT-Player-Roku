' Main scene for the PXT Player application.
' It coordinates feature screens while keeping login data in memory only.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.account = invalid

    configureScene()

    m.homeScreen.ObserveField("openSettings", "onOpenSettings")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")

    if hasSavedAccount() then
        showHome()
    else
        showLogin()
    end if
end sub

sub configureScene()
    m.top.backgroundColor = "#000000"
    m.top.backgroundURI = ""
end sub

function hasSavedAccount() as Boolean
    ' Persistent account loading will be added with the Xtream/M3U integration.
    return false
end function

sub showHome()
    m.loginScreen.callFunc("hide")
    m.homeScreen.callFunc("show")
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("show", m.account)
end sub

sub onOpenSettings()
    showLogin()
end sub

sub onLoginSubmit()
    ' No validation or remote connection is performed in this step.
    m.account = m.loginScreen.submit
    showHome()
end sub

sub onLoginBack()
    showHome()
end sub
