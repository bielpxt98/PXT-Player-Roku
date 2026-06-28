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
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.messageLabel = m.top.FindNode("messageLabel")

    m.focusRings = [
        m.top.FindNode("dnsFocus"),
        m.top.FindNode("userFocus"),
        m.top.FindNode("passwordFocus")
    ]
    m.focusableControls = [m.dnsInput, m.userInput, m.passwordInput, m.enterButton, m.backButton]
    m.textFieldMaxLengths = [200, 100, 100]
    m.textFieldTitles = ["DNS", "USUÁRIO", "SENHA"]
    m.activeTextFieldIndex = invalid
    m.keyboardDialog = invalid
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

sub show(account as Object)
    m.top.visible = true
    if account <> invalid then
        m.dnsInput.text = account.dns
        m.userInput.text = account.username
        m.passwordInput.text = account.password
    end if
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
    clearMessage()
    m.top.submit = {
        dns: m.dnsInput.text,
        username: m.userInput.text,
        password: m.passwordInput.text
    }
end sub

sub onBackSelected()
    if m.isLoading then return
    m.top.backRequested = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.isLoading then return true

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
    else if key = "OK" then
        if m.focusIndex <= 2 then
            openTextKeyboard(m.focusIndex)
            return true
        end if
    end if

    return false
end function

sub openTextKeyboard(fieldIndex as Integer)
    m.activeTextFieldIndex = fieldIndex
    input = m.focusableControls[fieldIndex]

    dialog = CreateObject("roSGNode", "StandardKeyboardDialog")
    dialog.title = "Editar " + m.textFieldTitles[fieldIndex]
    dialog.text = input.text
    dialog.buttons = ["OK", "Cancelar"]

    if dialog.keyboard <> invalid and dialog.keyboard.textEditBox <> invalid then
        dialog.keyboard.textEditBox.maxTextLength = m.textFieldMaxLengths[fieldIndex]
        dialog.keyboard.textEditBox.leadingEllipsis = true
        dialog.keyboard.textEditBox.clearOnDownKey = false
        dialog.keyboard.textEditBox.secureMode = (fieldIndex = 2)
    end if

    dialog.ObserveField("buttonSelected", "onKeyboardDialogButtonSelected")
    m.keyboardDialog = dialog
    m.top.getScene().dialog = dialog
end sub

sub onKeyboardDialogButtonSelected()
    if m.keyboardDialog = invalid or m.activeTextFieldIndex = invalid then return

    selectedButton = m.keyboardDialog.buttonSelected
    if selectedButton = 0 then
        ' Use the complete final value from Roku's native text component so pasted
        ' content from the Roku mobile app keeps the exact character order.
        m.focusableControls[m.activeTextFieldIndex].text = m.keyboardDialog.text
    end if

    m.top.getScene().dialog = invalid
    m.keyboardDialog = invalid
    m.activeTextFieldIndex = invalid
    updateFocus()
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
