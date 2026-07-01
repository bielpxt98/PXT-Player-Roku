' Minimal Xtream service for Login + Live TV only.
sub Init()
    m.top.functionName = "executeRequest"
end sub

sub clearCache()
    ' Cache is disabled in the reset flow.
end sub

sub executeRequest()
    print "XTREAM ACTION: "; m.top.action
    action = LCase(safeTrim(m.top.action))
    if action = "" then action = "connect"

    if action = "connect" then
        m.top.result = requestXtream("connect", "")
    else if action = "getlivecategories" then
        m.top.result = requestXtream("getLiveCategories", "get_live_categories")
    else if action = "getlivestreams" then
        m.top.result = requestXtream("getLiveStreams", "get_live_streams")
    else if action = "buildlivestreamurl" then
        m.top.result = buildLiveStreamUrl()
    else
        m.top.result = buildFailure("Ação Xtream não suportada nesta versão: " + m.top.action)
    end if
end sub

function buildLiveStreamUrl() as Object
    credentials = getCredentials()
    if not credentials.valid then return buildFailure("Informe DNS, usuário e senha para reproduzir o canal.")

    streamId = safeTrim(m.top.streamId)
    if streamId = "" then return buildFailure("Canal sem identificador de reprodução.")

    extension = safeTrim(m.top.streamExtension)
    if extension = "" then extension = "ts"
    if Left(extension, 1) = "." then extension = Mid(extension, 2)

    return {
        success: true,
        connected: true,
        request: "buildLiveStreamUrl",
        data: {
            url: credentials.dns + "/live/" + escapePathValue(credentials.username) + "/" + escapePathValue(credentials.password) + "/" + escapePathValue(streamId) + "." + escapePathValue(extension)
        },
        message: "URL de reprodução montada com sucesso."
    }
end function

function requestXtream(requestName as String, apiAction as String) as Object
    credentials = getCredentials()
    if not credentials.valid then return buildFailure("Informe DNS, usuário e senha para conectar.")

    url = buildPlayerApiUrl(credentials.dns, credentials.username, credentials.password, apiAction)
    if apiAction = "get_live_streams" and safeTrim(m.top.categoryId) <> "" then
        url = url + "&category_id=" + escapeQueryValue(m.top.categoryId)
    end if

    print "XTREAM URL SAFE: "; safeUrlWithoutPassword(url)
    httpResponse = sendHttpGet(url)
    if not httpResponse.success then return withRequestName(httpResponse, requestName)

    parsedResponse = validateJsonResponse(httpResponse.body, apiAction)
    if not parsedResponse.success then
        parsedResponse.statusCode = httpResponse.statusCode
        parsedResponse.elapsedMs = httpResponse.elapsedMs
        parsedResponse.url = httpResponse.url
        return withRequestName(parsedResponse, requestName)
    end if

    success = buildSuccess(requestName, parsedResponse.data)
    success.statusCode = httpResponse.statusCode
    success.elapsedMs = httpResponse.elapsedMs
    success.url = httpResponse.url
    return success
end function

function getCredentials() as Object
    dns = normalizeDns(m.top.dns)
    username = safeTrim(m.top.username)
    password = safeTrim(m.top.password)
    return { valid: dns <> "" and username <> "" and password <> "", dns: dns, username: username, password: password }
end function

function buildPlayerApiUrl(dns as String, username as String, password as String, apiAction as String) as String
    url = dns + "/player_api.php?username=" + escapeQueryValue(username) + "&password=" + escapeQueryValue(password)
    if apiAction <> "" then url = url + "&action=" + escapeQueryValue(apiAction)
    return url
end function

function sendHttpGet(url as String) as Object
    timer = CreateObject("roTimespan")
    transfer = CreateObject("roUrlTransfer")
    transfer.SetUrl(url)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    port = CreateObject("roMessagePort")
    transfer.SetMessagePort(port)

    if not transfer.AsyncGetToString() then
        failure = buildFailure("Não foi possível iniciar a conexão com o servidor Xtream.")
        failure.url = safeUrlWithoutPassword(url) : failure.elapsedMs = timer.TotalMilliseconds()
        return failure
    end if

    event = Wait(15000, port)
    elapsedMs = timer.TotalMilliseconds()
    if Type(event) <> "roUrlEvent" then
        transfer.AsyncCancel()
        failure = buildFailure("Tempo esgotado.")
        failure.url = safeUrlWithoutPassword(url) : failure.elapsedMs = elapsedMs
        return failure
    end if

    response = event.GetString()
    statusCode = event.GetResponseCode()
    bodyLen = 0
    if response <> invalid then bodyLen = Len(response)
    print "XTREAM HTTP: "; statusCode
    print "XTREAM BODY LEN: "; bodyLen
    if statusCode < 200 or statusCode > 299 then
        failure = buildFailure("Não foi possível conectar ao servidor Xtream. Código HTTP: " + statusCode.ToStr())
        failure.statusCode = statusCode : failure.elapsedMs = elapsedMs : failure.url = safeUrlWithoutPassword(url)
        return failure
    end if
    if response = invalid or response = "" then
        failure = buildFailure("O servidor Xtream respondeu sem dados.")
        failure.statusCode = statusCode : failure.elapsedMs = elapsedMs : failure.url = safeUrlWithoutPassword(url)
        return failure
    end if

    return { success: true, body: response, statusCode: statusCode, elapsedMs: elapsedMs, url: safeUrlWithoutPassword(url) }
end function

function validateJsonResponse(response as String, apiAction as String) as Object
    parsedResponse = ParseJson(response)
    if parsedResponse = invalid then
        print "XTREAM JSON INVALID"
        return buildFailure("O servidor Xtream respondeu em um formato inválido.")
    end if

    if apiAction = "" then
        userInfo = parsedResponse.user_info
        if userInfo = invalid then return buildFailure("Não foi possível validar a conta neste servidor.")
        if not isSuccessfulUserInfo(userInfo) then return buildFailure("Login inválido ou conta inativa. Verifique usuário e senha.")
    end if

    return { success: true, data: parsedResponse }
end function

function normalizeDns(dns as Dynamic) as String
    normalized = safeTrim(dns)
    if normalized = "" then return ""
    lowerDns = LCase(normalized)
    if Left(lowerDns, 7) <> "http://" and Left(lowerDns, 8) <> "https://" then normalized = "http://" + normalized
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

function safeUrlWithoutPassword(url as String) as String
    if url = invalid then return ""
    passwordPos = Instr(1, url, "password=")
    if passwordPos <= 0 then return url
    valueStart = passwordPos + Len("password=")
    ampPos = Instr(valueStart, url, "&")
    if ampPos > 0 then return Left(url, valueStart - 1) + "***" + Mid(url, ampPos)
    return Left(url, valueStart - 1) + "***"
end function

function safeTrim(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr().Trim()
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
    return { success: true, connected: true, request: requestName, data: data, message: message }
end function

function buildFailure(message as String) as Object
    return { success: false, connected: false, request: m.top.action, data: invalid, message: message }
end function

function withRequestName(result as Dynamic, requestName as String) as Object
    if result = invalid or Type(result) <> "roAssociativeArray" then
        return { success: false, connected: false, request: requestName, data: invalid, message: "Não foi possível concluir a requisição Xtream." }
    end if
    result.request = requestName
    return result
end function
