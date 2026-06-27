' Main scene for the PXT Player application.
' It coordinates feature screens and persists playlist credentials locally.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.account = invalid

    configureScene()

    m.homeScreen.ObserveField("removePlaylist", "onRemovePlaylistRequested")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")

    m.account = LoadSavedPlaylist()
    if hasSavedPlaylist() then
        showHome()
    else
        showLogin()
    end if
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

sub onRemovePlaylistRequested()
    dialog = CreateObject("roSGNode", "Dialog")
    dialog.title = "Remover Lista de Reprodução"
    dialog.message = "Deseja remover a Lista de Reprodução salva? Você precisará informar DNS, usuário e senha novamente."
    dialog.buttons = ["REMOVER", "CANCELAR"]
    dialog.ObserveField("buttonSelected", "onRemovePlaylistDialogSelected")
    m.top.dialog = dialog
end sub

sub onRemovePlaylistDialogSelected()
    dialog = m.top.dialog
    if dialog = invalid then return

    selectedIndex = dialog.buttonSelected
    m.top.dialog = invalid

    if selectedIndex = 0 then
        DeleteSavedPlaylist()
        m.account = invalid
        showLogin()
    else
        showHome()
    end if
end sub

sub onLoginSubmit()
    ' No validation or remote connection is performed in this step.
    m.account = m.loginScreen.submit
    SavePlaylist(m.account)
    showHome()
end sub

sub onLoginBack()
    if hasSavedPlaylist() then
        showHome()
    end if
end sub
