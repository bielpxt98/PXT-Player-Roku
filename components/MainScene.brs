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
    m.seriesSearchScreen = m.top.findNode("SeriesSearchScreen")
    m.liveCategoriesScreen = m.top.FindNode("liveCategoriesScreen")
    m.liveChannelsScreen = m.top.FindNode("liveChannelsScreen")
    m.livePlayerScreen = m.top.FindNode("livePlayerScreen")
    m.movieCategoriesScreen = m.top.FindNode("movieCategoriesScreen")
    m.movieListScreen = m.top.FindNode("movieListScreen")
    m.movieDetailScreen = m.top.FindNode("movieDetailScreen")
    m.moviePlayerScreen = m.top.FindNode("moviePlayerScreen")
    m.simpleSeriesScreen = m.top.FindNode("simpleSeriesScreen")
    m.seriesDetailsScreen = m.top.FindNode("seriesDetailsScreen")
    m.seriesPlayerScreen = m.top.FindNode("seriesPlayerScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.loginTimeoutTimer = m.top.FindNode("loginTimeoutTimer")
    m.detailTimeoutTimer = m.top.FindNode("detailTimeoutTimer")
    m.autoConnectTimer = m.top.FindNode("autoConnectTimer")
    m.searchIndexTimer = m.top.FindNode("searchIndexTimer")
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
    m.isDemoMode = false
    m.loginErrorActive = false
    m.liveCategories = []
    m.liveCategoriesLoading = false
    m.liveChannels = []
    m.liveChannelsLoading = false
    m.selectedLiveCategory = invalid
    m.selectedLiveCategoryId = ""
    m.selectedLiveChannel = invalid
    m.liveChannelsRestoreState = invalid
    m.movieCategories = []
    m.movieCategoriesLoading = false
    m.movies = []
    m.moviesLoading = false
    m.selectedMovieCategory = invalid
    m.selectedMovieCategoryId = ""
    m.selectedMovie = invalid
    m.openedFromFavorites = false
    m.openedFromSearch = false
    m.openedFromRecent = false
    m.searchChannels = []
    m.searchMovies = []
    m.searchLoadStep = ""
    m.searchIndexCache = LoadSearchIndexCache()
    m.movieSearchIndex = m.searchIndexCache.movieSearchIndex
    m.cachedMovies = m.searchIndexCache.movies
    m.cachedSeries = m.searchIndexCache.series
    m.seriesCategories = m.searchIndexCache.seriesCategories
    m.movieCategoryPreviewCache = m.searchIndexCache.movieCategoryPreviewCache
    m.seriesCategoryPreviewCache = m.searchIndexCache.seriesCategoryPreviewCache
    m.cachedLiveChannels = m.searchIndexCache.liveChannels
    m.searchIndexQueue = []
    m.searchIndexKind = ""
    m.searchIndexCategoryId = ""
    m.previewQueue = []
    m.previewUpdating = false
    m.previewKind = ""
    m.previewCategory = invalid
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
    m.lastMovieCategory = invalid
    m.lastMovieList = invalid
    m.lastMovieIndex = 0
    m.lastMovieFirstVisibleIndex = 0
    m.returnFromMoviePlayer = false
    m.entryPoint = ""
    m.isReturningFromPlayer = false
    if m.cachedMovies = invalid then m.cachedMovies = []
    if m.cachedSeries = invalid then m.cachedSeries = []
    if m.seriesCategories = invalid then m.seriesCategories = []
    if m.cachedLiveChannels = invalid then m.cachedLiveChannels = []
    if m.movieCategoryPreviewCache = invalid then m.movieCategoryPreviewCache = []
    if m.seriesCategoryPreviewCache = invalid then m.seriesCategoryPreviewCache = []

    configureScene()

    m.homeScreen.ObserveField("openPlaylist", "onOpenPlaylistRequested")
    m.homeScreen.ObserveField("openLiveCategories", "onOpenLiveCategoriesRequested")
    m.homeScreen.ObserveField("openMovieCategories", "onOpenMovieCategoriesRequested")
    m.homeScreen.ObserveField("openSeriesCategories", "onOpenSeriesRequested")
    m.searchScreen.ObserveField("backRequested", "onSearchBack")
    m.searchScreen.ObserveField("channelSelected", "onSearchChannelSelected")
    m.searchScreen.ObserveField("movieSelected", "onSearchMovieSelected")
    m.searchScreen.ObserveField("seriesSelected", "onSearchSeriesSelected")
    m.movieSearchScreen.ObserveField("backRequested", "onMovieSearchBack")
    m.movieSearchScreen.ObserveField("movieSelected", "onMovieSearchMovieSelected")
    if m.seriesSearchScreen <> invalid then
        m.seriesSearchScreen.ObserveField("backRequested", "onSeriesSearchBack")
        m.seriesSearchScreen.ObserveField("seriesSelected", "onSeriesSearchSeriesSelected")
    end if
    m.recentScreen.ObserveField("backRequested", "onRecentBack")
    m.recentScreen.ObserveField("historySelected", "onHistorySelected")
    m.favoritesScreen.ObserveField("backRequested", "onFavoritesBack")
    m.favoritesScreen.ObserveField("favoriteSelected", "onFavoriteSelected")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")
    m.loginScreen.ObserveField("demoRequested", "onDemoRequested")
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
    m.simpleSeriesScreen.ObserveField("backRequested", "onSimpleSeriesBack")
    m.simpleSeriesScreen.ObserveField("seriesSelected", "onSeriesSelected")
    m.simpleSeriesScreen.ObserveField("categorySelected", "onSeriesCategorySelected")
    m.simpleSeriesScreen.ObserveField("searchRequested", "onSeriesSearchRequested")
    m.seriesDetailsScreen.ObserveField("backRequested", "onSeriesDetailsBack")
    m.seriesDetailsScreen.ObserveField("episodeSelected", "onSeriesEpisodeSelected")
    m.seriesPlayerScreen.ObserveField("backRequested", "onSeriesPlayerBack")
    m.xtreamService.ObserveField("result", "onXtreamConnectionResult")
    m.loginTimeoutTimer.ObserveField("fire", "onLoginTimeout")
    m.detailTimeoutTimer.ObserveField("fire", "onDetailTimeout")
    m.autoConnectTimer.ObserveField("fire", "onAutoConnectTimerFire")
    m.searchIndexTimer.ObserveField("fire", "onSearchIndexTimerFire")
    m.splashMinimumTimer.ObserveField("fire", "onSplashMinimumElapsed")
    m.splashMaximumTimer.ObserveField("fire", "onSplashMaximumElapsed")

    startInitialFlow()
end sub

sub startInitialFlow()
    m.localFavoritesCache = LoadFavorites()
    m.localHistoryCache = LoadViewingHistory()

    if hasAccount(m.account) then
        m.isDemoMode = false
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
    end if

    focusActiveScreen()
    return false
end function

function closeActivePlayerScreen() as Boolean
    if m.moviePlayerScreen <> invalid and m.moviePlayerScreen.visible = true then
        onMoviePlayerBack()
        return true
    else if m.livePlayerScreen <> invalid and m.livePlayerScreen.visible = true then
        onLivePlayerBack()
        return true
    end if

    return false
end function

sub focusActiveScreen()
    screens = [m.homeScreen, m.loginScreen, m.favoritesScreen, m.recentScreen, m.searchScreen, m.movieSearchScreen, m.seriesSearchScreen, m.liveChannelsScreen, m.movieListScreen, m.movieDetailScreen, m.simpleSeriesScreen, m.seriesDetailsScreen]
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
    screens = [m.homeScreen, m.loginScreen, m.favoritesScreen, m.recentScreen, m.searchScreen, m.movieSearchScreen, m.seriesSearchScreen, m.liveCategoriesScreen, m.liveChannelsScreen, m.livePlayerScreen, m.movieCategoriesScreen, m.movieListScreen, m.movieDetailScreen, m.moviePlayerScreen, m.simpleSeriesScreen, m.seriesDetailsScreen]
    for each screen in screens
        if screen <> invalid and screen.id <> visibleId then screen.callFunc("hide")
    end for
end sub

function isValidAccount(account as Dynamic) as Boolean
    return hasAccount(account)
end function

sub runXtreamRequest(action as String, categoryId as String)
end sub

sub showHome()
    if m.splashScreen <> invalid then m.splashScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.seriesSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.simpleSeriesScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("hide")
    m.homeScreen.callFunc("show")
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.seriesSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.simpleSeriesScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("hide")
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
    m.simpleSeriesScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("hide")
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
        m.simpleSeriesScreen.callFunc("show")
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

sub onSeriesSearchRequested()
    m.simpleSeriesScreen.callFunc("hide")
    m.searchBackTarget = "series"
    m.seriesSearchScreen.callFunc("show")
    seriesSearchData = getSeriesForSearch()
    m.seriesSearchScreen.callFunc("setSeries", seriesSearchData)
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

sub onSeriesSearchBack()
    m.seriesSearchScreen.callFunc("hide")
    m.simpleSeriesScreen.callFunc("show")
end sub

sub onSeriesSearchSeriesSelected()
    series = m.seriesSearchScreen.seriesSelected
    if series = invalid then return
    m.selectedSeries = series
    m.openedFromSearch = true
    m.seriesSearchScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("show", series)
    m.seriesDetailsScreen.callFunc("setDetails", series)
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

function getSeriesForSearch() as Object
    if m.cachedSeries <> invalid then return m.cachedSeries
    return []
end function

function getSearchDataForMode(mode as String) as Object
    channels = m.cachedLiveChannels
    movies = m.movieSearchIndex
    series = m.cachedSeries
    if mode = "live" and m.liveChannels <> invalid and m.liveChannels.Count() > 0 then channels = m.liveChannels
    return { channels: channels, movies: movies, series: series }
end function

function needsSearchData(mode as String) as Boolean
    if mode = "live" then return m.searchChannels.Count() = 0
    if mode = "movies" then return m.searchMovies.Count() = 0
    if mode = "series" then return false
    return m.searchChannels.Count() = 0 or m.searchMovies.Count() = 0
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
    hideAllScreensExcept(m.moviePlayerScreen)
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
    m.seriesDetailsScreen.callFunc("show", series)
    m.seriesDetailsScreen.callFunc("setDetails", series)
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



sub onRecentBack()
    showHome()
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
        hideAllScreensExcept(m.moviePlayerScreen)
        m.moviePlayerScreen.callFunc("show", item.content)
        m.moviePlayerScreen.callFunc("setResumePosition", item.position)
        buildMovieStreamUrl(item.content)
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
        hideAllScreensExcept(m.moviePlayerScreen)
        m.moviePlayerScreen.callFunc("show", content)
        m.moviePlayerScreen.callFunc("setResumePosition", GetHistoryPosition("movie", content))
        buildMovieStreamUrl(content)
    end if
end sub

sub onLiveChannelFavoriteToggled()
    ToggleFavorite("live", m.liveChannelsScreen.channelFavoriteToggled)
end sub

sub onMovieFavoriteToggled()
    ToggleFavorite("movie", m.movieListScreen.movieFavoriteToggled)
end sub


sub onOpenFavoritesRequested()
    m.homeScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.favoritesScreen.callFunc("show")
    m.favoritesScreen.callFunc("setFavorites", LoadFavorites())
end sub

sub onOpenRecentRequested()
    m.homeScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("show")
    m.recentScreen.callFunc("setHistory", LoadViewingHistory())
end sub

sub onOpenPlaylistRequested()
    if m.isDemoMode = true then
        m.account = invalid
        m.isDemoMode = false
        resetAccountLoadedData()
        updateConnectionStatus(false, "Nenhuma playlist conectada")
    end if
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
    m.seriesSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.simpleSeriesScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("resetSelection")
    m.liveChannelsScreen.callFunc("setAccount", m.account)
    m.liveChannelsScreen.callFunc("show", invalid)
    m.liveChannelsScreen.callFunc("focusCategories")

    if m.isDemoMode = true then
        m.liveChannelsScreen.callFunc("setCategories", m.liveCategories)
        m.liveChannelsScreen.callFunc("showMessage", "Escolha uma categoria demo para carregar os canais.")
        m.liveChannelsScreen.callFunc("focusCategories")
    else if not hasAccount(m.account) then
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
    m.seriesSearchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.simpleSeriesScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("hide")
    m.movieListScreen.callFunc("resetSelection")
    m.movieListScreen.callFunc("show", invalid)
    m.movieListScreen.callFunc("focusCategories")

    if m.isDemoMode = true then
        m.movieListScreen.callFunc("setCategories", m.movieCategories)
        m.movieListScreen.callFunc("showMessage", "Escolha uma categoria demo para carregar os filmes.")
        m.movieListScreen.callFunc("focusCategories")
    else if not hasAccount(m.account) then
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
    m.isDemoMode = false
    account = m.loginScreen.submit
    if not hasAccount(account) then
        stopLoginTimeout()
        cancelXtreamRequest()
        m.pendingAccount = invalid
        m.loginFormAccount = invalid
        m.loginConnecting = false
        m.isConnecting = false
        m.connectionMode = ""
        m.isDemoMode = false
        m.loginErrorActive = false
        m.account = invalid
        DeleteSavedPlaylist()
        resetAccountLoadedData()
        updateConnectionStatus(false, "Nenhuma playlist conectada")
        showHome()
        return
    end if

    m.pendingAccount = account
    m.loginFormAccount = account
    m.loginConnecting = true
    m.loginErrorActive = false
    m.connectionMode = "manual"

    m.loginScreen.callFunc("showMessage", "Tentando conectar...")
    m.loginScreen.callFunc("setLoading", true)
    updateConnectionStatus(false, "Conectando...")
    startLoginTimeout()
    connectXtream(account)
end sub


sub onDemoRequested()
    demo = CreateDemoData()
    m.isDemoMode = true
    m.account = demo.account
    m.pendingAccount = invalid
    m.loginFormAccount = invalid
    m.loginConnecting = false
    m.isConnecting = false
    m.connectionMode = ""
    m.loginErrorActive = false
    stopLoginTimeout()
    cancelXtreamRequest()
    m.liveCategories = demo.liveCategories
    m.cachedLiveChannels = demo.liveChannels
    m.liveChannels = []
    m.movieCategories = demo.movieCategories
    m.cachedMovies = demo.movies
    m.movies = []
    m.cachedSeries = demo.series
    m.seriesCategories = demo.seriesCategories
    m.searchIndexCache = createEmptySearchIndexCache()
    m.searchIndexCache.liveCategories = m.liveCategories
    m.searchIndexCache.liveChannels = m.cachedLiveChannels
    m.searchIndexCache.movieCategories = m.movieCategories
    m.searchIndexCache.movies = m.cachedMovies
    m.searchIndexCache.series = m.cachedSeries
    m.searchIndexCache.seriesCategories = m.seriesCategories
    m.movieSearchIndex = BuildMovieSearchIndexItems(m.cachedMovies, "")
    m.searchIndexCache.movieSearchIndex = m.movieSearchIndex
    updateConnectionStatus(true, "Modo Demo")
    showHome()
end sub

sub onLoginBack()
    stopLoginTimeout()
    m.loginConnecting = false
    m.isConnecting = false
    m.connectionMode = ""
    m.isDemoMode = false
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
    if isFavoritesCategory(category) then
        showFavoriteMoviesInMovieList()
        return
    else if isRecentCategory(category) then
        showRecentMoviesInMovieList()
        return
    end if
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
    m.lastMovieCategory = m.selectedMovieCategory
    m.lastMovieList = m.currentMovieList
    if m.lastMovieList = invalid then
        m.lastMovieList = m.movies
    else if m.lastMovieList.Count() = 0 then
        m.lastMovieList = m.movies
    end if
    m.lastMovieIndex = m.movieListScreen.callFunc("getSelectedIndex")
    m.lastMovieFirstVisibleIndex = m.movieListScreen.callFunc("getFirstVisibleIndex")
    m.returnFromMoviePlayer = true
    m.movieListRestoreState = m.movieListScreen.callFunc("getState")
    m.currentMovieList = m.lastMovieList
    m.entryPoint = "movies"
    if m.movieListRestoreState <> invalid then
        m.movieListSelectedIndex = m.movieListRestoreState.selectedIndex
        m.movieListFirstVisibleIndex = m.movieListRestoreState.firstVisibleRow
    end if
    if getStreamId(m.selectedMovie) = "" then
        m.movieDetailScreen.callFunc("setLoading", false)
        return
    end if
    hideAllScreensExcept(m.moviePlayerScreen)
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

    PRINT "MOVIE_PLAYER_BACK"
    PRINT "return category valid="; m.lastMovieCategory <> invalid
    PRINT "return list valid="; m.lastMovieList <> invalid
    PRINT "return index="; m.lastMovieIndex

    ' Temporarily do not persist movie history while isolating the BACK crash.
    ' position = 0
    ' if m.moviePlayerScreen <> invalid then position = m.moviePlayerScreen.callFunc("getPlaybackPosition")
    ' UpsertMovieHistory(m.selectedMovie, position)

    if m.moviePlayerScreen <> invalid then
        m.moviePlayerScreen.callFunc("hide")
        m.moviePlayerScreen.SetFocus(false)
    end if

    if m.lastMovieCategory <> invalid and m.lastMovieList <> invalid then
        hideAllScreensExcept(m.movieListScreen)
        m.selectedMovieCategory = m.lastMovieCategory
        m.selectedMovieCategoryId = getCategoryId(m.lastMovieCategory)
        m.movies = m.lastMovieList
        m.currentMovieList = m.lastMovieList
        m.movieListScreen.callFunc("show", m.lastMovieCategory)
        m.movieListScreen.callFunc("setMovies", m.lastMovieList)
        m.movieListScreen.callFunc("restoreMovieSelection", m.lastMovieIndex, m.lastMovieFirstVisibleIndex)
        m.activePanel = "movies"
        m.movieListScreen.SetFocus(true)
    else if m.movieCategoriesScreen <> invalid then
        hideAllScreensExcept(m.movieCategoriesScreen)
        m.movieCategoriesScreen.callFunc("show")
        m.movieCategoriesScreen.SetFocus(true)
    else if m.movieListScreen <> invalid then
        hideAllScreensExcept(m.movieListScreen)
        if m.selectedMovieCategory <> invalid then m.movieListScreen.callFunc("show", m.selectedMovieCategory)
        m.movieListScreen.SetFocus(true)
    else
        showHome()
    end if

    m.movieListRestoreState = invalid
    m.returnFromMoviePlayer = false
    m.openedFromFavorites = false
    m.openedFromRecent = false
    m.openedFromSearch = false
    m.isReturningFromPlayer = false
end sub

sub returnToSafeMovieDestination()
    ' Leaving the movie player must only land on the movie catalog/list or Home.
    ' Hide detail/search/series/live surfaces first so a stale focused screen
    ' cannot consume the same BACK event and navigate somewhere unexpected.
    m.movieDetailScreen.callFunc("hide")
    m.movieSearchScreen.callFunc("hide")
    m.seriesSearchScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.simpleSeriesScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")

    if m.selectedMovieCategory <> invalid and m.currentMovieList <> invalid then
        m.movieCategoriesScreen.callFunc("hide")
        m.movieListScreen.callFunc("show", m.selectedMovieCategory)
        if m.currentMovieList.Count() > 0 then m.movieListScreen.callFunc("setMovies", m.currentMovieList)
        if m.movieListRestoreState <> invalid then m.movieListScreen.callFunc("restoreState", m.movieListRestoreState)
        m.movieListScreen.SetFocus(true)
    else
        showHome()
    end if
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
    m.liveChannelsRestoreState = m.liveChannelsScreen.callFunc("getState")
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
        if m.liveChannels <> invalid and m.liveChannels.Count() > 0 then m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
        if m.liveChannelsRestoreState <> invalid then m.liveChannelsScreen.callFunc("restoreState", m.liveChannelsRestoreState)
        m.liveChannelsScreen.SetFocus(true)
    end if

    m.liveChannelsRestoreState = invalid
end sub

sub buildLiveStreamUrl(channel as Object)
    directUrl = getDirectUrl(channel)
    if directUrl = "" and m.isDemoMode = true then directUrl = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    if directUrl <> "" then
        m.livePlayerScreen.callFunc("play", directUrl)
        return
    end if
    cancelBlockingRequestForPlayback()
    if not beginXtreamRequest("buildLiveStreamUrl") then return
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "buildLiveStreamUrl"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.streamId = getStreamId(channel)
    m.xtreamService.streamExtension = getStreamExtension(channel)
    if not hasAccount(m.account) then
        m.livePlayerScreen.callFunc("play", "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")
        return
    end if
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
    directUrl = getDirectUrl(movie)
    if directUrl <> "" then
        m.moviePlayerScreen.callFunc("play", directUrl)
        return
    end if
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
    if m.isDemoMode = true then return
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
    if m.isDemoMode = true then
        m.movies = filterItemsByCategory(m.cachedMovies, getCategoryId(category))
        m.moviesLoading = false
        m.movieListScreen.callFunc("setLoading", false)
        m.movieListScreen.callFunc("setMovies", m.movies)
        return
    end if
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
    if m.isDemoMode = true then return
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
    if m.isDemoMode = true then
        m.liveChannels = filterItemsByCategory(m.cachedLiveChannels, getCategoryId(category))
        m.liveChannelsLoading = false
        m.liveChannelsScreen.callFunc("setLoading", false)
        m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
        return
    end if
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
    if m.isDemoMode = true then return
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


sub showFavoriteMoviesInMovieList()
    m.selectedMovieCategory = { category_name: "FAVORITOS", name: "FAVORITOS", isFavorites: true }
    m.selectedMovieCategoryId = ""
    m.movies = favoriteContents(LoadFavorites().movies)
    m.moviesLoading = false
    m.movieListScreen.callFunc("setLoading", false)
    m.movieListScreen.callFunc("setMovies", m.movies)
end sub

sub showRecentMoviesInMovieList()
    m.selectedMovieCategory = { category_name: "ÚLTIMOS ASSISTIDOS", name: "ÚLTIMOS ASSISTIDOS", isRecent: true }
    m.selectedMovieCategoryId = ""
    history = LoadViewingHistory()
    m.movies = historyContents(history.movies, "content")
    m.moviesLoading = false
    m.movieListScreen.callFunc("setLoading", false)
    m.movieListScreen.callFunc("setMovies", m.movies)
end sub




function favoriteContents(items as Dynamic) as Object
    contents = []
    if items = invalid or Type(items) <> "roArray" then return contents
    for each item in items
        if item <> invalid and item.content <> invalid then contents.Push(item.content)
    end for
    return contents
end function

function historyContents(items as Dynamic, contentField as String) as Object
    contents = []
    if items = invalid or Type(items) <> "roArray" then return contents
    for each item in items
        if item <> invalid then
            if contentField = "series" and item.series <> invalid then
                contents.Push(item.series)
            else if item.content <> invalid then
                contents.Push(item.content)
            end if
        end if
    end for
    return contents
end function

function historyContentsWithProgress(items as Dynamic, contentField as String) as Object
    contents = []
    if items = invalid or Type(items) <> "roArray" then return contents
    for each item in items
        if item <> invalid and item.position <> invalid and item.position > 0 then
            if contentField = "series" and item.series <> invalid then
                contents.Push(item.series)
            else if item.content <> invalid then
                contents.Push(item.content)
            end if
        end if
    end for
    return contents
end function

function isFavoritesCategory(category as Dynamic) as Boolean
    return category <> invalid and category.isFavorites = true
end function

function isRecentCategory(category as Dynamic) as Boolean
    return category <> invalid and category.isRecent = true
end function

function isContinueCategory(category as Dynamic) as Boolean
    return category <> invalid and category.isContinue = true
end function

sub showMoviesFromCacheOrLoad(category as Object)
    categoryId = getCategoryId(category)
    cached = filterItemsByCategory(m.cachedMovies, categoryId)
    if cached.Count() > 0 then
        m.movies = cached
        m.moviesLoading = false
        m.movieListScreen.callFunc("setLoading", false)
        m.movieListScreen.callFunc("setMovies", m.movies)
        return
    end if
    preview = getPreviewItems(m.movieCategoryPreviewCache, categoryId)
    if preview.Count() > 0 then
        m.movies = preview
        m.movieListScreen.callFunc("setMovies", m.movies)
    end if
    m.moviesLoading = true
    m.movieListScreen.callFunc("setLoading", preview.Count() = 0)
    loadMovies(category)
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

    if handlePreviewCacheResult(result) then return
    if handleSearchIndexResult(result) then return

    if isMovieInfoResult(result) then
        onMovieInfoResult(result)
        return
    else if result.request = "getMovieCategories" then
        onMovieCategoriesResult(result)
        return
    else if result.request = "getSeriesCategories" then
        onSeriesCategoriesResult(result)
        return
    else if Left(result.request, 9) = "getMovies" then
        onMoviesResult(result)
        return
    else if Left(result.request, 9) = "getSeries" then
        onSeriesResult(result)
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
        m.loginScreen.callFunc("showMessage", "Login confirmado. Carregando...")
        showHome()
        startInitialCategoryPreviewCache()
    else
        SavePlaylistConnectionStatus("Desconectado")
        m.pendingAccount = invalid
        resetAccountLoadedData()
        if connectionMode = "auto" then
            m.loginErrorActive = false
            updateConnectionStatus(false, "Não foi possível reconectar. Abra CONTA para corrigir.")
            m.connectionMode = ""
            showHome()
        else
            m.loginErrorActive = true
            updateConnectionStatus(false, "Não foi possível conectar. Verifique os dados.")
            m.connectionMode = ""
            showLogin()
            if result <> invalid and result.message = "Tempo esgotado ao conectar." then
                m.loginScreen.callFunc("showError", "Tempo esgotado ao conectar.")
            else
                m.loginScreen.callFunc("showError", "Login inválido. Verifique DNS, usuário e senha.")
            end if
        end if
    end if
end sub

sub resetAccountLoadedData()
    m.searchIndexCache = createEmptySearchIndexCache()
    m.movieSearchIndex = []
    m.searchIndexQueue = []
    m.searchIndexUpdating = false
    m.previewQueue = []
    m.previewUpdating = false
    m.previewKind = ""
    m.previewCategory = invalid
    m.liveCategories = []
    m.liveChannels = []
    m.cachedLiveChannels = []
    m.liveCategoriesLoading = false
    m.liveChannelsLoading = false
    m.movieCategories = []
    m.movies = []
    m.cachedMovies = []
    m.movieCategoryPreviewCache = []
    m.seriesCategoryPreviewCache = []
    m.cachedSeries = []
    m.seriesCategories = []
    m.searchChannels = []
    m.searchMovies = []
    m.movieCategoriesLoading = false
    m.moviesLoading = false
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
    m.cachedMovies = m.searchIndexCache.movies
    m.cachedSeries = m.searchIndexCache.series
    m.seriesCategories = m.searchIndexCache.seriesCategories
    m.movieCategoryPreviewCache = m.searchIndexCache.movieCategoryPreviewCache
    m.seriesCategoryPreviewCache = m.searchIndexCache.seriesCategoryPreviewCache
    m.cachedLiveChannels = m.searchIndexCache.liveChannels
    if m.searchIndexCache.liveCategories.Count() > 0 then m.liveCategories = m.searchIndexCache.liveCategories
    if m.searchIndexCache.liveChannels.Count() > 0 then m.cachedLiveChannels = m.searchIndexCache.liveChannels
    if m.searchIndexCache.movieCategories.Count() > 0 then m.movieCategories = m.searchIndexCache.movieCategories
    if m.searchIndexCache.movies.Count() > 0 then m.cachedMovies = m.searchIndexCache.movies
    if m.searchIndexCache.seriesCategories.Count() > 0 then m.seriesCategories = m.searchIndexCache.seriesCategories
    if m.searchIndexCache.series.Count() > 0 then m.cachedSeries = m.searchIndexCache.series
    if m.searchIndexCache.movieCategoryPreviewCache <> invalid then m.movieCategoryPreviewCache = m.searchIndexCache.movieCategoryPreviewCache
    if m.searchIndexCache.seriesCategoryPreviewCache <> invalid then m.seriesCategoryPreviewCache = m.searchIndexCache.seriesCategoryPreviewCache
    m.movieSearchIndex = BuildMovieSearchIndexItems(m.cachedMovies, "")
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
    if m.isDemoMode = true then return
    if not hasAccount(m.account) then return
    if m.searchIndexUpdating = true then return
    m.searchIndexQueue = []
    if m.liveCategories = invalid or m.liveCategories.Count() = 0 then m.searchIndexQueue.Push({ action: "getLiveCategories", kind: "liveCategories", categoryId: "" })
    if m.cachedLiveChannels = invalid or m.cachedLiveChannels.Count() = 0 then m.searchIndexQueue.Push({ action: "getLiveStreams", kind: "live", categoryId: "" })
    if m.movieCategories = invalid or m.movieCategories.Count() = 0 then m.searchIndexQueue.Push({ action: "getMovieCategories", kind: "movieCategories", categoryId: "" })
    ' Do not load full movie/series catalogs into the registry; preview cache handles startup.
    m.searchIndexUpdating = true
    m.searchIndexTimer.control = "stop"
    m.searchIndexTimer.control = "start"
end sub

sub onSearchIndexTimerFire()
    if m.previewUpdating = true then
        processNextPreviewRequest()
    else
        processNextSearchIndexRequest()
    end if
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
        else if kind = "movies" then
            m.cachedMovies = normalizeMovies(result.data)
            m.searchIndexCache.movies = m.cachedMovies
            m.movieSearchIndex = BuildMovieSearchIndexItems(m.cachedMovies, "")
            m.searchIndexCache.movieSearchIndex = m.movieSearchIndex
        end if
        SaveSearchIndexCache(m.searchIndexCache)
    end if
    m.searchIndexTimer.control = "start"
    return true
end function

sub replaceSearchIndexCategory(kind as String, categoryId as String, entries as Object)
    target = []
    current = m.movieSearchIndex
    for each entry in current
        if entry.categoryId = invalid or entry.categoryId.ToStr() <> categoryId then target.Push(entry)
    end for
    for each entry in entries
        target.Push(entry)
    end for
    m.movieSearchIndex = target
    m.searchIndexCache.movieSearchIndex = target
end sub

sub onOpenSeriesRequested()
    hideAllScreensExcept(m.simpleSeriesScreen)
    m.simpleSeriesScreen.callFunc("setCategories", m.seriesCategories)
    m.simpleSeriesScreen.callFunc("setPreviewCache", m.seriesCategoryPreviewCache)
    m.simpleSeriesScreen.callFunc("setSeries", m.cachedSeries)
    m.simpleSeriesScreen.callFunc("show")
    m.simpleSeriesScreen.SetFocus(true)
end sub

sub onSeriesCategoriesResult(result as Object)
    if result.success = true then
        m.seriesCategories = normalizeSeriesCategories(result.data)
        m.searchIndexCache.seriesCategories = m.seriesCategories
        SaveSearchIndexCache(m.searchIndexCache)
    end if
end sub

sub onSeriesResult(result as Object)
    resultCategoryId = getSeriesResultCategoryId(result)
    if result.success = true then
        fresh = normalizeSeries(result.data)
        m.cachedSeries = replaceCachedCategoryItems(m.cachedSeries, fresh, resultCategoryId)
        if m.simpleSeriesScreen.visible = true then m.simpleSeriesScreen.callFunc("setSeries", m.cachedSeries)
    end if
end sub

function getSeriesResultCategoryId(result as Dynamic) as String
    if result = invalid or result.request = invalid then return ""
    request = result.request.ToStr()
    prefix = "getSeries:"
    if Left(request, Len(prefix)) = prefix then return Mid(request, Len(prefix) + 1)
    return ""
end function

sub onSeriesCategorySelected()
    category = m.simpleSeriesScreen.categorySelected
    if category = invalid then return
    categoryId = getCategoryId(category)
    if filterItemsByCategory(m.cachedSeries, categoryId).Count() > 0 then return
    if not hasAccount(m.account) or m.isLoadingRequest = true then return
    if beginXtreamRequest("getSeries") then
        m.xtreamService.control = "STOP"
        m.xtreamService.action = "getSeries"
        m.xtreamService.cacheEnabled = true
        m.xtreamService.categoryId = categoryId
        m.xtreamService.dns = m.account.dns
        m.xtreamService.username = m.account.username
        m.xtreamService.password = m.account.password
        m.xtreamService.control = "RUN"
    end if
end sub

sub onSimpleSeriesBack()
    m.simpleSeriesScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("hide")
    showHome()
end sub

sub onSeriesSelected()
    series = m.simpleSeriesScreen.seriesSelected
    if series = invalid then return
    m.selectedSeries = series
    m.simpleSeriesScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("show", series)
    m.seriesDetailsScreen.callFunc("setDetails", series)
end sub

sub onSeriesDetailsBack()
    m.seriesDetailsScreen.callFunc("hide")
    m.simpleSeriesScreen.callFunc("show")
end sub

sub onSeriesEpisodeSelected()
    episode = m.seriesDetailsScreen.episodeSelected
    if episode = invalid then return
    title = "Episódio"
    streamUrl = ""
    if episode.title <> invalid then title = episode.title.ToStr().Trim()
    if episode.streamUrl <> invalid then streamUrl = episode.streamUrl.ToStr().Trim()
    if title = "" then title = "Episódio"
    if streamUrl = "" then
        m.seriesDetailsScreen.callFunc("showMessage", "Episódio sem link disponível.")
        return
    end if
    m.seriesDetailsScreen.callFunc("hide")
    m.seriesPlayerScreen.callFunc("show", { title: title, streamUrl: streamUrl })
end sub

sub onSeriesPlayerBack()
    m.seriesPlayerScreen.callFunc("hide")
    m.seriesDetailsScreen.callFunc("show", m.selectedSeries)
    m.seriesDetailsScreen.callFunc("setDetails", m.selectedSeries)
    m.seriesDetailsScreen.callFunc("focusEpisodes")
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

function getDirectUrl(item as Dynamic) as String
    if item = invalid then return ""
    if item.direct_url <> invalid and item.direct_url.ToStr().Trim() <> "" then return item.direct_url.ToStr().Trim()
    if item.directUrl <> invalid and item.directUrl.ToStr().Trim() <> "" then return item.directUrl.ToStr().Trim()
    return ""
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

function safeText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr()
end function

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

sub startInitialCategoryPreviewCache()
    if m.isDemoMode = true then return
    if not hasAccount(m.account) then return
    m.previewQueue = []
    if m.movieCategories = invalid or m.movieCategories.Count() = 0 then m.previewQueue.Push({ action: "getMovieCategories", kind: "movieCategories", categoryId: "" })
    if m.seriesCategories = invalid or m.seriesCategories.Count() = 0 then m.previewQueue.Push({ action: "getSeriesCategories", kind: "seriesCategories", categoryId: "" })
    m.previewUpdating = true
    processNextPreviewRequest()
end sub

sub processNextPreviewRequest()
    if m.previewUpdating <> true then return
    if m.isLoadingRequest = true then
        m.searchIndexTimer.control = "start"
        return
    end if
    if m.previewQueue = invalid or m.previewQueue.Count() = 0 then
        m.previewUpdating = false
        m.searchIndexCache.movieCategoryPreviewCache = m.movieCategoryPreviewCache
        m.searchIndexCache.seriesCategoryPreviewCache = m.seriesCategoryPreviewCache
        m.searchIndexCache.movieCategories = m.movieCategories
        m.searchIndexCache.seriesCategories = m.seriesCategories
        m.searchIndexCache.updatedAt = CreateObject("roDateTime").AsSeconds().ToStr()
        SaveSearchIndexCache(m.searchIndexCache)
        return
    end if
    job = m.previewQueue.Shift()
    m.previewKind = job.kind
    m.previewCategory = invalid
    if job.DoesExist("category") then m.previewCategory = job.category
    if beginXtreamRequest(job.action) then
        m.xtreamService.control = "STOP"
        m.xtreamService.action = job.action
        m.xtreamService.cacheEnabled = true
        m.xtreamService.categoryId = job.categoryId
        m.xtreamService.dns = m.account.dns
        m.xtreamService.username = m.account.username
        m.xtreamService.password = m.account.password
        m.xtreamService.control = "RUN"
    end if
end sub

function handlePreviewCacheResult(result as Object) as Boolean
    if m.previewUpdating <> true or m.previewKind = "" then return false
    kind = m.previewKind
    category = m.previewCategory
    m.previewKind = ""
    m.previewCategory = invalid
    if result <> invalid and result.success = true then
        if kind = "movieCategories" then
            m.movieCategories = normalizeMovieCategories(result.data)
            m.searchIndexCache.movieCategories = m.movieCategories
            for each cat in m.movieCategories
                m.previewQueue.Push({ action: "getMovies", kind: "moviePreview", categoryId: getCategoryId(cat), category: cat })
            end for
        else if kind = "seriesCategories" then
            m.seriesCategories = normalizeSeriesCategories(result.data)
            m.searchIndexCache.seriesCategories = m.seriesCategories
            for each cat in m.seriesCategories
                m.previewQueue.Push({ action: "getSeries", kind: "seriesPreview", categoryId: getCategoryId(cat), category: cat })
            end for
        else if kind = "moviePreview" then
            m.movieCategoryPreviewCache = upsertCategoryPreview(m.movieCategoryPreviewCache, category, normalizeMovies(result.data), "movie")
            m.searchIndexCache.movieCategoryPreviewCache = m.movieCategoryPreviewCache
        else if kind = "seriesPreview" then
            m.seriesCategoryPreviewCache = upsertCategoryPreview(m.seriesCategoryPreviewCache, category, normalizeSeries(result.data), "series")
            m.searchIndexCache.seriesCategoryPreviewCache = m.seriesCategoryPreviewCache
        end if
        SaveSearchIndexCache(m.searchIndexCache)
    end if
    processNextPreviewRequest()
    return true
end function

function upsertCategoryPreview(cache as Dynamic, category as Dynamic, items as Object, itemType as String) as Object
    categoryId = getCategoryId(category)
    result = []
    if cache <> invalid and Type(cache) = "roArray" then
        for each preview in cache
            if preview <> invalid and preview.categoryId <> invalid and preview.categoryId.ToStr() <> categoryId then result.Push(preview)
        end for
    end if
    lightItems = []
    maxItems = items.Count()
    if maxItems > 10 then maxItems = 10
    for i = 0 to maxItems - 1
        lightItems.Push(createLightPreviewItem(items[i], categoryId, itemType))
    end for
    result.Push({ categoryId: categoryId, categoryName: getCategoryName(category), items: lightItems })
    return result
end function

function createLightPreviewItem(item as Dynamic, categoryId as String, itemType as String) as Object
    return { id: getPreviewItemId(item, itemType), title: getPreviewTitle(item), poster: getPreviewPoster(item), categoryId: categoryId, category_id: categoryId, type: itemType, stream_id: getPreviewItemId(item, itemType), series_id: getPreviewItemId(item, itemType), name: getPreviewTitle(item), stream_icon: getPreviewPoster(item), cover: getPreviewPoster(item) }
end function

function getPreviewItems(cache as Dynamic, categoryId as String) as Object
    if cache = invalid or Type(cache) <> "roArray" then return []
    for each preview in cache
        if preview <> invalid and preview.categoryId <> invalid and preview.categoryId.ToStr() = categoryId and preview.items <> invalid and Type(preview.items) = "roArray" then return preview.items
    end for
    return []
end function

function getPreviewItemId(item as Dynamic, itemType as String) as String
    if item = invalid then return ""
    if itemType = "series" and item.series_id <> invalid then return item.series_id.ToStr()
    if item.stream_id <> invalid then return item.stream_id.ToStr()
    if item.id <> invalid then return item.id.ToStr()
    return getPreviewTitle(item)
end function

function getPreviewTitle(item as Dynamic) as String
    if item = invalid then return ""
    if item.name <> invalid then return item.name.ToStr()
    if item.title <> invalid then return item.title.ToStr()
    return ""
end function

function getPreviewPoster(item as Dynamic) as String
    if item = invalid then return ""
    if item.stream_icon <> invalid and item.stream_icon.ToStr().Trim() <> "" then return item.stream_icon.ToStr()
    if item.cover <> invalid and item.cover.ToStr().Trim() <> "" then return item.cover.ToStr()
    if item.series_image <> invalid and item.series_image.ToStr().Trim() <> "" then return item.series_image.ToStr()
    return ""
end function

function normalizeSeriesCategories(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

function normalizeSeries(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function
