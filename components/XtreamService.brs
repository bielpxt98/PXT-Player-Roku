' Xtream API connection service.
' This task only validates the saved credentials against player_api.php.
' Loading channels, movies, series and playback belong to later feature steps.
sub Init()
    m.top.functionName = "testConnection"
end sub

sub testConnection()
    dns = normalizeDns(m.top.dns)
    username = m.top.username
    password = m.top.password

    if dns = "" or username = "" or password = "" then
        m.top.result = buildFailure("Informe DNS, usuário e senha para conectar.")
        return
    end if

    url = buildPlayerApiUrl(dns, username, password)
    transfer = CreateObject("roUrlTransfer")
    transfer.SetUrl(url)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()

    response = transfer.GetToString()
    statusCode = transfer.GetResponseCode()

    if statusCode <> 200 or response = invalid or response = "" then
        m.top.result = buildFailure("Não foi possível conectar ao servidor. Verifique sua internet e os dados da conta.")
        return
    end if

    parsedResponse = ParseJson(response)
    if parsedResponse = invalid then
        m.top.result = buildFailure("O servidor respondeu em um formato inválido. Confira o DNS informado.")
        return
    end if

    userInfo = parsedResponse.user_info
    if userInfo = invalid then
        m.top.result = buildFailure("Não foi possível validar a conta neste servidor.")
        return
    end if

    if isSuccessfulUserInfo(userInfo) then
        m.top.result = {
            success: true,
            connected: true,
            message: "Conectado ao servidor com sucesso."
        }
    else
        m.top.result = buildFailure("Login inválido ou conta inativa. Verifique usuário e senha.")
    end if
end sub

function buildPlayerApiUrl(dns as String, username as String, password as String) as String
    return dns + "/player_api.php?username=" + escapeQueryValue(username) + "&password=" + escapeQueryValue(password)
end function

function normalizeDns(dns as Dynamic) as String
    if dns = invalid then return ""

    normalized = dns.Trim()
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
    if value = invalid then return ""

    transfer = CreateObject("roUrlTransfer")
    return transfer.Escape(value.Trim())
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

function buildFailure(message as String) as Object
    return {
        success: false,
        connected: false,
        message: message
    }
end function
