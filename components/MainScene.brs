' Main scene for the PXT Player application.
' It coordinates feature screens and persists playlist credentials locally.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.account = invalid

    configureScene()

    m.homeScreen.ObserveField("openPlaylist", "onOpenPlaylistRequested")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")

    m.account = LoadSavedPlaylist()
    showHome()
end sub

sub configureScene()
    m.top.backgroundColor = "#000000"
    m.top.backgroundURI = ""
    m.homeScreen.SetFocus(true)
end sub

function hasSavedPlaylist() as Boolean
    return m.account <> invalid
end function

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
    ' No validation or remote connection is performed in this step.
    m.account = m.loginScreen.submit
    SavePlaylist(m.account)
    showHome()
end sub

sub onLoginBack()
    showHome()
end sub
