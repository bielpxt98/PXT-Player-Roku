' Xtream API communication service.
' This Task owns only server communication and returns structured data for
' future screens. It intentionally does not load data into the interface,
' implement playback, search, favorites, or Home behavior.
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
    else if action = "getmovies" then
        m.top.result = getMovies()
    else if action = "getseries" then
        m.top.result = getSeries()
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
    return requestXtream("getLiveStreams", "get_live_streams")
end function

function getMovies() as Object
    return requestXtream("getMovies", "get_vod_streams")
end function

function getSeries() as Object
    return requestXtream("getSeries", "get_series")
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
    httpResponse = sendHttpGet(url)
    if not httpResponse.success then return httpResponse

    parsedResponse = validateJsonResponse(httpResponse.body, apiAction)
    if not parsedResponse.success then return parsedResponse

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

function sendHttpGet(url as String) as Object
    transfer = CreateObject("roUrlTransfer")
    transfer.SetUrl(url)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()

    response = transfer.GetToString()
    statusCode = transfer.GetResponseCode()

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
        data: invalid,
        message: message
    }
end function
