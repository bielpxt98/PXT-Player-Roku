' Home screen for PXT Player.
sub Init()
    m.background = m.top.FindNode("homeBackground")
    m.title = m.top.FindNode("homeTitle")
    m.subtitle = m.top.FindNode("homeSubtitle")
    m.settingsButton = m.top.FindNode("settingsButton")

    m.settingsButton.ObserveField("buttonSelected", "onSettingsSelected")
    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, Int(height * 0.26)]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, Int(height * 0.38)]

    m.settingsButton.translation = [Int((width - 360) / 2), Int(height * 0.58)]
end sub

sub show()
    m.top.visible = true
    m.settingsButton.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub onSettingsSelected()
    m.top.openSettings = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    return false
end function

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
