' Main splash scene for the PXT Player application.
' Future feature flows (login, catalog, player) should be composed from this scene
' instead of being implemented directly in main.brs.
sub Init()
    m.background = m.top.FindNode("splashBackground")
    m.title = m.top.FindNode("splashTitle")

    configureScene()
    showSplash()
end sub

sub configureScene()
    m.top.backgroundColor = "#000000"
    m.top.backgroundURI = ""
end sub

sub showSplash()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.height = height
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, 0]
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
