' Main scene for the PXT Player application.
' Startup is intentionally safe: Init only opens Home and never contacts the API.
sub Init()
    m.globalBackground = m.top.FindNode("globalBackground")
    m.globalBackgroundOverlay = m.top.FindNode("globalBackgroundOverlay")
    m.homeScreen = m.top.FindNode("homeScreen")
    m.splashScreen = m.top.FindNode("splashScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.favoritesScreen = m.top.FindNode("favoritesScreen")
    m.recentScreen = m.top.FindNode("recentScreen")
    m.searchScreen = m.top.FindNode("searchScreen")
    m.liveChannelsScreen = m.top.FindNode("liveChannelsScreen")
    m.livePlayerScreen = m.top.FindNode("livePlayerScreen")
    m.movieListScreen = m.top.FindNode("movieListScreen")
    m.movieDetailScreen = m.top.FindNode("movieDetailScreen")
    m.moviePlayerScreen = m.top.FindNode("moviePlayerScreen")
    m.seriesListScreen = m.top.FindNode("seriesListScreen")
    m.seriesDetailScreen = m.top.FindNode("seriesDetailScreen")
    m.seriesSeasonsScreen = m.top.FindNode("seriesSeasonsScreen")
    m.seriesEpisodesScreen = m.top.FindNode("seriesEpisodesScreen")
    m.seriesPlayerScreen = m.top.FindNode("seriesPlayerScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.loginTimeoutTimer = m.top.FindNode("loginTimeoutTimer")
    m.detailTimeoutTimer = m.top.FindNode("detailTimeoutTimer")
    m.splashMinimumTimer = m.top.FindNode("splashMinimumTimer")
    m.splashMaximumTimer = m.top.FindNode("splashMaximumTimer")
    m.pendingDetailRequest = ""
    m.account = invalid
    m.pendingAccount = invalid
    m.liveCategories = []
    m.liveCategoriesLoading = false
    m.liveChannels = []
    m.liveChannelsByCategory = {}
    m.liveChannelsLoading = false
    m.selectedLiveCategory = invalid
    m.selectedLiveCategoryId = ""
    m.selectedLiveChannel = invalid
    m.movieCategories = []
    m.movieCategoriesLoading = false
    m.movies = []
    m.moviesByCategory = {}
    m.moviesLoading = false
    m.selectedMovieCategory = invalid
    m.selectedMovieCategoryId = ""
    m.selectedMovie = invalid
    m.seriesCategories = []
    m.seriesCategoriesLoading = false
    m.series = []
    m.seriesByCategory = {}
    m.seriesLoading = false
    m.selectedSeriesCategory = invalid
    m.selectedSeriesCategoryId = ""
    m.selectedSeries = invalid
    m.selectedSeason = invalid
    m.selectedEpisode = invalid
    m.selectedSeriesSeasons = []
    m.entryPoint = "home"
    m.searchChannels = []
    m.searchMovies = []
    m.searchSeries = []
    m.searchLoadStep = ""
    m.searchMoviesBackgroundLoading = false
    m.searchMode = "all"
    m.searchBackTarget = "home"
    m.splashMinimumElapsed = false
    m.splashMaximumElapsed = false
    m.bootstrapActive = false
    m.bootstrapQueue = []
    m.appReady = false
    m.moviesCacheReady = false
    m.seriesCacheReady = false
    m.liveCacheReady = false

    configureScene()

    m.homeScreen.ObserveField("openPlaylist", "onOpenPlaylistRequested")
    m.homeScreen.ObserveField("openLiveCategories", "onOpenLiveCategoriesRequested")
    m.homeScreen.ObserveField("openMovieCategories", "onOpenMovieCategoriesRequested")
    m.homeScreen.ObserveField("openSeriesCategories", "onOpenSeriesCategoriesRequested")
    m.homeScreen.ObserveField("openFavorites", "onOpenFavoritesRequested")
    m.homeScreen.ObserveField("openRecent", "onOpenRecentRequested")
    m.searchScreen.ObserveField("backRequested", "onSearchBack")
    m.searchScreen.ObserveField("channelSelected", "onSearchChannelSelected")
    m.searchScreen.ObserveField("movieSelected", "onSearchMovieSelected")
    m.searchScreen.ObserveField("seriesSelected", "onSearchSeriesSelected")
    m.recentScreen.ObserveField("backRequested", "onRecentBack")
    m.recentScreen.ObserveField("historySelected", "onHistorySelected")
    m.favoritesScreen.ObserveField("backRequested", "onFavoritesBack")
    m.favoritesScreen.ObserveField("favoriteSelected", "onFavoriteSelected")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")
    m.liveChannelsScreen.ObserveField("searchRequested", "onLiveSearchRequested")
    m.liveChannelsScreen.ObserveField("backRequested", "onLiveChannelsBack")
    m.liveChannelsScreen.ObserveField("channelSelected", "onLiveChannelSelected")
    m.liveChannelsScreen.ObserveField("categorySelected", "onLiveChannelsCategorySelected")
    m.liveChannelsScreen.ObserveField("channelFavoriteToggled", "onLiveChannelFavoriteToggled")
    m.livePlayerScreen.ObserveField("backRequested", "onLivePlayerBack")
    m.movieListScreen.ObserveField("backRequested", "onMovieListBack")
    m.movieListScreen.ObserveField("categorySelected", "onMovieListCategorySelected")
    m.movieListScreen.ObserveField("searchRequested", "onMovieSearchRequested")
    m.movieListScreen.ObserveField("movieSelected", "onMovieSelected")
    m.movieListScreen.ObserveField("movieFavoriteToggled", "onMovieFavoriteToggled")
    m.movieDetailScreen.ObserveField("backRequested", "onMovieDetailBack")
    m.movieDetailScreen.ObserveField("playRequested", "onMovieDetailPlay")
    m.movieDetailScreen.ObserveField("favoriteToggled", "onMovieDetailFavoriteToggled")
    m.moviePlayerScreen.ObserveField("backRequested", "onMoviePlayerBack")
    m.seriesListScreen.ObserveField("backRequested", "onSeriesListBack")
    m.seriesListScreen.ObserveField("categorySelected", "onSeriesListCategorySelected")
    m.seriesListScreen.ObserveField("searchRequested", "onSeriesSearchRequested")
    m.seriesListScreen.ObserveField("seriesSelected", "onSeriesSelected")
    m.seriesListScreen.ObserveField("seriesFavoriteToggled", "onSeriesFavoriteToggled")
    m.seriesDetailScreen.ObserveField("backRequested", "onSeriesDetailBack")
    m.seriesDetailScreen.ObserveField("playRequested", "onSeriesDetailPlay")
    m.seriesDetailScreen.ObserveField("favoriteToggled", "onSeriesDetailFavoriteToggled")
    m.seriesSeasonsScreen.ObserveField("backRequested", "onSeriesSeasonsBack")
    m.seriesSeasonsScreen.ObserveField("seasonSelected", "onSeriesSeasonSelected")
    m.seriesEpisodesScreen.ObserveField("backRequested", "onSeriesEpisodesBack")
    m.seriesEpisodesScreen.ObserveField("episodeSelected", "onSeriesEpisodeSelected")
    m.seriesEpisodesScreen.ObserveField("episodeFavoriteToggled", "onEpisodeFavoriteToggled")
    m.seriesPlayerScreen.ObserveField("backRequested", "onSeriesPlayerBack")
    m.xtreamService.ObserveField("result", "onXtreamConnectionResult")
    m.loginTimeoutTimer.ObserveField("fire", "onLoginTimeout")
    m.detailTimeoutTimer.ObserveField("fire", "onDetailTimeout")
    m.splashMinimumTimer.ObserveField("fire", "onSplashMinimumElapsed")
    m.splashMaximumTimer.ObserveField("fire", "onSplashMaximumElapsed")

    updateConnectionStatus(false, "Modo seguro: nenhuma lista carregada")
    showHome()
end sub

sub startSplashBootstrap()
    ' Keep startup lightweight: Home must become navigable without waiting for
    ' category, movie, series, favorites, recent, or search data.  Those data
    ' loads are intentionally deferred until the user opens each section.
    m.splashMinimumElapsed = true
    m.splashMaximumElapsed = true
    m.bootstrapActive = false
    m.appReady = true
    m.moviesCacheReady = false
    m.seriesCacheReady = false
    m.liveCacheReady = false
    m.bootstrapQueue = []

    if m.splashMinimumTimer <> invalid then m.splashMinimumTimer.control = "stop"
    if m.splashMaximumTimer <> invalid then m.splashMaximumTimer.control = "stop"
    if m.splashScreen <> invalid then m.splashScreen.callFunc("hide")
    showHome()
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
    m.appReady = true
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
    screens = [m.homeScreen, m.loginScreen, m.favoritesScreen, m.recentScreen, m.searchScreen, m.liveChannelsScreen, m.movieListScreen, m.movieDetailScreen, m.seriesListScreen, m.seriesDetailScreen, m.seriesSeasonsScreen, m.seriesEpisodesScreen]
    for each screen in screens
        if screen <> invalid and screen.visible = true then
            screen.SetFocus(true)
            return
        end if
    end for

    m.top.SetFocus(true)
end sub


sub hideScreen(screen as Object)
    if screen <> invalid then screen.callFunc("hide")
end sub

sub hidePlaybackScreens()
    hideScreen(m.livePlayerScreen)
    hideScreen(m.moviePlayerScreen)
    hideScreen(m.seriesPlayerScreen)
end sub

sub hideScreenUnless(screen as Object, activeScreen as Object)
    if screen <> activeScreen then hideScreen(screen)
end sub

sub hidePlaybackScreensExcept(activeScreen as Object)
    hideScreenUnless(m.livePlayerScreen, activeScreen)
    hideScreenUnless(m.moviePlayerScreen, activeScreen)
    hideScreenUnless(m.seriesPlayerScreen, activeScreen)
end sub

sub hideSeriesScreens()
    hideScreen(m.seriesListScreen)
    hideScreen(m.seriesDetailScreen)
    hideScreen(m.seriesSeasonsScreen)
    hideScreen(m.seriesEpisodesScreen)
    hideScreen(m.seriesPlayerScreen)
end sub

sub hideContentScreens()
    hideContentScreensExcept(invalid)
end sub

sub hideContentScreensExcept(activeScreen as Object)
    hideScreenUnless(m.homeScreen, activeScreen)
    hideScreenUnless(m.loginScreen, activeScreen)
    hideScreenUnless(m.favoritesScreen, activeScreen)
    hideScreenUnless(m.recentScreen, activeScreen)
    hideScreenUnless(m.searchScreen, activeScreen)
    hideScreenUnless(m.liveChannelsScreen, activeScreen)
    hideScreenUnless(m.movieListScreen, activeScreen)
    hideScreenUnless(m.movieDetailScreen, activeScreen)
    hideScreenUnless(m.seriesListScreen, activeScreen)
    hideScreenUnless(m.seriesDetailScreen, activeScreen)
    hideScreenUnless(m.seriesSeasonsScreen, activeScreen)
    hideScreenUnless(m.seriesEpisodesScreen, activeScreen)
    hideScreenUnless(m.seriesPlayerScreen, activeScreen)
end sub

sub hideAllScreens()
    hideAllScreensExcept(invalid)
end sub

sub hideAllScreensExcept(activeScreen as Object)
    hideScreenUnless(m.splashScreen, activeScreen)
    hideContentScreensExcept(activeScreen)
    hidePlaybackScreensExcept(activeScreen)
end sub

sub showOnlyScreen(screen as Object)
    hideAllScreensExcept(screen)
    if screen <> invalid then screen.callFunc("show")
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


sub showHome()
    showOnlyScreen(m.homeScreen)
    if m.homeScreen <> invalid then m.homeScreen.SetFocus(true)
end sub

sub showLogin()
    if not hasAccount(m.account) then m.account = LoadSavedPlaylist()
    hideAllScreensExcept(m.loginScreen)
    m.loginScreen.callFunc("show", m.account)
end sub



sub openSearch(mode as String, backTarget as String)
    hideAllScreensExcept(m.searchScreen)
    m.searchMode = mode
    m.searchBackTarget = backTarget
    m.searchScreen.callFunc("show", mode)

    if not hasAccount(m.account) then
        m.searchScreen.callFunc("showMessage", "Conecte uma lista Xtream para buscar.")
        return
    end if

    searchData = getSearchDataForMode(mode)
    m.searchScreen.callFunc("setData", searchData)

    if needsSearchData(mode) then
        m.searchScreen.callFunc("setLoading", true)
        if mode = "movies" then
            m.searchLoadStep = "movies"
            loadSearchMovies()
        else if mode = "live" then
            m.searchLoadStep = "channels"
            loadSearchChannels()
        else if mode = "series" then
            m.searchLoadStep = "series"
            loadSearchSeries()
        end if
    end if
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
        m.seriesListScreen.callFunc("show", m.selectedSeriesCategory)
        m.seriesListScreen.callFunc("focusCategories")
        m.searchScreen.callFunc("hide")
    else
        showHome()
    end if
end sub

function returnToEntryPoint() as Boolean
    if m.entryPoint = "favorites" then
        m.entryPoint = "home"
        m.favoritesScreen.callFunc("setFavorites", LoadFavorites())
        m.favoritesScreen.callFunc("show")
        return true
    else if m.entryPoint = "recent" then
        m.entryPoint = "home"
        m.recentScreen.callFunc("setHistory", LoadViewingHistory())
        m.recentScreen.callFunc("show")
        return true
    else if m.entryPoint = "search" then
        m.entryPoint = "home"
        m.searchScreen.callFunc("show", m.searchMode)
        return true
    end if

    return false
end function

sub onLiveSearchRequested()
    openSearch("live", "live")
end sub

sub onMovieSearchRequested()
    openSearch("movies", "movies")
end sub

sub onSeriesSearchRequested()
    openSearch("series", "series")
end sub

function getSearchDataForMode(mode as String) as Object
    channels = m.searchChannels
    movies = m.searchMovies
    series = m.searchSeries
    if mode = "live" and m.liveChannels <> invalid and m.liveChannels.Count() > 0 then channels = m.liveChannels
    if mode = "movies" and m.movies <> invalid and m.movies.Count() > 0 then movies = m.movies
    if mode = "series" and m.series <> invalid and m.series.Count() > 0 then series = m.series
    return { channels: channels, movies: movies, series: series }
end function

function needsSearchData(mode as String) as Boolean
    if mode = "live" then return m.searchChannels.Count() = 0
    if mode = "movies" then
        if m.searchMovies.Count() > 0 then return false
        return m.movies = invalid or m.movies.Count() = 0
    end if
    if mode = "series" then return m.searchSeries.Count() = 0
    return m.searchChannels.Count() = 0 or m.searchMovies.Count() = 0 or m.searchSeries.Count() = 0
end function

sub onSearchChannelSelected()
    channel = m.searchScreen.channelSelected
    if channel = invalid then return
    m.selectedLiveChannel = channel
    m.entryPoint = "search"
    m.searchScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("show", channel)
    buildLiveStreamUrl(channel)
end sub

sub onSearchMovieSelected()
    movie = m.searchScreen.movieSelected
    if movie = invalid then return
    m.selectedMovie = movie
    m.entryPoint = "search"
    m.searchScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("show", movie)
    m.moviePlayerScreen.callFunc("setResumePosition", GetHistoryPosition("movie", movie))
    buildMovieStreamUrl(movie)
end sub

sub onSearchSeriesSelected()
    series = m.searchScreen.seriesSelected
    if series = invalid then return
    m.selectedSeries = series
    m.entryPoint = "search"
    m.searchScreen.callFunc("hide")
    m.seriesDetailScreen.callFunc("show", series)
    m.seriesDetailScreen.callFunc("setLoading", true)
    loadSeriesInfo(series)
end sub

sub loadSearchChannels()
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
    m.searchMoviesBackgroundLoading = false
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovies"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = ""
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub startBackgroundMoviePreload()
    if not hasAccount(m.account) then return
    if m.searchMoviesBackgroundLoading = true then return
    if m.searchMovies <> invalid and m.searchMovies.Count() > 0 then return
    if m.searchLoadStep <> "" then return

    m.searchMoviesBackgroundLoading = true
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
    hideAllScreensExcept(m.recentScreen)
    m.recentScreen.callFunc("setHistory", LoadViewingHistory())
    m.recentScreen.callFunc("show")
end sub

sub onRecentBack()
    showHome()
end sub

sub onOpenFavoritesRequested()
    hideAllScreensExcept(m.favoritesScreen)
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
    m.entryPoint = "recent"
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
    m.entryPoint = "favorites"
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

sub onSeriesFavoriteToggled()
    ToggleFavorite("series", m.seriesListScreen.seriesFavoriteToggled)
end sub

sub onEpisodeFavoriteToggled()
    ToggleFavorite("episode", m.seriesEpisodesScreen.episodeFavoriteToggled)
end sub

sub onOpenPlaylistRequested()
    showLogin()
end sub

sub onOpenLiveCategoriesRequested()
    hideAllScreensExcept(m.liveChannelsScreen)
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
    hideAllScreensExcept(m.movieListScreen)
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
    m.loginScreen.callFunc("setLoading", true)
    startLoginTimeout()
    connectXtream(account)
end sub

sub onLoginBack()
    stopLoginTimeout()
    showHome()
end sub



sub onLiveChannelsBack()
    showHome()
end sub




sub onMovieListBack()
    showHome()
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
    m.moviesLoading = true
    m.movieListScreen.callFunc("show", category)
    m.movieListScreen.callFunc("setLoading", true)
    loadMovies(category)
end sub

sub onMovieSelected()
    movie = m.movieListScreen.movieSelected
    if movie = invalid then return

    if not hasAccount(m.account) then
        m.movieListScreen.callFunc("showMessage", "Conecte uma lista Xtream para reproduzir filmes.")
        return
    end if

    m.selectedMovie = movie
    m.entryPoint = "home"
    m.movieListScreen.callFunc("hide")
    m.movieDetailScreen.callFunc("show", movie)
    m.movieDetailScreen.callFunc("setLoading", true)
    startDetailTimeout("movie")
    loadMovieInfo(movie)
end sub

sub onMovieDetailBack()
    m.movieDetailScreen.callFunc("hide")
    if returnToEntryPoint() then
        return
    else
        m.movieListScreen.callFunc("show", m.selectedMovieCategory)
    end if
end sub

sub onMovieDetailPlay()
    if m.selectedMovie = invalid then return
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
    UpsertMovieHistory(m.selectedMovie, m.moviePlayerScreen.callFunc("getPlaybackPosition"))
    m.moviePlayerScreen.callFunc("hide")
    if returnToEntryPoint() then
        return
    else
        m.movieDetailScreen.callFunc("show", m.selectedMovie)
    end if
end sub



sub onLiveChannelsCategorySelected()
    category = m.liveChannelsScreen.categorySelected
    if category = invalid then return

    newCategoryId = getCategoryId(category)
    m.selectedLiveCategory = category
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("setAccount", m.account)
    if newCategoryId = m.selectedLiveCategoryId and m.liveChannels <> invalid and m.liveChannels.Count() > 0 then
        m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
        return
    end if
    m.selectedLiveCategoryId = newCategoryId
    m.liveChannels = []
    m.liveChannelsLoading = true
    m.liveChannelsScreen.callFunc("setLoading", true)
    loadLiveChannels(category)
end sub


sub onLiveChannelSelected()
    channel = m.liveChannelsScreen.channelSelected
    if channel = invalid then return

    if not hasAccount(m.account) then
        m.liveChannelsScreen.callFunc("showMessage", "Conecte uma lista Xtream para reproduzir canais de TV ao vivo.")
        return
    end if

    m.selectedLiveChannel = channel
    m.entryPoint = "home"
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("show", channel)
    buildLiveStreamUrl(channel)
end sub

sub onLivePlayerBack()
    m.livePlayerScreen.callFunc("hide")
    if returnToEntryPoint() then
        return
    else
        m.liveChannelsScreen.callFunc("setAccount", m.account)
        m.liveChannelsScreen.callFunc("setCategories", m.liveCategories)
        m.liveChannelsScreen.callFunc("show", m.selectedLiveCategory)
        if m.liveChannels <> invalid and m.liveChannels.Count() > 0 then
            m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
        end if
        m.liveChannelsScreen.callFunc("restoreSelectedChannel", m.selectedLiveChannel)
        m.liveChannelsScreen.SetFocus(true)
    end if
end sub

sub buildLiveStreamUrl(channel as Object)
    streamId = getStreamId(channel)
    streamExtension = getStreamExtension(channel)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "buildLiveStreamUrl"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.streamId = streamId
    m.xtreamService.streamExtension = streamExtension
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub


sub loadMovieInfo(movie as Object)
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
    m.xtreamService.control = "STOP"
    m.xtreamService.callFunc("clearCache")
    m.xtreamService.action = "connect"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub


sub loadMovies(category as Object)
    if not hasAccount(m.account) then
        m.moviesLoading = false
        m.movieListScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar os filmes.")
        return
    end if

    categoryId = getCategoryId(category)
    if m.moviesByCategory <> invalid and m.moviesByCategory.DoesExist(categoryId) then
        m.movies = m.moviesByCategory[categoryId]
        m.moviesLoading = false
        m.movieListScreen.callFunc("setMovies", m.movies)
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
    m.movieCategoriesLoading = true
    m.homeScreen.callFunc("setMovieCategoriesLoading", true)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovieCategories"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub loadLiveChannels(category as Object)
    if not hasAccount(m.account) then
        m.liveChannelsLoading = false
        m.liveChannelsScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar os canais de TV ao vivo.")
        return
    end if

    categoryId = getCategoryId(category)
    if m.liveChannelsByCategory <> invalid and m.liveChannelsByCategory.DoesExist(categoryId) then
        m.liveChannels = m.liveChannelsByCategory[categoryId]
        m.liveChannelsLoading = false
        m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
        return
    end if

    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveStreams"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = categoryId
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadLiveCategories(account as Object)
    m.liveCategoriesLoading = true
    m.homeScreen.callFunc("setLiveCategoriesLoading", true)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveCategories"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub onXtreamConnectionResult()
    result = m.xtreamService.result
    if result = invalid then return

    if isSeriesInfoResult(result) then
        onSeriesInfoResult(result)
        return
    else if result.request = "getSeriesCategories" then
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

    stopLoginTimeout()
    m.loginScreen.callFunc("setLoading", false)

    if m.pendingAccount = invalid then
        return
    end if

    if isValidXtreamConnectionResult(result) then
        m.account = m.pendingAccount
        SavePlaylist(m.account)
        SavePlaylistConnectionStatus("Conectado")
        updateConnectionStatus(true, "Conectado")
        m.pendingAccount = invalid
        m.liveCategories = []
        m.liveChannels = []
        m.liveChannelsByCategory = {}
        m.liveCategoriesLoading = false
        m.liveChannelsLoading = false
        m.movieCategories = []
        m.movies = []
        m.moviesByCategory = {}
        m.searchChannels = []
        m.searchMovies = []
        m.searchSeries = []
        m.movieCategoriesLoading = false
        m.moviesLoading = false
        resetSeriesData()
        showHome()
    else
        SavePlaylistConnectionStatus("Desconectado")
        m.pendingAccount = invalid
        m.liveCategories = []
        m.liveChannels = []
        m.liveChannelsByCategory = {}
        m.liveCategoriesLoading = false
        m.liveChannelsLoading = false
        m.movieCategories = []
        m.movies = []
        m.moviesByCategory = {}
        m.searchChannels = []
        m.searchMovies = []
        m.searchSeries = []
        m.movieCategoriesLoading = false
        m.moviesLoading = false
        resetSeriesData()
        m.loginScreen.callFunc("showError", getResultMessage(result))
    end if
end sub


sub continueBootstrapIfNeeded()
    if m.bootstrapActive = true and m.splashMaximumElapsed <> true then processNextBootstrapRequest()
end sub

sub resetSeriesData()
    m.seriesCategories = []
    m.series = []
    m.seriesByCategory = {}
    m.seriesCategoriesLoading = false
    m.seriesLoading = false
end sub

sub onOpenSeriesCategoriesRequested()
    ' Temporary safe screen: do not load categories or series from Home.
    hideAllScreensExcept(m.seriesListScreen)
    m.seriesListScreen.callFunc("resetSelection")
    m.seriesListScreen.callFunc("show", invalid)
    m.seriesListScreen.callFunc("showMessage", "Séries será carregado depois")
end sub



sub onSeriesListBack()
    showHome()
end sub

sub onSeriesSeasonsBack()
    m.seriesSeasonsScreen.callFunc("hide")
    m.seriesDetailScreen.callFunc("show", m.selectedSeries)
end sub

sub onSeriesEpisodesBack()
    m.seriesEpisodesScreen.callFunc("hide")
    m.seriesSeasonsScreen.callFunc("show", m.selectedSeries)
end sub

sub onSeriesPlayerBack()
    UpsertSeriesHistory(m.selectedSeries, m.selectedSeason, m.selectedEpisode, m.seriesPlayerScreen.callFunc("getPlaybackPosition"))
    m.seriesPlayerScreen.callFunc("hide")
    if returnToEntryPoint() then
        return
    else
        m.seriesEpisodesScreen.callFunc("show", m.selectedSeason)
    end if
end sub



sub onSeriesListCategorySelected()
    category = m.seriesListScreen.categorySelected
    if category = invalid then return
    newCategoryId = getCategoryId(category)
    m.selectedSeriesCategory = category
    if newCategoryId = m.selectedSeriesCategoryId and m.series <> invalid and m.series.Count() > 0 then
        m.seriesListScreen.callFunc("show", category)
        m.seriesListScreen.callFunc("setSeries", m.series)
        return
    end if
    m.selectedSeriesCategoryId = newCategoryId
    m.series = []
    m.seriesLoading = true
    m.seriesListScreen.callFunc("show", category)
    m.seriesListScreen.callFunc("setLoading", true)
    loadSeries(category)
end sub

sub onSeriesSelected()
    series = m.seriesListScreen.seriesSelected
    if series = invalid then return
    m.selectedSeries = series
    m.entryPoint = "home"
    m.selectedSeriesSeasons = []
    m.seriesListScreen.callFunc("hide")
    m.seriesDetailScreen.callFunc("show", series)
    m.seriesDetailScreen.callFunc("setLoading", true)
    loadSeriesInfo(series)
end sub

sub onSeriesDetailBack()
    m.seriesDetailScreen.callFunc("hide")
    if returnToEntryPoint() then
        return
    else
        m.seriesListScreen.callFunc("show", m.selectedSeriesCategory)
    end if
end sub

sub onSeriesDetailPlay()
    if m.selectedSeries = invalid then return
    m.seriesDetailScreen.callFunc("hide")
    m.seriesSeasonsScreen.callFunc("resetSelection")
    m.seriesSeasonsScreen.callFunc("show", m.selectedSeries)
    if m.selectedSeriesSeasons <> invalid and m.selectedSeriesSeasons.Count() > 0 then
        m.seriesSeasonsScreen.callFunc("setSeasons", m.selectedSeriesSeasons)
    else if m.pendingDetailRequest = "series" then
        m.seriesSeasonsScreen.callFunc("setLoading", true)
    else
        m.seriesSeasonsScreen.callFunc("setLoading", true)
        loadSeriesInfo(m.selectedSeries)
    end if
end sub


sub onSeriesDetailFavoriteToggled()
    ToggleFavorite("series", m.seriesDetailScreen.favoriteToggled)
end sub

sub onSeriesSeasonSelected()
    season = m.seriesSeasonsScreen.seasonSelected
    if season = invalid then return
    m.selectedSeason = season
    m.seriesSeasonsScreen.callFunc("hide")
    m.seriesEpisodesScreen.callFunc("resetSelection")
    m.seriesEpisodesScreen.callFunc("show", season)
    m.seriesEpisodesScreen.callFunc("setLoading", true)

    episodes = getSeasonEpisodes(season)
    if episodes.Count() > 0 then
        m.seriesEpisodesScreen.callFunc("setEpisodes", episodes)
    else
        m.seriesEpisodesScreen.callFunc("showMessage", "Esta temporada não possui episódios disponíveis.")
    end if
end sub

sub onSeriesEpisodeSelected()
    episode = m.seriesEpisodesScreen.episodeSelected
    if episode = invalid then return
    if not hasAccount(m.account) then
        m.seriesEpisodesScreen.callFunc("showMessage", "Conecte uma lista Xtream para reproduzir episódios.")
        return
    end if
    m.selectedEpisode = episode
    if getEpisodeId(episode) = "" then
        m.seriesEpisodesScreen.callFunc("showMessage", "Não foi possível abrir este episódio: stream inválido.")
        return
    end if
    m.seriesEpisodesScreen.callFunc("hide")
    m.seriesPlayerScreen.callFunc("show", episode)
    m.seriesPlayerScreen.callFunc("setResumePosition", GetHistoryPosition("episode", episode))
    buildSeriesStreamUrl(episode)
end sub

sub loadSeriesCategories(account as Object)
    m.seriesCategoriesLoading = true
    m.homeScreen.callFunc("setSeriesCategoriesLoading", true)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeriesCategories"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSeries(category as Object)
    if not hasAccount(m.account) then
        m.seriesLoading = false
        m.seriesListScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as séries.")
        return
    end if
    categoryId = getCategoryId(category)
    if m.seriesByCategory <> invalid and m.seriesByCategory.DoesExist(categoryId) then
        m.series = m.seriesByCategory[categoryId]
        m.seriesLoading = false
        m.seriesListScreen.callFunc("setSeries", m.series)
        return
    end if
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeries"
    m.xtreamService.cacheEnabled = true
    m.xtreamService.categoryId = categoryId
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSeriesInfo(series as Object)
    if not hasAccount(m.account) then
        showSeriesInfoFailure("Conecte uma lista Xtream para carregar as temporadas desta série.")
        return
    end if

    seriesId = getSeriesId(series)
    if seriesId = "" then
        showSeriesInfoFailure("Não foi possível carregar temporadas: série sem identificador.")
        return
    end if

    startDetailTimeout("series")
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

sub startLoginTimeout()
    if m.loginTimeoutTimer = invalid then return
    m.loginTimeoutTimer.control = "stop"
    m.loginTimeoutTimer.duration = 15
    m.loginTimeoutTimer.control = "start"
end sub

sub stopLoginTimeout()
    if m.loginTimeoutTimer = invalid then return
    m.loginTimeoutTimer.control = "stop"
end sub

sub onLoginTimeout()
    if m.pendingAccount = invalid then return

    m.xtreamService.control = "STOP"
    m.pendingAccount = invalid
    m.liveCategoriesLoading = false
    m.liveChannelsLoading = false
    m.movieCategoriesLoading = false
    m.moviesLoading = false
    resetSeriesData()
    SavePlaylistConnectionStatus("Desconectado")
    m.loginScreen.callFunc("showError", "Servidor não respondeu. Verifique DNS, usuário e senha.")
end sub


sub startDetailTimeout(kind as String)
    m.pendingDetailRequest = kind
    if m.detailTimeoutTimer = invalid then return
    m.detailTimeoutTimer.control = "stop"
    m.detailTimeoutTimer.duration = 10
    m.detailTimeoutTimer.control = "start"
end sub

sub stopDetailTimeout(kind as String)
    if m.pendingDetailRequest = kind then m.pendingDetailRequest = ""
    if m.detailTimeoutTimer <> invalid then m.detailTimeoutTimer.control = "stop"
end sub

sub onDetailTimeout()
    kind = m.pendingDetailRequest
    m.pendingDetailRequest = ""
    m.xtreamService.control = "STOP"
    if kind = "movie" then
        if m.movieDetailScreen.visible = true then m.movieDetailScreen.callFunc("setLoading", false)
    else if kind = "series" then
        if m.seriesDetailScreen.visible = true then m.seriesDetailScreen.callFunc("setLoading", false)
        if m.seriesSeasonsScreen.visible = true then m.seriesSeasonsScreen.callFunc("showMessage", "Não foi possível carregar as temporadas desta série. Tente novamente mais tarde.")
    end if
end sub

sub onMovieCategoriesResult(result as Object)
    m.movieCategoriesLoading = false

    if result.success = true then
        m.movieCategories = normalizeMovieCategories(result.data)
        if m.movieCategories.Count() > 0 then
            updateConnectionStatus(true, "Conectado • Categorias de filmes carregadas")
            if m.movieListScreen.visible = true then
                m.movieListScreen.callFunc("setCategories", m.movieCategories)
                m.movieListScreen.callFunc("showMessage", "Escolha uma categoria para carregar os filmes.")
                m.movieListScreen.callFunc("focusCategories")
            end if
        else
            updateConnectionStatus(true, "Conectado • Nenhuma categoria de filmes encontrada")
            if m.movieListScreen.visible = true then
                m.movieListScreen.callFunc("showMessage", "Nenhuma categoria de filmes foi encontrada.")
                m.movieListScreen.callFunc("focusCategories")
            end if
        end if
    else
        updateConnectionStatus(true, "Conectado • Não foi possível carregar categorias de filmes")
        if m.movieListScreen.visible = true then
            m.movieListScreen.callFunc("showMessage", "Não foi possível carregar as categorias de filmes. Tente novamente mais tarde.")
            m.movieListScreen.callFunc("focusCategories")
        end if
    end if
    continueBootstrapIfNeeded()
end sub

sub onMoviesResult(result as Object)
    if m.searchLoadStep = "movies" and getMoviesResultCategoryId(result) = "" then
        if result.success = true then m.searchMovies = normalizeMovies(result.data) : m.moviesCacheReady = true
        m.searchLoadStep = "series"
        if m.searchScreen.visible = true then m.searchScreen.callFunc("setData", { channels: m.searchChannels, movies: m.searchMovies, series: m.searchSeries })
        loadSearchSeries()
        return
    end if

    if m.searchMoviesBackgroundLoading = true and getMoviesResultCategoryId(result) = "" then
        m.searchMoviesBackgroundLoading = false
        if result.success = true then m.searchMovies = normalizeMovies(result.data) : m.moviesCacheReady = true
        if m.searchScreen.visible = true then
            m.searchScreen.callFunc("setLoading", false)
            m.searchScreen.callFunc("setData", { channels: m.searchChannels, movies: m.searchMovies, series: m.searchSeries })
        end if
        return
    end if

    resultCategoryId = getMoviesResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedMovieCategoryId then
        return
    end if

    m.moviesLoading = false

    if result.success = true then
        m.movies = normalizeMovies(result.data)
        if m.moviesByCategory = invalid then m.moviesByCategory = {}
        m.moviesByCategory[resultCategoryId] = m.movies
        if m.movies.Count() > 0 then
            if m.movieListScreen.visible = true then
                m.movieListScreen.callFunc("setMovies", m.movies)
            end if
        else
            if m.movieListScreen.visible = true then
                m.movieListScreen.callFunc("showMessage", "Nenhum filme foi encontrado nesta categoria.")
            end if
        end if
    else
        if m.movieListScreen.visible = true then
            m.movieListScreen.callFunc("showMessage", "Não foi possível carregar os filmes desta categoria. Tente novamente mais tarde.")
        end if
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

sub onLiveCategoriesResult(result as Object)
    m.liveCategoriesLoading = false

    if result.success = true then
        m.liveCategories = normalizeLiveCategories(result.data)
        if m.liveCategories.Count() > 0 then
            updateConnectionStatus(true, "Conectado • Categorias de TV ao vivo carregadas")
            if m.liveChannelsScreen.visible = true then
                m.liveChannelsScreen.callFunc("setCategories", m.liveCategories)
                m.liveChannelsScreen.callFunc("showMessage", "Escolha uma categoria para carregar os canais.")
                m.liveChannelsScreen.callFunc("focusCategories")
            end if
        else
            updateConnectionStatus(true, "Conectado • Nenhuma categoria de TV ao vivo encontrada")
            if m.liveChannelsScreen.visible = true then
                m.liveChannelsScreen.callFunc("showMessage", "Nenhuma categoria de TV ao vivo foi encontrada.")
                m.liveChannelsScreen.callFunc("focusCategories")
            end if
        end if
    else
        updateConnectionStatus(true, "Conectado • Não foi possível carregar categorias de TV ao vivo")
        if m.liveChannelsScreen.visible = true then
            m.liveChannelsScreen.callFunc("showMessage", "Não foi possível carregar as categorias de TV ao vivo. Tente novamente mais tarde.")
            m.liveChannelsScreen.callFunc("focusCategories")
        end if
    end if
    continueBootstrapIfNeeded()
end sub

sub onLiveChannelsResult(result as Object)
    if m.searchLoadStep = "channels" and getLiveStreamsResultCategoryId(result) = "" then
        if result.success = true then m.searchChannels = normalizeLiveChannels(result.data) : m.liveCacheReady = true
        m.searchLoadStep = "movies"
        if m.searchScreen.visible = true then m.searchScreen.callFunc("setData", { channels: m.searchChannels, movies: m.searchMovies, series: m.searchSeries })
        loadSearchMovies()
        return
    end if

    resultCategoryId = getLiveStreamsResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedLiveCategoryId then
        return
    end if

    m.liveChannelsLoading = false

    if result.success = true then
        m.liveChannels = normalizeLiveChannels(result.data)
        if m.liveChannelsByCategory = invalid then m.liveChannelsByCategory = {}
        m.liveChannelsByCategory[resultCategoryId] = m.liveChannels
        if m.liveChannels.Count() > 0 then
            if m.liveChannelsScreen.visible = true then
                m.liveChannelsScreen.callFunc("setChannels", m.liveChannels)
            end if
        else
            if m.liveChannelsScreen.visible = true then
                m.liveChannelsScreen.callFunc("showMessage", "Nenhum canal foi encontrado nesta categoria.")
            end if
        end if
    else
        if m.liveChannelsScreen.visible = true then
            m.liveChannelsScreen.callFunc("showMessage", "Não foi possível carregar os canais desta categoria. Tente novamente mais tarde.")
        end if
    end if
end sub


sub onLiveStreamUrlResult(result as Object)
    if m.livePlayerScreen.visible <> true then return

    if result.success = true and result.data <> invalid and result.data.url <> invalid then
        m.livePlayerScreen.callFunc("play", result.data.url)
    else
        m.livePlayerScreen.callFunc("showError", "Não foi possível preparar a reprodução deste canal.")
    end if
end sub



sub onSeriesCategoriesResult(result as Object)
    m.seriesCategoriesLoading = false
    if result.success = true then
        m.seriesCategories = normalizeSeriesCategories(result.data)
        if m.seriesCategories.Count() > 0 then
            updateConnectionStatus(true, "Conectado • Categorias de séries carregadas")
            if m.seriesListScreen.visible = true then
                m.seriesListScreen.callFunc("setCategories", m.seriesCategories)
                m.seriesListScreen.callFunc("showMessage", "Escolha uma categoria para carregar as séries.")
                m.seriesListScreen.callFunc("focusCategories")
            end if
        else
            updateConnectionStatus(true, "Conectado • Nenhuma categoria de séries encontrada")
            if m.seriesListScreen.visible = true then
                m.seriesListScreen.callFunc("showMessage", "Nenhuma categoria de séries foi encontrada.")
                m.seriesListScreen.callFunc("focusCategories")
            end if
        end if
    else
        updateConnectionStatus(true, "Conectado • Não foi possível carregar categorias de séries")
        if m.seriesListScreen.visible = true then
            m.seriesListScreen.callFunc("showMessage", "Não foi possível carregar as categorias de séries. Tente novamente mais tarde.")
            m.seriesListScreen.callFunc("focusCategories")
        end if
    end if
    continueBootstrapIfNeeded()
end sub

sub onSeriesResult(result as Object)
    if m.searchLoadStep = "series" and getSeriesResultCategoryId(result) = "" then
        if result.success = true then m.searchSeries = normalizeSeries(result.data) : m.seriesCacheReady = true
        m.searchLoadStep = ""
        if m.searchScreen.visible = true then
            m.searchScreen.callFunc("setLoading", false)
            m.searchScreen.callFunc("setData", { channels: m.searchChannels, movies: m.searchMovies, series: m.searchSeries })
        end if
        return
    end if

    resultCategoryId = getSeriesResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedSeriesCategoryId then
        return
    end if

    m.seriesLoading = false
    if result.success = true then
        m.series = normalizeSeries(result.data)
        if m.seriesByCategory = invalid then m.seriesByCategory = {}
        m.seriesByCategory[resultCategoryId] = m.series
        if m.series.Count() > 0 then
            if m.seriesListScreen.visible = true then m.seriesListScreen.callFunc("setSeries", m.series)
        else
            if m.seriesListScreen.visible = true then m.seriesListScreen.callFunc("showMessage", "Nenhuma série foi encontrada nesta categoria.")
        end if
    else
        if m.seriesListScreen.visible = true then m.seriesListScreen.callFunc("showMessage", "Não foi possível carregar as séries desta categoria. Tente novamente mais tarde.")
    end if
end sub

sub onSeriesInfoResult(result as Object)
    stopDetailTimeout("series")
    if result.success = true then
        if m.seriesDetailScreen.visible = true then m.seriesDetailScreen.callFunc("setDetails", result.data)
        seasons = normalizeSeriesSeasons(result.data)
        m.selectedSeriesSeasons = seasons
        if seasons.Count() > 0 then
            if m.seriesSeasonsScreen.visible = true then m.seriesSeasonsScreen.callFunc("setSeasons", seasons)
        else
            if m.seriesSeasonsScreen.visible = true then m.seriesSeasonsScreen.callFunc("showMessage", "Esta série não possui temporadas ou episódios disponíveis.")
        end if
    else
        showSeriesInfoFailure("Não foi possível carregar as temporadas desta série. Você pode voltar e tentar novamente.")
    end if
end sub

sub showSeriesInfoFailure(message as String)
    stopDetailTimeout("series")
    m.selectedSeriesSeasons = []
    if m.seriesDetailScreen.visible = true then m.seriesDetailScreen.callFunc("setLoading", false)
    if m.seriesSeasonsScreen.visible = true then m.seriesSeasonsScreen.callFunc("showMessage", message)
end sub

sub onMovieInfoResult(result as Object)
    stopDetailTimeout("movie")
    if m.movieDetailScreen.visible <> true then return
    if result.success = true then
        m.movieDetailScreen.callFunc("setDetails", result.data)
    else
        m.movieDetailScreen.callFunc("setLoading", false)
    end if
end sub

function isMovieInfoResult(result as Dynamic) as Boolean
    if result = invalid or result.request = invalid then return false
    prefix = "getMovieInfo"
    return Left(result.request.ToStr(), Len(prefix)) = prefix
end function

sub onSeriesStreamUrlResult(result as Object)
    if m.seriesPlayerScreen.visible <> true then return
    if result.success = true and result.data <> invalid and result.data.url <> invalid then
        m.seriesPlayerScreen.callFunc("play", result.data.url)
    else
        m.seriesPlayerScreen.callFunc("showError", "Não foi possível preparar a reprodução deste episódio.")
    end if
end sub

function isSeriesInfoResult(result as Dynamic) as Boolean
    if result = invalid or result.request = invalid then return false
    request = result.request.ToStr()
    prefix = "getSeriesInfo"
    return Left(request, Len(prefix)) = prefix
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
    data = unwrapSeriesInfoData(data)
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

function unwrapSeriesInfoData(data as Dynamic) as Dynamic
    if data = invalid or Type(data) <> "roAssociativeArray" then return data
    if (not data.DoesExist("seasons")) and (not data.DoesExist("episodes")) then
        if data.DoesExist("data") and data.data <> invalid then return unwrapSeriesInfoData(data.data)
        if data.DoesExist("result") and data.result <> invalid then return unwrapSeriesInfoData(data.result)
        if data.DoesExist("response") and data.response <> invalid then return unwrapSeriesInfoData(data.response)
    end if
    return data
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
    if channel.stream_id <> invalid and channel.stream_id.ToStr().Trim() <> "" then return channel.stream_id.ToStr().Trim()
    if channel.id <> invalid and channel.id.ToStr().Trim() <> "" then return channel.id.ToStr().Trim()
    return ""
end function

function getChannelNameForLog(channel as Dynamic) as String
    if channel = invalid then return ""
    if channel.name <> invalid and channel.name.ToStr().Trim() <> "" then return channel.name.ToStr().Trim()
    if channel.title <> invalid and channel.title.ToStr().Trim() <> "" then return channel.title.ToStr().Trim()
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
