' Simple backend API communication service.
' Keep backend HTTP calls centralized here so future routes can reuse the same
' request layer (/bootstrap, /search, /cache/status).
sub Init()
    m.top.functionName = "runBackendRequest"
end sub

sub runBackendRequest()
    action = safeBackendText(m.top.action)

    if action = "login" then
        m.top.result = loginViaBackend()
    else if action = "bootstrap" then
        m.top.result = bootstrapViaBackend()
    else if action = "search" then
        m.top.result = searchViaBackend()
    else
        m.top.result = buildBackendFailure("Ação backend não suportada: " + action, false)
    end if
end sub

function loginViaBackend() as Object
    ' PRINT "Tentando login via backend"

    body = {
        dns: safeBackendText(m.top.dns),
        username: safeBackendText(m.top.username),
        password: safeBackendText(m.top.password)
    }

    response = requestBackendWithFallback(["/api/login", "/login"], body, 30000)
    if response.success <> true then
        ' PRINT "Backend indisponível"
        return buildBackendFailure("Não foi possível conectar ao servidor.", true)
    end if

    parsed = ParseJson(response.body)
    if parsed = invalid then
        ' PRINT "Backend indisponível"
        return buildBackendFailure("Não foi possível conectar ao servidor.", true)
    end if

    if parsed.ok = true then
        ' PRINT "Login aprovado"
        return {
            success: true,
            connected: true,
            request: "backendLogin",
            ok: true,
            message: "Login aprovado."
        }
    end if

    ' PRINT "Login recusado"
    errorMessage = safeBackendText(parsed.error)
    if errorMessage = "" then errorMessage = "Login inválido. Verifique DNS, usuário e senha."
    return {
        success: false,
        connected: false,
        request: "backendLogin",
        ok: false,
        backendUnavailable: false,
        message: errorMessage
    }
end function

function bootstrapViaBackend() as Object
    body = {
        dns: safeBackendText(m.top.dns),
        username: safeBackendText(m.top.username),
        password: safeBackendText(m.top.password)
    }

    response = requestBackendWithFallback(["/api/bootstrap", "/bootstrap"], body, 30000)
    if response.success <> true then
        return buildBackendBootstrapFailure("Backend bootstrap falhou.")
    end if

    parsed = ParseJson(response.body)
    if parsed = invalid then
        return buildBackendBootstrapFailure("Backend bootstrap retornou resposta inválida.")
    end if

    if parsed.ok = true then
        data = getBackendCatalogData(parsed)
        return {
            success: true,
            connected: true,
            request: "backendBootstrap",
            ok: true,
            movieCategories: getBackendCatalogArrayWithCounts(parsed, data, "movieCategories", ["movieCategories", "vodCategories", "categoriesMovies", "movie_categories", "vod_categories", "categories_movies", "movieCategoriesList"]),
            movies: getBackendCatalogArrayWithCounts(parsed, data, "movies", ["movies", "vod", "movieStreams"]),
            seriesCategories: getBackendCatalogArrayWithCounts(parsed, data, "seriesCategories", ["seriesCategories", "categoriesSeries", "series_categories", "categories_series", "seriesCategoriesList"]),
            series: getBackendCatalogArrayWithCounts(parsed, data, "series", ["series", "seriesStreams"]),
            message: "Bootstrap pronto."
        }
    end if

    errorMessage = safeBackendText(parsed.error)
    if errorMessage = "" then errorMessage = "Backend bootstrap falhou."
    return buildBackendBootstrapFailure(errorMessage)
end function

function searchViaBackend() as Object
    searchType = safeBackendText(m.top.searchType)
    if searchType = "" then searchType = "all"
    limit = m.top.limit
    if limit <= 0 then limit = 50
    requestId = m.top.requestId

    body = {
        dns: safeBackendText(m.top.dns),
        username: safeBackendText(m.top.username),
        query: safeBackendText(m.top.query),
        type: searchType,
        limit: limit
    }

    response = requestBackendWithFallback(["/api/search", "/search"], body, 12000)
    if response.success <> true then
        return buildBackendSearchFailure("Backend search falhou.", body.query, searchType, requestId)
    end if

    parsed = ParseJson(response.body)
    if parsed = invalid then
        return buildBackendSearchFailure("Backend search retornou resposta inválida.", body.query, searchType, requestId)
    end if

    if parsed.ok = true or parsed.success = true then
        data = getBackendCatalogData(parsed)
        results = getBackendSearchArray(data, searchType)
        return {
            success: true,
            connected: true,
            request: "backendSearch",
            ok: true,
            query: body.query,
            searchType: searchType,
            requestId: m.top.requestId,
            results: results,
            movies: getBackendCatalogArray(data, ["movies", "vod", "movieStreams"]),
            series: getBackendCatalogArray(data, ["series", "seriesStreams"]),
            message: "Pesquisa pronta."
        }
    end if

    errorMessage = safeBackendText(parsed.error)
    if errorMessage = "" then errorMessage = "Backend search falhou."
    return buildBackendSearchFailure(errorMessage, body.query, searchType, requestId)
end function

function getBackendSearchArray(data as Dynamic, searchType as String) as Object
    results = getBackendCatalogArray(data, ["results", "items"])
    if results.Count() > 0 then return results
    if searchType = "movies" then return getBackendCatalogArray(data, ["movies", "vod", "movieStreams"])
    if searchType = "series" then return getBackendCatalogArray(data, ["series", "seriesStreams"])
    combined = []
    movies = getBackendCatalogArray(data, ["movies", "vod", "movieStreams"])
    series = getBackendCatalogArray(data, ["series", "seriesStreams"])
    for each item in movies : combined.Push(item) : end for
    for each item in series : combined.Push(item) : end for
    return combined
end function

function buildBackendSearchFailure(message as String, query as String, searchType as String, requestId as Integer) as Object
    return {
        success: false,
        connected: false,
        request: "backendSearch",
        ok: false,
        query: query,
        searchType: searchType,
        requestId: requestId,
        results: [],
        message: message
    }
end function

function requestBackendWithFallback(paths as Object, body as Object, timeoutMs as Integer) as Object
    lastResponse = invalid
    for each path in paths
        response = requestBackend(path, body, timeoutMs)
        lastResponse = response
        if response.success = true then return response
        if response.statusCode <> 404 then return response
        ' PRINT "BACKEND_ROUTE_FALLBACK_404 "; path
    end for
    if lastResponse <> invalid then return lastResponse
    return buildBackendTransportFailure()
end function

function requestBackend(path as String, body as Object, timeoutMs as Integer) as Object
    baseUrl = normalizeBackendBaseUrl(GetBackendBaseUrl())
    if baseUrl = "" then return buildBackendTransportFailure()

    transfer = CreateObject("roUrlTransfer")
    fullUrl = baseUrl + path
    ' PRINT "BACKEND_REQUEST_URL "; fullUrl
    transfer.SetUrl(fullUrl)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    ' PRINT "BACKEND_SSL_READY"
    transfer.AddHeader("Content-Type", "application/json")
    transfer.AddHeader("Accept", "application/json")

    port = CreateObject("roMessagePort")
    transfer.SetMessagePort(port)

    payload = FormatJson(body)
    if payload = invalid then return buildBackendTransportFailure()

    if not transfer.AsyncPostFromString(payload) then
        ' PRINT "BACKEND_TRANSFER_ERROR async_post_failed"
        return buildBackendTransportFailure()
    end if

    event = Wait(timeoutMs, port)
    if Type(event) <> "roUrlEvent" then
        transfer.AsyncCancel()
        ' PRINT "BACKEND_TRANSFER_ERROR timeout"
        return buildBackendTransportFailure()
    end if

    statusCode = event.GetResponseCode()
    responseBody = event.GetString()
    ' PRINT "BACKEND_HTTP_STATUS "; statusCode
    if statusCode < 200 or statusCode > 299 then
        ' PRINT "BACKEND_ERROR_BODY "; safeBackendText(responseBody)
        return {
            success: false,
            statusCode: statusCode,
            body: safeBackendText(responseBody)
        }
    end if
    if responseBody = invalid or responseBody = "" then
        ' PRINT "BACKEND_TRANSFER_ERROR empty_body"
        return buildBackendTransportFailure()
    end if

    return {
        success: true,
        statusCode: statusCode,
        body: responseBody
    }
end function

function buildBackendTransportFailure() as Object
    return {
        success: false,
        statusCode: 0,
        body: ""
    }
end function

function buildBackendBootstrapFailure(message as String) as Object
    return {
        success: false,
        connected: false,
        request: "backendBootstrap",
        ok: false,
        movieCategories: 0,
        movies: 0,
        seriesCategories: 0,
        series: 0,
        message: message
    }
end function

function getBackendCatalogArrayWithCounts(parsed as Object, data as Dynamic, countKey as String, keys as Object) as Object
    items = getBackendCatalogArray(data, keys)
    if items.Count() > 0 then return items
    count = getBackendCount(parsed, countKey)
    if count > 0 then
        counted = []
        counted.Push({ __backendCountOnly: true, count: count })
        return counted
    end if
    return items
end function

function getBackendCatalogData(parsed as Object) as Dynamic
    if parsed.data <> invalid and Type(parsed.data) = "roAssociativeArray" then return parsed.data
    if parsed.catalog <> invalid and Type(parsed.catalog) = "roAssociativeArray" then return parsed.catalog
    return parsed
end function

function getBackendCatalogArray(data as Dynamic, keys as Object) as Object
    empty = []
    if data = invalid then return empty
    for each key in keys
        direct = getNestedBackendCatalogArray(data, key)
        if direct.Count() > 0 then return direct
    end for
    if data.categories <> invalid and Type(data.categories) = "roAssociativeArray" then
        for each key in keys
            nested = getNestedBackendCatalogArray(data.categories, key)
            if nested.Count() > 0 then return nested
        end for
    end if
    if data.catalog <> invalid and Type(data.catalog) = "roAssociativeArray" then
        for each key in keys
            nestedCatalog = getNestedBackendCatalogArray(data.catalog, key)
            if nestedCatalog.Count() > 0 then return nestedCatalog
        end for
    end if
    return empty
end function

function getNestedBackendCatalogArray(data as Dynamic, key as String) as Object
    empty = []
    if data = invalid or Type(data) <> "roAssociativeArray" then return empty
    if data[key] <> invalid and Type(data[key]) = "roArray" then return data[key]
    if data[key] <> invalid and Type(data[key]) = "roAssociativeArray" then
        for each nestedKey in ["items", "data", "categories", "results"]
            if data[key][nestedKey] <> invalid and Type(data[key][nestedKey]) = "roArray" then return data[key][nestedKey]
        end for
    end if
    return empty
end function

function getBackendCount(parsed as Object, key as String) as Integer
    value = invalid
    if parsed[key] <> invalid then value = parsed[key]
    if value = invalid and parsed.counts <> invalid and parsed.counts[key] <> invalid then value = parsed.counts[key]
    if value = invalid and parsed.data <> invalid and parsed.data[key] <> invalid then value = parsed.data[key]
    if value = invalid then return 0
    if Type(value) = "roInt" or Type(value) = "Integer" then return value
    if Type(value) = "roArray" then return value.Count()
    return 0
end function

function buildBackendFailure(message as String, backendUnavailable as Boolean) as Object
    return {
        success: false,
        connected: false,
        request: "backendLogin",
        ok: false,
        backendUnavailable: backendUnavailable,
        message: message
    }
end function

function normalizeBackendBaseUrl(url as Dynamic) as String
    normalized = safeBackendText(url)
    while Right(normalized, 1) = "/"
        normalized = Left(normalized, Len(normalized) - 1)
    end while
    return normalized
end function

function safeBackendText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr().Trim()
end function
