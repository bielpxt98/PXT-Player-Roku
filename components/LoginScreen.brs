' Login screen. It captures account data and delegates Xtream authentication
' to the MainScene/XtreamService integration.
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
    m.demoButton = m.top.FindNode("demoButton")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.messageLabel = m.top.FindNode("messageLabel")
    m.customKeyboard = m.top.FindNode("customKeyboard")
    m.keyboardTitle = m.top.FindNode("keyboardTitle")
    m.keyboardText = m.top.FindNode("keyboardText")
    m.keyboardGrid = m.top.FindNode("keyboardGrid")

    m.focusRings = [
        m.top.FindNode("dnsFocus"),
        m.top.FindNode("userFocus"),
        m.top.FindNode("passwordFocus")
    ]
    m.focusableControls = [m.dnsInput, m.userInput, m.passwordInput, m.enterButton, m.demoButton, m.backButton]
    m.textFieldMaxLengths = [200, 100, 100]
    m.textFieldTitles = ["DNS", "USUÁRIO", "SENHA"]
    m.textFieldLogNames = ["dns", "username", "password"]
    m.keyboardKeys = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3",
        "4", "5", "6", "7", "8", "9", ".", "/", ":", "-",
        "_", "@", "APAGAR", "ESPAÇO", "OK", "CANCELAR"
    ]
    m.keyboardColumns = 10
    m.activeTextFieldIndex = invalid
    m.keyboardTextValue = ""
    m.keyboardFocusIndex = 0
    m.focusIndex = 0
    m.isLoading = false

    m.enterButton.ObserveField("buttonSelected", "onEnterSelected")
    m.backButton.ObserveField("buttonSelected", "onBackSelected")
    m.demoButton.ObserveField("buttonSelected", "onDemoSelected")

    configureLayout()
    buildCustomKeyboard()
    setLoading(false)
    clearMessage()
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
    m.messageLabel.width = 600
    m.loadingLabel.width = 500

    m.customKeyboard.translation = [Int((width - 900) / 2), Int((height - 520) / 2)]
end sub

sub show(account as Object)
    m.top.visible = true
    if account <> invalid then
        m.dnsInput.text = account.dns
        m.userInput.text = account.username
        m.passwordInput.text = account.password
    end if
    closeCustomKeyboard(false)
    setLoading(false)
    clearMessage()
    m.focusIndex = 0
    updateFocus()
end sub

sub hide()
    closeCustomKeyboard(false)
    m.top.visible = false
    setLoading(false)
end sub

sub setLoading(isLoading as Boolean)
    m.isLoading = isLoading
    m.loadingSpinner.visible = isLoading
    if isLoading then
        m.loadingSpinner.control = "start"
    else
        m.loadingSpinner.control = "stop"
    end if
    m.loadingLabel.visible = isLoading
end sub

sub showError(message as String)
    setLoading(false)
    m.messageLabel.color = "#FF6B6B"
    m.messageLabel.text = message
    m.messageLabel.visible = true
    updateFocus()
end sub

sub showMessage(message as String)
    m.messageLabel.color = "#B8C3D6"
    m.messageLabel.text = message
    m.messageLabel.visible = true
end sub

sub clearMessage()
    m.messageLabel.text = ""
    m.messageLabel.visible = false
end sub

sub onEnterSelected()
    showMessage("Tentando conectar...")

    account = {
        dns: safeTrim(m.dnsInput.text),
        username: safeTrim(m.userInput.text),
        password: safeTrim(m.passwordInput.text)
    }

    ' MainScene decides whether empty fields return to Home or filled
    ' credentials should trigger a network request.

    ' LoginScreen only validates and submits data. MainScene owns navigation
    ' and all Xtream network work so focus never stays trapped on ENTRAR.
    setLoading(true)
    m.top.submit = account
end sub

sub onBackSelected()
    setLoading(false)
    m.top.backRequested = true
end sub

sub onDemoSelected()
    setLoading(false)
    clearMessage()
    m.top.demoRequested = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if m.customKeyboard.visible then
        return handleCustomKeyboardKey(key)
    end if

    if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
        return true
    else if key = "left" then
        if m.focusIndex > 3 and m.focusIndex <= 5 then
            m.focusIndex = m.focusIndex - 1
            updateFocus()
            return true
        end if
    else if key = "right" then
        if m.focusIndex >= 3 and m.focusIndex < 5 then
            m.focusIndex = m.focusIndex + 1
            updateFocus()
            return true
        end if
    else if key = "back" then
        onBackSelected()
        return true
    else if isOkKey(key) then
        if m.focusIndex <= 2 then
            openTextKeyboard(m.focusIndex)
            return true
        else if m.focusIndex = 3 then
            onEnterSelected()
            return true
        else if m.focusIndex = 4 then
            onDemoSelected()
            return true
        else if m.focusIndex = 5 then
            onBackSelected()
            return true
        end if
    end if

    return false
end function

sub openTextKeyboard(fieldIndex as Integer)
    m.activeTextFieldIndex = fieldIndex
    m.keyboardTextValue = m.focusableControls[fieldIndex].text
    m.keyboardFocusIndex = 0
    m.keyboardTitle.text = "Editar " + m.textFieldTitles[fieldIndex]
    m.customKeyboard.visible = true
    updateKeyboardText()
    updateKeyboardFocus()
end sub

function handleCustomKeyboardKey(key as String) as Boolean
    if key = "back" then
        closeCustomKeyboard(false)
        return true
    else if key = "left" then
        moveKeyboardFocus(-1, 0)
        return true
    else if key = "right" then
        moveKeyboardFocus(1, 0)
        return true
    else if key = "up" then
        moveKeyboardFocus(0, -1)
        return true
    else if key = "down" then
        moveKeyboardFocus(0, 1)
        return true
    else if isConfirmKey(key) then
        selectKeyboardKey()
        return true
    end if

    return true
end function

sub moveKeyboardFocus(horizontal as Integer, vertical as Integer)
    nextIndex = m.keyboardFocusIndex + horizontal + (vertical * m.keyboardColumns)
    if nextIndex < 0 then nextIndex = m.keyboardKeys.Count() - 1
    if nextIndex >= m.keyboardKeys.Count() then nextIndex = 0
    m.keyboardFocusIndex = nextIndex
    updateKeyboardFocus()
end sub

sub selectKeyboardKey()
    selectedKey = m.keyboardKeys[m.keyboardFocusIndex]
    if selectedKey = "APAGAR" then
        if Len(m.keyboardTextValue) > 0 then
            m.keyboardTextValue = Left(m.keyboardTextValue, Len(m.keyboardTextValue) - 1)
        end if
        updateKeyboardText()
    else if selectedKey = "ESPAÇO" then
        appendKeyboardText(" ")
    else if selectedKey = "OK" then
        if m.activeTextFieldIndex <> invalid then
            m.focusableControls[m.activeTextFieldIndex].text = m.keyboardTextValue
        end if
        closeCustomKeyboard(true)
    else if selectedKey = "CANCELAR" then
        closeCustomKeyboard(false)
    else
        appendKeyboardText(selectedKey)
    end if
end sub

sub appendKeyboardText(value as String)
    if m.activeTextFieldIndex = invalid then return
    if Len(m.keyboardTextValue) >= m.textFieldMaxLengths[m.activeTextFieldIndex] then return
    m.keyboardTextValue = m.keyboardTextValue + value
    updateKeyboardText()
end sub

sub closeCustomKeyboard(saved as Boolean)
    if m.customKeyboard = invalid then return
    m.customKeyboard.visible = false
    m.keyboardTextValue = ""
    m.keyboardFocusIndex = 0
    m.activeTextFieldIndex = invalid
    updateFocus()
end sub

sub buildCustomKeyboard()
    while m.keyboardGrid.GetChildCount() > 0
        m.keyboardGrid.RemoveChild(m.keyboardGrid.GetChild(0))
    end while

    keyWidth = 78
    keyHeight = 52
    keyGap = 8

    for index = 0 to m.keyboardKeys.Count() - 1
        keyGroup = CreateObject("roSGNode", "Group")
        row = Int(index / m.keyboardColumns)
        column = index MOD m.keyboardColumns
        keyGroup.translation = [column * (keyWidth + keyGap), row * (keyHeight + keyGap)]

        background = CreateObject("roSGNode", "Rectangle")
        background.width = keyWidth
        background.height = keyHeight
        background.color = "#26364F"

        label = CreateObject("roSGNode", "Label")
        label.width = keyWidth
        label.height = keyHeight
        label.text = m.keyboardKeys[index]
        label.color = "#FFFFFF"
        label.horizAlign = "center"
        label.vertAlign = "center"
        label.font = "font:SmallBoldSystemFont"

        keyGroup.AppendChild(background)
        keyGroup.AppendChild(label)
        m.keyboardGrid.AppendChild(keyGroup)
    end for
end sub

sub updateKeyboardFocus()
    for index = 0 to m.keyboardGrid.GetChildCount() - 1
        keyGroup = m.keyboardGrid.GetChild(index)
        background = keyGroup.GetChild(0)
        if index = m.keyboardFocusIndex then
            background.color = "#147DFF"
        else
            background.color = "#26364F"
        end if
    end for
end sub

sub updateKeyboardText()
    if m.activeTextFieldIndex = 2 then
        m.keyboardText.text = String(Len(m.keyboardTextValue), "*")
    else
        m.keyboardText.text = m.keyboardTextValue
    end if
end sub

function isOkKey(key as String) as Boolean
    k = LCase(key)
    return k = "ok" or k = "enter" or k = "return" or k = "select" or k = "numpadenter"
end function

function isConfirmKey(key as String) as Boolean
    return isOkKey(key)
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


function safeTrim(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr().Trim()
end function
