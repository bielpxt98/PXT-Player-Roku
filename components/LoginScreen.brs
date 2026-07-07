' Login screen with custom on-screen keyboard for Roku remote/mobile input.
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
    m.removeButton = m.top.FindNode("removeButton")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.messageLabel = m.top.FindNode("messageLabel")

    m.keyboardOverlay = m.top.FindNode("keyboardOverlay")
    m.keyboardDim = m.top.FindNode("keyboardDim")
    m.keyboardPanel = m.top.FindNode("keyboardPanel")
    m.keyboardTitle = m.top.FindNode("keyboardTitle")
    m.keyboardInputText = m.top.FindNode("keyboardInputText")
    m.keyboardKeysGroup = m.top.FindNode("keyboardKeys")

    m.focusRings = [
        m.top.FindNode("dnsFocus"),
        m.top.FindNode("userFocus"),
        m.top.FindNode("passwordFocus")
    ]
    m.focusableControls = [m.dnsInput, m.userInput, m.passwordInput, m.enterButton, m.demoButton, m.backButton]
    m.textFieldMaxLengths = [200, 100, 100]
    m.textFieldTitles = ["DNS", "USUÁRIO", "SENHA"]
    m.focusIndex = 0
    m.isLoading = false
    m.hasSavedAccount = false
    m.keyboardActive = false
    m.keyboardFieldIndex = 0
    m.keyboardText = ""
    m.keyboardFocusIndex = 0
    m.keyboardColumns = 10
    m.keyboardKeys = []

    ' PRINT "ACCOUNT_SCREEN_INIT"

    m.enterButton.ObserveField("buttonSelected", "onEnterSelected")
    m.backButton.ObserveField("buttonSelected", "onBackSelected")
    m.demoButton.ObserveField("buttonSelected", "onDemoSelected")
    if m.keyboardInputText <> invalid then m.keyboardInputText.ObserveField("text", "onKeyboardTextChanged")

    configureLayout()
    buildKeyboardKeys()
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
    if m.keyboardDim <> invalid then
        m.keyboardDim.width = width
        m.keyboardDim.height = height
    end if

    m.title.width = width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, 70]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, 142]

    m.formGroup.translation = [Int((width - 600) / 2), 230]
    m.messageLabel.width = 600
    m.loadingLabel.width = 500
end sub

sub buildKeyboardKeys()
    if m.keyboardKeysGroup = invalid then return
    while m.keyboardKeysGroup.GetChildCount() > 0 : m.keyboardKeysGroup.RemoveChildIndex(0) : end while
    m.keyboardKeys = []

    rows = [
        ["A","B","C","D","E","F","G","H","I","J"],
        ["K","L","M","N","O","P","Q","R","S","T"],
        ["U","V","W","X","Y","Z","1","2","3","4"],
        ["5","6","7","8","9","0",".",":","/","-"],
        ["_","@","http://","https://",".com","ESPAÇO","APAGAR","LIMPAR","OK","CANCELAR"]
    ]

    keyW = 86
    keyH = 48
    gap = 5
    for r = 0 to rows.Count() - 1
        row = rows[r]
        for c = 0 to row.Count() - 1
            value = row[c]
            x = c * (keyW + gap)
            y = r * (keyH + gap)
            rect = CreateObject("roSGNode", "Rectangle")
            rect.width = keyW
            rect.height = keyH
            rect.color = "#173B76"
            rect.translation = [x, y]
            label = CreateObject("roSGNode", "Label")
            label.text = value
            label.width = keyW
            label.height = keyH
            label.horizAlign = "center"
            label.vertAlign = "center"
            label.color = "#FFFFFF"
            label.font = "font:SmallBoldSystemFont"
            label.translation = [x, y + 4]
            m.keyboardKeysGroup.appendChild(rect)
            m.keyboardKeysGroup.appendChild(label)
            m.keyboardKeys.Push({ value: value, rect: rect, label: label })
        end for
    end for
end sub

sub show(account as Object)
    wasVisible = m.top.visible
    m.top.visible = true
    m.hasSavedAccount = account <> invalid and safeTrim(getAAValue(account, "dns")) <> "" and safeTrim(getAAValue(account, "username")) <> "" and safeTrim(getAAValue(account, "password")) <> ""
    if m.removeButton <> invalid then m.removeButton.visible = false
    if account <> invalid then
        m.dnsInput.text = safeTrim(getAAValue(account, "dns"))
        m.userInput.text = safeTrim(getAAValue(account, "username"))
        m.passwordInput.text = safeTrim(getAAValue(account, "password"))
        if m.hasSavedAccount then PRINT "ACCOUNT_RESTORE_SUCCESS"
    end if
    closeKeyboard(false)
    setLoading(false)
    clearMessage()
    if wasVisible <> true then m.focusIndex = 0
    updateFocus()
end sub

sub hide()
    closeKeyboard(false)
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
    account = {
        dns: resolveDnsShortcut(safeTrim(m.dnsInput.text)),
        username: safeTrim(m.userInput.text),
        password: safeTrim(m.passwordInput.text)
    }
    ' PRINT "ACCOUNT_LOGIN_SUBMIT"
    showMessage("Tentando conectar...")
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

sub onRemoveSelected()
    ' PRINT "ACCOUNT_REMOVE_CONFIRMED"
    setLoading(false)
    clearMessage()
    m.dnsInput.text = ""
    m.userInput.text = ""
    m.passwordInput.text = ""
    m.hasSavedAccount = false
    if m.removeButton <> invalid then m.removeButton.visible = false
    m.focusIndex = 0
    updateFocus()
    m.top.removeRequested = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if m.keyboardActive = true then return handleKeyboardKey(key)

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
            openKeyboard(m.focusIndex)
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
        else if m.focusIndex = 6 then
            onRemoveSelected()
            return true
        end if
    else if isPrintableKey(key) and m.focusIndex <= 2 then
        openKeyboard(m.focusIndex)
        appendKeyboardText(key)
        return true
    end if

    return false
end function

sub openKeyboard(fieldIndex as Integer)
    m.keyboardActive = true
    m.keyboardFieldIndex = fieldIndex
    m.keyboardFocusIndex = 0
    m.keyboardText = getFieldText(fieldIndex)
    m.keyboardTitle.text = "EDITAR " + m.textFieldTitles[fieldIndex]
    m.keyboardOverlay.visible = true
    if m.keyboardInputText <> invalid then
        m.keyboardInputText.secureMode = (fieldIndex = 2)
        m.keyboardInputText.maxTextLength = m.textFieldMaxLengths[fieldIndex]
        m.keyboardInputText.text = m.keyboardText
        m.keyboardInputText.SetFocus(false)
    end if
    if m.keyboardKeysGroup <> invalid then m.keyboardKeysGroup.SetFocus(true)
    ' PRINT "ACCOUNT_FIELD_EDIT_OPEN"
    updateKeyboardFocus()
end sub

sub closeKeyboard(applyValue as Boolean)
    if m.keyboardInputText <> invalid then m.keyboardText = safeTrim(m.keyboardInputText.text)
    if m.keyboardOverlay <> invalid then m.keyboardOverlay.visible = false
    if m.keyboardActive = true and applyValue = true then
        setFieldText(m.keyboardFieldIndex, m.keyboardText)
        ' PRINT "ACCOUNT_FIELD_EDIT_APPLIED"
    end if
    m.keyboardActive = false
    updateFocus()
end sub

function handleKeyboardKey(key as String) as Boolean
    if key = "back" then
        closeKeyboard(false)
        return true
    else if key = "left" then
        if m.keyboardFocusIndex > 0 then m.keyboardFocusIndex = m.keyboardFocusIndex - 1
        updateKeyboardFocus()
        return true
    else if key = "right" then
        if m.keyboardFocusIndex < m.keyboardKeys.Count() - 1 then m.keyboardFocusIndex = m.keyboardFocusIndex + 1
        updateKeyboardFocus()
        return true
    else if key = "up" then
        nextIndex = m.keyboardFocusIndex - m.keyboardColumns
        if nextIndex >= 0 then m.keyboardFocusIndex = nextIndex
        updateKeyboardFocus()
        return true
    else if key = "down" then
        nextIndex = m.keyboardFocusIndex + m.keyboardColumns
        if nextIndex < m.keyboardKeys.Count() then m.keyboardFocusIndex = nextIndex
        updateKeyboardFocus()
        return true
    else if isOkKey(key) then
        applyKeyboardValue(m.keyboardKeys[m.keyboardFocusIndex].value)
        return true
    else if isBackspaceKey(key) then
        applyKeyboardValue("APAGAR")
        return true
    else if isPrintableKey(key) then
        appendKeyboardText(key)
        return true
    end if
    return true
end function

sub applyKeyboardValue(value as String)
    if value = "OK" then
        closeKeyboard(true)
    else if value = "CANCELAR" then
        closeKeyboard(false)
    else if value = "APAGAR" then
        if m.keyboardInputText <> invalid then m.keyboardText = m.keyboardInputText.text
        if Len(m.keyboardText) > 0 then m.keyboardText = Left(m.keyboardText, Len(m.keyboardText) - 1)
        if m.keyboardInputText <> invalid then m.keyboardInputText.text = m.keyboardText
    else if value = "LIMPAR" then
        m.keyboardText = ""
        if m.keyboardInputText <> invalid then m.keyboardInputText.text = ""
    else if value = "ESPAÇO" then
        appendKeyboardText(" ")
    else
        appendKeyboardText(value)
    end if
end sub

sub appendKeyboardText(value as String)
    if m.keyboardInputText <> invalid then m.keyboardText = m.keyboardInputText.text
    maxLen = m.textFieldMaxLengths[m.keyboardFieldIndex]
    if Len(m.keyboardText) + Len(value) > maxLen then return
    m.keyboardText = m.keyboardText + value
    if m.keyboardInputText <> invalid then
        m.keyboardInputText.text = m.keyboardText
        m.keyboardInputText.SetFocus(false)
    end if
    if m.keyboardKeysGroup <> invalid then m.keyboardKeysGroup.SetFocus(true)
end sub

sub onKeyboardTextChanged()
    if m.keyboardActive <> true then return
    if m.keyboardInputText = invalid then return
    m.keyboardText = m.keyboardInputText.text
    ' PRINT "ACCOUNT_REMOTE_TEXT_APPLIED"
end sub

sub updateKeyboardDisplay()
    if m.keyboardInputText <> invalid then
        m.keyboardInputText.text = m.keyboardText
        m.keyboardInputText.SetFocus(false)
    end if
    if m.keyboardKeysGroup <> invalid then m.keyboardKeysGroup.SetFocus(true)
end sub

sub updateKeyboardFocus()
    for i = 0 to m.keyboardKeys.Count() - 1
        if i = m.keyboardFocusIndex then
            m.keyboardKeys[i].rect.color = "#2FA7FF"
            m.keyboardKeys[i].label.color = "#000000"
        else
            m.keyboardKeys[i].rect.color = "#173B76"
            m.keyboardKeys[i].label.color = "#FFFFFF"
        end if
    end for
end sub

sub moveFocus(direction as Integer)
    nextIndex = m.focusIndex + direction
    for i = 0 to m.focusableControls.Count() - 1
        if nextIndex < 0 then nextIndex = m.focusableControls.Count() - 1
        if nextIndex >= m.focusableControls.Count() then nextIndex = 0
        if nextIndex < m.focusableControls.Count() then exit for
        nextIndex = nextIndex + direction
    end for
    m.focusIndex = nextIndex
    updateFocus()
end sub

sub updateFocus()
    if m.keyboardActive = true then return
    for each ring in m.focusRings
        ring.visible = false
    end for
    if m.focusIndex >= m.focusableControls.Count() then m.focusIndex = 0
    if m.focusIndex <= 2 then m.focusRings[m.focusIndex].visible = true
    m.focusableControls[m.focusIndex].SetFocus(true)
end sub

function getFieldText(fieldIndex as Integer) as String
    if fieldIndex = 0 then return safeTrim(m.dnsInput.text)
    if fieldIndex = 1 then return safeTrim(m.userInput.text)
    if fieldIndex = 2 then return safeTrim(m.passwordInput.text)
    return ""
end function

sub setFieldText(fieldIndex as Integer, value as String)
    if fieldIndex = 0 then
        m.dnsInput.text = resolveDnsShortcut(value)
    else if fieldIndex = 1 then
        m.userInput.text = value
    else if fieldIndex = 2 then
        m.passwordInput.text = value
    end if
end sub

function isOkKey(key as String) as Boolean
    k = LCase(key)
    return k = "ok" or k = "enter" or k = "return" or k = "select" or k = "numpadenter"
end function

function isBackspaceKey(key as String) as Boolean
    k = LCase(key)
    return k = "backspace" or k = "delete" or k = "del"
end function

function isPrintableKey(key as String) as Boolean
    if key = invalid then return false
    if Len(key) <> 1 then return false
    code = Asc(key)
    return code >= 32 and code <= 126
end function

function resolveDnsShortcut(value as Dynamic) as String
    text = safeTrim(value)
    if text = "1010" then return "http://ttvp2.live"
    return text
end function

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()
    return { width: displaySize.w, height: displaySize.h }
end function

function safeTrim(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr().Trim()
end function

function getAAValue(aa as Dynamic, key as String) as Dynamic
    if aa = invalid or Type(aa) <> "roAssociativeArray" then return invalid
    return aa[key]
end function
