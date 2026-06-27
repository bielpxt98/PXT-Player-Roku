' Main SceneGraph scene for the PXT Player application.
' Feature flows (login, catalog, player) should be composed as child screens
' instead of being implemented directly in main.brs.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    configureScene()
end sub

sub configureScene()
    m.top.backgroundColor = "#000000"
    m.top.backgroundURI = ""
    m.homeScreen.SetFocus(true)
end sub
