' Main scene for the PXT Player application.
' It coordinates feature screens and authenticates playlist credentials through
' XtreamService, including live TV categories and channel lists.
sub Init()
    m.globalBackground = m.top.FindNode("globalBackground")
    m.globalBackgroundOverlay = m.top.FindNode("globalBackgroundOverlay")
    m.homeScreen = m.top.FindNode("homeScreen")
    m.splashScreen = m.top.FindNode("splashScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.favoritesScreen = m.top.FindNode("favoritesScreen")
    m.recentScreen = m.top.FindNode("recentScreen")
    m.searchScreen = m.top.FindNode("searchScreen")
    m.movieSearchScreen = m.top.FindNode("movieSearchScreen")
    m.liveCategoriesScreen = m.top.FindNode("liveCategoriesScreen")
    m.liveChannelsScreen = m.top.FindNode("liveChannelsScreen")
    m.livePlayerScreen = m.top.FindNode("livePlayerScreen")
    m.movieCategoriesScreen = m.top.FindNode("movieCategoriesScreen")
    m.movieListScreen = m.top.FindNode("movieListScreen")
    m.movieDetailScreen = m.top.FindNode("movieDetailScreen")
    m.moviePlayerScreen = m.top.FindNode("moviePlayerScreen")
    m.seriesHomeScreen = m.top.FindNode("seriesHomeScreen")
    m.seriesDetailScreen = m.top.FindNode("seriesDetailScreen")
    m.seriesPlayerScreen = m.top.FindNode("seriesPlayerScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.loginTimeoutTimer = m.top.FindNode("loginTimeoutTimer")
    m.detailTimeoutTimer = m.top.FindNode("detailTimeoutTimer")
    m.autoConnectTimer = m.top.FindNode("autoConnectTimer")
    m.searchIndexTimer = m.top.FindNode("searchIndexTimer")
    m.seriesOpenTimeoutTimer = m.top.FindNode("seriesOpenTimeoutTimer")
    m.splashMinimumTimer = m.top.FindNode("splashMinimumTimer")
    m.splashMaximumTimer = m.top.FindNode("splashMaximumTimer")
    m.pendingDetailRequest = ""
    m.pendingRequest = ""
    m.isLoadingRequest = false
    m.account = LoadSavedPlaylist()
    m.pendingAccount = invalid
    m.loginFormAccount = invalid
    m.loginConnecting = false
    m.isConnecting = false
    m.connectionMode = ""
    m.loginErrorActive = false
    m.liveCategories = []
    m.liveCategoriesLoading = false
    m.liveChannels = []
    m.liveChannelsLoading = false
    m.selectedLiveCategory = invalid
    m.selectedLiveCategoryId = ""
    m.selectedLiveChannel = invalid
    m.movieCategories = []
    m.movieCategoriesLoading = false
    m.movies = []
    m.moviesLoading = false
    m.selectedMovieCategory = invalid
    m.selectedMovieCategoryId = ""
    m.selectedMovie = invalid
    m.seriesCategories = []
    m.seriesCategoriesLoading = false
    m.series = []
    m.seriesLoading = false
    m.selectedSeriesCategory = invalid
    m.selectedSeriesCategoryId = ""
    m.selectedSeries = invalid
    m.selectedSeason = invalid
    m.selectedEpisode = invalid
    m.openedFromFavorites = false
    m.openedFromSearch = false
    m.openedFromRecent = false
    m.searchChannels = []
    m.searchMovies = []
    m.searchSeries = []
    m.searchLoadStep = ""
    m.searchIndexCache = LoadSearchIndexCache()
    m.movieSearchIndex = m.searchIndexCache.movieSearchIndex
    m.seriesSearchIndex = m.searchIndexCache.seriesSearchIndex
    m.cachedMovies = m.searchIndexCache.movies
    m.cachedSeries = m.searchIndexCache.series
    m.cachedLiveChannels = m.searchIndexCache.liveChannels
    m.cachedSeriesInfo = m.searchIndexCache.seriesInfo
    m.searchIndexQueue = []
    m.searchIndexKind = ""
    m.searchIndexCategoryId = ""
    m.searchIndexUpdating = false
    m.searchMode = "all"
    m.searchBackTarget = "home"
    m.splashMinimumElapsed = false
    m.splashMaximumElapsed = false
    m.bootstrapActive = false
    m.bootstrapQueue = []
    m.localFavoritesCache = []
    m.localHistoryCache = []
    m.movieListRestoreState = invalid
    m.currentMovieList = []
    m.movieListSelectedIndex = 0
    m.movieListFirstVisibleIndex = 0
    m.entryPoint = ""
    m.isReturningFromPlayer = false
    m.isOpeningSeries = false
    if m.cachedMovies = invalid then m.cachedMovies = []
    if m.cachedSeries = invalid then m.cachedSeries = []
    if m.cachedLiveChannels = invalid then m.cachedLiveChannels = []
    if m.cachedSeriesInfo = invalid then m.cachedSeriesInfo = {}

    configureScene()

    m.homeScreen.ObserveField("openPlaylist", "onOpenPlaylistRequested")
    m.homeScreen.ObserveField("openLiveCategories", "onOpenLiveCategoriesRequested")
    m.homeScreen.ObserveField("openMovieCategories", "onOpenMovieCategoriesRequested")
    m.homeScreen.ObserveField("openSeriesCategories", "onOpenSeriesRequested")
    m.homeScreen.ObserveField("openFavorites", "onOpenFavoritesRequested")
    m.homeScreen.ObserveField("openRecent", "onOpenRecentRequested")
    m.searchScreen.ObserveField("backRequested", "onSearchBack")
    m.searchScreen.ObserveField("channelSelected", "onSearchChannelSelected")
    m.searchScreen.ObserveField("seriesSelected", "onSearchSeriesSelected")
    m.movieSearchScreen.ObserveField("backRequested", "onMovieSearchBack")
    m.movieSearchScreen.ObserveField("movieSelected", "onMovieSearchMovieSelected")
    m.recentScreen.ObserveField("backRequested", "onRecentBack")
    m.recentScreen.ObserveField("historySelected", "onHistorySelected")
    m.favoritesScreen.ObserveField("backRequested", "onFavoritesBack")
    m.favoritesScreen.ObserveField("favoriteSelected", "onFavoriteSelected")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")
    m.liveCategoriesScreen.ObserveField("backRequested", "onLiveCategoriesBack")
    m.liveCategoriesScreen.ObserveField("categorySelected", "onLiveCategorySelected")
    m.liveCategoriesScreen.ObserveField("searchRequested", "onLiveSearchRequested")
    m.liveChannelsScreen.ObserveField("searchRequested", "onLiveSearchRequested")
    m.liveChannelsScreen.ObserveField("backRequested", "onLiveChannelsBack")
    m.liveChannelsScreen.ObserveField("channelSelected", "onLiveChannelSelected")
    m.liveChannelsScreen.ObserveField("categorySelected", "onLiveChannelsCategorySelected")
    m.liveChannelsScreen.ObserveField("channelFavoriteToggled", "onLiveChannelFavoriteToggled")
    m.livePlayerScreen.ObserveField("backRequested", "onLivePlayerBack")
    m.movieCategoriesScreen.ObserveField("backRequested", "onMovieCategoriesBack")
    m.movieCategoriesScreen.ObserveField("categorySelected", "onMovieCategorySelected")
    m.movieCategoriesScreen.ObserveField("searchRequested", "onMovieSearchRequested")
    m.movieListScreen.ObserveField("backRequested", "onMovieListBack")
    m.movieListScreen.ObserveField("categorySelected", "onMovieListCategorySelected")
    m.movieListScreen.ObserveField("searchRequested", "onMovieSearchRequested")
    m.movieListScreen.ObserveField("movieSelected", "onMovieSelected")
    m.movieListScreen.ObserveField("movieFavoriteToggled", "onMovieFavoriteToggled")
    m.movieDetailScreen.ObserveField("backRequested", "onMovieDetailBack")
    m.movieDetailScreen.ObserveField("playRequested", "onMovieDetailPlay")
    m.movieDetailScreen.ObserveField("favoriteToggled", "onMovieDetailFavoriteToggled")
    m.moviePlayerScreen.ObserveField("backRequested", "onMoviePlayerBack")
    m.seriesHomeScreen.ObserveField("backRequested", "onSeriesHomeBack")
    m.seriesHomeScreen.ObserveField("categorySelected", "onSeriesHomeCategorySelected")
    m.seriesHomeScreen.ObserveField("searchRequested", "onSeriesSearchRequested")
    m.seriesHomeScreen.ObserveField("seriesSelected", "onSeriesSelected")
    m.seriesDetailScreen.ObserveField("backRequested", "onSeriesDetailBack")
    m.seriesDetailScreen.ObserveField("episodeSelected", "onSeriesEpisodeSelected")
    m.seriesPlayerScreen.ObserveField("backRequested", "onSeriesPlayerBack")
    m.xtreamService.ObserveField("result", "onXtreamConnectionResult")
    m.loginTimeoutTimer.ObserveField("fire", "onLoginTimeout")
    m.detailTimeoutTimer.ObserveField("fire", "onDetailTimeout")
    m.autoConnectTimer.ObserveField("fire", "onAutoConnectTimerFire")
    m.searchIndexTimer.ObserveField("fire", "onSearchIndexTimerFire")
    m.seriesOpenTimeoutTimer.ObserveField("fire", "onSeriesOpenTimeout")
    m.splashMinimumTimer.ObserveField("fire", "onSplashMinimumElapsed")
    m.splashMaximumTimer.ObserveField("fire", "onSplashMaximumElapsed")

    startInitialFlow()
end sub

sub startInitialFlow()
    m.localFavoritesCache = LoadFavorites()
    m.localHistoryCache = LoadViewingHistory()

    if hasAccount(m.account) then
        showHome()
        updateConnectionStatus(false, "Conectando...")
        startAutoConnectTimer()
    else
        if m.account <> invalid then DeleteSavedPlaylist()
        m.account = invalid
        updateConnectionStatus(false, "Nenhuma playlist conectada")
        showLogin()
    end if
end sub

sub startAutoConnectTimer()
    if m.autoConnectTimer = invalid then
        onAutoConnectTimerFire()
        return
    end if

    m.autoConnectTimer.control = "stop"
    m.autoConnectTimer.duration = 0.3
    m.autoConnectTimer.control = "start"
end sub

sub onAutoConnectTimerFire()
    if m.isConnecting = true then return

    if not hasAccount(m.account) then
        m.account = invalid
        DeleteSavedPlaylist()
        updateConnectionStatus(false, "Nenhuma playlist conectada")
        showLogin()
        return
    end if

    m.pendingAccount = m.account
    m.connectionMode = "auto"
    updateConnectionStatus(false, "Conectando...")
    startLoginTimeout()
    connectXtream(m.account)
end sub

sub startSplashBootstrap()
    m.splashMinimumElapsed = false
    m.splashMaximumElapsed = false
    m.bootstrapActive = true
    m.bootstrapQueue = []
    m.localFavoritesCache = LoadFavorites()
    m.localHistoryCache = LoadViewingHistory()

    m.homeScreen.callFunc("hide")
    m.splashScreen.callFunc("show")
    m.splashMinimumTimer.control = "stop"
    m.splashMaximumTimer.control = "stop"
    m.splashMinimumTimer.duration = 4
    m.splashMaximumTimer.duration = 6
    m.splashMinimumTimer.control = "start"
    m.splashMaximumTimer.control = "start"

    if hasAccount(m.account) then
        m.bootstrapQueue = ["getLiveCategories", "getMovieCategories"]
        processNextBootstrapRequest()
    else
        m.bootstrapActive = false
    end if
end sub

sub processNextBootstrapRequest()
    if m.bootstrapQueue = invalid or m.bootstrapQueue.Count() = 0 then
        m.bootstrapActive = false
        finishSplashIfReady()
        return
    end if

    nextAction = m.bootstrapQueue.Shift()
    m.xtreamService.control = "STOP"
    m.xtreamService.action = nextAction
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = ""
    m.xtreamService.streamId = ""
    m.xtreamService.seriesId = ""
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub onSplashMinimumElapsed()
    m.splashMinimumElapsed = true
    finishSplashIfReady()
end sub

sub onSplashMaximumElapsed()
    m.splashMaximumElapsed = true
    m.bootstrapActive = false
    finishSplashIfReady()
end sub

sub finishSplashIfReady()
    if m.splashScreen = invalid or m.splashScreen.visible <> true then return
    if m.splashMaximumElapsed <> true and (m.splashMinimumElapsed <> true or m.bootstrapActive = true) then return

    m.splashMinimumTimer.control = "stop"
    m.splashMaximumTimer.control = "stop"
    m.splashScreen.callFunc("hide")
    showHome()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if m.splashScreen <> invalid and m.splashScreen.visible = true then return true
    if not press then return false

    if key = "back" then
        return handleBackKeySafely()
    end if

    return false
end function

function handleBackKeySafely() as Boolean
    if m.loginErrorActive = true then
        m.loginErrorActive = false
        m.loginConnecting = false
        showLogin()
        return true
    else if m.loginConnecting = true then
        m.loginConnecting = false
        m.isConnecting = false
        stopLoginTimeout()
        cancelXtreamRequest()
        updateConnectionStatus(false, "Conexão cancelada")
        showLogin()
        return true
    end if

    if closeActivePlayerScreen() then return true

    if m.movieDetailScreen <> invalid and m.movieDetailScreen.visible = true then
        onMovieDetailBack()
        return true
    else if m.seriesDetailScreen <> invalid and m.seriesDetailScreen.visible = true then
        onSeriesDetailBack()
        return true
    end if

    focusActiveScreen()
    return false
end function

function closeActivePlayerScreen() as Boolean
    if m.moviePlayerScreen <> invalid and m.moviePlayerScreen.visible = true then
        onMoviePlayerBack()
        return true
    else if m.seriesPlayerScreen <> invalid and m.seriesPlayerScreen.visible = true then
        onSeriesPlayerBack()
        return true
    else if m.livePlayerScreen <> invalid and m.livePlayerScreen.visible = true then
        onLivePlayerBack()
        return true
    end if

    return false
end function

sub focusActiveScreen()
    screens = [m.homeScreen, m.loginScreen, m.favoritesScreen, m.recentScreen, m.searchScreen, m.liveChannelsScreen, m.movieListScreen, m.movieDetailScreen, m.seriesHomeScreen, m.seriesDetailScreen]
    for each screen in screens
        if screen <> invalid and screen.visible = true then
            screen.SetFocus(true)
            return
        end if
    end for

    m.top.SetFocus(true)
end sub

sub configureScene()
    m.top.backgroundColor = "#000000"
    m.top.backgroundURI = ""

    resolution = getDisplayResolution()
    m.globalBackground.width = resolution.width
    m.globalBackground.height = resolution.height
    m.globalBackgroundOverlay.width = resolution.width
    m.globalBackgroundOverlay.height = resolution.height

    m.homeScreen.SetFocus(true)
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function


sub hideAllScreensExcept(visibleScreen as Object)
    visibleId = ""
    if visibleScreen <> invalid then visibleId = visibleScreen.id
    screens = [m.homeScreen, m.loginScreen, m.favoritesScreen, m.recentScreen, m.searchScreen, m.movieSearchScreen, m.liveCategoriesScreen, m.liveChannelsScreen, m.livePlayerScreen, m.movieCategoriesScreen, m.movieListScreen, m.movieDetailScreen, m.moviePlayerScreen, m.seriesHomeScreen, m.seriesDetailScreen, m.seriesPlayerScreen]
    for each screen in screens
        if screen <> invalid and screen.id <> visibleId then screen.callFunc("hide")
    end for
end sub

function isValidAccount(account as Dynamic) as Boolean
    return hasAccount(account)
end function

sub runXtreamRequest(action as String, categoryId as String)
    if action = "getSeriesCategories" then
        startSeriesOpenTimeout()
        loadSeriesCategories(m.account)
    end if
end sub

sub showHome()
    if m.splashScreen <> invalid then m.splashScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.homeScreen.callFunc("show")
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    account = m.account
    if m.loginFormAccount <> invalid then account = m.loginFormAccount
    m.loginScreen.callFunc("show", account)
end sub



sub openSearch(mode as String, backTarget as String)
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.searchMode = mode
    m.searchBackTarget = backTarget
    m.searchScreen.callFunc("show", mode)

    if not hasAccount(m.account) then
        m.searchScreen.callFunc("showMessage", "Conecte uma lista Xtream para buscar.")
        return
    end if

    searchData = getSearchDataForMode(mode)
    m.searchScreen.callFunc("setData", searchData)
end sub

sub onSearchBack()
    if m.searchBackTarget = "live" then
        m.liveChannelsScreen.callFunc("setAccount", m.account)
        m.liveChannelsScreen.callFunc("show", m.selectedLiveCategory)
        m.liveChannelsScreen.callFunc("focusCategories")
        m.searchScreen.callFunc("hide")
    else if m.searchBackTarget = "movies" then
        m.movieListScreen.callFunc("show", m.selectedMovieCategory)
        m.movieListScreen.callFunc("focusCategories")
        m.searchScreen.callFunc("hide")
    else if m.searchBackTarget = "series" then
        m.seriesHomeScreen.callFunc("show")
        m.seriesHomeScreen.callFunc("focusSearchEntry")
        m.searchScreen.callFunc("hide")
    else
        showHome()
    end if
end sub

sub onLiveSearchRequested()
    m.liveCategoriesScreen.callFunc("hide")
    openSearch("live", "live")
end sub

sub onMovieSearchRequested()
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.searchBackTarget = "movies"
    m.movieSearchScreen.callFunc("show")
    movieSearchData = getMoviesForSearch()
    m.movieSearchScreen.callFunc("setMovies", movieSearchData)
end sub

sub onMovieSearchBack()
    m.movieSearchScreen.callFunc("hide")
    if m.selectedMovieCategory <> invalid then
        m.movieListScreen.callFunc("show", m.selectedMovieCategory)
        if m.movies <> invalid and m.movies.Count() > 0 then m.movieListScreen.callFunc("setMovies", m.movies)
        m.movieListScreen.callFunc("focusCategories")
    else
        m.movieCategoriesScreen.callFunc("show")
    end if
end sub

sub onMovieSearchMovieSelected()
    movie = m.movieSearchScreen.movieSelected
    if movie = invalid then return
    m.selectedMovie = movie
    m.openedFromSearch = true
    m.movieSearchScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("show", movie)
    m.movieDetailScreen.callFunc("setDetails", movie)
end sub

function getMoviesForSearch() as Object
    if m.movies <> invalid and m.movies.Count() > 0 then return m.movies
    if m.selectedMovieCategoryId <> "" then
        cachedForCategory = filterItemsByCategory(m.cachedMovies, m.selectedMovieCategoryId)
        if cachedForCategory.Count() > 0 then return cachedForCategory
    end if
    if m.cachedMovies <> invalid then return m.cachedMovies
    return []
end function

function getSearchDataForMode(mode as String) as Object
    channels = m.cachedLiveChannels
    movies = m.movieSearchIndex
    series = m.seriesSearchIndex
    if mode = "live" and m.liveChannels <> invalid and m.liveChannels.Count() > 0 then channels = m.liveChannels
    return { channels: channels, movies: movies, series: series }
end function

function needsSearchData(mode as String) as Boolean
    if mode = "live" then return m.searchChannels.Count() = 0
    if mode = "movies" then return m.searchMovies.Count() = 0
    if mode = "series" then return m.searchSeries.Count() = 0
    return m.searchChannels.Count() = 0 or m.searchMovies.Count() = 0 or m.searchSeries.Count() = 0
end function

sub onSearchChannelSelected()
    channel = m.searchScreen.channelSelected
    if channel = invalid then return
    m.selectedLiveChannel = channel
    m.openedFromSearch = true
    m.searchScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("show", channel)
    buildLiveStreamUrl(channel)
end sub

sub onSearchMovieSelected()
    movie = m.searchScreen.movieSelected
    if movie = invalid then return
    m.selectedMovie = movie
    m.openedFromSearch = true
    m.searchScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("show", movie)
    m.moviePlayerScreen.callFunc("setResumePosition", GetHistoryPosition("movie", movie))
    buildMovieStreamUrl(movie)
end sub

sub onSearchSeriesSelected()
    series = m.searchScreen.seriesSelected
    if series = invalid then return
    m.selectedSeries = series
    m.openedFromSearch = true
    m.searchScreen.callFunc("hide")
    m.seriesDetailScreen.callFunc("show", series)
    m.seriesDetailScreen.callFunc("setLoading", true)
    m.seriesDetailScreen.callFunc("showMessage", "Carregando temporadas...")
    startDetailTimeout("series")
    loadSeriesInfo(series)
end sub

sub loadSearchChannels()
    if not beginXtreamRequest("getLiveStreams") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveStreams"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = ""
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSearchMovies()
    if not beginXtreamRequest("getMovies") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovies"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = ""
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSearchSeries()
    if not beginXtreamRequest("getSeries") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeries"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = ""
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub onOpenRecentRequested()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.recentScreen.callFunc("setHistory", LoadViewingHistory())
    m.recentScreen.callFunc("show")
end sub

sub onRecentBack()
    showHome()
end sub

sub onOpenFavoritesRequested()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.favoritesScreen.callFunc("setFavorites", LoadFavorites())
    m.favoritesScreen.callFunc("show")
end sub

sub onFavoritesBack()
    showHome()
end sub

sub onHistorySelected()
    item = m.recentScreen.historySelected
    if item = invalid then return
    m.recentScreen.callFunc("hide")
    m.openedFromRecent = true
    if item.type = "movie" then
        m.selectedMovie = item.content
        m.moviePlayerScreen.callFunc("show", item.content)
        m.moviePlayerScreen.callFunc("setResumePosition", item.position)
        buildMovieStreamUrl(item.content)
    else if item.type = "series" then
        m.selectedSeries = item.series
        m.selectedSeason = item.season
        m.selectedEpisode = item.content
        m.seriesPlayerScreen.callFunc("show", item.content)
        m.seriesPlayerScreen.callFunc("setResumePosition", item.position)
        buildSeriesStreamUrl(item.content)
    end if
end sub


sub onFavoriteSelected()
    favorite = m.favoritesScreen.favoriteSelected
    if favorite = invalid or favorite.content = invalid then return
    content = favorite.content
    m.favoritesScreen.callFunc("hide")
    m.openedFromFavorites = true
    if favorite.type = "live" then
        m.selectedLiveChannel = content
        m.livePlayerScreen.callFunc("show", content)
        buildLiveStreamUrl(content)
    else if favorite.type = "movie" then
        m.selectedMovie = content
        m.moviePlayerScreen.callFunc("show", content)
        m.moviePlayerScreen.callFunc("setResumePosition", GetHistoryPosition("movie", content))
        buildMovieStreamUrl(content)
    else if favorite.type = "series" then
        m.selectedSeries = content
        m.seriesDetailScreen.callFunc("show", content)
        m.seriesDetailScreen.callFunc("setLoading", true)
        loadSeriesInfo(content)
    else if favorite.type = "episode" then
        m.selectedEpisode = content
        m.seriesPlayerScreen.callFunc("show", content)
        m.seriesPlayerScreen.callFunc("setResumePosition", GetHistoryPosition("episode", content))
        buildSeriesStreamUrl(content)
    end if
end sub

sub onLiveChannelFavoriteToggled()
    ToggleFavorite("live", m.liveChannelsScreen.channelFavoriteToggled)
end sub

sub onMovieFavoriteToggled()
    ToggleFavorite("movie", m.movieListScreen.movieFavoriteToggled)
end sub

sub onOpenPlaylistRequested()
    showLogin()
end sub

sub onOpenLiveCategoriesRequested()
    cancelSearchIndexRefresh()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.liveChannelsScreen.callFunc("resetSelection")
    m.liveChannelsScreen.callFunc("setAccount", m.account)
    m.liveChannelsScreen.callFunc("show", invalid)
    m.liveChannelsScreen.callFunc("focusCategories")

    if not hasAccount(m.account) then
        m.liveChannelsScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as categorias de TV ao vivo.")
        m.liveChannelsScreen.callFunc("focusCategories")
    else if m.liveCategoriesLoading then
        m.liveChannelsScreen.callFunc("setLoading", true)
    else if m.liveCategories <> invalid and m.liveCategories.Count() > 0 then
        m.liveChannelsScreen.callFunc("setCategories", m.liveCategories)
        m.liveChannelsScreen.callFunc("showMessage", "Escolha uma categoria para carregar os canais.")
        m.liveChannelsScreen.callFunc("focusCategories")
    else
        m.liveChannelsScreen.callFunc("setLoading", true)
        loadLiveCategories(m.account)
    end if
end sub


sub onOpenMovieCategoriesRequested()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.movieListScreen.callFunc("resetSelection")
    m.movieListScreen.callFunc("show", invalid)
    m.movieListScreen.callFunc("focusCategories")

    if not hasAccount(m.account) then
        m.movieListScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as categorias de filmes.")
        m.movieListScreen.callFunc("focusCategories")
    else if m.movieCategoriesLoading then
        m.movieListScreen.callFunc("setLoading", true)
    else if m.movieCategories <> invalid and m.movieCategories.Count() > 0 then
        m.movieListScreen.callFunc("setCategories", m.movieCategories)
        m.movieListScreen.callFunc("showMessage", "Escolha uma categoria para carregar os filmes.")
        m.movieListScreen.callFunc("focusCategories")
    else
        m.movieListScreen.callFunc("setLoading", true)
        loadMovieCategories(m.account)
    end if
end sub

sub onLoginSubmit()
    account = m.loginScreen.submit
    if not hasAccount(account) then
        m.loginScreen.callFunc("showError", "Informe DNS, usuário e senha para conectar.")
        return
    end if

    m.pendingAccount = account
    m.loginFormAccount = account
    m.loginConnecting = true
    m.loginErrorActive = false
    m.connectionMode = "manual"

    showHome()
    updateConnectionStatus(false, "Conectando...")
    startLoginTimeout()
    connectXtream(account)
end sub

sub onLoginBack()
    stopLoginTimeout()
    m.loginConnecting = false
    m.isConnecting = false
    m.connectionMode = ""
    m.loginErrorActive = false
    cancelXtreamRequest()
    showHome()
end sub

sub onLiveCategoriesBack()
    showHome()
end sub

sub onLiveChannelsBack()
    showHome()
end sub


sub onMovieCategoriesBack()
    showHome()
end sub

sub onMovieListBack()
    showHome()
end sub

sub onMovieCategorySelected()
    category = m.movieCategoriesScreen.categorySelected
    if category = invalid then return

    m.selectedMovieCategory = category
    m.selectedMovieCategoryId = getCategoryId(category)
    m.movies = []
    m.moviesLoading = false
    m.movieCategoriesScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.movieListScreen.callFunc("setCategories", m.movieCategories)
    m.movieListScreen.callFunc("resetSelection")
    m.movieListScreen.callFunc("show", category)
    showMoviesFromCacheOrLoad(category)
end sub

sub onMovieListCategorySelected()
    category = m.movieListScreen.categorySelected
    if category = invalid then return
    newCategoryId = getCategoryId(category)
    m.selectedMovieCategory = category
    if newCategoryId = m.selectedMovieCategoryId and m.movies <> invalid and m.movies.Count() > 0 then
        m.movieListScreen.callFunc("show", category)
        m.movieListScreen.callFunc("setMovies", m.movies)
        return
    end if
    m.selectedMovieCategoryId = newCategoryId
    m.movies = []
    m.moviesLoading = false
    m.movieListScreen.callFunc("show", category)
    showMoviesFromCacheOrLoad(category)
end sub

sub onMovieSelected()
    movie = m.movieListScreen.movieSelected
    if movie = invalid then return

    if not hasAccount(m.account) then
        m.movieListScreen.callFunc("showMessage", "Conecte uma lista Xtream para reproduzir filmes.")
        return
    end if

    m.selectedMovie = movie
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("show", movie)
    m.movieDetailScreen.callFunc("setDetails", movie)
end sub

sub onMovieDetailBack()
    stopDetailTimeout("movie")
    if m.pendingRequest = "getMovieInfo" then cancelXtreamRequest()
    m.movieDetailScreen.callFunc("hide")
    m.movieListScreen.callFunc("show", m.selectedMovieCategory)
end sub

sub onMovieDetailPlay()
    if m.selectedMovie = invalid then return
    cancelSearchIndexRefresh()
    m.movieListRestoreState = m.movieListScreen.callFunc("getState")
    m.currentMovieList = m.movies
    m.entryPoint = "movies"
    if m.movieListRestoreState <> invalid then
        m.movieListSelectedIndex = m.movieListRestoreState.selectedIndex
        m.movieListFirstVisibleIndex = m.movieListRestoreState.firstVisibleRow
    end if
    if getStreamId(m.selectedMovie) = "" then
        m.movieDetailScreen.callFunc("setLoading", false)
        return
    end if
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("show", m.selectedMovie)
    m.moviePlayerScreen.callFunc("setResumePosition", GetHistoryPosition("movie", m.selectedMovie))
    buildMovieStreamUrl(m.selectedMovie)
end sub

sub onMovieDetailFavoriteToggled()
    ToggleFavorite("movie", m.movieDetailScreen.favoriteToggled)
end sub

sub onMoviePlayerBack()
    if m.isReturningFromPlayer = true then return
    m.isReturningFromPlayer = true

    position = 0
    if m.moviePlayerScreen <> invalid then position = m.moviePlayerScreen.callFunc("getPlaybackPosition")
    UpsertMovieHistory(m.selectedMovie, position)

    if m.moviePlayerScreen <> invalid then
        m.moviePlayerScreen.callFunc("hide")
        m.moviePlayerScreen.SetFocus(false)
    end if
    m.movieDetailScreen.callFunc("hide")

    if m.selectedMovieCategory <> invalid and m.currentMovieList <> invalid then
        m.movieListScreen.callFunc("show", m.selectedMovieCategory)
        if m.currentMovieList.Count() > 0 then m.movieListScreen.callFunc("setMovies", m.currentMovieList)
        if m.movieListRestoreState <> invalid then m.movieListScreen.callFunc("restoreState", m.movieListRestoreState)
        m.movieListScreen.SetFocus(true)
    else
        showHome()
    end if

    m.movieListRestoreState = invalid
    m.openedFromFavorites = false
    m.openedFromRecent = false
    m.openedFromSearch = false
    m.isReturningFromPlayer = false
end sub

sub onLiveCategorySelected()
    category = m.liveCategoriesScreen.categorySelected
    if category = invalid then return

    m.selectedLiveCategory = category
    m.selectedLiveCategoryId = getCategoryId(category)
    m.liveChannels = []
    m.liveChannelsLoading = false
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("resetSelection")
    m.liveChannelsScreen.callFunc("setCategories", m.liveCategories)
    m.liveChannelsScreen.callFunc("setAccount", m.account)
    m.liveChannelsScreen.callFunc("show", category)
    showLiveChannelsFromCacheOrLoad(category)
end sub

sub onLiveChannelsCategorySelected()
    category = m.liveChannelsScreen.categorySelected
    if category = invalid then return

    newCategoryId = getCategoryId(category)
    m.selectedLiveCategory = category
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("setAccount", m.account)
    if newCategoryId = m.selectedLiveCategoryId and m.liveChannels <> invalid and m.liveChannels.Count() > 0 then
        m.liveChannelsScreen.callFunc("show", category)
        m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
        return
    end if
    m.selectedLiveCategoryId = newCategoryId
    m.liveChannels = []
    m.liveChannelsLoading = false
    m.liveChannelsScreen.callFunc("show", category)
    showLiveChannelsFromCacheOrLoad(category)
end sub


sub onLiveChannelSelected()
    channel = m.liveChannelsScreen.channelSelected
    if channel = invalid then return

    if not hasAccount(m.account) then
        m.liveChannelsScreen.callFunc("showMessage", "Conecte uma lista Xtream para reproduzir canais de TV ao vivo.")
        return
    end if

    m.selectedLiveChannel = channel
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("show", channel)
    buildLiveStreamUrl(channel)
end sub

sub onLivePlayerBack()
    m.livePlayerScreen.callFunc("hide")
    if m.openedFromFavorites = true then
        m.openedFromFavorites = false
        showHome()
    else if m.openedFromRecent = true then
        m.openedFromRecent = false
        showHome()
    else if m.openedFromSearch = true then
        m.openedFromSearch = false
        showHome()
    else
        m.liveChannelsScreen.callFunc("setAccount", m.account)
        m.liveChannelsScreen.callFunc("show", m.selectedLiveCategory)
    end if
end sub

sub buildLiveStreamUrl(channel as Object)
    cancelBlockingRequestForPlayback()
    if not beginXtreamRequest("buildLiveStreamUrl") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "buildLiveStreamUrl"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.streamId = getStreamId(channel)
    m.xtreamService.streamExtension = getStreamExtension(channel)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub


sub loadMovieInfo(movie as Object)
    if not beginXtreamRequest("getMovieInfo") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovieInfo"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.streamId = getStreamId(movie)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub buildMovieStreamUrl(movie as Object)
    cancelBlockingRequestForPlayback()
    if not beginXtreamRequest("buildMovieStreamUrl") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "buildMovieStreamUrl"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.streamId = getStreamId(movie)
    m.xtreamService.streamExtension = getMovieStreamExtension(movie)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub connectXtream(account as Object)
    if m.isConnecting = true then return
    if m.isLoadingRequest = true then return
    if not hasAccount(account) then
        m.isConnecting = false
        updateConnectionStatus(false, "Não foi possível reconectar. Abra CONTA para corrigir.")
        return
    end if

    m.isConnecting = true
    if not beginXtreamRequest("connect") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "connect"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub


sub loadMovies(category as Object)
    if not beginXtreamRequest("getMovies") then return
    if not hasAccount(m.account) then
        m.moviesLoading = false
        m.movieListScreen.callFunc("setLoading", false)
        m.movieListScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar os filmes.")
        completeXtreamRequest()
        return
    end if

    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovies"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = getCategoryId(category)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadMovieCategories(account as Object)
    if not beginXtreamRequest("getMovieCategories") then return
    m.movieCategoriesLoading = true
    if m.movieCategoriesScreen.visible = true then
        m.movieCategoriesScreen.callFunc("setLoading", true)
    else
        m.homeScreen.callFunc("setMovieCategoriesLoading", true)
    end if
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovieCategories"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub loadLiveChannels(category as Object)
    if not beginXtreamRequest("getLiveStreams") then return
    if not hasAccount(m.account) then
        m.liveChannelsLoading = false
        m.liveChannelsScreen.callFunc("setLoading", false)
        m.liveChannelsScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar os canais de TV ao vivo.")
        completeXtreamRequest()
        return
    end if

    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveStreams"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = ""
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadLiveCategories(account as Object)
    if not beginXtreamRequest("getLiveCategories") then return
    m.liveCategoriesLoading = true
    if m.liveCategoriesScreen.visible = true then
        m.liveCategoriesScreen.callFunc("setLoading", true)
    else
        m.homeScreen.callFunc("setLiveCategoriesLoading", true)
    end if
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveCategories"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub


sub showMoviesFromCacheOrLoad(category as Object)
    cached = filterItemsByCategory(m.cachedMovies, getCategoryId(category))
    if cached.Count() > 0 then
        m.movies = cached
        m.moviesLoading = false
        m.movieListScreen.callFunc("setLoading", false)
        m.movieListScreen.callFunc("setMovies", m.movies)
        return
    end if
    m.moviesLoading = true
    m.movieListScreen.callFunc("setLoading", true)
    loadMovies(category)
end sub

sub showSeriesFromCacheOrLoad(category as Object)
    cached = filterItemsByCategory(m.cachedSeries, getCategoryId(category))
    if cached.Count() > 0 then
        m.series = cached
        m.seriesLoading = false
        m.seriesHomeScreen.callFunc("setLoading", false)
        m.seriesHomeScreen.callFunc("setSeries", m.series)
        return
    end if
    m.seriesLoading = true
    m.seriesHomeScreen.callFunc("setLoading", true)
    loadSeries(category)
end sub

sub showLiveChannelsFromCacheOrLoad(category as Object)
    cached = filterItemsByCategory(m.cachedLiveChannels, getCategoryId(category))
    if cached.Count() > 0 or (m.cachedLiveChannels <> invalid and m.cachedLiveChannels.Count() > 0) then
        m.liveChannels = cached
        m.liveChannelsLoading = false
        m.liveChannelsScreen.callFunc("setLoading", false)
        m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
        return
    end if
    m.liveChannelsLoading = true
    m.liveChannelsScreen.callFunc("setLoading", true)
    loadLiveChannels(category)
end sub

function filterItemsByCategory(items as Dynamic, categoryId as String) as Object
    filtered = []
    if items = invalid or Type(items) <> "roArray" then return filtered
    for each item in items
        if getItemCategoryId(item) = categoryId then filtered.Push(item)
    end for
    return filtered
end function

function replaceCachedCategoryItems(cache as Dynamic, freshItems as Object, categoryId as String) as Object
    if categoryId = "" then return freshItems
    merged = []
    if cache <> invalid and Type(cache) = "roArray" then
        for each item in cache
            if getItemCategoryId(item) <> categoryId then merged.Push(item)
        end for
    end if
    if freshItems <> invalid and Type(freshItems) = "roArray" then
        for each item in freshItems
            merged.Push(item)
        end for
    end if
    return merged
end function

function getItemCategoryId(item as Dynamic) as String
    if item = invalid or Type(item) <> "roAssociativeArray" then return ""
    if item.category_id <> invalid then return item.category_id.ToStr()
    if item.categoryId <> invalid then return item.categoryId.ToStr()
    return ""
end function

sub onXtreamConnectionResult()
    result = m.xtreamService.result
    if result = invalid then return
    completeXtreamRequest()

    if handleSearchIndexResult(result) then return

    if result.request = "getSeriesCategories" then
        onSeriesCategoriesResult(result)
        return
    else if Left(result.request, 9) = "getSeries" then
        onSeriesResult(result)
        return
    else if result.request = "buildSeriesStreamUrl" then
        onSeriesStreamUrlResult(result)
        return
    else if isMovieInfoResult(result) then
        onMovieInfoResult(result)
        return
    else if result.request = "getMovieCategories" then
        onMovieCategoriesResult(result)
        return
    else if Left(result.request, 9) = "getMovies" then
        onMoviesResult(result)
        return
    else if result.request = "buildMovieStreamUrl" then
        onMovieStreamUrlResult(result)
        return
    else if result.request = "getLiveCategories" then
        onLiveCategoriesResult(result)
        return
    else if result.request = "buildLiveStreamUrl" then
        onLiveStreamUrlResult(result)
        return
    else if Left(result.request, 14) = "getLiveStreams" then
        onLiveChannelsResult(result)
        return
    end if

    handleLoginConnectionResult(result)
end sub

sub handleLoginConnectionResult(result as Object)
    stopLoginTimeout()
    m.isConnecting = false
    m.loginConnecting = false
    m.loginScreen.callFunc("setLoading", false)

    if m.pendingAccount = invalid then
        m.connectionMode = ""
        return
    end if

    connectionMode = m.connectionMode

    if isValidXtreamConnectionResult(result) then
        m.account = m.pendingAccount
        m.loginFormAccount = invalid
        SavePlaylist(m.account)
        SavePlaylistConnectionStatus("Conectado")
        updateConnectionStatus(true, "Conectado")
        m.pendingAccount = invalid
        m.loginErrorActive = false
        m.connectionMode = ""
        resetAccountLoadedData()
        loadLocalSearchIndexCache()
        showHome()
        startSearchIndexRefresh()
    else
        SavePlaylistConnectionStatus("Desconectado")
        m.pendingAccount = invalid
        resetAccountLoadedData()
        if connectionMode = "auto" then
            m.loginErrorActive = false
            updateConnectionStatus(false, "Não foi possível reconectar. Abra CONTA para corrigir.")
        else
            m.loginErrorActive = true
            updateConnectionStatus(false, "Não foi possível conectar. Pressione Voltar para corrigir os dados.")
        end if
        m.connectionMode = ""
        showHome()
    end if
end sub

sub resetAccountLoadedData()
    m.searchIndexCache = createEmptySearchIndexCache()
    m.movieSearchIndex = []
    m.seriesSearchIndex = []
    m.searchIndexQueue = []
    m.searchIndexUpdating = false
    m.liveCategories = []
    m.liveChannels = []
    m.cachedLiveChannels = []
    m.liveCategoriesLoading = false
    m.liveChannelsLoading = false
    m.movieCategories = []
    m.movies = []
    m.cachedMovies = []
    m.searchChannels = []
    m.searchMovies = []
    m.searchSeries = []
    m.movieCategoriesLoading = false
    m.moviesLoading = false
    resetSeriesData()
end sub

sub startLoginTimeout()
    m.loginTimeoutTimer.control = "stop"
    m.loginTimeoutTimer.duration = 6
    m.loginTimeoutTimer.control = "start"
end sub

sub stopLoginTimeout()
    m.loginTimeoutTimer.control = "stop"
end sub

sub startDetailTimeout(requestName as String)
    m.pendingDetailRequest = requestName
    if m.detailTimeoutTimer = invalid then return
    m.detailTimeoutTimer.control = "stop"
    m.detailTimeoutTimer.duration = 8
    m.detailTimeoutTimer.control = "start"
end sub

sub stopDetailTimeout(requestName as String)
    if m.pendingDetailRequest = requestName then m.pendingDetailRequest = ""
    if m.detailTimeoutTimer <> invalid then m.detailTimeoutTimer.control = "stop"
end sub

sub onDetailTimeout()
    requestName = m.pendingDetailRequest
    if requestName = "" then return
    m.pendingDetailRequest = ""
    cancelXtreamRequest()

    if requestName = "movie" then
        if m.movieDetailScreen.visible = true then
            m.movieDetailScreen.callFunc("setLoading", false)
            m.movieDetailScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
        end if
    else if requestName = "series" then
        showSeriesInfoFailure("Não foi possível carregar os detalhes desta série. Pressione Voltar.")
    end if
end sub

sub onLoginTimeout()
    if m.pendingAccount = invalid then return
    cancelXtreamRequest()
    onXtreamConnectionResultForLogin({
        success: false,
        connected: false,
        request: "connect",
        message: "Tempo esgotado ao conectar."
    })
end sub

sub cancelXtreamRequest()
    if m.xtreamService <> invalid then m.xtreamService.control = "STOP"
    completeXtreamRequest()
end sub

sub cancelBlockingRequestForPlayback()
    if m.isLoadingRequest <> true then return
    if m.pendingRequest = "buildLiveStreamUrl" then return
    if m.pendingRequest = "buildMovieStreamUrl" then return
    if m.pendingRequest = "buildSeriesStreamUrl" then return
    cancelXtreamRequest()
end sub

function beginXtreamRequest(action as String) as Boolean
    if m.isLoadingRequest = true then return false
    m.isLoadingRequest = true
    m.pendingRequest = action
    return true
end function

sub completeXtreamRequest()
    m.isLoadingRequest = false
    m.pendingRequest = ""
end sub

sub onXtreamConnectionResultForLogin(result as Object)
    handleLoginConnectionResult(result)
end sub


sub continueBootstrapIfNeeded()
    if m.bootstrapActive = true and m.splashMaximumElapsed <> true then processNextBootstrapRequest()
end sub

sub loadLocalSearchIndexCache()
    m.searchIndexCache = LoadSearchIndexCache()
    m.movieSearchIndex = m.searchIndexCache.movieSearchIndex
    m.seriesSearchIndex = m.searchIndexCache.seriesSearchIndex
    m.cachedMovies = m.searchIndexCache.movies
    m.cachedSeries = m.searchIndexCache.series
    m.cachedLiveChannels = m.searchIndexCache.liveChannels
    m.cachedSeriesInfo = m.searchIndexCache.seriesInfo
    if m.searchIndexCache.liveCategories.Count() > 0 then m.liveCategories = m.searchIndexCache.liveCategories
    if m.searchIndexCache.liveChannels.Count() > 0 then m.cachedLiveChannels = m.searchIndexCache.liveChannels
    if m.searchIndexCache.movieCategories.Count() > 0 then m.movieCategories = m.searchIndexCache.movieCategories
    if m.searchIndexCache.movies.Count() > 0 then m.cachedMovies = m.searchIndexCache.movies
    if m.searchIndexCache.seriesCategories.Count() > 0 then m.seriesCategories = m.searchIndexCache.seriesCategories
    if m.searchIndexCache.series.Count() > 0 then m.cachedSeries = m.searchIndexCache.series
    if m.searchIndexCache.seriesInfo <> invalid then m.cachedSeriesInfo = m.searchIndexCache.seriesInfo
    m.movieSearchIndex = BuildMovieSearchIndexItems(m.cachedMovies, "")
    m.seriesSearchIndex = BuildSeriesSearchIndexItems(m.cachedSeries, "")
end sub


sub cancelSearchIndexRefresh()
    if m.searchIndexTimer <> invalid then m.searchIndexTimer.control = "stop"
    if m.searchIndexUpdating = true and m.searchIndexKind <> "" then
        if m.xtreamService <> invalid then m.xtreamService.control = "STOP"
        completeXtreamRequest()
    end if
    m.searchIndexUpdating = false
    m.searchIndexQueue = []
    m.searchIndexKind = ""
    m.searchIndexCategoryId = ""
end sub

sub startSearchIndexRefresh()
    if not hasAccount(m.account) then return
    if m.searchIndexUpdating = true then return
    m.searchIndexQueue = []
    if m.liveCategories = invalid or m.liveCategories.Count() = 0 then m.searchIndexQueue.Push({ action: "getLiveCategories", kind: "liveCategories", categoryId: "" })
    if m.cachedLiveChannels = invalid or m.cachedLiveChannels.Count() = 0 then m.searchIndexQueue.Push({ action: "getLiveStreams", kind: "live", categoryId: "" })
    if m.movieCategories = invalid or m.movieCategories.Count() = 0 then m.searchIndexQueue.Push({ action: "getMovieCategories", kind: "movieCategories", categoryId: "" })
    if m.cachedMovies = invalid or m.cachedMovies.Count() = 0 then m.searchIndexQueue.Push({ action: "getMovies", kind: "movies", categoryId: "" })
    if m.seriesCategories = invalid or m.seriesCategories.Count() = 0 then m.searchIndexQueue.Push({ action: "getSeriesCategories", kind: "seriesCategories", categoryId: "" })
    if m.cachedSeries = invalid or m.cachedSeries.Count() = 0 then m.searchIndexQueue.Push({ action: "getSeries", kind: "series", categoryId: "" })
    m.searchIndexUpdating = true
    m.searchIndexTimer.control = "stop"
    m.searchIndexTimer.control = "start"
end sub

sub onSearchIndexTimerFire()
    processNextSearchIndexRequest()
end sub

sub processNextSearchIndexRequest()
    if m.searchIndexUpdating <> true then return
    if m.isLoadingRequest = true then
        m.searchIndexTimer.control = "start"
        return
    end if
    if m.searchIndexQueue = invalid or m.searchIndexQueue.Count() = 0 then
        m.searchIndexUpdating = false
        m.searchIndexCache.movieSearchIndex = m.movieSearchIndex
        m.searchIndexCache.seriesSearchIndex = m.seriesSearchIndex
        m.searchIndexCache.updatedAt = CreateObject("roDateTime").AsSeconds().ToStr()
        SaveSearchIndexCache(m.searchIndexCache)
        return
    end if
    job = m.searchIndexQueue.Shift()
    m.searchIndexKind = job.kind
    m.searchIndexCategoryId = job.categoryId
    if beginXtreamRequest(job.action) then
        m.xtreamService.control = "STOP"
        m.xtreamService.action = job.action
        m.xtreamService.cacheEnabled = true
        m.xtreamService.categoryId = job.categoryId
        m.xtreamService.dns = m.account.dns
        m.xtreamService.username = m.account.username
        m.xtreamService.password = m.account.password
        m.xtreamService.control = "RUN"
    else
        m.searchIndexTimer.control = "start"
    end if
end sub

function handleSearchIndexResult(result as Object) as Boolean
    if m.searchIndexUpdating <> true or m.searchIndexKind = "" then return false
    kind = m.searchIndexKind
    m.searchIndexKind = ""
    if result.success = true then
        if kind = "liveCategories" then
            m.liveCategories = normalizeLiveCategories(result.data)
            m.searchIndexCache.liveCategories = m.liveCategories
        else if kind = "live" then
            m.cachedLiveChannels = normalizeLiveChannels(result.data)
            m.searchIndexCache.liveChannels = m.cachedLiveChannels
        else if kind = "movieCategories" then
            m.movieCategories = normalizeMovieCategories(result.data)
            m.searchIndexCache.movieCategories = m.movieCategories
        else if kind = "seriesCategories" then
            m.seriesCategories = normalizeSeriesCategories(result.data)
            m.searchIndexCache.seriesCategories = m.seriesCategories
        else if kind = "movies" then
            m.cachedMovies = normalizeMovies(result.data)
            m.searchIndexCache.movies = m.cachedMovies
            m.movieSearchIndex = BuildMovieSearchIndexItems(m.cachedMovies, "")
            m.searchIndexCache.movieSearchIndex = m.movieSearchIndex
        else if kind = "series" then
            m.cachedSeries = normalizeSeries(result.data)
            m.searchIndexCache.series = m.cachedSeries
            m.seriesSearchIndex = BuildSeriesSearchIndexItems(m.cachedSeries, "")
            m.searchIndexCache.seriesSearchIndex = m.seriesSearchIndex
        end if
        SaveSearchIndexCache(m.searchIndexCache)
    end if
    m.searchIndexTimer.control = "start"
    return true
end function

sub replaceSearchIndexCategory(kind as String, categoryId as String, entries as Object)
    target = []
    current = m.movieSearchIndex
    if kind = "series" then current = m.seriesSearchIndex
    for each entry in current
        if entry.categoryId = invalid or entry.categoryId.ToStr() <> categoryId then target.Push(entry)
    end for
    for each entry in entries
        target.Push(entry)
    end for
    if kind = "series" then
        m.seriesSearchIndex = target
        m.searchIndexCache.seriesSearchIndex = target
    else
        m.movieSearchIndex = target
        m.searchIndexCache.movieSearchIndex = target
    end if
end sub

sub hideSeriesScreens()
    m.seriesHomeScreen.callFunc("hide")
    m.seriesDetailScreen.callFunc("hide")
    m.seriesPlayerScreen.callFunc("hide")
end sub

sub resetSeriesData()
    m.seriesCategories = []
    m.series = []
    m.cachedSeries = []
    m.cachedSeriesInfo = {}
    m.seriesCategoriesLoading = false
    m.seriesLoading = false
    m.selectedSeriesCategory = invalid
    m.selectedSeriesCategoryId = ""
end sub

sub onOpenSeriesRequested()
    ' TESTE TEMPORÁRIO:
    ' botão Séries abre Filmes para isolar travamento da tela de Séries.
    onOpenMovieCategoriesRequested()
end sub

sub onOpenSeriesCategoriesRequested()
    ' TESTE TEMPORÁRIO:
    ' mantém qualquer entrada de Séries no mesmo fluxo do botão Filmes.
    onOpenMovieCategoriesRequested()
end sub

sub startSeriesOpenTimeout()
    if m.seriesOpenTimeoutTimer = invalid then return
    m.seriesOpenTimeoutTimer.control = "stop"
    m.seriesOpenTimeoutTimer.duration = 8
    m.seriesOpenTimeoutTimer.control = "start"
end sub

sub stopSeriesOpenTimeout()
    if m.seriesOpenTimeoutTimer <> invalid then m.seriesOpenTimeoutTimer.control = "stop"
    m.isOpeningSeries = false
end sub

sub onSeriesOpenTimeout()
    if m.isOpeningSeries <> true and m.seriesCategoriesLoading <> true and m.seriesLoading <> true then return
    if m.pendingRequest = "getSeriesCategories" or m.pendingRequest = "getSeries" then cancelXtreamRequest()
    m.seriesCategoriesLoading = false
    m.seriesLoading = false
    m.isOpeningSeries = false
    if m.seriesHomeScreen.visible = true then
        m.seriesHomeScreen.callFunc("setLoading", false)
        m.seriesHomeScreen.callFunc("showMessage", "Não foi possível carregar séries. Pressione Voltar e tente novamente.")
        m.seriesHomeScreen.SetFocus(true)
    end if
end sub

sub onSeriesHomeBack()
    stopSeriesOpenTimeout()
    m.seriesCategoriesLoading = false
    m.seriesLoading = false
    showHome()
end sub

sub onSeriesDetailBack()
    if m.pendingRequest = "getSeriesInfo" then cancelXtreamRequest()
    m.seriesDetailScreen.callFunc("hide")
    m.seriesHomeScreen.callFunc("show")
end sub

sub onSeriesPlayerBack()
    UpsertSeriesHistory(m.selectedSeries, m.selectedSeason, m.selectedEpisode, m.seriesPlayerScreen.callFunc("getPlaybackPosition"))
    m.seriesPlayerScreen.callFunc("hide")
    if m.openedFromFavorites = true or m.openedFromRecent = true or m.openedFromSearch = true then
        m.openedFromFavorites = false
        m.openedFromRecent = false
        m.openedFromSearch = false
        showHome()
    else if m.selectedSeries <> invalid then
        m.seriesDetailScreen.callFunc("show", m.selectedSeries)
    else
        showHome()
    end if
end sub

sub onSeriesSearchRequested()
    openSearch("series", "series")
end sub

sub onSeriesHomeCategorySelected()
    category = m.seriesHomeScreen.categorySelected
    if category = invalid then return
    m.selectedSeriesCategory = category
    m.selectedSeriesCategoryId = getCategoryId(category)
    m.series = []
    m.seriesLoading = false
    showSeriesFromCacheOrLoad(category)
end sub

sub onSeriesSelected()
    series = m.seriesHomeScreen.seriesSelected
    if series = invalid then return
    m.selectedSeries = series
    m.seriesHomeScreen.callFunc("hide")
    m.seriesDetailScreen.callFunc("show", series)
    m.seriesDetailScreen.callFunc("setLoading", true)
    m.seriesDetailScreen.callFunc("showMessage", "Carregando temporadas...")
    startDetailTimeout("series")
    loadSeriesInfo(series)
end sub

sub onSeriesEpisodeSelected()
    episode = m.seriesDetailScreen.episodeSelected
    if episode = invalid then return
    cancelSearchIndexRefresh()
    if not hasAccount(m.account) then
        m.seriesDetailScreen.callFunc("showMessage", "Conecte uma lista Xtream para reproduzir episódios.")
        return
    end if
    if getEpisodeId(episode) = "" then
        m.seriesDetailScreen.callFunc("showMessage", "Não foi possível abrir este episódio: stream inválido.")
        return
    end if
    m.selectedEpisode = episode
    m.seriesDetailScreen.callFunc("hide")
    m.seriesPlayerScreen.callFunc("show", episode)
    m.seriesPlayerScreen.callFunc("setResumePosition", GetHistoryPosition("episode", episode))
    buildSeriesStreamUrl(episode)
end sub

sub loadSeriesCategories(account as Object)
    if not beginXtreamRequest("getSeriesCategories") then return
    m.seriesCategoriesLoading = true
    if m.seriesHomeScreen.visible = true then m.seriesHomeScreen.callFunc("setLoading", true)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeriesCategories"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSeries(category as Object)
    startSeriesOpenTimeout()
    if not hasAccount(m.account) then
        m.seriesLoading = false
        m.seriesHomeScreen.callFunc("setLoading", false)
        m.seriesHomeScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as séries.")
        return
    end if
    if not beginXtreamRequest("getSeries") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeries"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = getCategoryId(category)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSeriesInfo(series as Object)
    if not beginXtreamRequest("getSeriesInfo") then return
    if not hasAccount(m.account) then
        showSeriesInfoFailure("Conecte uma lista Xtream para carregar as temporadas desta série.")
        completeXtreamRequest()
        return
    end if
    seriesId = getSeriesId(series)
    if seriesId = "" then
        showSeriesInfoFailure("Não foi possível carregar temporadas: série sem identificador.")
        completeXtreamRequest()
        return
    end if
    if m.cachedSeriesInfo <> invalid and m.cachedSeriesInfo.DoesExist(seriesId) then
        stopDetailTimeout("series")
        completeXtreamRequest()
        if m.seriesDetailScreen.visible = true then m.seriesDetailScreen.callFunc("setDetails", m.cachedSeriesInfo[seriesId])
        return
    end if
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeriesInfo"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.seriesId = seriesId
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub buildSeriesStreamUrl(episode as Object)
    cancelBlockingRequestForPlayback()
    if not beginXtreamRequest("buildSeriesStreamUrl") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "buildSeriesStreamUrl"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.streamId = getEpisodeId(episode)
    m.xtreamService.streamExtension = getSeriesStreamExtension(episode)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub onLiveCategoriesResult(result as Object)
    m.liveCategoriesLoading = false
    if m.liveChannelsScreen.visible = true then m.liveChannelsScreen.callFunc("setLoading", false)
    if m.liveCategoriesScreen.visible = true then m.liveCategoriesScreen.callFunc("setLoading", false)
    m.homeScreen.callFunc("setLiveCategoriesLoading", false)

    if result.success = true then
        m.liveCategories = normalizeLiveCategories(result.data)
        m.searchIndexCache.liveCategories = m.liveCategories
        SaveSearchIndexCache(m.searchIndexCache)
        if m.liveChannelsScreen.visible = true then
            m.liveChannelsScreen.callFunc("setCategories", m.liveCategories)
            m.liveChannelsScreen.callFunc("showMessage", "Escolha uma categoria para carregar os canais.")
            m.liveChannelsScreen.callFunc("focusCategories")
        end if
    else if m.liveChannelsScreen.visible = true then
        m.liveChannelsScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
        m.liveChannelsScreen.callFunc("focusCategories")
    end if

    continueBootstrapIfNeeded()
end sub

sub onLiveChannelsResult(result as Object)
    resultCategoryId = getLiveStreamsResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedLiveCategoryId then return
    m.liveChannelsLoading = false
    if m.liveChannelsScreen.visible = true then m.liveChannelsScreen.callFunc("setLoading", false)

    if result.success = true then
        m.cachedLiveChannels = normalizeLiveChannels(result.data)
        m.searchIndexCache.liveChannels = m.cachedLiveChannels
        SaveSearchIndexCache(m.searchIndexCache)
        m.liveChannels = filterItemsByCategory(m.cachedLiveChannels, m.selectedLiveCategoryId)
        if m.liveChannelsScreen.visible = true then m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
    else if m.liveChannelsScreen.visible = true then
        m.liveChannelsScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
        m.liveChannelsScreen.callFunc("focusCategories")
    end if
end sub

sub onMovieCategoriesResult(result as Object)
    m.movieCategoriesLoading = false
    if m.movieListScreen.visible = true then m.movieListScreen.callFunc("setLoading", false)
    if m.movieCategoriesScreen.visible = true then m.movieCategoriesScreen.callFunc("setLoading", false)
    m.homeScreen.callFunc("setMovieCategoriesLoading", false)

    if result.success = true then
        m.movieCategories = normalizeMovieCategories(result.data)
        m.searchIndexCache.movieCategories = m.movieCategories
        SaveSearchIndexCache(m.searchIndexCache)
        if m.movieListScreen.visible = true then
            m.movieListScreen.callFunc("setCategories", m.movieCategories)
            m.movieListScreen.callFunc("showMessage", "Escolha uma categoria para carregar os filmes.")
            m.movieListScreen.callFunc("focusCategories")
        end if
    else if m.movieListScreen.visible = true then
        m.movieListScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
        m.movieListScreen.callFunc("focusCategories")
    end if

    continueBootstrapIfNeeded()
end sub

sub onMoviesResult(result as Object)
    resultCategoryId = getMoviesResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedMovieCategoryId then return
    m.moviesLoading = false
    if m.movieListScreen.visible = true then m.movieListScreen.callFunc("setLoading", false)

    if result.success = true then
        m.cachedMovies = replaceCachedCategoryItems(m.cachedMovies, normalizeMovies(result.data), resultCategoryId)
        m.searchIndexCache.movies = m.cachedMovies
        m.movieSearchIndex = BuildMovieSearchIndexItems(m.cachedMovies, "")
        m.searchIndexCache.movieSearchIndex = m.movieSearchIndex
        SaveSearchIndexCache(m.searchIndexCache)
        m.movies = filterItemsByCategory(m.cachedMovies, m.selectedMovieCategoryId)
        if m.movieListScreen.visible = true then m.movieListScreen.callFunc("setMovies", m.movies)
    else if m.movieListScreen.visible = true then
        m.movieListScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
        m.movieListScreen.callFunc("focusCategories")
    end if
end sub

sub onSeriesCategoriesResult(result as Object)
    stopSeriesOpenTimeout()
    m.seriesCategoriesLoading = false
    if m.seriesHomeScreen.visible = true then m.seriesHomeScreen.callFunc("setLoading", false)
    if result.success = true then
        m.seriesCategories = normalizeSeriesCategories(result.data)
        m.searchIndexCache.seriesCategories = m.seriesCategories
        SaveSearchIndexCache(m.searchIndexCache)
        if m.seriesHomeScreen.visible = true then
            m.seriesHomeScreen.callFunc("setCategories", m.seriesCategories)
            m.seriesHomeScreen.callFunc("showMessage", "Escolha uma categoria para carregar as séries.")
        end if
    else if m.seriesHomeScreen.visible = true then
        m.seriesHomeScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
    end if
end sub

sub onSeriesResult(result as Object)
    if isSeriesInfoResult(result) then
        onSeriesInfoResult(result)
        return
    end if
    resultCategoryId = getSeriesResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedSeriesCategoryId then return
    stopSeriesOpenTimeout()
    m.seriesLoading = false
    if m.seriesHomeScreen.visible = true then m.seriesHomeScreen.callFunc("setLoading", false)
    if result.success = true then
        m.cachedSeries = replaceCachedCategoryItems(m.cachedSeries, normalizeSeries(result.data), resultCategoryId)
        m.searchIndexCache.series = m.cachedSeries
        m.seriesSearchIndex = BuildSeriesSearchIndexItems(m.cachedSeries, "")
        m.searchIndexCache.seriesSearchIndex = m.seriesSearchIndex
        SaveSearchIndexCache(m.searchIndexCache)
        m.series = filterItemsByCategory(m.cachedSeries, m.selectedSeriesCategoryId)
        if m.seriesHomeScreen.visible = true then m.seriesHomeScreen.callFunc("setSeries", m.series)
    else if m.seriesHomeScreen.visible = true then
        m.seriesHomeScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
    end if
end sub

sub onSeriesInfoResult(result as Object)
    stopDetailTimeout("series")
    if result.success = true then
        if m.cachedSeriesInfo = invalid then m.cachedSeriesInfo = {}
        seriesId = getSeriesInfoResultSeriesId(result)
        if seriesId <> "" then
            m.cachedSeriesInfo[seriesId] = result.data
            m.searchIndexCache.seriesInfo = m.cachedSeriesInfo
            SaveSearchIndexCache(m.searchIndexCache)
        end if
        if m.seriesDetailScreen.visible = true then m.seriesDetailScreen.callFunc("setDetails", result.data)
    else
        showSeriesInfoFailure("Não foi possível carregar os detalhes desta série. Pressione Voltar.")
    end if
end sub

sub showSeriesInfoFailure(message as String)
    if m.seriesDetailScreen.visible = true then
        m.seriesDetailScreen.callFunc("setLoading", false)
        m.seriesDetailScreen.callFunc("showMessage", message)
    end if
end sub

sub onLiveStreamUrlResult(result as Object)
    if m.livePlayerScreen.visible <> true then return
    if result = invalid or result.data = invalid then return
    if result.data.streamId <> invalid and result.data.streamId.ToStr() <> getStreamId(m.selectedLiveChannel) then return

    if result.success = true and result.data.url <> invalid then
        m.livePlayerScreen.callFunc("play", result.data.url)
    else
        m.livePlayerScreen.callFunc("showError", "Não foi possível preparar a reprodução deste canal.")
    end if
end sub

sub onMovieStreamUrlResult(result as Object)
    if m.moviePlayerScreen.visible <> true then return
    if result.success = true and result.data <> invalid and result.data.url <> invalid then
        m.moviePlayerScreen.callFunc("play", result.data.url)
    else
        m.moviePlayerScreen.callFunc("showError", "Não foi possível preparar a reprodução deste filme.")
    end if
end sub

sub onSeriesStreamUrlResult(result as Object)
    if m.seriesPlayerScreen.visible <> true then return
    if result.success = true and result.data <> invalid and result.data.url <> invalid then
        m.seriesPlayerScreen.callFunc("play", result.data.url)
    else
        m.seriesPlayerScreen.callFunc("showError", "Não foi possível preparar a reprodução deste episódio.")
    end if
end sub

sub onMovieInfoResult(result as Object)
    stopDetailTimeout("movie")
    if m.movieDetailScreen.visible <> true then return
    if result.success = true then
        m.movieDetailScreen.callFunc("setDetails", result.data)
    else
        m.movieDetailScreen.callFunc("setLoading", false)
        m.movieDetailScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
    end if
end sub

function isMovieInfoResult(result as Dynamic) as Boolean
    if result = invalid or result.request = invalid then return false
    prefix = "getMovieInfo"
    return Left(result.request.ToStr(), Len(prefix)) = prefix
end function

function isSeriesInfoResult(result as Dynamic) as Boolean
    if result = invalid or result.request = invalid then return false
    request = result.request.ToStr()
    prefix = "getSeriesInfo"
    return Left(request, Len(prefix)) = prefix
end function

function getSeriesInfoResultSeriesId(result as Dynamic) as String
    if result = invalid or result.request = invalid then return ""
    request = result.request.ToStr()
    prefix = "getSeriesInfo:"
    if Left(request, Len(prefix)) = prefix then return Mid(request, Len(prefix) + 1)
    return ""
end function

function getSeriesResultCategoryId(result as Dynamic) as String
    if result = invalid or result.request = invalid then return ""
    request = result.request.ToStr()
    prefix = "getSeries:"
    if Left(request, Len(prefix)) = prefix then return Mid(request, Len(prefix) + 1)
    return ""
end function

function normalizeSeries(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

function normalizeSeriesCategories(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

function normalizeSeriesSeasons(data as Dynamic) as Object
    if data = invalid or Type(data) <> "roAssociativeArray" then return []

    episodesBySeason = invalid
    if data.DoesExist("episodes") and data.episodes <> invalid and Type(data.episodes) = "roAssociativeArray" then
        episodesBySeason = data.episodes
    end if

    normalizedSeasons = []
    if data.DoesExist("seasons") and data.seasons <> invalid and Type(data.seasons) = "roArray" then
        for each season in data.seasons
            if season <> invalid and Type(season) = "roAssociativeArray" then
                normalizedSeason = season
            else
                normalizedSeason = {}
            end if
            seasonNumber = getSeasonNumber(normalizedSeason)
            seasonEpisodes = getEpisodesForSeason(episodesBySeason, seasonNumber)
            if seasonEpisodes.Count() > 0 then
                normalizedSeason.episodes = seasonEpisodes
                normalizedSeasons.Push(normalizedSeason)
            else if seasonNumber <> "" then
                normalizedSeason.episodes = []
                normalizedSeasons.Push(normalizedSeason)
            end if
        end for
    end if

    if normalizedSeasons.Count() = 0 and episodesBySeason <> invalid then
        for each seasonKey in episodesBySeason
            seasonEpisodes = getEpisodesForSeason(episodesBySeason, seasonKey)
            if seasonEpisodes.Count() > 0 then
                normalizedSeasons.Push({
                    name: "Temporada " + seasonKey.ToStr(),
                    title: "Temporada " + seasonKey.ToStr(),
                    season_number: seasonKey.ToStr(),
                    episodes: seasonEpisodes
                })
            end if
        end for
    end if

    return sortSeasons(normalizedSeasons)
end function

function getEpisodesForSeason(episodesBySeason as Dynamic, seasonNumber as Dynamic) as Object
    if episodesBySeason = invalid or Type(episodesBySeason) <> "roAssociativeArray" then return []

    key = safeText(seasonNumber)
    if key = "" then return []
    if episodesBySeason.DoesExist(key) and Type(episodesBySeason[key]) = "roArray" then return episodesBySeason[key]

    numericKey = key
    while Len(numericKey) > 1 and Left(numericKey, 1) = "0"
        numericKey = Mid(numericKey, 2)
    end while
    if numericKey <> key and episodesBySeason.DoesExist(numericKey) and Type(episodesBySeason[numericKey]) = "roArray" then return episodesBySeason[numericKey]

    paddedKey = key
    if Len(paddedKey) = 1 then paddedKey = "0" + paddedKey
    if paddedKey <> key and episodesBySeason.DoesExist(paddedKey) and Type(episodesBySeason[paddedKey]) = "roArray" then return episodesBySeason[paddedKey]

    return []
end function

function safeText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr().Trim()
end function

function getSeasonEpisodes(season as Dynamic) as Object
    if season <> invalid and Type(season) = "roAssociativeArray" and season.DoesExist("episodes") and Type(season.episodes) = "roArray" then return sortEpisodes(season.episodes)
    return []
end function

function getSeriesId(series as Dynamic) as String
    if series = invalid or Type(series) <> "roAssociativeArray" then return ""
    if series.DoesExist("series_id") and series.series_id <> invalid then return series.series_id.ToStr()
    if series.DoesExist("id") and series.id <> invalid then return series.id.ToStr()
    return ""
end function

function getSeasonNumber(season as Dynamic) as String
    if season = invalid or Type(season) <> "roAssociativeArray" then return ""
    if season.DoesExist("season_number") and season.season_number <> invalid then return season.season_number.ToStr()
    if season.DoesExist("number") and season.number <> invalid then return season.number.ToStr()
    return ""
end function

function getEpisodeId(episode as Dynamic) as String
    if episode = invalid or Type(episode) <> "roAssociativeArray" then return ""
    if episode.DoesExist("id") and episode.id <> invalid then return episode.id.ToStr()
    if episode.DoesExist("episode_id") and episode.episode_id <> invalid then return episode.episode_id.ToStr()
    return getStreamId(episode)
end function

function getSeriesStreamExtension(episode as Dynamic) as String
    if episode = invalid then return "mp4"
    if episode.container_extension <> invalid and episode.container_extension.ToStr().Trim() <> "" then return episode.container_extension.ToStr()
    if episode.info <> invalid and episode.info.container_extension <> invalid and episode.info.container_extension.ToStr().Trim() <> "" then return episode.info.container_extension.ToStr()
    return "mp4"
end function

function getMoviesResultCategoryId(result as Dynamic) as String
    if result = invalid or result.request = invalid then return ""

    request = result.request.ToStr()
    prefix = "getMovies:"
    if Left(request, Len(prefix)) = prefix then return Mid(request, Len(prefix) + 1)
    return ""
end function

function getMovieStreamExtension(movie as Dynamic) as String
    if movie = invalid then return "mp4"
    if movie.container_extension <> invalid and movie.container_extension.ToStr().Trim() <> "" then return movie.container_extension.ToStr()
    return "mp4"
end function

function normalizeMovies(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

function normalizeMovieCategories(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

function isValidXtreamConnectionResult(result as Dynamic) as Boolean
    if result = invalid then return false
    if result.success <> true or result.connected <> true then return false
    if result.data = invalid then return false
    if Type(result.data) <> "roAssociativeArray" then return false
    userInfo = result.data.user_info
    if userInfo = invalid then return false
    if Type(userInfo) <> "roAssociativeArray" then return false
    return true
end function

function getResultMessage(result as Dynamic) as String
    if result <> invalid and result.message <> invalid and result.message.ToStr().Trim() <> "" then
        return result.message.ToStr()
    end if
    return "Não foi possível conectar ao servidor."
end function

function getStreamId(channel as Dynamic) as String
    if channel = invalid then return ""
    if channel.stream_id <> invalid then return channel.stream_id.ToStr()
    if channel.id <> invalid then return channel.id.ToStr()
    return ""
end function

function getLiveStreamsResultCategoryId(result as Dynamic) as String
    if result = invalid or result.request = invalid then return ""

    request = result.request.ToStr()
    prefix = "getLiveStreams:"
    if Left(request, Len(prefix)) = prefix then return Mid(request, Len(prefix) + 1)
    return ""
end function

function getStreamExtension(channel as Dynamic) as String
    if channel = invalid then return "ts"
    if channel.container_extension <> invalid and channel.container_extension.ToStr().Trim() <> "" then return channel.container_extension.ToStr()
    if channel.stream_type <> invalid and LCase(channel.stream_type.ToStr()) = "m3u8" then return "m3u8"
    return "ts"
end function

function normalizeLiveChannels(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

function getCategoryId(category as Dynamic) as String
    if category = invalid then return ""
    if category.category_id <> invalid then return category.category_id.ToStr()
    if category.id <> invalid then return category.id.ToStr()
    return ""
end function

function normalizeLiveCategories(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

sub updateConnectionStatus(connected as Boolean, message as String)
    m.homeScreen.callFunc("updateConnectionStatus", {
        connected: connected,
        message: message
    })
end sub

function hasAccount(account as Dynamic) as Boolean
    if account = invalid then return false
    return safeText(account.dns) <> "" and safeText(account.username) <> "" and safeText(account.password) <> ""
end function



function sortSeasons(items as Object) as Object
    sorted = []
    for each item in items
        insertSorted(sorted, item, "season")
    end for
    return sorted
end function

function sortEpisodes(items as Object) as Object
    sorted = []
    for each item in items
        insertSorted(sorted, item, "episode")
    end for
    return sorted
end function

sub insertSorted(sorted as Object, item as Object, kind as String)
    insertAt = sorted.Count()
    for i = 0 to sorted.Count() - 1
        if compareNumberedItems(item, sorted[i], kind) < 0 then
            insertAt = i
            exit for
        end if
    end for
    sorted.Insert(insertAt, item)
end sub

function compareNumberedItems(left as Dynamic, right as Dynamic, kind as String) as Integer
    leftNumber = sortableNumber(left, kind)
    rightNumber = sortableNumber(right, kind)
    if leftNumber >= 0 and rightNumber >= 0 then
        if leftNumber < rightNumber then return -1
        if leftNumber > rightNumber then return 1
    else if leftNumber >= 0 then
        return -1
    else if rightNumber >= 0 then
        return 1
    end if
    leftName = LCase(sortableName(left, kind))
    rightName = LCase(sortableName(right, kind))
    if leftName < rightName then return -1
    if leftName > rightName then return 1
    return 0
end function

function sortableNumber(item as Dynamic, kind as String) as Integer
    value = ""
    if item <> invalid then
        if kind = "season" then
            if item.season_number <> invalid then value = item.season_number.ToStr()
            if value = "" and item.number <> invalid then value = item.number.ToStr()
        else
            if item.episode_num <> invalid then value = item.episode_num.ToStr()
            if value = "" and item.episode_number <> invalid then value = item.episode_number.ToStr()
            if value = "" and item.num <> invalid then value = item.num.ToStr()
        end if
    end if
    value = value.Trim()
    if value = "" then return -1
    return Val(value)
end function

function sortableName(item as Dynamic, kind as String) as String
    if item = invalid then return ""
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return ""
end function
