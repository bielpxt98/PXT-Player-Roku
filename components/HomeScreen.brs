' Home screen for PXT Player.
sub Init()
    m.background = m.top.FindNode("homeBackground")
    m.title = m.top.FindNode("homeTitle")
    m.subtitle = m.top.FindNode("homeSubtitle")
    m.liveTvButton = m.top.FindNode("liveTvButton")
    m.moviesButton = m.top.FindNode("moviesButton")
    m.seriesButton = m.top.FindNode("seriesButton")
    m.favoritesButton = m.top.FindNode("favoritesButton")
    m.searchButton = m.top.FindNode("searchButton")
    m.playlistButton = m.top.FindNode("playlistButton")
    m.connectionStatusLabel = m.top.FindNode("connectionStatusLabel")
    m.continueWatchingLabel = m.top.FindNode("continueWatchingLabel")
    m.lastMoviesLabel = m.top.FindNode("lastMoviesLabel")
    m.lastSeriesLabel = m.top.FindNode("lastSeriesLabel")

    m.buttons = [m.liveTvButton, m.moviesButton, m.seriesButton, m.favoritesButton, m.searchButton, m.playlistButton]
    m.focusIndex = 0

    m.liveTvButton.ObserveField("buttonSelected", "onLiveTvSelected")
    m.moviesButton.ObserveField("buttonSelected", "onMoviesSelected")
    m.seriesButton.ObserveField("buttonSelected", "onSeriesSelected")
    m.favoritesButton.ObserveField("buttonSelected", "onFavoritesSelected")
    m.searchButton.ObserveField("buttonSelected", "onSearchSelected")
    m.playlistButton.ObserveField("buttonSelected", "onPlaylistSelected")
    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, Int(height * 0.22)]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, Int(height * 0.34)]

    m.liveTvButton.translation = [Int((width - 520) / 2), Int(height * 0.46)]
    m.moviesButton.translation = [Int((width - 520) / 2), Int(height * 0.57)]
    m.seriesButton.translation = [Int((width - 520) / 2), Int(height * 0.68)]
    m.favoritesButton.translation = [Int((width - 520) / 2), Int(height * 0.75)]
    m.searchButton.translation = [Int((width - 520) / 2), Int(height * 0.84)]
    m.playlistButton.translation = [Int((width - 520) / 2), Int(height * 0.93)]
    m.continueWatchingLabel.width = width - 144
    m.continueWatchingLabel.font = "font:SmallSystemFont"
    m.continueWatchingLabel.translation = [72, Int(height * 0.08)]
    m.lastMoviesLabel.width = width - 144
    m.lastMoviesLabel.font = "font:SmallSystemFont"
    m.lastMoviesLabel.translation = [72, Int(height * 0.12)]
    m.lastSeriesLabel.width = width - 144
    m.lastSeriesLabel.font = "font:SmallSystemFont"
    m.lastSeriesLabel.translation = [72, Int(height * 0.16)]
    m.connectionStatusLabel.width = width
    m.connectionStatusLabel.font = "font:MediumSystemFont"
    m.connectionStatusLabel.translation = [0, Int(height * 0.98)]
end sub

sub show()
    updateHistorySections()
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

sub onSearchSelected()
    m.top.openSearch = true
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

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
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
        m.buttons[i].SetFocus(i = m.focusIndex)
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

sub setSeriesCategoriesLoading(isLoading as Boolean)
    if isLoading then
        m.connectionStatusLabel.color = "#B8C3D6"
        m.connectionStatusLabel.text = "Carregando categorias de séries..."
    end if
end sub


sub updateHistorySections()
    history = LoadViewingHistory()
    m.continueWatchingLabel.text = "Continuar assistindo: " + summarizeHistory(history.continueWatching)
    m.lastMoviesLabel.text = "Últimos filmes assistidos: " + summarizeHistory(history.movies)
    m.lastSeriesLabel.text = "Últimas séries assistidas: " + summarizeHistory(history.series)
end sub

function summarizeHistory(items as Object) as String
    if items = invalid or items.Count() = 0 then return "nenhum item"
    summary = ""
    limit = items.Count()
    if limit > 3 then limit = 3
    for i = 0 to limit - 1
        title = "Conteúdo"
        if items[i].title <> invalid and items[i].title.ToStr().Trim() <> "" then title = items[i].title.ToStr()
        if summary <> "" then summary = summary + " • "
        summary = summary + title
    end for
    return summary
end function
