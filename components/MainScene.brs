' Main scene for the PXT Player application.
' It coordinates feature screens and authenticates playlist credentials through
' XtreamService, including live TV categories and channel lists.
sub Init()
    m.globalBackground = m.top.FindNode("globalBackground")
    m.globalBackgroundOverlay = m.top.FindNode("globalBackgroundOverlay")
    m.homeScreen = m.top.FindNode("homeScreen")
    m.videoSplashScreen = m.top.FindNode("videoSplashScreen")
    m.splashScreen = m.top.FindNode("splashScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.playlistAccountsScreen = m.top.FindNode("playlistAccountsScreen")
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
    m.backendService = m.top.FindNode("backendService")
    m.backendBootstrapService = m.top.FindNode("backendBootstrapService")
    m.backendSearchService = m.top.FindNode("backendSearchService")
    m.loginTimeoutTimer = m.top.FindNode("loginTimeoutTimer")
    m.detailTimeoutTimer = m.top.FindNode("detailTimeoutTimer")
    m.autoConnectTimer = m.top.FindNode("autoConnectTimer")
    m.searchIndexTimer = m.top.FindNode("searchIndexTimer")
    m.splashMinimumTimer = m.top.FindNode("splashMinimumTimer")
    m.splashMaximumTimer = m.top.FindNode("splashMaximumTimer")
    m.pendingDetailRequest = ""
    m.pendingRequest = ""
    m.isLoadingRequest = false
    m.savedPlaylists = LoadSavedPlaylists()
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
    m.liveChannelsLoading = true
    m.selectedLiveCategory = invalid
    m.selectedLiveCategoryId = ""
    m.selectedLiveChannel = invalid
    m.liveChannelsRestoreState = invalid
    m.movieCategories = []
    m.movieCategoriesLoading = false
    m.movies = []
    m.moviesLoading = true
    m.selectedMovieCategory = invalid
    m.selectedMovieCategoryId = ""
    m.selectedSeriesCategory = invalid
    m.selectedSeriesCategoryId = ""
    m.selectedMovie = invalid
    m.openedFromFavorites = false
    m.openedFromSearch = false
    m.openedFromRecent = false
    m.searchChannels = []
    m.searchMovies = []
    m.searchLoadStep = ""
    m.searchIndexCache = LoadSearchIndexCache()
    m.movieSearchIndex = m.searchIndexCache.movieSearchIndex
    m.seriesSearchIndex = m.searchIndexCache.seriesSearchIndex
    m.cachedMovies = m.searchIndexCache.movies
    m.cachedSeries = m.searchIndexCache.series
    m.allMoviesCache = m.searchIndexCache.movies
    m.allSeriesCache = m.searchIndexCache.series
    m.seriesCategories = m.searchIndexCache.seriesCategories
    m.movieCategoryPreviewCache = m.searchIndexCache.movieCategoryPreviewCache
    m.seriesCategoryPreviewCache = m.searchIndexCache.seriesCategoryPreviewCache
    m.cachedLiveChannels = m.searchIndexCache.liveChannels
    m.allLiveCache = m.searchIndexCache.liveChannels
    m.movieSearchIndexQueue = []
    m.seriesSearchIndexQueue = []
    m.searchIndexKind = ""
    m.searchIndexCategoryId = ""
    m.searchIndexActiveType = ""
    m.previewQueue = []
    m.previewUpdating = false
    m.previewKind = ""
    m.previewCategory = invalid
    m.movieSearchIndexUpdating = false
    m.seriesSearchIndexUpdating = false
    m.allCatalogLoadingMovies = false
    m.allCatalogLoadingSeries = false
    m.allCatalogLoadingLive = false
    ' Tracks one-shot global movie catalog request for search.
    m.movieGlobalCatalogRequested = false
    m.movieGlobalCatalogLoaded = false
    m.seriesGlobalCatalogRequested = false
    m.seriesGlobalCatalogLoaded = false
    m.movieCategoryIndex = {}
    m.seriesCategoryIndex = {}
    m.movieCategoryLoadState = {}
    m.seriesCategoryLoadState = {}
    m.searchMode = "all"
    m.searchBackTarget = "home"
    m.splashMinimumElapsed = false
    m.splashMaximumElapsed = false
    m.bootstrapActive = false
    m.bootstrapQueue = []
    m.backendBootstrapStatus = createBackendBootstrapStatus("idle")
    m.backendSearchActiveType = ""
    m.backendSearchActiveQuery = ""
    m.backendSearchRequestId = 0
    m.backendSearchLatestRequestId = 0
    m.backendSearchLastKey = ""
    m.backendBootstrapAccountKey = ""
    m.backendCatalogAccountKey = ""
    m.backendCatalogCache = invalid
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
    m.bootState = "booting"
    m.currentScreen = ""
    m.movieSearchRestoreState = invalid
    m.seriesSearchRestoreState = invalid
    if m.cachedMovies = invalid then m.cachedMovies = []
    if m.cachedSeries = invalid then m.cachedSeries = []
    if m.allMoviesCache = invalid then m.allMoviesCache = []
    if m.allSeriesCache = invalid then m.allSeriesCache = []
    if m.allLiveCache = invalid then m.allLiveCache = []
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
    m.movieSearchScreen.ObserveField("loadMoreRequested", "onMovieSearchNeedsMore")
    if m.seriesSearchScreen <> invalid then
        m.seriesSearchScreen.ObserveField("backRequested", "onSeriesSearchBack")
        m.seriesSearchScreen.ObserveField("seriesSelected", "onSeriesSearchSeriesSelected")
        m.seriesSearchScreen.ObserveField("loadMoreRequested", "onSeriesSearchNeedsMore")
    end if
    m.recentScreen.ObserveField("backRequested", "onRecentBack")
    m.recentScreen.ObserveField("historySelected", "onHistorySelected")
    m.favoritesScreen.ObserveField("backRequested", "onFavoritesBack")
    m.favoritesScreen.ObserveField("favoriteSelected", "onFavoriteSelected")
    m.playlistAccountsScreen.ObserveField("backRequested", "onPlaylistAccountsBack")
    m.playlistAccountsScreen.ObserveField("playlistSelected", "onPlaylistAccountSelected")
    m.playlistAccountsScreen.ObserveField("newPlaylistRequested", "onNewPlaylistRequested")
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
    m.livePlayerScreen.ObserveField("channelChangeRequested", "onLivePlayerChannelChangeRequested")
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
    m.movieDetailScreen.ObserveField("continueRequested", "onMovieDetailContinue")
    m.movieDetailScreen.ObserveField("favoriteToggled", "onMovieDetailFavoriteToggled")
    m.moviePlayerScreen.ObserveField("backRequested", "onMoviePlayerBack")
    m.simpleSeriesScreen.ObserveField("backRequested", "onSimpleSeriesBack")
    m.simpleSeriesScreen.ObserveField("seriesSelected", "onSeriesSelected")
    m.simpleSeriesScreen.ObserveField("categorySelected", "onSeriesCategorySelected")
    m.simpleSeriesScreen.ObserveField("categoryLoadRequested", "onSeriesCategoryLoadRequested")
    m.simpleSeriesScreen.ObserveField("searchRequested", "onSeriesSearchRequested")
    m.seriesDetailsScreen.ObserveField("backRequested", "onSeriesDetailsBack")
    m.seriesDetailsScreen.ObserveField("episodeSelected", "onSeriesEpisodeSelected")
    m.seriesPlayerScreen.ObserveField("backRequested", "onSeriesPlayerBack")
    m.xtreamService.ObserveField("result", "onXtreamConnectionResult")
    m.backendService.ObserveField("result", "onBackendLoginResult")
    m.backendBootstrapService.ObserveField("result", "onBackendBootstrapResult")
    if m.backendSearchService <> invalid then m.backendSearchService.ObserveField("result", "onBackendSearchResult")
    m.loginTimeoutTimer.ObserveField("fire", "onLoginTimeout")
    m.detailTimeoutTimer.ObserveField("fire", "onDetailTimeout")
    m.autoConnectTimer.ObserveField("fire", "onAutoConnectTimerFire")
    m.searchIndexTimer.ObserveField("fire", "onSearchIndexTimerFire")
    m.splashMinimumTimer.ObserveField("fire", "onSplashMinimumElapsed")
    m.splashMaximumTimer.ObserveField("fire", "onSplashMaximumElapsed")
    m.videoSplashScreen.ObserveField("finished", "onVideoSplashFinished")

    startInitialFlow()
end sub

sub startInitialFlow()
    m.localFavoritesCache = LoadFavorites()
    m.localHistoryCache = LoadViewingHistory()

    ' The app always opens on the Home screen, whether or not a playlist is
    ' connected. Without an account the user can still browse to TV/Filmes/
    ' Séries (they'll be prompted to connect there) or tap CONTA to log in.
    if hasAccount(m.account) then
        m.isDemoMode = false
        setBootState("reconnecting")
        updateConnectionStatus(false, "Conectando...")
    else
        if m.account <> invalid then PRINT "LOGIN_RESTORE_FAILED"
        m.account = invalid
        setBootState("error")
        updateConnectionStatus(false, "Nenhuma playlist conectada")
    end if

    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.playlistAccountsScreen.callFunc("hide")
    m.splashScreen.callFunc("hide")
    m.videoSplashScreen.callFunc("show")
end sub

sub onVideoSplashFinished()
    m.videoSplashScreen.callFunc("hide")
    loadLocalSearchIndexCache()
    if hasValidLocalCatalogData() then updateConnectionStatus(false, "Atualizando lista...")
    startSplashBootstrap()
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
        PRINT "LOGIN_RESTORE_FAILED"
        updateConnectionStatus(false, "Nenhuma playlist conectada")
        showPlaylistAccounts()
        return
    end if

    m.pendingAccount = m.account
    m.connectionMode = "auto"
    updateConnectionStatus(false, "Conectando...")
    startLoginTimeout()
    connectBackendLogin(m.account)
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
        m.bootstrapQueue = ["getLiveCategories", "getSeriesCategories", "getMovieCategories"]
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
    if hasAccount(m.account) and m.isDemoMode <> true and m.isConnecting <> true then startAutoConnectTimer()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if m.videoSplashScreen <> invalid and m.videoSplashScreen.visible = true then return true
    if m.splashScreen <> invalid and m.splashScreen.visible = true then return true
    if not press then return false

    if key = "back" then
        return handleBackKeySafely()
    end if

    return false
end function

function handleBackKeySafely() as Boolean
    if m.movieSearchScreen <> invalid and m.movieSearchScreen.visible = true then
        onMovieSearchBack()
        return true
    else if m.seriesSearchScreen <> invalid and m.seriesSearchScreen.visible = true then
        onSeriesSearchBack()
        return true
    end if
    if m.loginErrorActive = true then
        m.loginErrorActive = false
        m.loginConnecting = false
        showLogin()
        return true
    else if m.loginConnecting = true then
        m.loginConnecting = false
        m.isConnecting = false
        stopLoginTimeout()
        cancelLoginRequest()
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
    else if m.seriesPlayerScreen <> invalid and m.seriesPlayerScreen.visible = true then
        onSeriesPlayerBack()
        return true
    end if

    return false
end function

sub focusActiveScreen()
    screens = [m.homeScreen, m.loginScreen, m.playlistAccountsScreen, m.favoritesScreen, m.recentScreen, m.searchScreen, m.movieSearchScreen, m.seriesSearchScreen, m.liveChannelsScreen, m.movieListScreen, m.movieDetailScreen, m.simpleSeriesScreen, m.seriesDetailsScreen]
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
    screens = [m.homeScreen, m.loginScreen, m.playlistAccountsScreen, m.favoritesScreen, m.recentScreen, m.searchScreen, m.movieSearchScreen, m.seriesSearchScreen, m.liveCategoriesScreen, m.liveChannelsScreen, m.livePlayerScreen, m.movieCategoriesScreen, m.movieListScreen, m.movieDetailScreen, m.moviePlayerScreen, m.simpleSeriesScreen, m.seriesDetailsScreen]
    for each screen in screens
        if screen <> invalid and screen.id <> visibleId then screen.callFunc("hide")
    end for
end sub

function isValidAccount(account as Dynamic) as Boolean
    return hasAccount(account)
end function

sub runXtreamRequest(action as String, categoryId as String)
end sub

sub setBootState(state as String)
    m.bootState = state
end sub

function isAccountBootLoading() as Boolean
    return m.bootState = "booting" or m.bootState = "reconnecting"
end function

function canStartCatalogDuringBoot(kind as String) as Boolean
    if not isAccountBootLoading() then return true
    if kind = "live" then return (m.liveCategories <> invalid and m.liveCategories.Count() > 0) or (m.cachedLiveChannels <> invalid and m.cachedLiveChannels.Count() > 0) or (m.allLiveCache <> invalid and m.allLiveCache.Count() > 0)
    if kind = "movies" then return (m.movieCategories <> invalid and m.movieCategories.Count() > 0) or (m.cachedMovies <> invalid and m.cachedMovies.Count() > 0) or (m.allMoviesCache <> invalid and m.allMoviesCache.Count() > 0)
    if kind = "series" then return (m.seriesCategories <> invalid and m.seriesCategories.Count() > 0) or (m.cachedSeries <> invalid and m.cachedSeries.Count() > 0) or (m.allSeriesCache <> invalid and m.allSeriesCache.Count() > 0)
    return false
end function

sub showBootLoadingMessage(screen as Object)
    if screen = invalid then return
    screen.callFunc("setLoading", true)
    screen.callFunc("showMessage", "Carregando conta/lista...")
end sub

sub showHome()
    if m.splashScreen <> invalid then m.splashScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.playlistAccountsScreen.callFunc("hide")
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
    m.currentScreen = "home"
    if m.bootState = "ready" then startBackgroundCatalogCache()
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.playlistAccountsScreen.callFunc("hide")
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
    m.currentScreen = "login"
end sub



sub openSearch(mode as String, backTarget as String)
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.playlistAccountsScreen.callFunc("hide")
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

    ' Pesquisa de filmes é independente de séries e não deve ficar presa
    ' na categoria aberta. Mostra o cache atual imediatamente e, se o
    ' catálogo global ainda não foi carregado, faz uma única chamada global
    ' get_vod_streams em Task. A tela fica com loader, sem travar a render thread.
    movieSearchData = getMoviesForSearch()
    m.movieSearchScreen.callFunc("setMovies", movieSearchData)
    if movieSearchData = invalid then
        PRINT "BACKEND_SEARCH_CACHE_EMPTY"
    else if movieSearchData.Count() = 0 then
        PRINT "BACKEND_SEARCH_CACHE_EMPTY"
    end if
    if hasAccount(m.account) then
        if m.movieGlobalCatalogLoaded <> true then
            m.movieSearchScreen.callFunc("setCatalogLoading", true)
            startGlobalSearchCache("movies")
        else
            m.movieSearchScreen.callFunc("setCatalogLoading", false)
        end if
    else
        m.movieSearchScreen.callFunc("setCatalogLoading", false)
    end if
end sub

sub onSeriesSearchRequested()
    m.simpleSeriesScreen.callFunc("hide")
    m.searchBackTarget = "series"
    m.seriesSearchScreen.callFunc("show")

    ' Igual filmes: a busca de séries usa o catálogo global acumulado,
    ' não apenas a última categoria aberta. Se o provedor não devolver tudo
    ' em get_series sem categoria, carregamos as categorias restantes em
    ' segundo plano somente enquanto a busca está aberta.
    m.seriesSearchScreen.callFunc("setInitialSeries", getInitialSeriesForSearch())
    seriesSearchData = getSeriesForSearch()
    m.seriesSearchScreen.callFunc("setSeries", seriesSearchData)
    if seriesSearchData = invalid then
        PRINT "BACKEND_SEARCH_CACHE_EMPTY"
    else if seriesSearchData.Count() = 0 then
        PRINT "BACKEND_SEARCH_CACHE_EMPTY"
    end if
    if hasAccount(m.account) then
        if hasUnloadedSeriesCategories() then
            ' Se ainda não há nada em memória, faz só uma tentativa global.
            ' Nunca varre categorias nem reinicia busca ao apertar letras.
            m.seriesSearchScreen.callFunc("setCatalogLoading", true)
            startGlobalSearchCache("series")
        else
            m.seriesSearchScreen.callFunc("setCatalogLoading", false)
        end if
    end if
end sub

sub onMovieSearchBack()
    ' Movie search must return to the real Movies catalog screen.
    ' The app currently uses MovieListScreen for the Movies area; returning to
    ' MovieCategoriesScreen leaves a dead/empty screen with only title/background.
    if m.movieSearchScreen <> invalid then m.movieSearchScreen.callFunc("hide")
    if m.movieCategoriesScreen <> invalid then m.movieCategoriesScreen.callFunc("hide")
    if m.movieDetailScreen <> invalid then m.movieDetailScreen.callFunc("hide")
    if m.moviePlayerScreen <> invalid then m.moviePlayerScreen.callFunc("hide")

    if m.movieListScreen = invalid then return

    if m.selectedMovieCategory <> invalid then
        m.movieListScreen.callFunc("show", m.selectedMovieCategory)
        if m.movieCategories <> invalid and m.movieCategories.Count() > 0 then m.movieListScreen.callFunc("setCategories", m.movieCategories)
        if m.movies <> invalid and m.movies.Count() > 0 then m.movieListScreen.callFunc("setMovies", m.movies)
        m.movieListScreen.callFunc("focusCategories")
    else
        m.movieListScreen.callFunc("show", invalid)
        if m.movieCategories <> invalid and m.movieCategories.Count() > 0 then
            m.movieListScreen.callFunc("setCategories", m.movieCategories)
            m.movieListScreen.callFunc("showMessage", "Escolha uma categoria para carregar os filmes.")
        else if m.movieCategoriesLoading = true then
            m.movieListScreen.callFunc("setLoading", true)
        else
            m.movieListScreen.callFunc("showMessage", "Nenhuma categoria de filmes foi encontrada.")
        end if
        m.movieListScreen.callFunc("focusCategories")
    end if

    m.currentScreen = "movies"
end sub

sub onMovieSearchMovieSelected()
    movie = m.movieSearchScreen.movieSelected
    if movie = invalid then return
    PRINT "DETAIL_OPEN_FROM_SEARCH"
    m.movieSearchRestoreState = m.movieSearchScreen.callFunc("getState")
    m.selectedMovie = normalizeMovieFromSearch(movie)
    m.openedFromSearch = true
    m.movieSearchScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("show", m.selectedMovie)
    m.movieDetailScreen.callFunc("setDetails", m.selectedMovie)
    m.movieDetailScreen.callFunc("setResumePosition", GetHistoryPosition("movie", m.selectedMovie))
    if getStreamId(m.selectedMovie) <> "" and hasAccount(m.account) and m.isDemoMode <> true then
        m.movieDetailScreen.callFunc("setLoading", true)
        startDetailTimeout("movie")
        loadMovieInfo(m.selectedMovie)
    end if
end sub

sub onSeriesSearchBack()
    m.seriesSearchScreen.callFunc("hide")
    m.simpleSeriesScreen.callFunc("show")
end sub

sub onSeriesSearchSeriesSelected()
    series = m.seriesSearchScreen.seriesSelected
    if series = invalid then return
    PRINT "DETAIL_OPEN_FROM_SEARCH"
    m.seriesSearchRestoreState = m.seriesSearchScreen.callFunc("getState")
    m.selectedSeries = normalizeSeriesFromSearch(series)
    m.openedFromSearch = true
    m.seriesSearchScreen.callFunc("hide")
    setSeriesDetailsCredentials()
    m.seriesDetailsScreen.callFunc("show", m.selectedSeries)
    m.seriesDetailsScreen.callFunc("setDetails", m.selectedSeries)
    m.seriesDetailsScreen.callFunc("setContinueEpisode", GetLastSeriesEpisode(m.selectedSeries))
    loadSeriesInfo(m.selectedSeries)
end sub

function normalizeMovieFromSearch(movie as Dynamic) as Object
    normalized = {}
    if movie <> invalid and Type(movie) = "roAssociativeArray" then
        for each k in movie
            normalized[k] = movie[k]
        end for
    end if
    id = getStreamId(normalized)
    if id = "" and normalized.id <> invalid then id = normalized.id.ToStr()
    if id <> "" then normalized.stream_id = id
    if normalized.title <> invalid and normalized.name = invalid then normalized.name = normalized.title
    if normalized.poster <> invalid and normalized.stream_icon = invalid then normalized.stream_icon = normalized.poster
    if normalized.cover <> invalid and normalized.stream_icon = invalid then normalized.stream_icon = normalized.cover
    if normalized.categoryId <> invalid and normalized.category_id = invalid then normalized.category_id = normalized.categoryId
    return normalized
end function

function normalizeSeriesFromSearch(series as Dynamic) as Object
    normalized = {}
    if series <> invalid and Type(series) = "roAssociativeArray" then
        for each k in series
            normalized[k] = series[k]
        end for
    end if
    id = getSeriesId(normalized)
    if id = "" and normalized.id <> invalid then id = normalized.id.ToStr()
    if id <> "" then normalized.series_id = id
    if normalized.title <> invalid and normalized.name = invalid then normalized.name = normalized.title
    if normalized.poster <> invalid and normalized.series_image = invalid then normalized.series_image = normalized.poster
    if normalized.cover <> invalid and normalized.series_image = invalid then normalized.series_image = normalized.cover
    if normalized.categoryId <> invalid and normalized.category_id = invalid then normalized.category_id = normalized.categoryId
    return normalized
end function

sub onMovieSearchNeedsMore()
    query = ""
    if m.movieSearchScreen <> invalid then query = m.movieSearchScreen.loadMoreRequested
    startBackendSearch(query, "movies")
end sub

sub onSeriesSearchNeedsMore()
    query = ""
    if m.seriesSearchScreen <> invalid then query = m.seriesSearchScreen.loadMoreRequested
    startBackendSearch(query, "series")
end sub

sub startBackendSearch(query as String, searchType as String)
    if m.backendSearchService = invalid or not hasAccount(m.account) then
        PRINT "BACKEND_SEARCH_CACHE_EMPTY"
        useBackendSearchFallback(query, searchType)
        return
    end if
    cleanQuery = safeText(query)
    if cleanQuery = "" then return
    searchKey = searchType + "|" + cleanQuery
    if searchKey = m.backendSearchLastKey then return
    m.backendSearchLastKey = searchKey
    m.backendSearchRequestId = m.backendSearchRequestId + 1
    m.backendSearchLatestRequestId = m.backendSearchRequestId

    PRINT "SEARCH_REQUEST_START id="; m.backendSearchRequestId; " query="; cleanQuery
    PRINT "BACKEND_SEARCH_START type="; searchType; " query="; cleanQuery
    m.backendSearchActiveType = searchType
    m.backendSearchActiveQuery = cleanQuery
    m.backendSearchActiveRequestId = m.backendSearchRequestId
    if searchType = "movies" and m.movieSearchScreen <> invalid then m.movieSearchScreen.callFunc("setCatalogLoading", true)
    if searchType = "series" and m.seriesSearchScreen <> invalid then m.seriesSearchScreen.callFunc("setCatalogLoading", true)

    m.backendSearchService.control = "STOP"
    m.backendSearchService.action = "search"
    m.backendSearchService.dns = m.account.dns
    m.backendSearchService.username = m.account.username
    m.backendSearchService.password = m.account.password
    m.backendSearchService.query = cleanQuery
    m.backendSearchService.searchType = searchType
    m.backendSearchService.limit = 50
    m.backendSearchService.requestId = m.backendSearchRequestId
    m.backendSearchService.control = "RUN"
end sub

sub onBackendSearchResult()
    result = m.backendSearchService.result
    if result = invalid or result.request <> "backendSearch" then return
    searchType = safeText(result.searchType)
    query = safeText(result.query)
    if searchType = "" then searchType = m.backendSearchActiveType
    if query = "" then query = m.backendSearchActiveQuery
    requestId = result.requestId
    if requestId = invalid then requestId = 0
    if requestId = 0 then requestId = m.backendSearchActiveRequestId
    if requestId <> m.backendSearchLatestRequestId then
        PRINT "SEARCH_REQUEST_IGNORED_STALE id="; requestId; " query="; query
        return
    end if

    if result.success = true and result.ok = true then
        items = result.results
        if items = invalid or Type(items) <> "roArray" then items = []
        PRINT "SEARCH_REQUEST_APPLY id="; requestId; " query="; query
        PRINT "BACKEND_SEARCH_READY type="; searchType; " query="; query; " count="; items.Count()
        if searchType = "movies" then
            if items.Count() > 0 then m.allMoviesCache = mergeUniqueItems(items, m.allMoviesCache, "movies")
            if m.movieSearchScreen <> invalid and m.movieSearchScreen.visible = true then
                m.movieSearchScreen.callFunc("setCatalogLoading", false)
                m.movieSearchScreen.callFunc("setBackendSearchResults", items)
            end if
        else if searchType = "series" then
            if items.Count() > 0 then m.allSeriesCache = mergeUniqueItems(items, m.allSeriesCache, "series")
            if m.seriesSearchScreen <> invalid and m.seriesSearchScreen.visible = true then
                m.seriesSearchScreen.callFunc("setCatalogLoading", false)
                m.seriesSearchScreen.callFunc("setBackendSearchResults", items)
            end if
        end if
    else
        PRINT "BACKEND_SEARCH_ERROR type="; searchType; " query="; query
        useBackendSearchFallback(query, searchType)
    end if
end sub

sub useBackendSearchFallback(query as String, searchType as String)
    PRINT "BACKEND_SEARCH_FALLBACK type="; searchType; " query="; query
    ' Do not run the old heavy local search fallback here. Keep the previous
    ' results visible and only clear the loading indicator. Background cache
    ' refresh may continue independently, but search itself stays tied to
    ' /api/search for PR 11.1.
    if searchType = "movies" then
        if m.movieSearchScreen <> invalid then m.movieSearchScreen.callFunc("setCatalogLoading", false)
    else if searchType = "series" then
        if m.seriesSearchScreen <> invalid then m.seriesSearchScreen.callFunc("setCatalogLoading", false)
    end if
end sub


function getMoviesForSearch() as Object
    ' Primeiro usa os previews persistentes: 10 itens por categoria já salvos.
    ' Depois completa com o cache global acumulado, sem prender a busca à categoria aberta.
    source = []
    preview = flattenPreviewCache(m.movieCategoryPreviewCache, "movies")
    if preview <> invalid and Type(preview) = "roArray" and preview.Count() > 0 then source = mergeUniqueItems(source, preview, "movies")
    if m.allMoviesCache <> invalid and Type(m.allMoviesCache) = "roArray" and m.allMoviesCache.Count() > 0 then source = mergeUniqueItems(source, m.allMoviesCache, "movies")
    if (source = invalid or source.Count() = 0) and m.cachedMovies <> invalid and Type(m.cachedMovies) = "roArray" then source = m.cachedMovies
    if (source = invalid or source.Count() = 0) and m.movies <> invalid and Type(m.movies) = "roArray" then source = m.movies
    return buildSearchPreviewByCategory(source, 10, 1200, "movies")
end function

function limitMovieSearchItems(items as Dynamic) as Object
    return buildSearchPreviewByCategory(items, 10, 1200, "movies")
end function

function getSeriesForSearch() as Object
    ' Igual filmes: usa previews salvos + cache global acumulado.
    source = []
    preview = flattenPreviewCache(m.seriesCategoryPreviewCache, "series")
    if preview <> invalid and Type(preview) = "roArray" and preview.Count() > 0 then source = mergeUniqueItems(source, preview, "series")
    if m.allSeriesCache <> invalid and Type(m.allSeriesCache) = "roArray" and m.allSeriesCache.Count() > 0 then source = mergeUniqueItems(source, m.allSeriesCache, "series")
    if (source = invalid or source.Count() = 0) and m.cachedSeries <> invalid and Type(m.cachedSeries) = "roArray" then source = m.cachedSeries
    return buildSearchPreviewByCategory(source, 10, 1200, "series")
end function


function flattenPreviewCache(cache as Dynamic, kind as String) as Object
    result = []
    if cache = invalid or Type(cache) <> "roArray" then return result
    for each preview in cache
        if preview <> invalid and preview.items <> invalid and Type(preview.items) = "roArray" then
            for each item in preview.items
                result.Push(item)
            end for
        end if
    end for
    return result
end function

function buildSearchPreviewByCategory(items as Dynamic, perCategory as Integer, maxItems as Integer, kind as String) as Object
    result = []
    if items = invalid or Type(items) <> "roArray" then return result
    counts = {}
    for each item in items
        if result.Count() >= maxItems then exit for
        cid = getItemCategoryId(item)
        if cid = "" then cid = "_sem_categoria"
        currentCount = 0
        if counts[cid] <> invalid then currentCount = counts[cid]
        if currentCount < perCategory then
            result.Push(item)
            counts[cid] = currentCount + 1
        end if
    end for
    ' If the list has few categories, fill the remaining slots with more global items.
    if result.Count() < 80 then
        seen = {}
        for each item in result
            key = getCatalogItemKey(item, kind)
            if key <> "" then seen[key] = true
        end for
        for each item in items
            if result.Count() >= maxItems then exit for
            key = getCatalogItemKey(item, kind)
            if key <> "" and seen[key] = invalid then
                result.Push(item)
                seen[key] = true
            end if
        end for
    end if
    return result
end function

function hasGlobalSeriesCatalog() as Boolean
    return m.allSeriesCache <> invalid and Type(m.allSeriesCache) = "roArray" and m.allSeriesCache.Count() > 0
end function

function hasGlobalMovieCatalog() as Boolean
    return m.allMoviesCache <> invalid and Type(m.allMoviesCache) = "roArray" and m.allMoviesCache.Count() > 0
end function

function getInitialSeriesForSearch() as Object
    if m.cachedSeries <> invalid and m.cachedSeries.Count() > 0 then return limitArrayForUiBatch(m.cachedSeries, 60)
    if m.allSeriesCache <> invalid then return limitArrayForUiBatch(m.allSeriesCache, 60)
    return []
end function

function getSearchDataForMode(mode as String) as Object
    channels = m.allLiveCache
    movies = m.allMoviesCache
    series = m.allSeriesCache
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
    openPlayer(channel, "live")
end sub

sub onSearchMovieSelected()
    movie = m.searchScreen.movieSelected
    if movie = invalid then return
    m.selectedMovie = movie
    m.openedFromSearch = true
    m.moviePlayerScreen.callFunc("setResumePosition", GetHistoryPosition("movie", movie))
    openPlayer(movie, "movie")
end sub

sub onSearchSeriesSelected()
    series = m.searchScreen.seriesSelected
    if series = invalid then return
    m.selectedSeries = series
    m.openedFromSearch = true
    m.searchScreen.callFunc("hide")
    setSeriesDetailsCredentials()
    m.seriesDetailsScreen.callFunc("show", series)
    m.seriesDetailsScreen.callFunc("setDetails", series)
    m.seriesDetailsScreen.callFunc("setContinueEpisode", GetLastSeriesEpisode(series))
    loadSeriesInfo(series)
end sub



sub startGlobalSearchCache(kind as String)
    if m.isDemoMode = true then return
    if not hasAccount(m.account) then return

    ' A busca deve usar primeiro o cache e continuar carregando mais dados
    ' em segundo plano. Nunca misturar filmes com séries. Nunca bloquear a tela.
    if kind = "movies" then
        if m.movieSearchIndexUpdating = true then return
        m.movieSearchIndexQueue = []

        if m.movieGlobalCatalogLoaded <> true and m.movieGlobalCatalogRequested <> true then
            m.movieGlobalCatalogRequested = true
            queueMovieSearchIndexJob({ action: "getMovies", kind: "movies", categoryId: "", indexType: "movies" })
        end if

        if m.movieCategories = invalid or m.movieCategories.Count() = 0 then
            queueMovieSearchIndexJob({ action: "getMovieCategories", kind: "movieCategories", categoryId: "", indexType: "movies" })
        else
            queueMissingMovieCategoryJobs()
        end if

        if m.movieSearchIndexQueue.Count() = 0 then
            if m.movieSearchScreen <> invalid and m.movieSearchScreen.visible = true then
                m.movieSearchScreen.callFunc("setMovies", getMoviesForSearch())
                m.movieSearchScreen.callFunc("setCatalogLoading", false)
            end if
            return
        end if
        m.movieSearchIndexUpdating = true
    else if kind = "series" then
        if m.seriesSearchIndexUpdating = true then return
        m.seriesSearchIndexQueue = []

        if m.seriesGlobalCatalogLoaded <> true and m.seriesGlobalCatalogRequested <> true then
            m.seriesGlobalCatalogRequested = true
            queueSeriesSearchIndexJob({ action: "getSeries", kind: "series", categoryId: "", indexType: "series" })
        end if

        if m.seriesCategories = invalid or m.seriesCategories.Count() = 0 then
            queueSeriesSearchIndexJob({ action: "getSeriesCategories", kind: "seriesCategories", categoryId: "", indexType: "series" })
        else
            queueMissingSeriesCategoryJobs()
        end if

        if m.seriesSearchIndexQueue.Count() = 0 then
            if m.seriesSearchScreen <> invalid and m.seriesSearchScreen.visible = true then
                m.seriesSearchScreen.callFunc("setSeries", getSeriesForSearch())
                m.seriesSearchScreen.callFunc("setCatalogLoading", false)
            end if
            return
        end if
        m.seriesSearchIndexUpdating = true
    end if

    if m.searchIndexTimer <> invalid then
        m.searchIndexTimer.control = "stop"
        m.searchIndexTimer.control = "start"
    end if
end sub

sub queueMovieSearchIndexJob(job as Object)
    if m.movieSearchIndexQueue = invalid then m.movieSearchIndexQueue = []
    m.movieSearchIndexQueue.Push(job)
end sub

sub queueSeriesSearchIndexJob(job as Object)
    if m.seriesSearchIndexQueue = invalid then m.seriesSearchIndexQueue = []
    m.seriesSearchIndexQueue.Push(job)
end sub

sub queueMissingMovieCategoryJobs()
    if m.movieCategories = invalid or Type(m.movieCategories) <> "roArray" then return
    added = 0
    for each category in m.movieCategories
        if added >= 2 then exit for
        cid = getCategoryId(category)
        if cid <> "" and getCategoryLoadState(m.movieCategoryLoadState, cid) <> "LOADED" and getCategoryLoadState(m.movieCategoryLoadState, cid) <> "LOADING" then
            m.movieCategoryLoadState[cid] = "LOADING"
            queueMovieSearchIndexJob({ action: "getMovies", kind: "movies", categoryId: cid, indexType: "movies" })
            added = added + 1
        end if
    end for
end sub

sub queueMissingSeriesCategoryJobs()
    if m.seriesCategories = invalid or Type(m.seriesCategories) <> "roArray" then return
    added = 0
    for each category in m.seriesCategories
        if added >= 2 then exit for
        cid = getCategoryId(category)
        if cid <> "" and getCategoryLoadState(m.seriesCategoryLoadState, cid) <> "LOADED" and getCategoryLoadState(m.seriesCategoryLoadState, cid) <> "LOADING" then
            m.seriesCategoryLoadState[cid] = "LOADING"
            queueSeriesSearchIndexJob({ action: "getSeries", kind: "series", categoryId: cid, indexType: "series" })
            added = added + 1
        end if
    end for
end sub

function nextSearchIndexJob() as Dynamic
    if m.movieSearchIndexUpdating = true and m.movieSearchIndexQueue <> invalid and m.movieSearchIndexQueue.Count() > 0 then return m.movieSearchIndexQueue.Shift()
    if m.movieSearchIndexUpdating = true then finishSearchIndexTypeIfDone("movies")
    if m.seriesSearchIndexUpdating = true and m.seriesSearchIndexQueue <> invalid and m.seriesSearchIndexQueue.Count() > 0 then return m.seriesSearchIndexQueue.Shift()
    if m.seriesSearchIndexUpdating = true then finishSearchIndexTypeIfDone("series")
    return invalid
end function

sub finishSearchIndexTypeIfDone(indexType as String)
    if indexType = "movies" then
        if m.movieSearchIndexQueue <> invalid and m.movieSearchIndexQueue.Count() > 0 then return
        if hasUnloadedMovieCategories() and m.movieSearchScreen <> invalid and m.movieSearchScreen.visible = true then
            queueMissingMovieCategoryJobs()
            if m.movieSearchIndexQueue <> invalid and m.movieSearchIndexQueue.Count() > 0 then
                m.searchIndexTimer.control = "start"
                return
            end if
        end if
        m.movieSearchIndexUpdating = false
        m.searchIndexCache.movieSearchIndex = m.movieSearchIndex
        if m.movieSearchScreen.visible = true then m.movieSearchScreen.callFunc("setCatalogLoading", false)
    else if indexType = "series" then
        if m.seriesSearchIndexQueue <> invalid and m.seriesSearchIndexQueue.Count() > 0 then return
        if hasUnloadedSeriesCategories() and m.seriesSearchScreen <> invalid and m.seriesSearchScreen.visible = true then
            queueMissingSeriesCategoryJobs()
            if m.seriesSearchIndexQueue <> invalid and m.seriesSearchIndexQueue.Count() > 0 then
                m.searchIndexTimer.control = "start"
                return
            end if
        end if
        m.seriesSearchIndexUpdating = false
        m.searchIndexCache.seriesSearchIndex = m.seriesSearchIndex
        if m.seriesSearchScreen.visible = true then m.seriesSearchScreen.callFunc("setCatalogLoading", false)
    end if
    m.searchIndexCache.updatedAt = CreateObject("roDateTime").AsSeconds().ToStr()
    SaveSearchIndexCache(m.searchIndexCache)
    PRINT "SEARCH_FINISHED"
end sub

function prioritizedSearchCategories(categories as Dynamic) as Object
    prioritized = []
    rest = []
    streaming = []
    if categories = invalid or Type(categories) <> "roArray" then return prioritized
    for each category in categories
        name = LCase(getCategoryName(category))
        if Instr(1, name, "lançamento") > 0 or Instr(1, name, "lancamento") > 0 or Instr(1, name, "cinema") > 0 or Instr(1, name, "novidade") > 0 or Instr(1, name, "popular") > 0 then
            prioritized.Push(category)
        else if isStreamingCategoryName(name) then
            insertCategoryByName(streaming, category)
        else
            rest.Push(category)
        end if
    end for
    for each category in streaming
        prioritized.Push(category)
    end for
    for each category in rest
        prioritized.Push(category)
    end for
    return prioritized
end function

function isStreamingCategoryName(name as String) as Boolean
    return Instr(1, name, "netflix") > 0 or Instr(1, name, "prime") > 0 or Instr(1, name, "disney") > 0 or Instr(1, name, "globoplay") > 0 or Instr(1, name, "hbo") > 0 or Instr(1, name, "apple tv") > 0 or Instr(1, name, "paramount") > 0
end function

sub insertCategoryByName(sorted as Object, category as Object)
    insertAt = sorted.Count()
    currentName = LCase(getCategoryName(category))
    for i = 0 to sorted.Count() - 1
        if currentName < LCase(getCategoryName(sorted[i])) then
            insertAt = i
            exit for
        end if
    end for

    ' BrightScript roArray does not support Insert() in all runtimes/simulators.
    ' Append and shift manually to avoid runtime error &hf4 during startup/search cache loading.
    sorted.Push(category)
    if insertAt < sorted.Count() - 1 then
        for j = sorted.Count() - 1 to insertAt + 1 step -1
            sorted[j] = sorted[j - 1]
        end for
        sorted[insertAt] = category
    end if
end sub

function getCategoryLoadState(states as Dynamic, categoryId as String) as String
    if states <> invalid and states[categoryId] <> invalid then return states[categoryId]
    return "NOT_LOADED"
end function

function hasUnloadedMovieCategories() as Boolean
    if m.movieCategories = invalid or Type(m.movieCategories) <> "roArray" or m.movieCategories.Count() = 0 then return true
    for each category in m.movieCategories
        cid = getCategoryId(category)
        if cid <> "" and getCategoryLoadState(m.movieCategoryLoadState, cid) <> "LOADED" then return true
    end for
    return false
end function

function hasUnloadedSeriesCategories() as Boolean
    if m.seriesCategories = invalid or Type(m.seriesCategories) <> "roArray" or m.seriesCategories.Count() = 0 then return true
    for each category in m.seriesCategories
        cid = getCategoryId(category)
        if cid <> "" and getCategoryLoadState(m.seriesCategoryLoadState, cid) <> "LOADED" then return true
    end for
    return false
end function

function mergeUniqueItems(cache as Dynamic, freshItems as Object, kind as String) as Object
    merged = [] : seen = {}
    if cache <> invalid and Type(cache) = "roArray" then
        for each item in cache
            key = getCatalogItemKey(item, kind)
            if key <> "" and seen[key] = invalid then seen[key] = true : merged.Push(item)
        end for
    end if
    if freshItems <> invalid and Type(freshItems) = "roArray" then
        for each item in freshItems
            key = getCatalogItemKey(item, kind)
            if key <> "" and seen[key] = invalid then seen[key] = true : merged.Push(item)
        end for
    end if
    return merged
end function

function getCatalogItemKey(item as Dynamic, kind as String) as String
    if item = invalid then return ""
    if kind = "series" then
        if item.series_id <> invalid then return "series_" + item.series_id.ToStr()
    else
        if item.stream_id <> invalid then return "movie_" + item.stream_id.ToStr()
    end if
    if item.id <> invalid then return "id_" + item.id.ToStr()
    if item.name <> invalid then return LCase(item.name.ToStr())
    if item.title <> invalid then return LCase(item.title.ToStr())
    return ""
end function

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
        m.moviePlayerScreen.callFunc("setResumePosition", item.position)
        openPlayer(item.content, "movie")
    else if item.type = "series" then
        m.selectedSeries = item.series
        m.selectedEpisode = item.content
        m.seriesPlayerScreen.callFunc("setResumePosition", item.position)
        openPlayer(item.content, "series")
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
        openPlayer(content, "live")
    else if favorite.type = "movie" then
        m.selectedMovie = content
        m.moviePlayerScreen.callFunc("setResumePosition", GetHistoryPosition("movie", content))
        openPlayer(content, "movie")
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
    m.playlistAccountsScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.favoritesScreen.callFunc("show")
    m.favoritesScreen.callFunc("setFavorites", LoadFavorites())
end sub

sub onOpenRecentRequested()
    m.homeScreen.callFunc("hide")
    m.playlistAccountsScreen.callFunc("hide")
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
    showPlaylistAccounts()
end sub

sub showPlaylistAccounts()
    m.savedPlaylists = LoadSavedPlaylists()
    hideAllScreensExcept(m.playlistAccountsScreen)
    activeUsername = ""
    if hasAccount(m.account) then activeUsername = safeText(m.account.username)
    m.playlistAccountsScreen.callFunc("setPlaylists", { playlists: m.savedPlaylists, activeUsername: activeUsername })
    m.playlistAccountsScreen.callFunc("show")
    m.currentScreen = "playlistAccounts"
end sub

sub onPlaylistAccountsBack()
    showHome()
end sub

sub onNewPlaylistRequested()
    showLogin()
end sub

sub onPlaylistAccountSelected()
    selected = m.playlistAccountsScreen.playlistSelected
    if not hasAccount(selected) then return
    stopLoginTimeout()
    cancelLoginRequest()
    m.account = selected
    SavePlaylist(m.account)
    m.savedPlaylists = LoadSavedPlaylists()
    m.pendingAccount = m.account
    m.loginFormAccount = invalid
    m.loginConnecting = false
    m.loginErrorActive = false
    m.connectionMode = "manual"
    m.isDemoMode = false
    resetAccountLoadedData()
    loadLocalSearchIndexCache()
    updateConnectionStatus(false, "Conectando...")
    showHome()
    startLoginTimeout()
    connectBackendLogin(m.account)
end sub

sub onOpenLiveCategoriesRequested()
    cancelSearchIndexRefresh()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.playlistAccountsScreen.callFunc("hide")
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
    m.currentScreen = "live"

    if isAccountBootLoading() and not canStartCatalogDuringBoot("live") then
        showBootLoadingMessage(m.liveChannelsScreen)
        return
    else if m.isDemoMode = true then
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
    m.playlistAccountsScreen.callFunc("hide")
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
    m.currentScreen = "movies"

    if isAccountBootLoading() and not canStartCatalogDuringBoot("movies") then
        showBootLoadingMessage(m.movieListScreen)
        return
    else if m.isDemoMode = true then
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
        cancelLoginRequest()
        m.pendingAccount = invalid
        m.loginFormAccount = invalid
        m.loginConnecting = false
        m.isConnecting = false
        m.connectionMode = ""
        m.isDemoMode = false
        m.loginErrorActive = false
        m.account = invalid
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
    connectBackendLogin(account)
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
    cancelLoginRequest()
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
    m.movieSearchIndex = []
    m.seriesSearchIndex = []
    m.searchIndexCache.movieSearchIndex = m.movieSearchIndex
    m.searchIndexCache.seriesSearchIndex = m.seriesSearchIndex
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
    cancelLoginRequest()
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
    m.movieListScreen.callFunc("setLoading", true)
    m.movieListScreen.callFunc("showMessage", "Carregando categoria...")
    showMoviesFromCacheOrLoad(category)
end sub

sub onMovieListCategorySelected()
    category = m.movieListScreen.categorySelected
    if category = invalid then return
    if isFavoritesCategory(category) then
        showFavoriteMoviesInMovieList()
        return
    end if
    if isRecentCategory(category) then
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
    m.movieListScreen.callFunc("setLoading", true)
    m.movieListScreen.callFunc("showMessage", "Carregando categoria...")
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
    m.movieDetailScreen.callFunc("setResumePosition", GetHistoryPosition("movie", movie))
end sub

sub onMovieDetailBack()
    stopDetailTimeout("movie")
    if m.pendingRequest = "getMovieInfo" then cancelXtreamRequest()
    m.movieDetailScreen.callFunc("hide")
    if m.openedFromSearch = true then
        PRINT "DETAIL_RETURN_TO_SEARCH"
        if m.movieSearchScreen <> invalid then
            m.movieSearchScreen.callFunc("show")
            m.movieSearchScreen.callFunc("restoreState", m.movieSearchRestoreState)
            PRINT "DETAIL_SEARCH_CONTEXT_RESTORED"
        end if
        m.openedFromSearch = false
        return
    end if
    if m.openedFromFavorites = true then
        m.openedFromFavorites = false
        onOpenFavoritesRequested()
        return
    end if
    m.movieListScreen.callFunc("show", m.selectedMovieCategory)
end sub

sub onMovieDetailPlay()
    startSelectedMovieFromDetail(0)
end sub

sub onMovieDetailContinue()
    startSelectedMovieFromDetail(GetHistoryPosition("movie", m.selectedMovie))
end sub

sub startSelectedMovieFromDetail(resumePosition as Integer)
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
    m.moviePlayerScreen.callFunc("setResumePosition", resumePosition)
    openPlayer(m.selectedMovie, "movie")
end sub

sub onMovieDetailFavoriteToggled()
    ToggleFavorite("movie", m.movieDetailScreen.favoriteToggled)
end sub

sub onMoviePlayerBack()
    if m.isReturningFromPlayer = true then return
    m.isReturningFromPlayer = true

    position = 0
    duration = 0
    if m.moviePlayerScreen <> invalid then
        position = m.moviePlayerScreen.callFunc("getPlaybackPosition")
        duration = m.moviePlayerScreen.callFunc("getPlaybackDuration")
    end if
    UpsertMovieHistory(m.selectedMovie, position, duration)

    if m.moviePlayerScreen <> invalid then
        m.moviePlayerScreen.callFunc("hide")
        m.moviePlayerScreen.SetFocus(false)
    end if

    if m.selectedMovie <> invalid then
        hideAllScreensExcept(m.movieDetailScreen)
        m.movieDetailScreen.callFunc("show", m.selectedMovie)
        m.movieDetailScreen.callFunc("setDetails", m.selectedMovie)
        m.movieDetailScreen.callFunc("setResumePosition", position)
        m.movieDetailScreen.SetFocus(true)
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
    m.liveChannelsScreen.callFunc("setLoading", true)
    m.liveChannelsScreen.callFunc("showMessage", "Carregando categoria...")
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
    m.liveChannelsScreen.callFunc("setLoading", true)
    m.liveChannelsScreen.callFunc("showMessage", "Carregando categoria...")
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
    openPlayer(channel, "live")
end sub

sub onLivePlayerChannelChangeRequested()
    direction = m.livePlayerScreen.channelChangeRequested
    if direction = invalid or direction = "" then return
    switchLivePlayerChannel(direction)
end sub

sub switchLivePlayerChannel(direction as String)
    channels = m.liveChannels
    if channels = invalid then channels = []
    if channels.Count() = 0 and m.cachedLiveChannels <> invalid then channels = m.cachedLiveChannels
    if channels = invalid then return
    if channels.Count() = 0 then return

    currentId = getStreamId(m.selectedLiveChannel)
    currentIndex = -1
    for i = 0 to channels.Count() - 1
        if getStreamId(channels[i]) = currentId then
            currentIndex = i
            exit for
        end if
    end for
    if currentIndex < 0 then currentIndex = 0

    if direction = "previous" then
        nextIndex = currentIndex - 1
        if nextIndex < 0 then nextIndex = channels.Count() - 1
    else
        nextIndex = currentIndex + 1
        if nextIndex >= channels.Count() then nextIndex = 0
    end if

    nextChannel = channels[nextIndex]
    m.selectedLiveChannel = nextChannel
    m.livePlayerScreen.callFunc("show", nextChannel)
    buildLiveStreamUrl(nextChannel)
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

sub openPlayer(item as Dynamic, itemType as String)
    cleanType = LCase(itemType)
    if cleanType = "live" then
        hideAllScreensExcept(m.livePlayerScreen)
        m.livePlayerScreen.callFunc("show", item)
        buildLiveStreamUrl(item)
    else if cleanType = "movie" then
        hideAllScreensExcept(m.moviePlayerScreen)
        m.moviePlayerScreen.callFunc("show", item)
        buildMovieStreamUrl(item)
    else if cleanType = "series" then
        hideAllScreensExcept(m.seriesPlayerScreen)
        if getDirectUrl(item) = "" then
            m.seriesPlayerScreen.callFunc("show", item)
            m.seriesPlayerScreen.callFunc("showError", "Stream sem URL válida")
        else
            m.seriesPlayerScreen.callFunc("show", item)
        end if
    end if
end sub

sub buildLiveStreamUrl(channel as Object)
    directUrl = getLiveDirectUrl(channel)
    if directUrl = "" and m.isDemoMode = true then directUrl = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    if directUrl <> "" then
        print "LIVE PLAYER URL: "; directUrl
        m.livePlayerScreen.callFunc("play", directUrl)
        return
    end if
    if getStreamId(channel) = "" then
        m.livePlayerScreen.callFunc("showError", "Stream sem URL válida")
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
        m.livePlayerScreen.callFunc("showError", "Stream sem URL válida")
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
    if getStreamId(movie) = "" then
        m.moviePlayerScreen.callFunc("showError", "Stream sem URL válida")
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

sub connectBackendLogin(account as Object)
    if m.isDemoMode = true then return
    if m.isConnecting = true then return
    if m.isLoadingRequest = true then return
    if not hasAccount(account) then
        m.isConnecting = false
        showReconnectErrorIfNoValidCache()
        return
    end if

    m.isConnecting = true
    if not beginXtreamRequest("backendLogin") then return
    m.backendService.control = "STOP"
    m.backendService.action = "login"
    m.backendService.dns = account.dns
    m.backendService.username = account.username
    m.backendService.password = account.password
    m.backendService.control = "RUN"
end sub


sub loadMovies(category as Object)
    categoryId = getCategoryId(category)
    cached = []
    if m.movieCategoryIndex <> invalid and m.movieCategoryIndex[categoryId] <> invalid then cached = m.movieCategoryIndex[categoryId] else cached = filterItemsByCategory(m.cachedMovies, categoryId)
    if cached.Count() > 0 then
        m.movies = cached
        m.moviesLoading = false
        m.movieListScreen.callFunc("setLoading", false)
        m.movieListScreen.callFunc("setMovies", m.movies)
        return
    end if
    if canUseBackendCatalog() then
        m.movies = filterItemsByCategory(m.cachedMovies, categoryId)
        m.moviesLoading = false
        m.movieListScreen.callFunc("setLoading", false)
        m.movieListScreen.callFunc("setMovies", m.movies)
        return
    end if
    if m.isDemoMode = true then
        m.movies = cached
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
    m.xtreamService.categoryId = categoryId
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadMovieCategories(account as Object)
    if m.isDemoMode = true then return
    if canUseBackendCatalog() and m.movieCategories <> invalid and m.movieCategories.Count() > 0 then
        m.movieCategoriesLoading = false
        if m.movieListScreen.visible = true then
            m.movieListScreen.callFunc("setLoading", false)
            m.movieListScreen.callFunc("setCategories", m.movieCategories)
        end if
        if m.movieCategoriesScreen.visible = true then m.movieCategoriesScreen.callFunc("setLoading", false)
        m.homeScreen.callFunc("setMovieCategoriesLoading", false)
        return
    end if
    PRINT "CATEGORIES_FALLBACK_XTREAM movies"
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
    m.movies = historyContents(LoadViewingHistory().movies, "movies")
    m.moviesLoading = false
    m.movieListScreen.callFunc("setLoading", false)
    if m.movies.Count() = 0 then
        m.movieListScreen.callFunc("showMessage", "Você ainda não assistiu filmes.")
    else
        m.movieListScreen.callFunc("setMovies", m.movies)
    end if
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
    cancelSearchIndexRefresh()
    if m.previewUpdating = true then
        m.previewQueue = []
        m.previewUpdating = false
        m.previewKind = ""
    end if
    categoryId = getCategoryId(category)
    cached = []
    if m.movieCategoryIndex <> invalid and m.movieCategoryIndex[categoryId] <> invalid then cached = m.movieCategoryIndex[categoryId]
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
    else if isSeriesInfoResult(result) then
        onSeriesInfoResult(result)
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

    if isValidLoginConnectionResult(result) then
        m.account = m.pendingAccount
        m.loginFormAccount = invalid
        SavePlaylist(m.account)
        m.savedPlaylists = LoadSavedPlaylists()
        SavePlaylistConnectionStatus("Conectado")
        setBootState("ready")
        updateConnectionStatus(true, "Conectado")
        m.pendingAccount = invalid
        m.loginErrorActive = false
        m.connectionMode = ""
        resetAccountLoadedData()
        loadLocalSearchIndexCache()
        m.loginScreen.callFunc("showMessage", "Login confirmado. Carregando...")
        startBackendBootstrap(m.account)
        if m.currentScreen = "home" or m.currentScreen = "login" or m.currentScreen = "" then showHome()
        refreshCurrentCatalogScreenAfterBoot()
        startBackgroundCatalogCache()
        startInitialCategoryPreviewCache()
    else
        SavePlaylistConnectionStatus("Desconectado")
        m.pendingAccount = invalid
        if connectionMode = "auto" then
            m.loginErrorActive = false
            m.connectionMode = ""
            if hasValidLocalCatalogData() then
                setBootState("ready")
                clearAccountReconnectError()
                refreshCurrentCatalogScreenAfterBoot()
            else
                setBootState("error")
                resetAccountLoadedData()
                updateConnectionStatus(false, "Não foi possível reconectar. Abra CONTA para corrigir.")
                if m.currentScreen = "" then showHome()
            end if
        else
            setBootState("error")
            resetAccountLoadedData()
            m.loginErrorActive = true
            updateConnectionStatus(false, "Não foi possível conectar. Verifique os dados.")
            m.connectionMode = ""
            showLogin()
            if result <> invalid and result.backendUnavailable = true then
                m.loginScreen.callFunc("showError", "Não foi possível conectar ao servidor.")
            else if result <> invalid and result.message <> invalid and result.message.ToStr().Trim() <> "" then
                m.loginScreen.callFunc("showError", result.message.ToStr())
            else
                m.loginScreen.callFunc("showError", "Login inválido. Verifique DNS, usuário e senha.")
            end if
        end if
    end if
end sub

sub resetAccountLoadedData()
    m.searchIndexCache = createEmptySearchIndexCache()
    m.movieSearchIndex = []
    m.seriesSearchIndex = []
    m.movieSearchIndexQueue = []
    m.seriesSearchIndexQueue = []
    m.movieSearchIndexUpdating = false
    m.seriesSearchIndexUpdating = false
    m.previewQueue = []
    m.previewUpdating = false
    m.previewKind = ""
    m.previewCategory = invalid
    m.liveCategories = []
    m.liveChannels = []
    m.cachedLiveChannels = []
    m.allLiveCache = []
    m.liveCategoriesLoading = false
    m.liveChannelsLoading = false
    m.movieCategories = []
    m.movies = []
    m.cachedMovies = []
    m.allMoviesCache = []
    m.movieCategoryPreviewCache = []
    m.seriesCategoryPreviewCache = []
    m.cachedSeries = []
    m.allSeriesCache = []
    m.seriesCategories = []
    m.searchChannels = []
    m.searchMovies = []
    m.movieCategoriesLoading = false
    m.moviesLoading = false
    m.backendCatalogAccountKey = ""
    m.backendCatalogCache = invalid
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
    cancelLoginRequest()
    PRINT "Backend indisponível"
    onXtreamConnectionResultForLogin({
        success: false,
        connected: false,
        request: "backendLogin",
        ok: false,
        backendUnavailable: true,
        message: "Não foi possível conectar ao servidor."
    })
end sub

sub cancelXtreamRequest()
    if m.xtreamService <> invalid then m.xtreamService.control = "STOP"
    completeXtreamRequest()
end sub

sub cancelLoginRequest()
    if m.backendService <> invalid then m.backendService.control = "STOP"
    completeXtreamRequest()
end sub

sub onBackendLoginResult()
    result = m.backendService.result
    if result = invalid then return
    completeXtreamRequest()
    handleLoginConnectionResult(result)
end sub

sub startBackendBootstrap(account as Object)
    if m.isDemoMode = true then return
    if m.backendBootstrapService = invalid then return
    if not hasAccount(account) then return

    accountKey = buildBackendBootstrapAccountKey(account)
    if m.backendBootstrapStatus <> invalid then
        if m.backendBootstrapAccountKey = accountKey and (m.backendBootstrapStatus.status = "loading" or m.backendBootstrapStatus.status = "ready") then return
    end if

    m.backendBootstrapAccountKey = accountKey
    m.backendBootstrapStatus = createBackendBootstrapStatus("loading")
    PRINT "BACKEND_REFRESH_START"
    PRINT "BACKEND_BOOTSTRAP_START"

    m.backendBootstrapService.control = "STOP"
    m.backendBootstrapService.action = "bootstrap"
    m.backendBootstrapService.dns = account.dns
    m.backendBootstrapService.username = account.username
    m.backendBootstrapService.password = account.password
    m.backendBootstrapService.control = "RUN"
end sub

sub onBackendBootstrapResult()
    result = m.backendBootstrapService.result
    if result = invalid then return
    if result.request <> "backendBootstrap" then return

    if result.success = true and result.ok = true then
        m.backendBootstrapStatus = buildBackendBootstrapReadyStatus(result)
        PRINT "BOOTSTRAP_COUNTS_RECEIVED movieCategories="; m.backendBootstrapStatus.movieCategories; " movies="; m.backendBootstrapStatus.movies; " seriesCategories="; m.backendBootstrapStatus.seriesCategories; " series="; m.backendBootstrapStatus.series
        if m.backendBootstrapStatus.movieCategories = 0 and m.backendBootstrapStatus.movies = 0 and m.backendBootstrapStatus.seriesCategories = 0 and m.backendBootstrapStatus.series = 0 and hasValidLocalCatalogData() then
            PRINT "BACKEND_EMPTY_USING_CACHE"
        else
            applyBackendCatalog(result)
        end if
        PRINT "BACKEND_REFRESH_READY movieCategories="; m.backendBootstrapStatus.movieCategories; " movies="; m.backendBootstrapStatus.movies; " seriesCategories="; m.backendBootstrapStatus.seriesCategories; " series="; m.backendBootstrapStatus.series
        PRINT "BACKEND_BOOTSTRAP_READY movieCategories="; m.backendBootstrapStatus.movieCategories; " movies="; m.backendBootstrapStatus.movies; " seriesCategories="; m.backendBootstrapStatus.seriesCategories; " series="; m.backendBootstrapStatus.series
    else
        m.backendBootstrapStatus = createBackendBootstrapStatus("error")
        PRINT "BACKEND_BOOTSTRAP_ERROR"
        if result.message <> invalid then PRINT "Backend bootstrap falhou: "; result.message
    end if
end sub

sub applyBackendCatalog(result as Object)
    if result = invalid or result.ok <> true then return
    if not hasAccount(m.account) then return

    movieCategories = normalizeMovieCategories(removeBackendCountOnlyItems(result.movieCategories))
    movies = normalizeMovies(removeBackendCountOnlyItems(result.movies))
    seriesCategories = normalizeSeriesCategories(removeBackendCountOnlyItems(result.seriesCategories))
    series = normalizeSeries(removeBackendCountOnlyItems(result.series))
    if movieCategories.Count() = 0 and movies.Count() = 0 and seriesCategories.Count() = 0 and series.Count() = 0 then return

    m.backendCatalogAccountKey = buildBackendBootstrapAccountKey(m.account)
    m.backendCatalogCache = {
        movieCategories: movieCategories,
        movies: movies,
        seriesCategories: seriesCategories,
        series: series
    }

    if movieCategories.Count() > 0 then
        PRINT "CATEGORIES_FROM_BACKEND movies"
        m.movieCategories = movieCategories
    else if m.movieCategories <> invalid and m.movieCategories.Count() > 0 then
        PRINT "CATEGORIES_FROM_LOCAL_CACHE movies"
    else
        PRINT "CATEGORIES_EMPTY movies"
    end if
    if movies.Count() > 0 then
        m.cachedMovies = movies
        m.allMoviesCache = movies
        m.movieGlobalCatalogLoaded = true
    end if
    if seriesCategories.Count() > 0 then
        PRINT "CATEGORIES_FROM_BACKEND series"
        m.seriesCategories = seriesCategories
    else if m.seriesCategories <> invalid and m.seriesCategories.Count() > 0 then
        PRINT "CATEGORIES_FROM_LOCAL_CACHE series"
    else
        PRINT "CATEGORIES_EMPTY series"
    end if
    if series.Count() > 0 then
        m.cachedSeries = series
        m.allSeriesCache = series
        m.seriesGlobalCatalogLoaded = true
    end if

    rebuildBackendCatalogIndexes()
    m.searchIndexCache.movieCategories = m.movieCategories
    m.searchIndexCache.movies = m.allMoviesCache
    m.searchIndexCache.seriesCategories = m.seriesCategories
    m.searchIndexCache.series = m.allSeriesCache
    SaveSearchIndexCache(m.searchIndexCache)

    PRINT "MOVIE_CATEGORIES_LOADED count="; m.movieCategories.Count()
    PRINT "SERIES_CATEGORIES_LOADED count="; m.seriesCategories.Count()

    refreshCatalogScreensFromBackendCatalog()
    startInitialCategoryPreviewCache()
end sub

function canUseBackendCatalog() as Boolean
    if m.backendBootstrapStatus = invalid or m.backendBootstrapStatus.status <> "ready" then return false
    if m.backendCatalogCache = invalid then return false
    if not hasAccount(m.account) then return false
    return m.backendCatalogAccountKey = buildBackendBootstrapAccountKey(m.account)
end function

sub rebuildBackendCatalogIndexes()
    m.movieCategoryIndex = {}
    m.movieCategoryLoadState = {}
    if m.cachedMovies <> invalid and Type(m.cachedMovies) = "roArray" then
        for each item in m.cachedMovies
            cid = getItemCategoryId(item)
            if cid <> "" then
                if m.movieCategoryIndex[cid] = invalid then m.movieCategoryIndex[cid] = []
                m.movieCategoryIndex[cid].Push(item)
                m.movieCategoryLoadState[cid] = "LOADED"
            end if
        end for
    end if

    m.seriesCategoryIndex = {}
    m.seriesCategoryLoadState = {}
    if m.cachedSeries <> invalid and Type(m.cachedSeries) = "roArray" then
        for each item in m.cachedSeries
            cid = getItemCategoryId(item)
            if cid <> "" then
                if m.seriesCategoryIndex[cid] = invalid then m.seriesCategoryIndex[cid] = []
                m.seriesCategoryIndex[cid].Push(item)
                m.seriesCategoryLoadState[cid] = "LOADED"
            end if
        end for
    end if
end sub

sub refreshCatalogScreensFromBackendCatalog()
    if m.movieListScreen <> invalid and m.movieListScreen.visible = true then
        m.movieListScreen.callFunc("setLoading", false)
        m.movieListScreen.callFunc("setCategories", m.movieCategories)
        if m.selectedMovieCategoryId <> "" then
            m.movies = filterItemsByCategory(m.cachedMovies, m.selectedMovieCategoryId)
            m.movieListScreen.callFunc("setMovies", m.movies)
        end if
    end if
    if m.simpleSeriesScreen <> invalid and m.simpleSeriesScreen.visible = true then
        m.simpleSeriesScreen.callFunc("setLoading", false)
        m.simpleSeriesScreen.callFunc("setCategories", m.seriesCategories)
        if m.selectedSeriesCategoryId <> "" then
            m.simpleSeriesScreen.callFunc("setSeries", filterItemsByCategory(m.cachedSeries, m.selectedSeriesCategoryId))
        else
            m.simpleSeriesScreen.callFunc("setSeries", limitArrayForUiBatch(m.cachedSeries, 60))
        end if
    end if
end sub

function createBackendBootstrapStatus(status as String) as Object
    return {
        status: status,
        movieCategories: 0,
        movies: 0,
        seriesCategories: 0,
        series: 0
    }
end function

function buildBackendBootstrapReadyStatus(result as Object) as Object
    status = createBackendBootstrapStatus("ready")
    status.movieCategories = safeCount(result.movieCategories)
    status.movies = safeCount(result.movies)
    status.seriesCategories = safeCount(result.seriesCategories)
    status.series = safeCount(result.series)
    return status
end function

function buildBackendBootstrapAccountKey(account as Object) as String
    return account.dns.ToStr().Trim() + "|" + account.username.ToStr().Trim() + "|" + account.password.ToStr().Trim()
end function

function safeCount(value as Dynamic) as Integer
    if value = invalid then return 0
    if Type(value) = "roInt" or Type(value) = "Integer" then return value
    if Type(value) = "roArray" then
        if value.Count() = 1 and value[0] <> invalid and value[0].__backendCountOnly = true then return value[0].count
        return value.Count()
    end if
    return 0
end function

function removeBackendCountOnlyItems(value as Dynamic) as Object
    empty = []
    if value = invalid or Type(value) <> "roArray" then return empty
    if value.Count() = 1 and value[0] <> invalid and value[0].__backendCountOnly = true then return empty
    return value
end function

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
    m.seriesSearchIndex = m.searchIndexCache.seriesSearchIndex
    m.cachedMovies = m.searchIndexCache.movies
    m.cachedSeries = m.searchIndexCache.series
    m.allMoviesCache = m.searchIndexCache.movies
    m.allSeriesCache = m.searchIndexCache.series
    m.seriesCategories = m.searchIndexCache.seriesCategories
    m.movieCategoryPreviewCache = m.searchIndexCache.movieCategoryPreviewCache
    m.seriesCategoryPreviewCache = m.searchIndexCache.seriesCategoryPreviewCache
    m.cachedLiveChannels = m.searchIndexCache.liveChannels
    if m.searchIndexCache.liveCategories.Count() > 0 then m.liveCategories = m.searchIndexCache.liveCategories
    if m.searchIndexCache.liveChannels.Count() > 0 then
        m.cachedLiveChannels = m.searchIndexCache.liveChannels
        m.allLiveCache = m.searchIndexCache.liveChannels
    end if
    if m.searchIndexCache.movieCategories.Count() > 0 then
        m.movieCategories = m.searchIndexCache.movieCategories
        PRINT "CATEGORIES_FROM_LOCAL_CACHE movies"
        PRINT "MOVIE_CATEGORIES_LOADED count="; m.movieCategories.Count()
    end if
    if m.searchIndexCache.movies.Count() > 0 then
        m.cachedMovies = m.searchIndexCache.movies
        m.allMoviesCache = m.searchIndexCache.movies
    end if
    if m.searchIndexCache.seriesCategories.Count() > 0 then
        m.seriesCategories = m.searchIndexCache.seriesCategories
        PRINT "CATEGORIES_FROM_LOCAL_CACHE series"
        PRINT "SERIES_CATEGORIES_LOADED count="; m.seriesCategories.Count()
    end if
    if m.searchIndexCache.series.Count() > 0 then
        m.cachedSeries = m.searchIndexCache.series
        m.allSeriesCache = m.searchIndexCache.series
    end if
    if m.searchIndexCache.movieCategoryPreviewCache <> invalid then m.movieCategoryPreviewCache = m.searchIndexCache.movieCategoryPreviewCache
    if m.searchIndexCache.seriesCategoryPreviewCache <> invalid then m.seriesCategoryPreviewCache = m.searchIndexCache.seriesCategoryPreviewCache
    m.movieSearchIndex = []
    m.seriesSearchIndex = []
    m.movieCategoryIndex = {}
    m.movieCategoryLoadState = {}
    if m.cachedMovies <> invalid and Type(m.cachedMovies) = "roArray" then
        for each item in m.cachedMovies
            cid = getItemCategoryId(item)
            if m.movieCategoryIndex[cid] = invalid then m.movieCategoryIndex[cid] = []
            m.movieCategoryIndex[cid].Push(item)
            if cid <> "" then m.movieCategoryLoadState[cid] = "LOADED"
        end for
    end if
    m.seriesCategoryIndex = {}
    m.seriesCategoryLoadState = {}
    if m.cachedSeries <> invalid and Type(m.cachedSeries) = "roArray" then
        for each item in m.cachedSeries
            cid = getItemCategoryId(item)
            if m.seriesCategoryIndex[cid] = invalid then m.seriesCategoryIndex[cid] = []
            m.seriesCategoryIndex[cid].Push(item)
            if cid <> "" then m.seriesCategoryLoadState[cid] = "LOADED"
        end for
    end if
    if hasValidLocalCatalogData() then
        PRINT "LOCAL_CACHE_HIT"
    else
        PRINT "LOCAL_CACHE_EMPTY"
    end if
end sub

sub startBackgroundCatalogCache()
    ' Home must stay light. Do not start global movies/series caching here.
    ' The full lists are loaded only when search is opened or when a category is selected.
    return
end sub

sub cancelSearchIndexRefresh()
    if m.searchIndexTimer <> invalid then m.searchIndexTimer.control = "stop"
    if (m.movieSearchIndexUpdating = true or m.seriesSearchIndexUpdating = true) and m.searchIndexKind <> "" then
        if m.xtreamService <> invalid then m.xtreamService.control = "STOP"
        completeXtreamRequest()
    end if
    m.movieSearchIndexUpdating = false
    m.seriesSearchIndexUpdating = false
    m.movieSearchIndexQueue = []
    m.seriesSearchIndexQueue = []
    m.searchIndexKind = ""
    m.searchIndexCategoryId = ""
    m.searchIndexActiveType = ""
end sub

sub startSearchIndexRefresh()
    ' Disabled: building global movie/series search cache on the render thread
    ' was freezing category navigation and causing runtime &h23 timeouts.
    return
end sub

sub onSearchIndexTimerFire()
    ' Requisições da busca aberta têm prioridade. O cache de previews
    ' roda só em segundo plano para não atrasar filme/série/categoria.
    if m.movieSearchIndexUpdating = true or m.seriesSearchIndexUpdating = true then
        processNextSearchIndexRequest()
    else if m.previewUpdating = true then
        processNextPreviewRequest()
    else
        processNextSearchIndexRequest()
    end if
end sub

sub processNextSearchIndexRequest()
    if m.movieSearchIndexUpdating <> true and m.seriesSearchIndexUpdating <> true then return
    if m.searchIndexKind <> "" then return
    if m.isLoadingRequest = true then
        m.searchIndexTimer.control = "start"
        return
    end if
    job = nextSearchIndexJob()
    if job = invalid then return
    if job.categoryId <> invalid and job.categoryId.ToStr() <> "" then
        if job.kind = "movies" and getCategoryLoadState(m.movieCategoryLoadState, job.categoryId.ToStr()) = "LOADED" then
            if m.searchIndexTimer <> invalid then m.searchIndexTimer.control = "start"
            return
        end if
        if job.kind = "series" and getCategoryLoadState(m.seriesCategoryLoadState, job.categoryId.ToStr()) = "LOADED" then
            if m.searchIndexTimer <> invalid then m.searchIndexTimer.control = "start"
            return
        end if
    end if
    PRINT "SEARCH_CATEGORY_LOADING"
    m.searchIndexKind = job.kind
    m.searchIndexCategoryId = job.categoryId
    m.searchIndexActiveType = job.indexType
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
    if (m.movieSearchIndexUpdating <> true and m.seriesSearchIndexUpdating <> true) or m.searchIndexKind = "" then return false
    kind = m.searchIndexKind
    activeType = m.searchIndexActiveType
    m.searchIndexKind = ""
    m.searchIndexActiveType = ""
    if result.success = true then
        clearAccountReconnectError()
        if kind = "liveCategories" then
            m.liveCategories = normalizeLiveCategories(result.data)
            m.searchIndexCache.liveCategories = m.liveCategories
        else if kind = "live" then
            m.allLiveCache = normalizeLiveChannels(result.data)
            m.cachedLiveChannels = m.allLiveCache
            m.searchIndexCache.liveChannels = m.allLiveCache
        else if kind = "movieCategories" then
            m.movieCategories = normalizeMovieCategories(result.data)
            m.searchIndexCache.movieCategories = m.movieCategories
            queueMissingMovieCategoryJobs()
        else if kind = "movies" then
            freshMovies = normalizeMovies(result.data)
            if m.searchIndexCategoryId = "" then
                if freshMovies.Count() > 0 then m.movieGlobalCatalogLoaded = true
                previewMovies = buildSearchPreviewByCategory(freshMovies, 10, 1200, "movies")
                m.allMoviesCache = mergeUniqueItems(m.allMoviesCache, previewMovies, "movies")
            else
                previewMovies = buildSearchPreviewByCategory(freshMovies, 10, 1200, "movies")
                m.allMoviesCache = mergeUniqueItems(m.allMoviesCache, previewMovies, "movies")
                m.cachedMovies = m.allMoviesCache
                m.movieCategoryPreviewCache = upsertCategoryPreview(m.movieCategoryPreviewCache, { category_id: m.searchIndexCategoryId, category_name: "" }, freshMovies, "movie")
                m.searchIndexCache.movieCategoryPreviewCache = m.movieCategoryPreviewCache
                m.movieCategoryLoadState[m.searchIndexCategoryId] = "LOADED"
            end if
            m.searchIndexCache.movies = getMoviesForSearch()
            m.movieSearchIndex = []
            m.searchIndexCache.movieSearchIndex = []
            if m.movieSearchScreen.visible = true then
                m.movieSearchScreen.callFunc("setMovies", getMoviesForSearch())
                m.movieSearchScreen.callFunc("setCatalogLoading", hasUnloadedMovieCategories())
            end if
            PRINT "SEARCH_CATEGORY_LOADED"
        else if kind = "seriesCategories" then
            m.seriesCategories = normalizeSeriesCategories(result.data)
            m.searchIndexCache.seriesCategories = m.seriesCategories
            queueMissingSeriesCategoryJobs()
        else if kind = "series" then
            freshSeries = normalizeSeries(result.data)
            if m.searchIndexCategoryId = "" then
                if freshSeries.Count() > 0 then m.seriesGlobalCatalogLoaded = true
                previewSeries = buildSearchPreviewByCategory(freshSeries, 10, 1200, "series")
                m.allSeriesCache = mergeUniqueItems(m.allSeriesCache, previewSeries, "series")
            else
                previewSeries = buildSearchPreviewByCategory(freshSeries, 10, 1200, "series")
                m.allSeriesCache = mergeUniqueItems(m.allSeriesCache, previewSeries, "series")
                m.cachedSeries = m.allSeriesCache
                m.seriesCategoryPreviewCache = upsertCategoryPreview(m.seriesCategoryPreviewCache, { category_id: m.searchIndexCategoryId, category_name: "" }, freshSeries, "series")
                m.searchIndexCache.seriesCategoryPreviewCache = m.seriesCategoryPreviewCache
                m.seriesCategoryLoadState[m.searchIndexCategoryId] = "LOADED"
            end if
            m.searchIndexCache.series = getSeriesForSearch()
            m.seriesSearchIndex = []
            m.searchIndexCache.seriesSearchIndex = []
            if m.seriesSearchScreen.visible = true then
                m.seriesSearchScreen.callFunc("setSeries", getSeriesForSearch())
                m.seriesSearchScreen.callFunc("setCatalogLoading", hasUnloadedSeriesCategories())
            end if
            PRINT "SEARCH_CATEGORY_LOADED"
        end if
        SaveSearchIndexCache(m.searchIndexCache)
    else
        if kind = "movies" and m.searchIndexCategoryId = "" then m.movieGlobalCatalogRequested = false
        if kind = "series" and m.searchIndexCategoryId = "" then m.seriesGlobalCatalogRequested = false
        if kind = "movies" and m.searchIndexCategoryId <> "" then m.movieCategoryLoadState[m.searchIndexCategoryId] = "NOT_LOADED"
        if kind = "series" and m.searchIndexCategoryId <> "" then m.seriesCategoryLoadState[m.searchIndexCategoryId] = "NOT_LOADED"
    end if
    finishSearchIndexTypeIfDone(activeType)
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
    m.currentScreen = "series"
    m.simpleSeriesScreen.callFunc("setCategories", m.seriesCategories)
    m.simpleSeriesScreen.callFunc("setPreviewCache", m.seriesCategoryPreviewCache)
    m.simpleSeriesScreen.callFunc("setSeries", limitArrayForUiBatch(m.cachedSeries, 60))
    if isAccountBootLoading() and not canStartCatalogDuringBoot("series") then
        showBootLoadingMessage(m.simpleSeriesScreen)
    else if hasAccount(m.account) and (m.seriesCategories = invalid or m.seriesCategories.Count() = 0) and m.isLoadingRequest <> true then
        m.simpleSeriesScreen.callFunc("setLoading", true)
        loadSeriesCategoriesForCurrentScreen()
    end if
    m.simpleSeriesScreen.callFunc("show")
    m.simpleSeriesScreen.SetFocus(true)
end sub

sub refreshCurrentCatalogScreenAfterBoot()
    if m.currentScreen = "live" then
        if m.liveChannelsScreen <> invalid then
            m.liveChannelsScreen.callFunc("setLoading", false)
            if m.liveCategories <> invalid and m.liveCategories.Count() > 0 then
                m.liveChannelsScreen.callFunc("setCategories", m.liveCategories)
                m.liveChannelsScreen.callFunc("showMessage", "Escolha uma categoria para carregar os canais.")
            else
                loadLiveCategories(m.account)
            end if
        end if
    else if m.currentScreen = "movies" then
        if m.movieListScreen <> invalid then
            m.movieListScreen.callFunc("setLoading", false)
            if m.movieCategories <> invalid and m.movieCategories.Count() > 0 then
                m.movieListScreen.callFunc("setCategories", m.movieCategories)
                m.movieListScreen.callFunc("showMessage", "Escolha uma categoria para carregar os filmes.")
            else
                loadMovieCategories(m.account)
            end if
        end if
    else if m.currentScreen = "series" then
        if m.simpleSeriesScreen <> invalid then
            m.simpleSeriesScreen.callFunc("setLoading", false)
            if m.seriesCategories <> invalid and m.seriesCategories.Count() > 0 then m.simpleSeriesScreen.callFunc("setCategories", m.seriesCategories)
            m.simpleSeriesScreen.callFunc("setSeries", limitArrayForUiBatch(m.cachedSeries, 60))
            if m.seriesCategories = invalid or m.seriesCategories.Count() = 0 then loadSeriesCategoriesForCurrentScreen()
        end if
    end if
end sub

sub loadSeriesCategoriesForCurrentScreen()
    if not hasAccount(m.account) then return
    if canUseBackendCatalog() and m.seriesCategories <> invalid and m.seriesCategories.Count() > 0 then
        if m.simpleSeriesScreen.visible = true then
            m.simpleSeriesScreen.callFunc("setLoading", false)
            m.simpleSeriesScreen.callFunc("setCategories", m.seriesCategories)
        end if
        return
    end if
    PRINT "CATEGORIES_FALLBACK_XTREAM series"
    if beginXtreamRequest("getSeriesCategories") then
        m.seriesCategoriesLoading = true
        m.xtreamService.control = "STOP"
        m.xtreamService.action = "getSeriesCategories"
        m.xtreamService.cacheEnabled = true
        m.xtreamService.categoryId = ""
        m.xtreamService.dns = m.account.dns
        m.xtreamService.username = m.account.username
        m.xtreamService.password = m.account.password
        m.xtreamService.control = "RUN"
    end if
end sub

sub onSeriesCategoriesResult(result as Object)
    if result.success = true then
        clearAccountReconnectError()
        freshCategories = normalizeSeriesCategories(result.data)
        if freshCategories.Count() > 0 then
            m.seriesCategories = freshCategories
        else if m.seriesCategories <> invalid and m.seriesCategories.Count() > 0 then
            PRINT "CATEGORIES_FROM_LOCAL_CACHE series"
        else
            m.seriesCategories = freshCategories
        end if
        PRINT "SERIES_CATEGORIES_LOADED count="; m.seriesCategories.Count()
        if m.seriesCategories.Count() = 0 then PRINT "CATEGORIES_EMPTY series"
        m.searchIndexCache.seriesCategories = m.seriesCategories
        SaveSearchIndexCache(m.searchIndexCache)
        if m.simpleSeriesScreen.visible = true then
            m.simpleSeriesScreen.callFunc("setLoading", false)
            m.simpleSeriesScreen.callFunc("setCategories", m.seriesCategories)
        end if
    end if
end sub

sub onSeriesResult(result as Object)
    resultCategoryId = getSeriesResultCategoryId(result)
    if result.success = true then
        clearAccountReconnectError()
        fresh = normalizeSeries(result.data)
        if resultCategoryId = "" then
            m.allSeriesCache = mergeUniqueItems(m.allSeriesCache, fresh, "series")
            m.cachedSeries = m.allSeriesCache
            m.searchIndexCache.series = m.allSeriesCache
            SaveSearchIndexCache(m.searchIndexCache)
        else
            m.cachedSeries = replaceCachedCategoryItems(m.cachedSeries, fresh, resultCategoryId)
            m.allSeriesCache = mergeUniqueItems(m.allSeriesCache, fresh, "series")
            m.seriesCategoryLoadState[resultCategoryId] = "LOADED"
            m.searchIndexCache.series = m.allSeriesCache
            SaveSearchIndexCache(m.searchIndexCache)
        end if
        ' Keep category index incremental. Rebuilding the whole index on the
        ' render thread after every category/global result causes mini freezes.
        if m.seriesCategoryIndex = invalid then m.seriesCategoryIndex = {}
        if resultCategoryId <> "" then
            m.seriesCategoryIndex[resultCategoryId] = fresh
        else
            addItemsToSeriesCategoryIndex(fresh)
        end if
        if m.simpleSeriesScreen.visible = true then
            if resultCategoryId <> "" then
                if resultCategoryId = m.selectedSeriesCategoryId then
                    m.simpleSeriesScreen.callFunc("setLoading", false)
                    m.simpleSeriesScreen.callFunc("setSeries", limitArrayForUiBatch(fresh, 60))
                end if
            else
                m.simpleSeriesScreen.callFunc("setSeries", limitArrayForUiBatch(m.cachedSeries, 60))
            end if
        end if
        if m.seriesSearchScreen.visible = true then m.seriesSearchScreen.callFunc("setSeries", getSeriesForSearch()) : m.seriesSearchScreen.callFunc("setCatalogLoading", hasUnloadedSeriesCategories())
    else if m.simpleSeriesScreen.visible = true then
        m.simpleSeriesScreen.callFunc("setLoading", false)
    end if
end sub


sub addItemsToMovieCategoryIndex(items as Dynamic)
    if m.movieCategoryIndex = invalid then m.movieCategoryIndex = {}
    if items = invalid or Type(items) <> "roArray" then return
    for each item in items
        cid = getItemCategoryId(item)
        if cid <> "" then
            if m.movieCategoryIndex[cid] = invalid then m.movieCategoryIndex[cid] = []
            m.movieCategoryIndex[cid].Push(item)
        end if
    end for
end sub

sub addItemsToSeriesCategoryIndex(items as Dynamic)
    if m.seriesCategoryIndex = invalid then m.seriesCategoryIndex = {}
    if items = invalid or Type(items) <> "roArray" then return
    for each item in items
        cid = getItemCategoryId(item)
        if cid <> "" then
            if m.seriesCategoryIndex[cid] = invalid then m.seriesCategoryIndex[cid] = []
            m.seriesCategoryIndex[cid].Push(item)
        end if
    end for
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
    showSeriesFromCacheOrLoad(category)
end sub

sub onSeriesCategoryLoadRequested()
    category = m.simpleSeriesScreen.categoryLoadRequested
    if category = invalid then return
    showSeriesFromCacheOrLoad(category)
end sub

sub showSeriesFromCacheOrLoad(category as Object)
    cancelSearchIndexRefresh()
    if m.previewUpdating = true then
        m.previewQueue = []
        m.previewUpdating = false
        m.previewKind = ""
    end if
    categoryId = getCategoryId(category)
    m.selectedSeriesCategory = category
    m.selectedSeriesCategoryId = categoryId
    cached = []
    if m.seriesCategoryIndex <> invalid and m.seriesCategoryIndex[categoryId] <> invalid then cached = m.seriesCategoryIndex[categoryId] else cached = filterItemsByCategory(m.cachedSeries, categoryId)
    if cached.Count() > 0 then
        m.simpleSeriesScreen.callFunc("setLoading", false)
        m.simpleSeriesScreen.callFunc("setSeries", cached)
        return
    end if
    preview = getPreviewItems(m.seriesCategoryPreviewCache, categoryId)
    if preview.Count() > 0 then
        m.simpleSeriesScreen.callFunc("setSeries", preview)
    end if
    m.simpleSeriesScreen.callFunc("setLoading", preview.Count() = 0)
    loadSeries(category)
end sub

sub loadSeries(category as Object)
    categoryId = getCategoryId(category)
    cached = []
    if m.seriesCategoryIndex <> invalid and m.seriesCategoryIndex[categoryId] <> invalid then cached = m.seriesCategoryIndex[categoryId] else cached = filterItemsByCategory(m.cachedSeries, categoryId)
    if cached.Count() > 0 then
        m.simpleSeriesScreen.callFunc("setLoading", false)
        m.simpleSeriesScreen.callFunc("setSeries", cached)
        return
    end if
    if m.isDemoMode = true then
        m.simpleSeriesScreen.callFunc("setLoading", false)
        m.simpleSeriesScreen.callFunc("setSeries", cached)
        return
    end if
    if canUseBackendCatalog() then
        m.simpleSeriesScreen.callFunc("setLoading", false)
        m.simpleSeriesScreen.callFunc("setSeries", filterItemsByCategory(m.cachedSeries, categoryId))
        return
    end if
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
    if series.isHistoryEpisode = true and series.episode <> invalid then
        m.selectedSeries = series.series
        m.selectedEpisode = series.episode
        m.simpleSeriesScreen.callFunc("hide")
        hideAllScreensExcept(m.seriesPlayerScreen)
        m.seriesPlayerScreen.callFunc("setResumePosition", GetHistoryPosition("episode", series.episode))
        m.seriesPlayerScreen.callFunc("show", series.episode)
        return
    end if
    m.selectedSeries = series
    m.simpleSeriesScreen.callFunc("hide")
    setSeriesDetailsCredentials()
    m.seriesDetailsScreen.callFunc("show", series)
    m.seriesDetailsScreen.callFunc("setDetails", series)
    m.seriesDetailsScreen.callFunc("setContinueEpisode", GetLastSeriesEpisode(series))
    loadSeriesInfo(series)
end sub

sub loadSeriesInfo(series as Dynamic)
    seriesId = getSeriesId(series)
    if seriesId = "" or not hasAccount(m.account) or m.isDemoMode = true or m.isLoadingRequest = true then return
    if beginXtreamRequest("getSeriesInfo") then
        m.seriesDetailsScreen.callFunc("setLoading", true)
        m.xtreamService.control = "STOP"
        m.xtreamService.action = "getSeriesInfo"
        m.xtreamService.cacheEnabled = true
        m.xtreamService.categoryId = ""
        m.xtreamService.streamId = seriesId
        m.xtreamService.dns = m.account.dns
        m.xtreamService.username = m.account.username
        m.xtreamService.password = m.account.password
        m.xtreamService.control = "RUN"
    end if
end sub

function getSeriesId(series as Dynamic) as String
    if series = invalid then return ""
    if series.series_id <> invalid then return series.series_id.ToStr()
    if series.stream_id <> invalid then return series.stream_id.ToStr()
    if series.id <> invalid then return series.id.ToStr()
    return ""
end function

function isSeriesInfoResult(result as Dynamic) as Boolean
    return result <> invalid and result.request <> invalid and Left(result.request.ToStr(), 13) = "getSeriesInfo"
end function

sub onSeriesInfoResult(result as Object)
    if m.seriesDetailsScreen.visible = true then m.seriesDetailsScreen.callFunc("setLoading", false)
    if result.success = true and result.data <> invalid then
        details = result.data
        m.selectedSeries = mergeSeriesDetails(m.selectedSeries, details)
        if m.seriesDetailsScreen.visible = true then m.seriesDetailsScreen.callFunc("setDetails", m.selectedSeries)
    else if m.seriesDetailsScreen.visible = true then
        m.seriesDetailsScreen.callFunc("showMessage", "Não foi possível carregar episódios desta série.")
    end if
end sub

function mergeSeriesDetails(series as Dynamic, details as Dynamic) as Object
    merged = {}
    if series <> invalid and Type(series) = "roAssociativeArray" then
        for each k in series
            merged[k] = series[k]
        end for
    end if
    if details <> invalid and Type(details) = "roAssociativeArray" then
        info = details
        if details.info <> invalid then info = details.info
        if info <> invalid and Type(info) = "roAssociativeArray" then
            for each k in info
                merged[k] = info[k]
            end for
        end if
        for each k in ["seasons", "episodes"]
            if details.DoesExist(k) and details[k] <> invalid then merged[k] = details[k]
        end for
    end if
    return merged
end function

sub onSeriesDetailsBack()
    m.seriesDetailsScreen.callFunc("hide")
    if m.openedFromSearch = true then
        PRINT "DETAIL_RETURN_TO_SEARCH"
        if m.seriesSearchScreen <> invalid then
            m.seriesSearchScreen.callFunc("show")
            m.seriesSearchScreen.callFunc("restoreState", m.seriesSearchRestoreState)
            PRINT "DETAIL_SEARCH_CONTEXT_RESTORED"
        end if
        m.openedFromSearch = false
        return
    end if
    m.simpleSeriesScreen.callFunc("show")
end sub

sub onSeriesEpisodeSelected()
    episode = m.seriesDetailsScreen.episodeSelected
    if episode = invalid then return
    title = "Episódio"
    streamUrl = ""
    if episode.title <> invalid then title = episode.title.ToStr().Trim()
    if episode.streamUrl <> invalid then streamUrl = episode.streamUrl.ToStr().Trim()
    if streamUrl = "" then streamUrl = getDirectUrl(episode)
    if title = "" then title = "Episódio"
    if streamUrl = "" then
        m.seriesDetailsScreen.callFunc("showMessage", "Stream sem URL válida")
        return
    end if
    print "MAIN_SCENE openSeriesPlayer chamado selectedEpisode="; title; " episode.url/streamUrl="; streamUrl
    m.selectedEpisode = episode
    episodeToPlay = episode
    episodeToPlay.title = title
    episodeToPlay.streamUrl = streamUrl
    resumePosition = GetHistoryPosition("episode", episodeToPlay)
    m.seriesDetailsScreen.callFunc("hide")
    m.seriesPlayerScreen.callFunc("setResumePosition", resumePosition)
    openPlayer(episodeToPlay, "series")
    UpsertSeriesHistory(m.selectedSeries, invalid, episodeToPlay, 0, 0)
end sub

sub onSeriesPlayerBack()
    position = 0
    duration = 0
    if m.seriesPlayerScreen <> invalid then
        position = m.seriesPlayerScreen.callFunc("getPlaybackPosition")
        duration = m.seriesPlayerScreen.callFunc("getPlaybackDuration")
    end if
    UpsertSeriesHistory(m.selectedSeries, invalid, m.selectedEpisode, position, duration)
    m.seriesPlayerScreen.callFunc("hide")
    setSeriesDetailsCredentials()
    m.seriesDetailsScreen.callFunc("show", m.selectedSeries)
    m.seriesDetailsScreen.callFunc("setDetails", m.selectedSeries)
    m.seriesDetailsScreen.callFunc("setContinueEpisode", GetLastSeriesEpisode(m.selectedSeries))
    m.seriesDetailsScreen.callFunc("focusEpisodes")
end sub

sub onLiveCategoriesResult(result as Object)
    m.liveCategoriesLoading = false
    if m.liveChannelsScreen.visible = true then m.liveChannelsScreen.callFunc("setLoading", false)
    if m.liveCategoriesScreen.visible = true then m.liveCategoriesScreen.callFunc("setLoading", false)
    m.homeScreen.callFunc("setLiveCategoriesLoading", false)

    if result.success = true then
        clearAccountReconnectError()
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
        clearAccountReconnectError()
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
        clearAccountReconnectError()
        freshCategories = normalizeMovieCategories(result.data)
        if freshCategories.Count() > 0 then
            m.movieCategories = freshCategories
        else if m.movieCategories <> invalid and m.movieCategories.Count() > 0 then
            PRINT "CATEGORIES_FROM_LOCAL_CACHE movies"
        else
            m.movieCategories = freshCategories
        end if
        PRINT "MOVIE_CATEGORIES_LOADED count="; m.movieCategories.Count()
        if m.movieCategories.Count() = 0 then PRINT "CATEGORIES_EMPTY movies"
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
        clearAccountReconnectError()
        fresh = normalizeMovies(result.data)
        if resultCategoryId = "" then
            m.allMoviesCache = mergeUniqueItems(m.allMoviesCache, buildSearchPreviewByCategory(fresh, 10, 1200, "movies"), "movies")
        else
            m.cachedMovies = replaceCachedCategoryItems(m.cachedMovies, fresh, resultCategoryId)
            m.allMoviesCache = mergeUniqueItems(m.allMoviesCache, buildSearchPreviewByCategory(fresh, 10, 1200, "movies"), "movies")
            m.movieCategoryLoadState[resultCategoryId] = "LOADED"
        end if
        m.searchIndexCache.movies = getMoviesForSearch()
        m.movieSearchIndex = []
        m.searchIndexCache.movieSearchIndex = []
        SaveSearchIndexCache(m.searchIndexCache)
        if resultCategoryId <> "" then addItemsToMovieCategoryIndex(fresh)
        if m.movieCategoryIndex <> invalid and m.movieCategoryIndex[m.selectedMovieCategoryId] <> invalid then m.movies = m.movieCategoryIndex[m.selectedMovieCategoryId] else m.movies = filterItemsByCategory(m.cachedMovies, m.selectedMovieCategoryId)
        if m.movieListScreen.visible = true then m.movieListScreen.callFunc("setMovies", m.movies)
        if m.movieSearchScreen.visible = true then m.movieSearchScreen.callFunc("setMovies", getMoviesForSearch()) : m.movieSearchScreen.callFunc("setCatalogLoading", hasUnloadedMovieCategories())
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
        print "LIVE PLAYER URL: "; result.data.url
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
        m.selectedMovie = mergeMovieDetails(m.selectedMovie, result.data)
        m.movieDetailScreen.callFunc("setDetails", m.selectedMovie)
    else
        m.movieDetailScreen.callFunc("setLoading", false)
        m.movieDetailScreen.callFunc("showMessage", "Não foi possível carregar. Pressione Voltar e tente novamente.")
    end if
end sub

function mergeMovieDetails(movie as Dynamic, details as Dynamic) as Object
    merged = normalizeMovieFromSearch(movie)
    info = details
    if details <> invalid and Type(details) = "roAssociativeArray" and details.info <> invalid then info = details.info
    if info <> invalid and Type(info) = "roAssociativeArray" then
        for each k in info
            merged[k] = info[k]
        end for
    end if
    return normalizeMovieFromSearch(merged)
end function

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

function isValidLoginConnectionResult(result as Dynamic) as Boolean
    if isValidBackendLoginResult(result) then return true
    return isValidXtreamConnectionResult(result)
end function

function isValidBackendLoginResult(result as Dynamic) as Boolean
    if result = invalid then return false
    if result.request <> "backendLogin" then return false
    return result.success = true and result.connected = true and result.ok = true
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
    urlFields = ["stream_url", "streamUrl", "url", "movie_url", "movieUrl", "direct_source", "direct_url", "directUrl", "playbackUrl"]
    for each field in urlFields
        if item.DoesExist(field) and item[field] <> invalid and item[field].ToStr().Trim() <> "" then return item[field].ToStr().Trim()
    end for
    return ""
end function

function getLiveDirectUrl(item as Dynamic) as String
    if item = invalid then return ""
    urlFields = ["stream_url", "streamUrl", "url", "direct_url", "directUrl", "playbackUrl"]
    for each field in urlFields
        if item.DoesExist(field) and item[field] <> invalid then
            candidate = item[field].ToStr().Trim()
            if isSupportedLiveStreamUrl(candidate) then return candidate
        end if
    end for
    return ""
end function

function isSupportedLiveStreamUrl(streamUrl as String) as Boolean
    lowerUrl = LCase(streamUrl)
    return Instr(1, lowerUrl, ".m3u8") > 0 or Instr(1, lowerUrl, ".ts") > 0
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

function getCategoryName(category as Dynamic) as String
    if category = invalid then return ""
    if category.category_name <> invalid and category.category_name.ToStr().Trim() <> "" then return category.category_name.ToStr().Trim()
    if category.name <> invalid and category.name.ToStr().Trim() <> "" then return category.name.ToStr().Trim()
    if category.title <> invalid and category.title.ToStr().Trim() <> "" then return category.title.ToStr().Trim()
    return ""
end function

function normalizeLiveCategories(data as Dynamic) as Object
    if data = invalid then return []
    if Type(data) = "roArray" then return data
    return []
end function

sub showReconnectErrorIfNoValidCache()
    if hasValidLocalCatalogData() then
        clearAccountReconnectError()
    else
        updateConnectionStatus(false, "Não foi possível reconectar. Abra CONTA para corrigir.")
    end if
end sub

sub clearAccountReconnectError()
    m.accountError = ""
    m.reconnectError = ""
    if m.homeScreen <> invalid then updateConnectionStatus(true, "Conectado")
end sub

function hasValidLocalCatalogData() as Boolean
    if m.liveCategories <> invalid and m.liveCategories.Count() > 0 then return true
    if m.cachedLiveChannels <> invalid and m.cachedLiveChannels.Count() > 0 then return true
    if m.allLiveCache <> invalid and m.allLiveCache.Count() > 0 then return true
    if m.movieCategories <> invalid and m.movieCategories.Count() > 0 then return true
    if m.cachedMovies <> invalid and m.cachedMovies.Count() > 0 then return true
    if m.allMoviesCache <> invalid and m.allMoviesCache.Count() > 0 then return true
    if m.seriesCategories <> invalid and m.seriesCategories.Count() > 0 then return true
    if m.cachedSeries <> invalid and m.cachedSeries.Count() > 0 then return true
    if m.allSeriesCache <> invalid and m.allSeriesCache.Count() > 0 then return true
    return false
end function

function limitArrayForUiBatch(items as Dynamic, maxItems as Integer) as Object
    limited = []
    if items = invalid or Type(items) <> "roArray" then return limited
    for each item in items
        if limited.Count() >= maxItems then exit for
        limited.Push(item)
    end for
    return limited
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

sub setSeriesDetailsCredentials()
    if m.seriesDetailsScreen = invalid then return
    if not hasAccount(m.account) then
        m.seriesDetailsScreen.dns = ""
        m.seriesDetailsScreen.username = ""
        m.seriesDetailsScreen.password = ""
        return
    end if
    m.seriesDetailsScreen.dns = safeText(m.account.dns)
    m.seriesDetailsScreen.username = safeText(m.account.username)
    m.seriesDetailsScreen.password = safeText(m.account.password)
end sub



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
    ' Cache leve: salva até 10 itens por categoria de filmes/séries,
    ' progressivamente, uma requisição por vez. Isso alimenta a busca sem
    ' travar a tela e persiste enquanto a conta permanecer cadastrada.
    if m.isDemoMode = true then return
    if not hasAccount(m.account) then return
    if m.previewUpdating = true then return
    m.previewQueue = []
    if m.seriesCategories <> invalid and Type(m.seriesCategories) = "roArray" then
        PRINT "SERIES_PRELOAD_START"
        for each category in m.seriesCategories
            cid = getCategoryId(category)
            previewItems = getPreviewItems(m.seriesCategoryPreviewCache, cid)
            if cid <> "" and previewItems.Count() = 0 then
                m.previewQueue.Push({ kind: "seriesPreview", action: "getSeries", categoryId: cid, category: category })
            end if
        end for
    end if
    if m.movieCategories <> invalid and Type(m.movieCategories) = "roArray" then
        PRINT "MOVIES_PRELOAD_START"
        for each category in m.movieCategories
            cid = getCategoryId(category)
            previewItems = getPreviewItems(m.movieCategoryPreviewCache, cid)
            if cid <> "" and previewItems.Count() = 0 then
                m.previewQueue.Push({ kind: "moviePreview", action: "getMovies", categoryId: cid, category: category })
            end if
        end for
    end if
    if m.previewQueue.Count() = 0 then return
    m.previewUpdating = true
    m.previewKind = ""
    if m.searchIndexTimer <> invalid then
        m.searchIndexTimer.control = "stop"
        m.searchIndexTimer.control = "start"
    end if
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
        PRINT "SERIES_PRELOAD_READY"
        PRINT "MOVIES_PRELOAD_READY"
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
            ' Do not queue every movie category preview.
        else if kind = "seriesCategories" then
            m.seriesCategories = normalizeSeriesCategories(result.data)
            m.searchIndexCache.seriesCategories = m.seriesCategories
            ' Do not queue every series category preview.
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
