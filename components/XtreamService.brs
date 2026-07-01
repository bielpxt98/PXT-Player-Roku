' Xtream API communication service.
' This Task owns only server communication and returns structured data for
' future screens. It intentionally does not load data into the interface,
' search, favorites, or Home behavior. Playback screens ask it to build Xtream URLs.
sub Init()
    m.top.functionName = "executeRequest"
    m.cache = {}
end sub

sub executeRequest()
    action = LCase(m.top.action)
    if action = "" then action = "connect"

    if action = "connect" then
        m.top.result = connect()
    else if action = "getlivecategories" then
        m.top.result = getLiveCategories()
    else if action = "getmoviecategories" then
        m.top.result = getMovieCategories()
    else if action = "getseriescategories" then
        m.top.result = getSeriesCategories()
    else if action = "getlivestreams" then
        m.top.result = getLiveStreams()
    else if action = "buildlivestreamurl" then
        m.top.result = buildLiveStreamUrl()
    else if action = "buildmoviestreamurl" then
        m.top.result = buildMovieStreamUrl()
    else if action = "getmovies" then
        m.top.result = getMovies()
    else if action = "getmovieinfo" then
        m.top.result = getMovieInfo()
    else if action = "getseries" then
        m.top.result = getSeries()
    else if action = "getseriesinfo" then
        m.top.result = getSeriesInfo()
    else if action = "buildseriesstreamurl" then
        m.top.result = buildSeriesStreamUrl()
    else
        m.top.result = buildFailure("Ação Xtream não suportada: " + m.top.action)
    end if
end sub

function connect() as Object
    return requestXtream("connect", "")
end function

function getLiveCategories() as Object
    return requestXtream("getLiveCategories", "get_live_categories")
end function

function getMovieCategories() as Object
    return requestXtream("getMovieCategories", "get_vod_categories")
end function

function getSeriesCategories() as Object
    return requestXtream("getSeriesCategories", "get_series_categories")
end function

function getLiveStreams() as Object
    categoryId = safeTrim(m.top.categoryId)
    cacheKey = "getLiveStreams"
    if categoryId <> "" then cacheKey = cacheKey + ":" + categoryId
    return requestXtream(cacheKey, "get_live_streams")
end function

function getMovies() as Object
    categoryId = safeTrim(m.top.categoryId)
    cacheKey = "getMovies"
    if categoryId <> "" then cacheKey = cacheKey + ":" + categoryId
    return requestXtream(cacheKey, "get_vod_streams")
end function

function getMovieInfo() as Object
    streamId = safeTrim(m.top.streamId)
    cacheKey = "getMovieInfo"
    if streamId <> "" then cacheKey = cacheKey + ":" + streamId
    return requestXtream(cacheKey, "get_vod_info")
end function

function getSeries() as Object
    categoryId = safeTrim(m.top.categoryId)
    cacheKey = "getSeries"
    if categoryId <> "" then cacheKey = cacheKey + ":" + categoryId
    return requestXtream(cacheKey, "get_series")
end function

function getSeriesInfo() as Object
    seriesId = safeTrim(m.top.seriesId)
    cacheKey = "getSeriesInfo"
    if seriesId <> "" then cacheKey = cacheKey + ":" + seriesId
    return requestXtream(cacheKey, "get_series_info")
end function


function buildLiveStreamUrl() as Object
    credentials = getCredentials()
    if not credentials.valid then
        return buildFailure("Informe DNS, usuário e senha para reproduzir o canal.")
    end if

    streamId = safeTrim(m.top.streamId)
    if streamId = "" then
        return buildFailure("Canal sem identificador de reprodução.")
    end if

    extension = safeTrim(m.top.streamExtension)
    if extension = "" then extension = "ts"
    if Left(extension, 1) = "." then extension = Mid(extension, 2)

    return {
        success: true,
        connected: true,
        request: "buildLiveStreamUrl",
        data: {
            url: credentials.dns + "/live/" + escapePathValue(credentials.username) + "/" + escapePathValue(credentials.password) + "/" + escapePathValue(streamId) + "." + escapePathValue(extension),
            streamId: streamId
        },
        message: "URL de reprodução montada com sucesso."
    }
end function

function buildMovieStreamUrl() as Object
    credentials = getCredentials()
    if not credentials.valid then
        return buildFailure("Informe DNS, usuário e senha para reproduzir o filme.")
    end if

    streamId = safeTrim(m.top.streamId)
    if streamId = "" then
        return buildFailure("Filme sem identificador de reprodução.")
    end if

    extension = safeTrim(m.top.streamExtension)
    if extension = "" then extension = "mp4"
    if Left(extension, 1) = "." then extension = Mid(extension, 2)

    return {
        success: true,
        connected: true,
        request: "buildMovieStreamUrl",
        data: {
            url: credentials.dns + "/movie/" + escapePathValue(credentials.username) + "/" + escapePathValue(credentials.password) + "/" + escapePathValue(streamId) + "." + escapePathValue(extension)
        },
        message: "URL de reprodução montada com sucesso."
    }
end function

function buildSeriesStreamUrl() as Object
    credentials = getCredentials()
    if not credentials.valid then
        return buildFailure("Informe DNS, usuário e senha para reproduzir o episódio.")
    end if

    streamId = safeTrim(m.top.streamId)
    if streamId = "" then
        return buildFailure("Episódio sem identificador de reprodução.")
    end if

    extension = safeTrim(m.top.streamExtension)
    if extension = "" then extension = "mp4"
    if Left(extension, 1) = "." then extension = Mid(extension, 2)

    return {
        success: true,
        connected: true,
        request: "buildSeriesStreamUrl",
        data: {
            url: credentials.dns + "/series/" + escapePathValue(credentials.username) + "/" + escapePathValue(credentials.password) + "/" + escapePathValue(streamId) + "." + escapePathValue(extension)
        },
        message: "URL de reprodução montada com sucesso."
    }
end function

function requestXtream(cacheKey as String, apiAction as String) as Object
    credentials = getCredentials()
    if not credentials.valid then
        return buildFailure("Informe DNS, usuário e senha para conectar.")
    end if

    if shouldUseCache(cacheKey) then
        return m.cache[cacheKey]
    end if

    url = buildPlayerApiUrl(credentials.dns, credentials.username, credentials.password, apiAction)
    if (apiAction = "get_live_streams" or apiAction = "get_vod_streams" or apiAction = "get_series") and safeTrim(m.top.categoryId) <> "" then
        url = url + "&category_id=" + escapeQueryValue(m.top.categoryId)
    end if
    if apiAction = "get_series_info" and safeTrim(m.top.seriesId) <> "" then
        url = url + "&series_id=" + escapeQueryValue(m.top.seriesId)
    end if
    if apiAction = "get_vod_info" and safeTrim(m.top.streamId) <> "" then
        url = url + "&vod_id=" + escapeQueryValue(m.top.streamId)
    end if
    timeoutMs = 8000

    httpResponse = sendHttpGet(url, timeoutMs)
    if not httpResponse.success then
        return withRequestName(httpResponse, cacheKey)
    end if

    parsedResponse = validateJsonResponse(httpResponse.body, apiAction)
    if not parsedResponse.success then
        return withRequestName(parsedResponse, cacheKey)
    end if

    result = buildSuccess(cacheKey, parsedResponse.data)
    m.cache[cacheKey] = result
    return result
end function

function getCredentials() as Object
    dns = normalizeDns(m.top.dns)
    username = safeTrim(m.top.username)
    password = safeTrim(m.top.password)

    return {
        valid: dns <> "" and username <> "" and password <> "",
        dns: dns,
        username: username,
        password: password
    }
end function

function buildPlayerApiUrl(dns as String, username as String, password as String, apiAction as String) as String
    url = dns + "/player_api.php?username=" + escapeQueryValue(username) + "&password=" + escapeQueryValue(password)
    if apiAction <> "" then url = url + "&action=" + escapeQueryValue(apiAction)
    return url
end function

function sendHttpGet(url as String, timeoutMs as Integer) as Object
    transfer = CreateObject("roUrlTransfer")
    transfer.SetUrl(url)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    port = CreateObject("roMessagePort")
    transfer.SetMessagePort(port)

    if not transfer.AsyncGetToString() then
        return buildFailure("Não foi possível iniciar a conexão com o servidor Xtream.")
    end if

    event = waitForHttpResponse(port, timeoutMs)
    if event = invalid then
        transfer.AsyncCancel()
        return buildFailure("Tempo esgotado ao carregar dados.")
    end if

    response = event.GetString()
    statusCode = event.GetResponseCode()

    if statusCode < 200 or statusCode > 299 then
        return buildFailure("Não foi possível conectar ao servidor Xtream. Código HTTP: " + statusCode.ToStr())
    end if

    if response = invalid or response = "" then
        return buildFailure("O servidor Xtream respondeu sem dados.")
    end if

    return {
        success: true,
        body: response,
        statusCode: statusCode
    }
end function

function waitForHttpResponse(port as Object, timeoutMs as Integer) as Dynamic
    if port = invalid then return invalid

    event = Wait(timeoutMs, port)
    if Type(event) = "roUrlEvent" then return event

    return invalid
end function

function validateJsonResponse(response as String, apiAction as String) as Object
    parsedResponse = ParseJson(response)
    if parsedResponse = invalid then
        return buildFailure("O servidor Xtream respondeu em um formato inválido.")
    end if

    if apiAction = "" then
        userInfo = parsedResponse.user_info
        if userInfo = invalid then
            return buildFailure("Não foi possível validar a conta neste servidor.")
        end if

        if not isSuccessfulUserInfo(userInfo) then
            return buildFailure("Login inválido ou conta inativa. Verifique usuário e senha.")
        end if
    end if

    return {
        success: true,
        data: parsedResponse
    }
end function

function shouldUseCache(cacheKey as String) as Boolean
    if m.top.cacheEnabled <> true then return false
    if m.cache = invalid then m.cache = {}
    return m.cache.DoesExist(cacheKey)
end function

function normalizeDns(dns as Dynamic) as String
    normalized = safeTrim(dns)
    if normalized = "" then return ""

    lowerDns = LCase(normalized)
    if Left(lowerDns, 7) <> "http://" and Left(lowerDns, 8) <> "https://" then
        normalized = "http://" + normalized
    end if

    while Right(normalized, 1) = "/"
        normalized = Left(normalized, Len(normalized) - 1)
    end while

    return normalized
end function

function escapeQueryValue(value as Dynamic) as String
    transfer = CreateObject("roUrlTransfer")
    return transfer.Escape(safeTrim(value))
end function

function escapePathValue(value as Dynamic) as String
    transfer = CreateObject("roUrlTransfer")
    return transfer.Escape(safeTrim(value))
end function

function safeTrim(value as Dynamic) as String
    if value = invalid then return ""
    return value.Trim()
end function

function isSuccessfulUserInfo(userInfo as Object) as Boolean
    auth = userInfo.auth
    status = ""
    if userInfo.status <> invalid then status = LCase(userInfo.status)

    if auth <> invalid then
        authType = Type(auth)
        if authType = "roBoolean" or authType = "Boolean" then return auth
        authText = LCase(auth.ToStr())
        if authText = "1" or authText = "true" then return true
    end if

    return status = "active"
end function

function buildSuccess(requestName as String, data as Dynamic) as Object
    message = "Dados Xtream retornados com sucesso."
    if requestName = "connect" then message = "Conectado ao servidor com sucesso."

    return {
        success: true,
        connected: true,
        request: requestName,
        data: data,
        message: message
    }
end function

function buildFailure(message as String) as Object
    return {
        success: false,
        connected: false,
        request: m.top.action,
        data: invalid,
        message: message
    }
end function

function withRequestName(result as Dynamic, requestName as String) as Object
    if result = invalid or Type(result) <> "roAssociativeArray" then
        return {
            success: false,
            connected: false,
            request: requestName,
            data: invalid,
            message: "Não foi possível concluir a requisição Xtream."
        }
    end if

    result.request = requestName
    return result
end function
