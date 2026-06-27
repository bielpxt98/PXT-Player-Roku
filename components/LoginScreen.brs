' Login screen. It captures account data locally and intentionally does not
' validate or connect to Xtream/M3U services yet.
sub Init()
    m.background = m.top.FindNode("loginBackground")
    m.title = m.top.FindNode("loginTitle")
    m.subtitle = m.top.FindNode("loginSubtitle")
    m.formGroup = m.top.FindNode("formGroup")

    m.dnsInput = m.top.FindNode("dnsInput")
    m.userInput = m.top.FindNode("userInput")
    m.passwordInput = m.top.FindNode("passwordInput")
    m.enterButton = m.top.FindNode("enterButton")
    m.backButton = m.top.FindNode("backButton")

    m.focusRings = [
        m.top.FindNode("dnsFocus"),
        m.top.FindNode("userFocus"),
        m.top.FindNode("passwordFocus")
    ]
    m.focusableControls = [m.dnsInput, m.userInput, m.passwordInput, m.enterButton, m.backButton]
    m.focusIndex = 0

    m.enterButton.ObserveField("buttonSelected", "onEnterSelected")
    m.backButton.ObserveField("buttonSelected", "onBackSelected")

    configureLayout()
    updateFocus()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, 70]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, 142]

    m.formGroup.translation = [Int((width - 600) / 2), 230]
end sub

sub show(account as Object)
    m.top.visible = true
    if account <> invalid then
        m.dnsInput.text = account.dns
        m.userInput.text = account.username
        m.passwordInput.text = account.password
    end if
    m.focusIndex = 0
    updateFocus()
end sub

sub hide()
    m.top.visible = false
end sub

sub onEnterSelected()
    m.top.submit = {
        dns: m.dnsInput.text,
        username: m.userInput.text,
        password: m.passwordInput.text
    }
end sub

sub onBackSelected()
    m.top.backRequested = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
        return true
    else if key = "left" then
        if m.focusIndex = 4 then
            m.focusIndex = 3
            updateFocus()
            return true
        end if
    else if key = "right" then
        if m.focusIndex = 3 then
            m.focusIndex = 4
            updateFocus()
            return true
        end if
    else if key = "back" then
        onBackSelected()
        return true
    end if

    return false
end function

sub moveFocus(direction as Integer)
    nextIndex = m.focusIndex + direction
    if nextIndex < 0 then nextIndex = m.focusableControls.Count() - 1
    if nextIndex >= m.focusableControls.Count() then nextIndex = 0
    m.focusIndex = nextIndex
    updateFocus()
end sub

sub updateFocus()
    for each ring in m.focusRings
        ring.visible = false
    end for

    if m.focusIndex <= 2 then
        m.focusRings[m.focusIndex].visible = true
    end if

    m.focusableControls[m.focusIndex].SetFocus(true)
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
