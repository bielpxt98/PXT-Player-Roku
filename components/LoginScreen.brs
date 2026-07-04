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
    m.removeButton = m.top.FindNode("removeButton")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.messageLabel = m.top.FindNode("messageLabel")
    ' Use native TextEditBox input so Roku Remote/mobile keyboards can type directly.

    m.focusRings = [
        m.top.FindNode("dnsFocus"),
        m.top.FindNode("userFocus"),
        m.top.FindNode("passwordFocus")
    ]
    m.focusableControls = [m.dnsInput, m.userInput, m.passwordInput, m.enterButton, m.demoButton, m.backButton, m.removeButton]
    m.textFieldMaxLengths = [200, 100, 100]
    m.textFieldTitles = ["DNS", "USUÁRIO", "SENHA"]
    m.textFieldLogNames = ["dns", "username", "password"]
    m.focusIndex = 0
    m.isLoading = false
    m.isEditingField = false
    m.hasSavedAccount = false
    PRINT "ACCOUNT_SCREEN_INIT"

    m.enterButton.ObserveField("buttonSelected", "onEnterSelected")
    m.backButton.ObserveField("buttonSelected", "onBackSelected")
    m.demoButton.ObserveField("buttonSelected", "onDemoSelected")
    m.removeButton.ObserveField("buttonSelected", "onRemoveSelected")
    m.dnsInput.ObserveField("text", "onAccountFieldTextChanged")
    m.userInput.ObserveField("text", "onAccountFieldTextChanged")
    m.passwordInput.ObserveField("text", "onAccountFieldTextChanged")

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
    wasVisible = m.top.visible
    m.top.visible = true
    m.hasSavedAccount = account <> invalid and safeTrim(account.dns) <> "" and safeTrim(account.username) <> "" and safeTrim(account.password) <> ""
    m.removeButton.visible = m.hasSavedAccount
    if account <> invalid then
        m.dnsInput.text = account.dns
        m.userInput.text = account.username
        m.passwordInput.text = account.password
        if m.hasSavedAccount then PRINT "ACCOUNT_RESTORE_SUCCESS"
    end if
    setLoading(false)
    clearMessage()
    if wasVisible <> true then m.focusIndex = 0
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
    PRINT "ACCOUNT_LOGIN_SUBMIT"
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
    PRINT "ACCOUNT_REMOVE_CONFIRMED"
    setLoading(false)
    clearMessage()
    m.dnsInput.text = ""
    m.userInput.text = ""
    m.passwordInput.text = ""
    m.hasSavedAccount = false
    m.removeButton.visible = false
    m.focusIndex = 0
    updateFocus()
    m.top.removeRequested = true
end sub

sub onAccountFieldTextChanged()
    if m.isEditingField = true then PRINT "ACCOUNT_FIELD_EDIT_APPLIED"
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
            m.isEditingField = true
            PRINT "ACCOUNT_FIELD_EDIT_OPEN"
            m.focusableControls[m.focusIndex].SetFocus(true)
            return false
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
    end if

    return false
end function

function isOkKey(key as String) as Boolean
    k = LCase(key)
    return k = "ok" or k = "enter" or k = "return" or k = "select" or k = "numpadenter"
end function

function isConfirmKey(key as String) as Boolean
    return isOkKey(key)
end function

sub moveFocus(direction as Integer)
    m.isEditingField = false
    nextIndex = m.focusIndex + direction
    for i = 0 to m.focusableControls.Count() - 1
        if nextIndex < 0 then nextIndex = m.focusableControls.Count() - 1
        if nextIndex >= m.focusableControls.Count() then nextIndex = 0
        if nextIndex <> 6 or m.removeButton.visible = true then exit for
        nextIndex = nextIndex + direction
    end for
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

    if m.focusIndex = 6 and m.removeButton.visible <> true then m.focusIndex = 0
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
