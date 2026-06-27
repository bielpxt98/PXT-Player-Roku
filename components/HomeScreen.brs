' Home screen for PXT Player.
sub Init()
    m.background = m.top.FindNode("homeBackground")
    m.overlay = m.top.FindNode("homeOverlay")
    m.title = m.top.FindNode("homeTitle")
    m.subtitle = m.top.FindNode("homeSubtitle")
    m.liveTvButton = m.top.FindNode("liveTvButton")
    m.moviesButton = m.top.FindNode("moviesButton")
    m.seriesButton = m.top.FindNode("seriesButton")
    m.favoritesButton = m.top.FindNode("favoritesButton")
    m.recentButton = m.top.FindNode("recentButton")
    m.settingsFooterLabel = m.top.FindNode("settingsFooterLabel")
    m.accountFooterLabel = m.top.FindNode("accountFooterLabel")
    m.connectionStatusLabel = m.top.FindNode("connectionStatusLabel")

    m.buttons = [m.liveTvButton, m.moviesButton, m.seriesButton, m.favoritesButton, m.recentButton]
    m.focusIndex = 0
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
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, Int(height * 0.18)]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, Int(height * 0.27)]

    buttonWidth = 224
    buttonGap = 30
    totalWidth = (buttonWidth * m.buttons.Count()) + (buttonGap * (m.buttons.Count() - 1))
    startX = Int((width - totalWidth) / 2)
    buttonY = Int(height * 0.44)

    for i = 0 to m.buttons.Count() - 1
        m.buttons[i].translation = [startX + (i * (buttonWidth + buttonGap)), buttonY]
    end for

    footerY = Int(height * 0.86)
    m.settingsFooterLabel.width = 240
    m.settingsFooterLabel.font = "font:SmallSystemFont"
    m.settingsFooterLabel.translation = [Int((width / 2) - 260), footerY]

    m.accountFooterLabel.width = 160
    m.accountFooterLabel.font = "font:SmallSystemFont"
    m.accountFooterLabel.translation = [Int((width / 2) + 60), footerY]

    m.connectionStatusLabel.width = width
    m.connectionStatusLabel.font = "font:SmallSystemFont"
    m.connectionStatusLabel.translation = [0, Int(height * 0.94)]
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
    history = LoadViewingHistory()
    if history <> invalid and history.continueWatching <> invalid and history.continueWatching.Count() > 0 then
        itemType = history.continueWatching[0].type
        if itemType = "episode" then
            m.top.openSeriesCategories = true
        else
            m.top.openMovieCategories = true
        end if
    else
        m.top.openMovieCategories = true
    end if
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
        moveFocus(-1)
        return true
    else if key = "right" then
        moveFocus(1)
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
        m.buttons[i].selected = (i = m.focusIndex)
        m.buttons[i].SetFocus(i = m.focusIndex)
    end for
end sub

sub selectFocusedButton()
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
