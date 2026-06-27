' Main scene for the PXT Player application.
' It coordinates feature screens and authenticates playlist credentials through
' XtreamService, including live TV categories and channel lists.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.favoritesScreen = m.top.FindNode("favoritesScreen")
    m.recentScreen = m.top.FindNode("recentScreen")
    m.searchScreen = m.top.FindNode("searchScreen")
    m.liveCategoriesScreen = m.top.FindNode("liveCategoriesScreen")
    m.liveChannelsScreen = m.top.FindNode("liveChannelsScreen")
    m.livePlayerScreen = m.top.FindNode("livePlayerScreen")
    m.movieCategoriesScreen = m.top.FindNode("movieCategoriesScreen")
    m.movieListScreen = m.top.FindNode("movieListScreen")
    m.moviePlayerScreen = m.top.FindNode("moviePlayerScreen")
    m.seriesCategoriesScreen = m.top.FindNode("seriesCategoriesScreen")
    m.seriesListScreen = m.top.FindNode("seriesListScreen")
    m.seriesSeasonsScreen = m.top.FindNode("seriesSeasonsScreen")
    m.seriesEpisodesScreen = m.top.FindNode("seriesEpisodesScreen")
    m.seriesPlayerScreen = m.top.FindNode("seriesPlayerScreen")
    m.xtreamService = m.top.FindNode("xtreamService")
    m.loginTimeoutTimer = m.top.FindNode("loginTimeoutTimer")
    m.account = LoadSavedPlaylist()
    m.pendingAccount = invalid
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
    m.searchMode = "all"
    m.searchBackTarget = "home"

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
    m.liveCategoriesScreen.ObserveField("backRequested", "onLiveCategoriesBack")
    m.liveCategoriesScreen.ObserveField("categorySelected", "onLiveCategorySelected")
    m.liveCategoriesScreen.ObserveField("searchRequested", "onLiveSearchRequested")
    m.liveChannelsScreen.ObserveField("backRequested", "onLiveChannelsBack")
    m.liveChannelsScreen.ObserveField("channelSelected", "onLiveChannelSelected")
    m.liveChannelsScreen.ObserveField("channelFavoriteToggled", "onLiveChannelFavoriteToggled")
    m.livePlayerScreen.ObserveField("backRequested", "onLivePlayerBack")
    m.movieCategoriesScreen.ObserveField("backRequested", "onMovieCategoriesBack")
    m.movieCategoriesScreen.ObserveField("categorySelected", "onMovieCategorySelected")
    m.movieCategoriesScreen.ObserveField("searchRequested", "onMovieSearchRequested")
    m.movieListScreen.ObserveField("backRequested", "onMovieListBack")
    m.movieListScreen.ObserveField("categorySelected", "onMovieListCategorySelected")
    m.movieListScreen.ObserveField("movieSelected", "onMovieSelected")
    m.movieListScreen.ObserveField("movieFavoriteToggled", "onMovieFavoriteToggled")
    m.moviePlayerScreen.ObserveField("backRequested", "onMoviePlayerBack")
    m.seriesCategoriesScreen.ObserveField("backRequested", "onSeriesCategoriesBack")
    m.seriesCategoriesScreen.ObserveField("categorySelected", "onSeriesCategorySelected")
    m.seriesCategoriesScreen.ObserveField("searchRequested", "onSeriesSearchRequested")
    m.seriesListScreen.ObserveField("backRequested", "onSeriesListBack")
    m.seriesListScreen.ObserveField("categorySelected", "onSeriesListCategorySelected")
    m.seriesListScreen.ObserveField("seriesSelected", "onSeriesSelected")
    m.seriesListScreen.ObserveField("seriesFavoriteToggled", "onSeriesFavoriteToggled")
    m.seriesSeasonsScreen.ObserveField("backRequested", "onSeriesSeasonsBack")
    m.seriesSeasonsScreen.ObserveField("seasonSelected", "onSeriesSeasonSelected")
    m.seriesEpisodesScreen.ObserveField("backRequested", "onSeriesEpisodesBack")
    m.seriesEpisodesScreen.ObserveField("episodeSelected", "onSeriesEpisodeSelected")
    m.seriesEpisodesScreen.ObserveField("episodeFavoriteToggled", "onEpisodeFavoriteToggled")
    m.seriesPlayerScreen.ObserveField("backRequested", "onSeriesPlayerBack")
    m.xtreamService.ObserveField("result", "onXtreamConnectionResult")
    m.loginTimeoutTimer.ObserveField("fire", "onLoginTimeout")

    if hasAccount(m.account) then
        updateConnectionStatus(true, "Conectado")
    else
        updateConnectionStatus(false, "Nenhuma playlist conectada")
    end if

    showHome()
end sub

sub configureScene()
    m.top.backgroundColor = "#000000"
    m.top.backgroundURI = ""
    m.homeScreen.SetFocus(true)
end sub

sub showHome()
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.homeScreen.callFunc("show")
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.loginScreen.callFunc("show", m.account)
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
    m.moviePlayerScreen.callFunc("hide")
    hideSeriesScreens()
    m.searchMode = mode
    m.searchBackTarget = backTarget
    m.searchScreen.callFunc("show", mode)

    if not hasAccount(m.account) then
        m.searchScreen.callFunc("showMessage", "Conecte uma lista Xtream para buscar.")
        return
    end if

    m.searchScreen.callFunc("setData", { channels: m.searchChannels, movies: m.searchMovies, series: m.searchSeries })
    if needsSearchData(mode) then
        m.searchScreen.callFunc("setLoading", true)
        m.searchLoadStep = "channels"
        loadSearchChannels()
    end if
end sub

sub onSearchBack()
    if m.searchBackTarget = "live" then
        m.liveCategoriesScreen.callFunc("show")
        m.searchScreen.callFunc("hide")
    else if m.searchBackTarget = "movies" then
        m.movieCategoriesScreen.callFunc("show")
        m.searchScreen.callFunc("hide")
    else if m.searchBackTarget = "series" then
        m.seriesCategoriesScreen.callFunc("show")
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
    openSearch("movies", "movies")
end sub

sub onSeriesSearchRequested()
    m.seriesCategoriesScreen.callFunc("hide")
    openSearch("series", "series")
end sub

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
    m.seriesSeasonsScreen.callFunc("resetSelection")
    m.seriesSeasonsScreen.callFunc("show", series)
    m.seriesSeasonsScreen.callFunc("setLoading", true)
    loadSeriesInfo(series)
end sub

sub loadSearchChannels()
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveStreams"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.categoryId = ""
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSearchMovies()
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovies"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.categoryId = ""
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSearchSeries()
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeries"
    m.xtreamService.cacheEnabled = false
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
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
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
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
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
        m.seriesSeasonsScreen.callFunc("resetSelection")
        m.seriesSeasonsScreen.callFunc("show", content)
        m.seriesSeasonsScreen.callFunc("setLoading", true)
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
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("resetSelection")
    m.liveCategoriesScreen.callFunc("show")

    if not hasAccount(m.account) then
        m.liveCategoriesScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as categorias de TV ao vivo.")
    else if m.liveCategoriesLoading then
        m.liveCategoriesScreen.callFunc("setLoading", true)
    else if m.liveCategories <> invalid and m.liveCategories.Count() > 0 then
        m.liveCategoriesScreen.callFunc("setCategories", m.liveCategories)
    else
        m.liveCategoriesScreen.callFunc("setLoading", true)
        loadLiveCategories(m.account)
    end if
end sub


sub onOpenMovieCategoriesRequested()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("resetSelection")
    m.movieCategoriesScreen.callFunc("show")

    if not hasAccount(m.account) then
        m.movieCategoriesScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as categorias de filmes.")
    else if m.movieCategoriesLoading then
        m.movieCategoriesScreen.callFunc("setLoading", true)
    else if m.movieCategories <> invalid and m.movieCategories.Count() > 0 then
        m.movieCategoriesScreen.callFunc("setCategories", m.movieCategories)
    else
        m.movieCategoriesScreen.callFunc("setLoading", true)
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
    print "DEBUG Login: início da autenticação Xtream"
    m.loginScreen.callFunc("setLoading", true)
    startLoginTimeout()
    connectXtream(account)
end sub

sub onLoginBack()
    stopLoginTimeout()
    showHome()
end sub

sub onLiveCategoriesBack()
    showHome()
end sub

sub onLiveChannelsBack()
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("show")
end sub


sub onMovieCategoriesBack()
    showHome()
end sub

sub onMovieListBack()
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("show")
end sub

sub onMovieCategorySelected()
    category = m.movieCategoriesScreen.categorySelected
    if category = invalid then return

    m.selectedMovieCategory = category
    m.selectedMovieCategoryId = getCategoryId(category)
    m.movies = []
    m.moviesLoading = true
    m.movieCategoriesScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.movieListScreen.callFunc("setCategories", m.movieCategories)
    m.movieListScreen.callFunc("resetSelection")
    m.movieListScreen.callFunc("show", category)
    m.movieListScreen.callFunc("setLoading", true)
    loadMovies(category)
end sub

sub onMovieListCategorySelected()
    category = m.movieListScreen.categorySelected
    if category = invalid then return
    m.selectedMovieCategory = category
    m.selectedMovieCategoryId = getCategoryId(category)
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
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("show", movie)
    m.moviePlayerScreen.callFunc("setResumePosition", GetHistoryPosition("movie", movie))
    buildMovieStreamUrl(movie)
end sub

sub onMoviePlayerBack()
    UpsertMovieHistory(m.selectedMovie, m.moviePlayerScreen.callFunc("getPlaybackPosition"))
    m.moviePlayerScreen.callFunc("hide")
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
        m.movieListScreen.callFunc("show", m.selectedMovieCategory)
    end if
end sub

sub onLiveCategorySelected()
    category = m.liveCategoriesScreen.categorySelected
    if category = invalid then return

    m.selectedLiveCategory = category
    m.selectedLiveCategoryId = getCategoryId(category)
    m.liveChannels = []
    m.liveChannelsLoading = true
    m.liveCategoriesScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("resetSelection")
    m.liveChannelsScreen.callFunc("show", category)
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
        m.liveChannelsScreen.callFunc("show", m.selectedLiveCategory)
    end if
end sub

sub buildLiveStreamUrl(channel as Object)
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
    print "DEBUG Login: enviando requisição de conexão Xtream"
    m.xtreamService.control = "STOP"
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

    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovies"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.categoryId = getCategoryId(category)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadMovieCategories(account as Object)
    m.movieCategoriesLoading = true
    if m.movieCategoriesScreen.visible = true then
        m.movieCategoriesScreen.callFunc("setLoading", true)
    else
        m.homeScreen.callFunc("setMovieCategoriesLoading", true)
    end if
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getMovieCategories"
    m.xtreamService.cacheEnabled = false
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

    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveStreams"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.categoryId = getCategoryId(category)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadLiveCategories(account as Object)
    m.liveCategoriesLoading = true
    if m.liveCategoriesScreen.visible = true then
        m.liveCategoriesScreen.callFunc("setLoading", true)
    else
        m.homeScreen.callFunc("setLiveCategoriesLoading", true)
    end if
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getLiveCategories"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.dns = account.dns
    m.xtreamService.username = account.username
    m.xtreamService.password = account.password
    m.xtreamService.control = "RUN"
end sub

sub onXtreamConnectionResult()
    result = m.xtreamService.result
    if result = invalid then return

    if result.request = "getSeriesCategories" then
        onSeriesCategoriesResult(result)
        return
    else if Left(result.request, 9) = "getSeries" then
        onSeriesResult(result)
        return
    else if result.request = "buildSeriesStreamUrl" then
        onSeriesStreamUrlResult(result)
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
        print "DEBUG Login: resposta ignorada porque não há login pendente"
        return
    end if

    if isValidXtreamConnectionResult(result) then
        print "DEBUG Login: autenticação Xtream concluída com sucesso"
        m.account = m.pendingAccount
        SavePlaylist(m.account)
        SavePlaylistConnectionStatus("Conectado")
        updateConnectionStatus(true, "Conectado")
        m.pendingAccount = invalid
        m.liveCategories = []
        m.liveChannels = []
        m.liveCategoriesLoading = false
        m.liveChannelsLoading = false
        m.movieCategories = []
        m.movies = []
        m.searchChannels = []
        m.searchMovies = []
        m.searchSeries = []
        m.movieCategoriesLoading = false
        m.moviesLoading = false
        resetSeriesData()
        showHome()
    else
        print "DEBUG Login: erro na autenticação Xtream - " + getResultMessage(result)
        SavePlaylistConnectionStatus("Desconectado")
        m.pendingAccount = invalid
        m.liveCategories = []
        m.liveChannels = []
        m.liveCategoriesLoading = false
        m.liveChannelsLoading = false
        m.movieCategories = []
        m.movies = []
        m.searchChannels = []
        m.searchMovies = []
        m.searchSeries = []
        m.movieCategoriesLoading = false
        m.moviesLoading = false
        resetSeriesData()
        m.loginScreen.callFunc("showError", getResultMessage(result))
    end if
end sub


sub hideSeriesScreens()
    m.seriesCategoriesScreen.callFunc("hide")
    m.seriesListScreen.callFunc("hide")
    m.seriesSeasonsScreen.callFunc("hide")
    m.seriesEpisodesScreen.callFunc("hide")
    m.seriesPlayerScreen.callFunc("hide")
end sub

sub resetSeriesData()
    m.seriesCategories = []
    m.series = []
    m.seriesCategoriesLoading = false
    m.seriesLoading = false
end sub

sub onOpenSeriesCategoriesRequested()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.favoritesScreen.callFunc("hide")
    m.recentScreen.callFunc("hide")
    m.searchScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.seriesListScreen.callFunc("hide")
    m.seriesSeasonsScreen.callFunc("hide")
    m.seriesEpisodesScreen.callFunc("hide")
    m.seriesPlayerScreen.callFunc("hide")
    m.seriesCategoriesScreen.callFunc("resetSelection")
    m.seriesCategoriesScreen.callFunc("show")

    if not hasAccount(m.account) then
        m.seriesCategoriesScreen.callFunc("showMessage", "Conecte uma lista Xtream para carregar as categorias de séries.")
    else if m.seriesCategoriesLoading then
        m.seriesCategoriesScreen.callFunc("setLoading", true)
    else if m.seriesCategories <> invalid and m.seriesCategories.Count() > 0 then
        m.seriesCategoriesScreen.callFunc("setCategories", m.seriesCategories)
    else
        m.seriesCategoriesScreen.callFunc("setLoading", true)
        loadSeriesCategories(m.account)
    end if
end sub

sub onSeriesCategoriesBack()
    showHome()
end sub

sub onSeriesListBack()
    m.seriesListScreen.callFunc("hide")
    m.seriesCategoriesScreen.callFunc("show")
end sub

sub onSeriesSeasonsBack()
    m.seriesSeasonsScreen.callFunc("hide")
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
        m.seriesListScreen.callFunc("show", m.selectedSeriesCategory)
    end if
end sub

sub onSeriesEpisodesBack()
    m.seriesEpisodesScreen.callFunc("hide")
    m.seriesSeasonsScreen.callFunc("show", m.selectedSeries)
end sub

sub onSeriesPlayerBack()
    UpsertSeriesHistory(m.selectedSeries, m.selectedSeason, m.selectedEpisode, m.seriesPlayerScreen.callFunc("getPlaybackPosition"))
    m.seriesPlayerScreen.callFunc("hide")
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
        m.seriesEpisodesScreen.callFunc("show", m.selectedSeason)
    end if
end sub

sub onSeriesCategorySelected()
    category = m.seriesCategoriesScreen.categorySelected
    if category = invalid then return
    m.selectedSeriesCategory = category
    m.selectedSeriesCategoryId = getCategoryId(category)
    m.series = []
    m.seriesLoading = true
    m.seriesCategoriesScreen.callFunc("hide")
    m.seriesListScreen.callFunc("setCategories", m.seriesCategories)
    m.seriesListScreen.callFunc("resetSelection")
    m.seriesListScreen.callFunc("show", category)
    m.seriesListScreen.callFunc("setLoading", true)
    loadSeries(category)
end sub

sub onSeriesListCategorySelected()
    category = m.seriesListScreen.categorySelected
    if category = invalid then return
    m.selectedSeriesCategory = category
    m.selectedSeriesCategoryId = getCategoryId(category)
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
    m.seriesListScreen.callFunc("hide")
    m.seriesSeasonsScreen.callFunc("resetSelection")
    m.seriesSeasonsScreen.callFunc("show", series)
    m.seriesSeasonsScreen.callFunc("setLoading", true)
    loadSeriesInfo(series)
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
    m.seriesEpisodesScreen.callFunc("hide")
    m.seriesPlayerScreen.callFunc("show", episode)
    m.seriesPlayerScreen.callFunc("setResumePosition", GetHistoryPosition("episode", episode))
    buildSeriesStreamUrl(episode)
end sub

sub loadSeriesCategories(account as Object)
    m.seriesCategoriesLoading = true
    if m.seriesCategoriesScreen.visible = true then
        m.seriesCategoriesScreen.callFunc("setLoading", true)
    else
        m.homeScreen.callFunc("setSeriesCategoriesLoading", true)
    end if
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeriesCategories"
    m.xtreamService.cacheEnabled = false
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
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeries"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.categoryId = getCategoryId(category)
    m.xtreamService.dns = m.account.dns
    m.xtreamService.username = m.account.username
    m.xtreamService.password = m.account.password
    m.xtreamService.control = "RUN"
end sub

sub loadSeriesInfo(series as Object)
    m.xtreamService.control = "STOP"
    m.xtreamService.action = "getSeriesInfo"
    m.xtreamService.cacheEnabled = false
    m.xtreamService.seriesId = getSeriesId(series)
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

    print "DEBUG Login: timeout ao aguardar resposta Xtream"
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


sub onMovieCategoriesResult(result as Object)
    m.movieCategoriesLoading = false

    if result.success = true then
        m.movieCategories = normalizeMovieCategories(result.data)
        if m.movieCategories.Count() > 0 then
            updateConnectionStatus(true, "Conectado • Categorias de filmes carregadas")
            if m.movieCategoriesScreen.visible = true then
                m.movieCategoriesScreen.callFunc("setCategories", m.movieCategories)
            end if
        else
            updateConnectionStatus(true, "Conectado • Nenhuma categoria de filmes encontrada")
            if m.movieCategoriesScreen.visible = true then
                m.movieCategoriesScreen.callFunc("showMessage", "Nenhuma categoria de filmes foi encontrada.")
            end if
        end if
    else
        updateConnectionStatus(true, "Conectado • Não foi possível carregar categorias de filmes")
        if m.movieCategoriesScreen.visible = true then
            m.movieCategoriesScreen.callFunc("showMessage", "Não foi possível carregar as categorias de filmes. Tente novamente mais tarde.")
        end if
    end if
end sub

sub onMoviesResult(result as Object)
    if m.searchLoadStep = "movies" and getMoviesResultCategoryId(result) = "" then
        if result.success = true then m.searchMovies = normalizeMovies(result.data)
        m.searchLoadStep = "series"
        if m.searchScreen.visible = true then m.searchScreen.callFunc("setData", { channels: m.searchChannels, movies: m.searchMovies, series: m.searchSeries })
        loadSearchSeries()
        return
    end if

    resultCategoryId = getMoviesResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedMovieCategoryId then
        print "DEBUG Movies: resposta ignorada para categoria fora do foco: " + resultCategoryId
        return
    end if

    m.moviesLoading = false

    if result.success = true then
        m.movies = normalizeMovies(result.data)
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
            if m.liveCategoriesScreen.visible = true then
                m.liveCategoriesScreen.callFunc("setCategories", m.liveCategories)
            end if
        else
            updateConnectionStatus(true, "Conectado • Nenhuma categoria de TV ao vivo encontrada")
            if m.liveCategoriesScreen.visible = true then
                m.liveCategoriesScreen.callFunc("showMessage", "Nenhuma categoria de TV ao vivo foi encontrada.")
            end if
        end if
    else
        updateConnectionStatus(true, "Conectado • Não foi possível carregar categorias de TV ao vivo")
        if m.liveCategoriesScreen.visible = true then
            m.liveCategoriesScreen.callFunc("showMessage", "Não foi possível carregar as categorias de TV ao vivo. Tente novamente mais tarde.")
        end if
    end if
end sub

sub onLiveChannelsResult(result as Object)
    if m.searchLoadStep = "channels" and getLiveStreamsResultCategoryId(result) = "" then
        if result.success = true then m.searchChannels = normalizeLiveChannels(result.data)
        m.searchLoadStep = "movies"
        if m.searchScreen.visible = true then m.searchScreen.callFunc("setData", { channels: m.searchChannels, movies: m.searchMovies, series: m.searchSeries })
        loadSearchMovies()
        return
    end if

    resultCategoryId = getLiveStreamsResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedLiveCategoryId then
        print "DEBUG LiveChannels: resposta ignorada para categoria fora do foco: " + resultCategoryId
        return
    end if

    m.liveChannelsLoading = false

    if result.success = true then
        m.liveChannels = normalizeLiveChannels(result.data)
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
            if m.seriesCategoriesScreen.visible = true then m.seriesCategoriesScreen.callFunc("setCategories", m.seriesCategories)
        else
            updateConnectionStatus(true, "Conectado • Nenhuma categoria de séries encontrada")
            if m.seriesCategoriesScreen.visible = true then m.seriesCategoriesScreen.callFunc("showMessage", "Nenhuma categoria de séries foi encontrada.")
        end if
    else
        updateConnectionStatus(true, "Conectado • Não foi possível carregar categorias de séries")
        if m.seriesCategoriesScreen.visible = true then m.seriesCategoriesScreen.callFunc("showMessage", "Não foi possível carregar as categorias de séries. Tente novamente mais tarde.")
    end if
end sub

sub onSeriesResult(result as Object)
    if isSeriesInfoResult(result) then
        onSeriesInfoResult(result)
        return
    end if

    if m.searchLoadStep = "series" and getSeriesResultCategoryId(result) = "" then
        if result.success = true then m.searchSeries = normalizeSeries(result.data)
        m.searchLoadStep = ""
        if m.searchScreen.visible = true then
            m.searchScreen.callFunc("setLoading", false)
            m.searchScreen.callFunc("setData", { channels: m.searchChannels, movies: m.searchMovies, series: m.searchSeries })
        end if
        return
    end if

    resultCategoryId = getSeriesResultCategoryId(result)
    if resultCategoryId <> "" and resultCategoryId <> m.selectedSeriesCategoryId then
        print "DEBUG Series: resposta ignorada para categoria fora do foco: " + resultCategoryId
        return
    end if

    m.seriesLoading = false
    if result.success = true then
        m.series = normalizeSeries(result.data)
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
    if result.success = true then
        seasons = normalizeSeriesSeasons(result.data)
        if seasons.Count() > 0 then
            if m.seriesSeasonsScreen.visible = true then m.seriesSeasonsScreen.callFunc("setSeasons", seasons)
        else
            if m.seriesSeasonsScreen.visible = true then m.seriesSeasonsScreen.callFunc("showMessage", "Esta série não possui episódios disponíveis.")
        end if
    else
        if m.seriesSeasonsScreen.visible = true then m.seriesSeasonsScreen.callFunc("showMessage", "Não foi possível carregar as temporadas desta série. Tente novamente mais tarde.")
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
    if data = invalid then return []

    episodesBySeason = invalid
    if data.episodes <> invalid and Type(data.episodes) = "roAssociativeArray" then
        episodesBySeason = data.episodes
    end if

    normalizedSeasons = []
    if data.seasons <> invalid and Type(data.seasons) = "roArray" then
        for each season in data.seasons
            normalizedSeason = season
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
    if season <> invalid and season.episodes <> invalid and Type(season.episodes) = "roArray" then return sortEpisodes(season.episodes)
    return []
end function

function getSeriesId(series as Dynamic) as String
    if series = invalid then return ""
    if series.series_id <> invalid then return series.series_id.ToStr()
    if series.id <> invalid then return series.id.ToStr()
    return ""
end function

function getSeasonNumber(season as Dynamic) as String
    if season = invalid then return ""
    if season.season_number <> invalid then return season.season_number.ToStr()
    if season.number <> invalid then return season.number.ToStr()
    return ""
end function

function getEpisodeId(episode as Dynamic) as String
    if episode = invalid then return ""
    if episode.id <> invalid then return episode.id.ToStr()
    if episode.episode_id <> invalid then return episode.episode_id.ToStr()
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
