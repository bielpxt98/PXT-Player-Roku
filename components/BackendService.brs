' Simple backend API communication service.
' Keep backend HTTP calls centralized here so future routes can reuse the same
' request layer (/api/bootstrap, /api/search, /api/cache/status).
sub Init()
    m.top.functionName = "runBackendRequest"
end sub

sub runBackendRequest()
    action = safeBackendText(m.top.action)

    if action = "login" then
        m.top.result = loginViaBackend()
    else
        m.top.result = buildBackendFailure("Ação backend não suportada: " + action, false)
    end if
end sub

function loginViaBackend() as Object
    PRINT "Tentando login via backend"

    body = {
        dns: safeBackendText(m.top.dns),
        username: safeBackendText(m.top.username),
        password: safeBackendText(m.top.password)
    }

    response = requestBackend("/api/login", body, 6000)
    if response.success <> true then
        PRINT "Backend indisponível"
        return buildBackendFailure("Não foi possível conectar ao servidor.", true)
    end if

    parsed = ParseJson(response.body)
    if parsed = invalid then
        PRINT "Backend indisponível"
        return buildBackendFailure("Não foi possível conectar ao servidor.", true)
    end if

    if parsed.ok = true then
        PRINT "Login aprovado"
        return {
            success: true,
            connected: true,
            request: "backendLogin",
            ok: true,
            message: "Login aprovado."
        }
    end if

    PRINT "Login recusado"
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

function requestBackend(path as String, body as Object, timeoutMs as Integer) as Object
    baseUrl = normalizeBackendBaseUrl(GetBackendBaseUrl())
    if baseUrl = "" then return buildBackendTransportFailure()

    transfer = CreateObject("roUrlTransfer")
    transfer.SetUrl(baseUrl + path)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    transfer.AddHeader("Content-Type", "application/json")
    transfer.AddHeader("Accept", "application/json")

    port = CreateObject("roMessagePort")
    transfer.SetMessagePort(port)

    payload = FormatJson(body)
    if payload = invalid then return buildBackendTransportFailure()

    if not transfer.AsyncPostFromString(payload) then
        return buildBackendTransportFailure()
    end if

    event = Wait(timeoutMs, port)
    if Type(event) <> "roUrlEvent" then
        transfer.AsyncCancel()
        return buildBackendTransportFailure()
    end if

    statusCode = event.GetResponseCode()
    responseBody = event.GetString()
    if statusCode < 200 or statusCode > 299 then return buildBackendTransportFailure()
    if responseBody = invalid or responseBody = "" then return buildBackendTransportFailure()

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
