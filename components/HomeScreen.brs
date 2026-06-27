' Home screen for PXT Player.
sub Init()
    m.background = m.top.FindNode("homeBackground")
    m.title = m.top.FindNode("homeTitle")
    m.subtitle = m.top.FindNode("homeSubtitle")
    m.playlistButton = m.top.FindNode("playlistButton")
    m.connectionStatusLabel = m.top.FindNode("connectionStatusLabel")

    m.buttons = [m.playlistButton]
    m.focusIndex = 0

    m.playlistButton.ObserveField("buttonSelected", "onPlaylistSelected")
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
    m.title.translation = [0, Int(height * 0.22)]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, Int(height * 0.34)]

    m.playlistButton.translation = [Int((width - 520) / 2), Int(height * 0.58)]
    m.connectionStatusLabel.width = width
    m.connectionStatusLabel.font = "font:MediumSystemFont"
    m.connectionStatusLabel.translation = [0, Int(height * 0.72)]
end sub

sub show()
    m.top.visible = true
    m.focusIndex = 0
    updateFocus()
end sub

sub updateConnectionStatus(status as Object)
    if status = invalid then return

    if status.connected = true then
        m.connectionStatusLabel.color = "#5CE08A"
    else
        m.connectionStatusLabel.color = "#FFCC66"
    end if

    m.connectionStatusLabel.text = status.message
end sub

sub hide()
    m.top.visible = false
end sub

sub onPlaylistSelected()
    m.top.openPlaylist = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
        return true
    end if

    return false
end function

sub moveFocus(direction as Integer)
    nextIndex = m.focusIndex + direction
    if nextIndex < 0 then nextIndex = m.buttons.Count() - 1
    if nextIndex >= m.buttons.Count() then nextIndex = 0
    m.focusIndex = nextIndex
    updateFocus()
end sub

sub updateFocus()
    m.buttons[m.focusIndex].SetFocus(true)
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
