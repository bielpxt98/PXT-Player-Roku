' Home screen for PXT Player.
sub Init()
    m.background = m.top.FindNode("homeBackground")
    m.overlay = m.top.FindNode("homeOverlay")
    m.title = m.top.FindNode("homeTitle")
    m.liveTvButton = m.top.FindNode("liveTvButton")
    m.moviesButton = m.top.FindNode("moviesButton")
    m.seriesButton = m.top.FindNode("seriesButton")
    m.favoritesButton = m.top.FindNode("favoritesButton")
    m.recentButton = m.top.FindNode("recentButton")
    m.accountIconLabel = m.top.FindNode("accountIconLabel")
    m.accountFooterLabel = m.top.FindNode("accountFooterLabel")
    m.connectionStatusLabel = m.top.FindNode("connectionStatusLabel")

    m.buttons = [m.liveTvButton, m.moviesButton, m.seriesButton, m.favoritesButton, m.recentButton]
    m.focusIndex = 0
    m.lastCardFocusIndex = 0
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

    m.title.width = width
    m.title.height = 110
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, Int(height * 0.105)]

    buttonCount = m.buttons.Count()
    horizontalMargin = Int(width * 0.055)
    buttonGap = 22
    buttonWidth = Int((width - (horizontalMargin * 2) - (buttonGap * (buttonCount - 1))) / buttonCount)
    if buttonWidth > 212 then buttonWidth = 212
    if buttonWidth < 158 then
        buttonGap = 12
        horizontalMargin = 24
        buttonWidth = Int((width - (horizontalMargin * 2) - (buttonGap * (buttonCount - 1))) / buttonCount)
    end if

    buttonHeight = 178
    buttonY = Int(height * 0.405)
    totalWidth = (buttonWidth * buttonCount) + (buttonGap * (buttonCount - 1))
    startX = Int((width - totalWidth) / 2)

    for i = 0 to buttonCount - 1
        configureHomeCard(m.buttons[i], buttonWidth, buttonHeight, i = 4)
        m.buttons[i].translation = [startX + (i * (buttonWidth + buttonGap)), buttonY]
    end for

    footerY = Int(height * 0.745)
    m.accountIconLabel.width = 260
    m.accountIconLabel.height = 44
    m.accountIconLabel.font = "font:LargeBoldSystemFont"
    m.accountIconLabel.translation = [Int((width - m.accountIconLabel.width) / 2), footerY - 46]

    m.accountFooterLabel.width = 260
    m.accountFooterLabel.height = 36
    m.accountFooterLabel.font = "font:SmallBoldSystemFont"
    m.accountFooterLabel.translation = [Int((width - m.accountFooterLabel.width) / 2), footerY]

    m.connectionStatusLabel.width = width
    m.connectionStatusLabel.font = "font:SmallSystemFont"
    m.connectionStatusLabel.translation = [0, Int(height * 0.94)]
end sub

sub configureHomeCard(button as Object, cardWidth as Integer, cardHeight as Integer, isRecent as Boolean)
    glow = button.FindNode("focusGlow")
    group = button.FindNode("buttonGroup")
    shadow = button.FindNode("buttonShadow")
    background = button.FindNode("buttonBackground")
    accent = button.FindNode("buttonAccent")
    icon = button.FindNode("buttonIcon")
    label = button.FindNode("buttonLabel")

    if glow <> invalid then
        glow.width = cardWidth + 18
        glow.height = cardHeight + 18
        glow.translation = [-9, -9]
    end if
    if group <> invalid then group.scaleRotateCenter = [Int(cardWidth / 2), Int(cardHeight / 2)]
    if shadow <> invalid then
        shadow.width = cardWidth
        shadow.height = cardHeight
        shadow.translation = [7, 9]
        shadow.opacity = 0.5
    end if
    if background <> invalid then
        background.width = cardWidth
        background.height = cardHeight
        background.opacity = 0.88
    end if
    if accent <> invalid then
        accent.width = cardWidth
        accent.height = cardHeight
        accent.opacity = 0.2
    end if
    if icon <> invalid then
        icon.width = cardWidth
        icon.height = 70
        icon.translation = [0, 34]
        icon.font = "font:LargeBoldSystemFont"
    end if
    if label <> invalid then
        label.width = cardWidth - 18
        label.height = 58
        label.translation = [9, 112]
        label.font = "font:SmallBoldSystemFont"
        if isRecent then
            label.text = "ÚLTIMOS" + Chr(10) + "ASSISTIDOS"
        end if
    end if
end sub

sub show()
    m.top.visible = true
    m.focusIndex = 0
    m.lastCardFocusIndex = 0
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

sub onFavoritesSelected()
    m.top.openFavorites = true
end sub

sub onRecentSelected()
    m.top.openRecent = true
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
        if m.focusArea = "cards" then m.lastCardFocusIndex = m.focusIndex
        m.focusArea = "account"
        updateFocus()
        return true
    else if key = "up" then
        m.focusArea = "cards"
        m.focusIndex = m.lastCardFocusIndex
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
    m.lastCardFocusIndex = nextIndex
    updateFocus()
end sub

sub updateFocus()
    for i = 0 to m.buttons.Count() - 1
        isCardFocused = (m.focusArea = "cards" and i = m.focusIndex)
        m.buttons[i].selected = isCardFocused
        m.buttons[i].SetFocus(isCardFocused)
    end for

    if m.focusArea = "account" then
        m.accountIconLabel.text = "◉"
        m.accountIconLabel.color = "#FFFFFF"
        m.accountIconLabel.opacity = 1.0
        m.accountFooterLabel.color = "#FFFFFF"
        m.accountFooterLabel.opacity = 1.0
        m.accountFooterLabel.SetFocus(true)
    else
        m.accountIconLabel.text = "○"
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
    else if m.focusIndex = 3 then
        onFavoritesSelected()
    else if m.focusIndex = 4 then
        onRecentSelected()
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
