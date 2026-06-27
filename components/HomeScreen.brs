' Home screen for PXT Player.
' This component owns home layout and remote navigation only; login and playback
' flows will be added as separate screens/components later.
sub Init()
    m.backgroundPoster = m.top.FindNode("backgroundPoster")
    m.readabilityOverlay = m.top.FindNode("readabilityOverlay")
    m.taglineLabel = m.top.FindNode("taglineLabel")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.buttons = [
        m.top.FindNode("liveButton"),
        m.top.FindNode("moviesButton"),
        m.top.FindNode("seriesButton"),
        m.top.FindNode("settingsButton")
    ]
    m.selectedIndex = 0

    configureTypography()
    resizeToDisplay()
    updateSelectedButton()
end sub

sub configureTypography()
    m.taglineLabel.font = "font:SmallSystemFont"
    m.hintLabel.font = "font:SmallSystemFont"
end sub

sub resizeToDisplay()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.backgroundPoster.width = width
    m.backgroundPoster.height = height
    m.readabilityOverlay.width = width
    m.readabilityOverlay.height = height
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press = false then return false

    if key = "up" then
        moveSelection(-1)
        return true
    else if key = "down" then
        moveSelection(1)
        return true
    else if key = "OK" then
        ' Placeholder for future screen routing. Login/player are intentionally
        ' not implemented in this first Home iteration.
        return true
    end if

    return false
end function

sub moveSelection(direction as Integer)
    buttonCount = m.buttons.Count()
    m.selectedIndex = (m.selectedIndex + direction + buttonCount) mod buttonCount
    updateSelectedButton()
end sub

sub updateSelectedButton()
    for index = 0 to m.buttons.Count() - 1
        m.buttons[index].selected = (index = m.selectedIndex)
    end for
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
