' Login screen. It captures account data and delegates Xtream authentication
' to the MainScene/XtreamService integration.
sub Init()
    m.background = m.top.FindNode("loginBackground")
    m.formGroup = m.top.FindNode("formGroup")

    m.dnsInput = m.top.FindNode("dnsInput")
    m.userInput = m.top.FindNode("userInput")
    m.passwordInput = m.top.FindNode("passwordInput")
    m.enterButton = m.top.FindNode("enterButton")
    m.backButton = m.top.FindNode("backButton")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.messageLabel = m.top.FindNode("messageLabel")
    m.customKeyboardOverlay = m.top.FindNode("customKeyboardOverlay")
    m.customKeyboardScrim = m.top.FindNode("customKeyboardScrim")
    m.customKeyboardPanel = m.top.FindNode("customKeyboardPanel")
    m.customKeyboardTitle = m.top.FindNode("customKeyboardTitle")
    m.customKeyboardText = m.top.FindNode("customKeyboardText")
    m.customKeyboardKeys = m.top.FindNode("customKeyboardKeys")

    m.focusRings = [
        m.top.FindNode("dnsFocus"),
        m.top.FindNode("userFocus"),
        m.top.FindNode("passwordFocus")
    ]
    m.focusableControls = [m.dnsInput, m.userInput, m.passwordInput, m.enterButton, m.backButton]
    m.textFieldMaxLengths = [200, 100, 100]
    m.textFieldTitles = ["DNS", "USUÁRIO", "SENHA"]
    m.textFieldNames = ["dns", "username", "password"]
    m.fieldValues = ["", "", ""]
    m.activeTextFieldIndex = invalid
    m.keyboardDraft = ""
    m.isCustomKeyboardOpen = false
    m.customKeyboardRows = [
        ["A","B","C","D","E","F","G","H","I","J"],
        ["K","L","M","N","O","P","Q","R","S","T"],
        ["U","V","W","X","Y","Z","0","1","2","3"],
        ["4","5","6","7","8","9",".","/",":"],
        ["-","_","APAGAR","ESPAÇO","OK","CANCELAR"]
    ]
    m.customKeyNodes = []
    m.selectedKeyRow = 0
    m.selectedKeyCol = 0
    m.customKeyW = 76
    m.customKeyH = 54
    m.customKeyGap = 8
    m.focusIndex = 0
    m.isLoading = false

    m.enterButton.ObserveField("buttonSelected", "onEnterSelected")
    m.backButton.ObserveField("buttonSelected", "onBackSelected")

    configureLayout()
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
    m.customKeyboardScrim.width = width
    m.customKeyboardScrim.height = height
    m.customKeyboardPanel.translation = [Int((width - 900) / 2), Int((height - 500) / 2)]

    m.formGroup.translation = [Int((width - 600) / 2), Int((height - 620) / 2)]
    m.messageLabel.width = 600
    m.loadingLabel.width = 500
end sub

sub show(account as Object)
    m.top.visible = true
    m.fieldValues = ["", "", ""]
    if account <> invalid then
        if account.dns <> invalid then m.fieldValues[0] = account.dns
        if account.username <> invalid then m.fieldValues[1] = account.username
        if account.password <> invalid then m.fieldValues[2] = account.password
    end if
    updateFieldDisplays()
    setLoading(false)
    clearMessage()
    m.focusIndex = 0
    updateFocus()
end sub

sub hide()
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
    m.enterButton.enabled = not isLoading
    m.backButton.enabled = not isLoading
end sub

sub showError(message as String)
    setLoading(false)
    m.messageLabel.color = "#FF6B6B"
    m.messageLabel.text = message
    m.messageLabel.visible = true
    updateFocus()
end sub

sub clearMessage()
    m.messageLabel.text = ""
    m.messageLabel.visible = false
end sub

sub onEnterSelected()
    if m.isLoading then return
    print "LOGIN_SUBMIT"
    clearMessage()
    m.top.submit = {
        dns: m.fieldValues[0],
        username: m.fieldValues[1],
        password: m.fieldValues[2]
    }
end sub

sub onBackSelected()
    if m.isLoading then return
    m.top.backRequested = true
end sub


function isOkKey(key as String) as Boolean
    k = LCase(key)
    return k = "ok" or k = "enter" or k = "return" or k = "select"
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    normalizedKey = normalizeKey(key)
    if m.isCustomKeyboardOpen then
        return handleCustomKeyboardKey(normalizedKey, key)
    end if
    if m.isLoading then return true

    if normalizedKey = "up" then
        moveFocus(-1)
        return true
    else if normalizedKey = "down" then
        moveFocus(1)
        return true
    else if normalizedKey = "left" then
        if m.focusIndex = 4 then
            m.focusIndex = 3
            updateFocus()
            return true
        end if
    else if normalizedKey = "right" then
        if m.focusIndex = 3 then
            m.focusIndex = 4
            updateFocus()
            return true
        end if
    else if normalizedKey = "back" then
        onBackSelected()
        return true
    else if isOkKey(key) then
        if m.focusIndex <= 2 then
            openTextKeyboard(m.focusIndex)
            return true
        end if
    end if

    return false
end function

sub openTextKeyboard(fieldIndex as Integer)
    m.activeTextFieldIndex = fieldIndex
    m.keyboardDraft = m.fieldValues[fieldIndex]
    m.isCustomKeyboardOpen = true
    m.selectedKeyRow = 0
    m.selectedKeyCol = 0
    m.customKeyboardTitle.text = "Editar " + m.textFieldTitles[fieldIndex]
    m.customKeyboardOverlay.visible = true
    print "CUSTOM_KEYBOARD_OPEN field=" + m.textFieldNames[fieldIndex]
    renderCustomKeyboard()
    updateKeyboardText()
    updateCustomKeyboardFocus()
    m.top.SetFocus(true)
end sub

sub closeCustomKeyboard(saveValue as Boolean)
    if m.activeTextFieldIndex = invalid then return
    if saveValue then
        m.fieldValues[m.activeTextFieldIndex] = m.keyboardDraft
        updateFieldDisplays()
        print "CUSTOM_KEYBOARD_SAVE"
    end if
    m.customKeyboardOverlay.visible = false
    m.isCustomKeyboardOpen = false
    m.activeTextFieldIndex = invalid
    m.keyboardDraft = ""
    updateFocus()
end sub

sub renderCustomKeyboard()
    while m.customKeyboardKeys.GetChildCount() > 0 : m.customKeyboardKeys.RemoveChildIndex(0) : end while
    m.customKeyNodes = []
    for r = 0 to m.customKeyboardRows.Count() - 1
        rowNodes = []
        rowX = getCustomRowX(r)
        for c = 0 to m.customKeyboardRows[r].Count() - 1
            keyLabel = m.customKeyboardRows[r][c]
            keyWidth = getCustomKeyWidth(keyLabel)
            g = CreateObject("roSGNode", "Group") : g.translation = [rowX + getCustomKeyX(r, c), r * (m.customKeyH + m.customKeyGap)]
            bg = CreateObject("roSGNode", "Rectangle") : bg.id = "keyBackground" : bg.width = keyWidth : bg.height = m.customKeyH : bg.color = "#101A2C" : bg.opacity = 0.96
            lb = CreateObject("roSGNode", "Label") : lb.id = "keyLabel" : lb.width = keyWidth : lb.height = m.customKeyH : lb.horizAlign = "center" : lb.vertAlign = "center" : lb.color = "#EAF2FF" : lb.font = "font:SmallBoldSystemFont" : lb.text = keyLabel
            g.AppendChild(bg) : g.AppendChild(lb) : m.customKeyboardKeys.AppendChild(g) : rowNodes.Push(g)
        end for
        m.customKeyNodes.Push(rowNodes)
    end for
end sub

function getCustomKeyWidth(keyLabel as String) as Integer
    if keyLabel = "APAGAR" or keyLabel = "ESPAÇO" or keyLabel = "CANCELAR" then return 128
    if keyLabel = "OK" then return 92
    return m.customKeyW
end function

function getCustomKeyX(rowIndex as Integer, colIndex as Integer) as Integer
    keyX = 0
    for i = 0 to colIndex - 1
        keyX = keyX + getCustomKeyWidth(m.customKeyboardRows[rowIndex][i]) + m.customKeyGap
    end for
    return keyX
end function

function getCustomRowX(rowIndex as Integer) as Integer
    rowWidth = getCustomKeyX(rowIndex, m.customKeyboardRows[rowIndex].Count())
    return Int((844 - rowWidth) / 2)
end function

function handleCustomKeyboardKey(normalizedKey as String, rawKey as String) as Boolean
    if normalizedKey = "back" then closeCustomKeyboard(false) : return true
    if normalizedKey = "up" then moveCustomKeyboardFocus(-1, 0) : return true
    if normalizedKey = "down" then moveCustomKeyboardFocus(1, 0) : return true
    if normalizedKey = "left" then moveCustomKeyboardFocus(0, -1) : return true
    if normalizedKey = "right" then moveCustomKeyboardFocus(0, 1) : return true
    if normalizedKey = "OK" then activateCustomKeyboardKey() : return true
    if Left(rawKey, 4) = "lit_" then appendKeyboardText(Mid(rawKey, 5)) : return true
    return true
end function

sub moveCustomKeyboardFocus(rowDelta as Integer, colDelta as Integer)
    if colDelta <> 0 then
        rowCount = m.customKeyboardRows[m.selectedKeyRow].Count()
        m.selectedKeyCol = m.selectedKeyCol + colDelta
        if m.selectedKeyCol < 0 then m.selectedKeyCol = rowCount - 1
        if m.selectedKeyCol >= rowCount then m.selectedKeyCol = 0
    else
        m.selectedKeyRow = m.selectedKeyRow + rowDelta
        if m.selectedKeyRow < 0 then m.selectedKeyRow = m.customKeyboardRows.Count() - 1
        if m.selectedKeyRow >= m.customKeyboardRows.Count() then m.selectedKeyRow = 0
        if m.selectedKeyCol >= m.customKeyboardRows[m.selectedKeyRow].Count() then m.selectedKeyCol = m.customKeyboardRows[m.selectedKeyRow].Count() - 1
    end if
    updateCustomKeyboardFocus()
end sub

sub activateCustomKeyboardKey()
    keyLabel = m.customKeyboardRows[m.selectedKeyRow][m.selectedKeyCol]
    if keyLabel = "APAGAR" then
        if Len(m.keyboardDraft) > 0 then m.keyboardDraft = Left(m.keyboardDraft, Len(m.keyboardDraft) - 1)
    else if keyLabel = "ESPAÇO" then
        appendKeyboardText(" ")
    else if keyLabel = "OK" then
        closeCustomKeyboard(true)
        return
    else if keyLabel = "CANCELAR" then
        closeCustomKeyboard(false)
        return
    else
        appendKeyboardText(keyLabel)
    end if
    updateKeyboardText()
end sub

sub appendKeyboardText(value as String)
    if Len(m.keyboardDraft) < m.textFieldMaxLengths[m.activeTextFieldIndex] then
        m.keyboardDraft = m.keyboardDraft + value
        updateKeyboardText()
    end if
end sub

sub updateKeyboardText()
    if m.activeTextFieldIndex = 2 then
        m.customKeyboardText.text = maskText(m.keyboardDraft)
    else
        m.customKeyboardText.text = m.keyboardDraft
    end if
end sub

sub updateFieldDisplays()
    m.dnsInput.text = m.fieldValues[0]
    m.userInput.text = m.fieldValues[1]
    m.passwordInput.text = maskText(m.fieldValues[2])
end sub

function maskText(value as String) as String
    masked = ""
    if Len(value) = 0 then return masked
    for i = 1 to Len(value)
        masked = masked + "*"
    end for
    return masked
end function

sub updateCustomKeyboardFocus()
    for r = 0 to m.customKeyNodes.Count() - 1
        for c = 0 to m.customKeyNodes[r].Count() - 1
            bg = m.customKeyNodes[r][c].FindNode("keyBackground") : lb = m.customKeyNodes[r][c].FindNode("keyLabel")
            if r = m.selectedKeyRow and c = m.selectedKeyCol then
                bg.color = "#FFCC00" : bg.opacity = 1.0 : lb.color = "#06111F" : m.customKeyNodes[r][c].scale = [1.06, 1.06]
            else
                bg.color = "#101A2C" : bg.opacity = 0.96 : lb.color = "#EAF2FF" : m.customKeyNodes[r][c].scale = [1.0, 1.0]
            end if
        end for
    end for
end sub

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
