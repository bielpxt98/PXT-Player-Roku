' Main scene for the PXT Player application.
' It coordinates feature screens and authenticates playlist credentials through
' XtreamService, including live TV categories and channel lists.
sub Init()
    m.homeScreen = m.top.FindNode("homeScreen")
    m.loginScreen = m.top.FindNode("loginScreen")
    m.liveCategoriesScreen = m.top.FindNode("liveCategoriesScreen")
    m.liveChannelsScreen = m.top.FindNode("liveChannelsScreen")
    m.livePlayerScreen = m.top.FindNode("livePlayerScreen")
    m.movieCategoriesScreen = m.top.FindNode("movieCategoriesScreen")
    m.movieListScreen = m.top.FindNode("movieListScreen")
    m.moviePlayerScreen = m.top.FindNode("moviePlayerScreen")
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

    configureScene()

    m.homeScreen.ObserveField("openPlaylist", "onOpenPlaylistRequested")
    m.homeScreen.ObserveField("openLiveCategories", "onOpenLiveCategoriesRequested")
    m.homeScreen.ObserveField("openMovieCategories", "onOpenMovieCategoriesRequested")
    m.loginScreen.ObserveField("submit", "onLoginSubmit")
    m.loginScreen.ObserveField("backRequested", "onLoginBack")
    m.liveCategoriesScreen.ObserveField("backRequested", "onLiveCategoriesBack")
    m.liveCategoriesScreen.ObserveField("categorySelected", "onLiveCategorySelected")
    m.liveChannelsScreen.ObserveField("backRequested", "onLiveChannelsBack")
    m.liveChannelsScreen.ObserveField("channelSelected", "onLiveChannelSelected")
    m.livePlayerScreen.ObserveField("backRequested", "onLivePlayerBack")
    m.movieCategoriesScreen.ObserveField("backRequested", "onMovieCategoriesBack")
    m.movieCategoriesScreen.ObserveField("categorySelected", "onMovieCategorySelected")
    m.movieListScreen.ObserveField("backRequested", "onMovieListBack")
    m.movieListScreen.ObserveField("movieSelected", "onMovieSelected")
    m.moviePlayerScreen.ObserveField("backRequested", "onMoviePlayerBack")
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
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.homeScreen.callFunc("show")
end sub

sub showLogin()
    m.homeScreen.callFunc("hide")
    m.liveCategoriesScreen.callFunc("hide")
    m.liveChannelsScreen.callFunc("hide")
    m.livePlayerScreen.callFunc("hide")
    m.movieCategoriesScreen.callFunc("hide")
    m.movieListScreen.callFunc("hide")
    m.moviePlayerScreen.callFunc("hide")
    m.loginScreen.callFunc("show", m.account)
end sub

sub onOpenPlaylistRequested()
    showLogin()
end sub

sub onOpenLiveCategoriesRequested()
    m.homeScreen.callFunc("hide")
    m.loginScreen.callFunc("hide")
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
    m.movieListScreen.callFunc("resetSelection")
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
    buildMovieStreamUrl(movie)
end sub

sub onMoviePlayerBack()
    m.moviePlayerScreen.callFunc("hide")
    m.movieListScreen.callFunc("show", m.selectedMovieCategory)
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
    m.liveChannelsScreen.callFunc("show", m.selectedLiveCategory)
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

    if result.request = "getMovieCategories" then
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
        m.movieCategoriesLoading = false
        m.moviesLoading = false
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
        m.movieCategoriesLoading = false
        m.moviesLoading = false
        m.loginScreen.callFunc("showError", getResultMessage(result))
    end if
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

function safeText(value as Dynamic) as String
    if value = invalid then return ""
    return value.Trim()
end function
