' Home screen for PXT Player.
sub Init()
    m.background = m.top.FindNode("homeBackground")
    m.overlay = m.top.FindNode("homeOverlay")
    m.liveTvButton = m.top.FindNode("liveTvButton")
    m.moviesButton = m.top.FindNode("moviesButton")
    m.seriesButton = m.top.FindNode("seriesButton")
    m.accountIconLabel = m.top.FindNode("accountIconLabel")
    m.accountFooterLabel = m.top.FindNode("accountFooterLabel")
    m.connectionStatusLabel = m.top.FindNode("connectionStatusLabel")

    m.buttons = [m.liveTvButton, m.moviesButton, m.seriesButton]
    m.focusIndex = 0
    m.focusArea = "cards"
    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.background.width = width
    m.background.height = height
    m.overlay.width = width
    m.overlay.height = height

    buttonWidth = 294
    buttonGap = 34
    columns = 3
    totalFirstRowWidth = (buttonWidth * columns) + (buttonGap * (columns - 1))
    startX = Int((width - totalFirstRowWidth) / 2)
    firstRowY = Int(height * 0.28)

    for i = 0 to m.buttons.Count() - 1
        m.buttons[i].translation = [startX + (i * (buttonWidth + buttonGap)), firstRowY]
    end for

    footerY = Int(height * 0.82)
    m.accountIconLabel.width = 220
    m.accountIconLabel.font = "font:LargeBoldSystemFont"
    m.accountIconLabel.translation = [Int((width - m.accountIconLabel.width) / 2), footerY - 42]

    m.accountFooterLabel.width = 220
    m.accountFooterLabel.font = "font:SmallBoldSystemFont"
    m.accountFooterLabel.translation = [Int((width - m.accountFooterLabel.width) / 2), footerY]

    m.connectionStatusLabel.width = width
    m.connectionStatusLabel.font = "font:SmallSystemFont"
    m.connectionStatusLabel.translation = [0, Int(height * 0.94)]
end sub

sub show()
    m.top.visible = true
    m.focusIndex = 0
    m.focusArea = "cards"
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

sub onLiveTvSelected()
    m.top.openLiveCategories = true
end sub

sub onMoviesSelected()
    m.top.openMovieCategories = true
end sub

sub onSeriesSelected()
    m.top.openSeriesCategories = true
end sub

sub onPlaylistSelected()
    m.top.openPlaylist = true
end sub

sub setLiveCategoriesLoading(isLoading as Boolean)
    if isLoading then
        m.connectionStatusLabel.color = "#B8C3D6"
        m.connectionStatusLabel.text = "Carregando categorias de TV ao vivo..."
    end if
end sub

sub setMovieCategoriesLoading(isLoading as Boolean)
    if isLoading then
        m.connectionStatusLabel.color = "#B8C3D6"
        m.connectionStatusLabel.text = "Carregando categorias de filmes..."
    end if
end sub

sub setSeriesCategoriesLoading(isLoading as Boolean)
    if isLoading then
        m.connectionStatusLabel.color = "#B8C3D6"
        m.connectionStatusLabel.text = "Carregando categorias de séries..."
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "left" then
        if m.focusArea = "cards" then moveFocus(-1)
        return true
    else if key = "right" then
        if m.focusArea = "cards" then moveFocus(1)
        return true
    else if key = "down" then
        m.focusArea = "account"
        updateFocus()
        return true
    else if key = "up" then
        m.focusArea = "cards"
        updateFocus()
        return true
    else if key = "OK" then
        selectFocusedButton()
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
    for i = 0 to m.buttons.Count() - 1
        isCardFocused = (m.focusArea = "cards" and i = m.focusIndex)
        m.buttons[i].focused = isCardFocused
        m.buttons[i].selected = isCardFocused
        m.buttons[i].SetFocus(isCardFocused)
    end for

    if m.focusArea = "account" then
        m.accountIconLabel.color = "#FFFFFF"
        m.accountIconLabel.opacity = 1.0
        m.accountFooterLabel.color = "#FFFFFF"
        m.accountFooterLabel.opacity = 1.0
        m.accountFooterLabel.SetFocus(true)
    else
        m.accountIconLabel.color = "#D8E2F3"
        m.accountIconLabel.opacity = 0.78
        m.accountFooterLabel.color = "#D8E2F3"
        m.accountFooterLabel.opacity = 0.78
        m.accountFooterLabel.SetFocus(false)
    end if
end sub

sub selectFocusedButton()
    if m.focusArea = "account" then
        onPlaylistSelected()
        return
    end if

    if m.focusIndex = 0 then
        onLiveTvSelected()
    else if m.focusIndex = 1 then
        onMoviesSelected()
    else if m.focusIndex = 2 then
        onSeriesSelected()
    end if
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
