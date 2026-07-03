sub Init()
    m.background = m.top.FindNode("background")
    m.poster = m.top.FindNode("poster")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.ratingGenreLabel = m.top.FindNode("ratingGenreLabel")
    m.synopsisTitle = m.top.FindNode("synopsisTitle")
    m.synopsisLabel = m.top.FindNode("synopsisLabel")
    m.actionsGroup = m.top.FindNode("actionsGroup")
    m.playButtonGroup = m.top.FindNode("playButtonGroup")
    m.playButtonBg = m.top.FindNode("playButtonBg")
    m.playButtonFocus = m.top.FindNode("playButtonFocus")
    m.playButtonLabel = m.top.FindNode("playButtonLabel")
    m.continueButtonGroup = m.top.FindNode("continueButtonGroup")
    m.continueButtonBg = m.top.FindNode("continueButtonBg")
    m.continueButtonFocus = m.top.FindNode("continueButtonFocus")
    m.continueButtonLabel = m.top.FindNode("continueButtonLabel")
    m.seasonTitle = m.top.FindNode("seasonTitle")
    m.seasonsGroup = m.top.FindNode("seasonsGroup")
    m.episodesGroup = m.top.FindNode("episodesGroup")
    m.episodesMessageLabel = m.top.FindNode("episodesMessageLabel")
    m.backButton = m.top.FindNode("backButton")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.selectedArea = 0 ' 0 jogar, 1 continuar, 2 temporada, 3 episódios, 4 voltar
    m.focusArea = "posterButton"
    m.selectedSeasonIndex = 0
    m.selectedEpisodeIndex = 0
    m.selectedSeason = invalid
    m.selectedEpisode = invalid
    m.episodeWindowStart = 0
    m.maxEpisodeCards = 5
    m.seasons = []
    m.episodes = []
    m.seasonNodes = []
    m.episodeNodes = []
    m.item = invalid
    m.continueEpisode = invalid
    configureLayout()
end sub

sub configureLayout()
    deviceInfo = CreateObject("roDeviceInfo")
    size = deviceInfo.GetDisplaySize()
    w = size.w
    h = size.h
    m.background.width = w
    m.background.height = h

    marginX = 80
    topY = 62
    posterW = 300
    posterH = 450
    buttonW = 138
    buttonH = 56
    episodeW = 202
    episodeH = 176
    episodeGap = 22
    if h <= 720 then
        marginX = 50
        topY = 38
        posterW = 210
        posterH = 315
        buttonW = 116
        buttonH = 50
        episodeW = 158
        episodeH = 138
        episodeGap = 18
    end if

    m.marginX = marginX
    m.posterW = posterW
    m.posterH = posterH
    m.episodeW = episodeW
    m.episodeH = episodeH
    m.episodeGap = episodeGap

    m.poster.translation = [marginX, topY]
    m.poster.width = posterW
    m.poster.height = posterH

    contentX = marginX + posterW + 58
    contentW = w - contentX - marginX
    m.titleLabel.translation = [contentX, topY + 4]
    m.titleLabel.width = contentW
    m.titleLabel.height = 66
    m.titleLabel.font = "font:LargeBoldSystemFont"

    m.ratingGenreLabel.translation = [contentX, topY + 76]
    m.ratingGenreLabel.width = contentW
    m.ratingGenreLabel.height = 42
    m.ratingGenreLabel.font = "font:MediumBoldSystemFont"

    m.synopsisTitle.translation = [contentX, topY + 128]
    m.synopsisTitle.width = contentW
    m.synopsisTitle.font = "font:MediumBoldSystemFont"
    m.synopsisLabel.translation = [contentX, topY + 166]
    m.synopsisLabel.width = contentW
    m.synopsisLabel.height = 138
    m.synopsisLabel.font = "font:MediumSystemFont"

    m.actionsGroup.translation = [marginX, topY + posterH + 28]
    setupActionButton(m.playButtonGroup, m.playButtonBg, m.playButtonFocus, m.playButtonLabel, 0, buttonW, buttonH)
    setupActionButton(m.continueButtonGroup, m.continueButtonBg, m.continueButtonFocus, m.continueButtonLabel, buttonW + 18, buttonW + 48, buttonH)

    seasonY = topY + 325
    if h <= 720 then seasonY = topY + 236
    m.seasonTitle.translation = [contentX, seasonY]
    m.seasonTitle.width = contentW
    m.seasonTitle.horizAlign = "left"
    m.seasonTitle.font = "font:MediumBoldSystemFont"
    m.seasonsGroup.translation = [contentX, seasonY + 38]

    episodesY = seasonY + 104
    if h <= 720 then episodesY = seasonY + 82
    m.episodesGroup.translation = [contentX, episodesY]
    m.maxEpisodeCards = Int((contentW + episodeGap) / (episodeW + episodeGap))
    if m.maxEpisodeCards < 1 then m.maxEpisodeCards = 1
    m.episodesMessageLabel.translation = [contentX, episodesY + 38]
    m.episodesMessageLabel.width = contentW
    m.episodesMessageLabel.height = 80
    m.episodesMessageLabel.font = "font:MediumSystemFont"
    m.loadingLabel.translation = [contentX, episodesY + 38]
    m.loadingLabel.width = contentW
    m.loadingLabel.font = "font:MediumSystemFont"
    m.backButton.translation = [w - marginX - 170, h - 76]
    m.backButton.width = 170
    m.backButton.height = 54
    m.backButton.font = "font:MediumBoldSystemFont"
end sub

sub setupActionButton(group as Object, bg as Object, focusRect as Object, label as Object, x as Integer, width as Integer, height as Integer)
    group.translation = [x, 0]
    bg.width = width
    bg.height = height
    focusRect.translation = [-4, -4]
    focusRect.width = width + 8
    focusRect.height = height + 8
    label.width = width
    label.height = height
    label.font = "font:MediumBoldSystemFont"
end sub

sub show(item as Dynamic)
    m.item = item
    m.selectedArea = 0
    m.selectedSeasonIndex = 0
    m.selectedEpisodeIndex = 0
    m.selectedSeason = invalid
    m.selectedEpisode = invalid
    m.episodeWindowStart = 0
    configureLayout()
    populate(item)
    setLoading(false)
    updateContinueButton()
    updateFocus()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub focusEpisodes()
    if m.episodes = invalid or m.episodes.Count() = 0 then
        setupEpisodes(m.item)
    end if
    if m.episodes = invalid or m.episodes.Count() = 0 then
        m.selectedArea = 2
        if not hasSeasons() then m.selectedArea = 0
        updateFocus()
        m.top.SetFocus(true)
        return
    end if
    m.selectedArea = 3
    if m.selectedEpisodeIndex >= m.episodes.Count() then m.selectedEpisodeIndex = 0
    updateFocus()
    m.top.SetFocus(true)
end sub

sub setLoading(isLoading as Boolean)
    if isLoading then m.loadingLabel.text = "Carregando detalhes..."
    m.loadingLabel.visible = isLoading
end sub

sub showMessage(message as String)
    m.loadingLabel.text = message
    m.loadingLabel.visible = message <> ""
end sub

sub setDetails(details as Dynamic)
    if details <> invalid then
        m.item = mergeItem(m.item, details)
        populate(m.item)
    end if
    setLoading(false)
end sub

sub populate(item as Dynamic)
    title = firstText(item, ["name", "title"])
    if title = "" then title = "Série"
    m.titleLabel.text = title
    image = firstText(item, ["cover", "series_image", "stream_icon", "cover_big", "backdrop_path"])
    m.poster.uri = image
    desc = firstText(item, ["description", "plot", "overview", "synopsis"])
    if desc = "" then desc = "Informações disponíveis no catálogo."
    if Len(desc) > 330 then desc = Left(desc, 327) + "..."
    m.synopsisLabel.text = desc
    genres = firstText(item, ["genre", "genres"])
    rating = firstText(item, ["rating", "rating_5based", "vote_average"])
    meta = joinText([ratingText(rating), genres], " • ")
    m.ratingGenreLabel.text = meta
    m.ratingGenreLabel.visible = meta <> ""
    if item <> invalid and Type(item) = "roAssociativeArray" then m.item = normalizeSeriesDetailsForPlayback(item)
    setupSeasons(m.item)
    setupEpisodes(m.item)
    updateContinueButton()
    updateFocus()
end sub

function mergeItem(base as Dynamic, details as Dynamic) as Object
    merged = {}
    if base <> invalid and Type(base) = "roAssociativeArray" then
        for each k in base
            merged[k] = base[k]
        end for
    end if
    info = details
    if details <> invalid and Type(details) = "roAssociativeArray" and details.info <> invalid then info = details.info
    if info <> invalid and Type(info) = "roAssociativeArray" then
        for each k in info
            merged[k] = info[k]
        end for
    end if
    if details <> invalid and Type(details) = "roAssociativeArray" then
        for each k in ["seasons", "episodes"]
            if details.DoesExist(k) and details[k] <> invalid then merged[k] = details[k]
        end for
    end if
    merged = normalizeSeriesDetailsForPlayback(merged)
    return merged
end function

function normalizeSeriesDetailsForPlayback(item as Object) as Object
    if item = invalid then return {}
    seasons = []
    episodesBySeason = {}
    if item.DoesExist("episodes") and item.episodes <> invalid then
        if Type(item.episodes) = "roAssociativeArray" then
            for each seasonKey in item.episodes
                eps = normalizeEpisodeArray(item.episodes[seasonKey], Val(seasonKey))
                episodesBySeason[seasonKey] = eps
            end for
        else if Type(item.episodes) = "roArray" then
            for each ep in normalizeEpisodeArray(item.episodes, 0)
                seasonNo = getEpisodeSeasonNumber(ep)
                if seasonNo <= 0 then seasonNo = 1
                key = seasonNo.ToStr()
                if not episodesBySeason.DoesExist(key) then episodesBySeason[key] = []
                episodesBySeason[key].Push(ep)
            end for
        end if
    end if
    if item.DoesExist("seasons") and item.seasons <> invalid and Type(item.seasons) = "roArray" then
        for each season in item.seasons
            seasonObj = season
            if seasonObj = invalid or Type(seasonObj) <> "roAssociativeArray" then seasonObj = { season_number: seasons.Count() + 1 }
            sn = getSeasonNumber(seasonObj, seasons.Count() + 1)
            key = sn.ToStr()
            if not seasonObj.DoesExist("episodes") or seasonObj.episodes = invalid or Type(seasonObj.episodes) <> "roArray" then
                if episodesBySeason.DoesExist(key) then seasonObj.episodes = episodesBySeason[key]
            end if
            seasons.Push(seasonObj)
        end for
    end if
    if seasons.Count() = 0 then
        for each key in episodesBySeason
            seasons.Push({ season_number: Val(key), name: "TEMPORADA " + key, episodes: episodesBySeason[key] })
        end for
    end if
    item.seasons = seasons
    return item
end function

function normalizeEpisodeArray(value as Dynamic, fallbackSeason as Integer) as Object
    result = []
    if value = invalid or Type(value) <> "roArray" then return result
    for each ep in value
        if ep <> invalid and Type(ep) = "roAssociativeArray" then
            if fallbackSeason > 0 and (not ep.DoesExist("season_number") or ep.season_number = invalid) then ep.season_number = fallbackSeason
            result.Push(ep)
        end if
    end for
    return result
end function

function getSeasonNumber(season as Dynamic, fallback as Integer) as Integer
    label = firstText(season, ["season_number", "season", "number"])
    if label <> "" then return Val(label)
    return fallback
end function

function getEpisodeSeasonNumber(episode as Dynamic) as Integer
    label = firstText(episode, ["season_number", "season"])
    if label <> "" then return Val(label)
    return 0
end function

function firstText(item as Dynamic, keys as Object) as String
    if item = invalid or Type(item) <> "roAssociativeArray" then return ""
    for each k in keys
        if item.DoesExist(k) and isScalarTextValue(item[k]) then
            text = safeText(item[k])
            if text <> "" then return text
        end if
    end for
    return ""
end function

function safeText(value as Dynamic) as String
    if value = invalid then return ""
    valueType = Type(value)
    if valueType = "roAssociativeArray" or valueType = "roArray" then return ""
    return value.ToStr().Trim()
end function

function joinText(parts as Object, sep as String) as String
    out = ""
    for each part in parts
        if part <> "" then
            if out <> "" then out = out + sep
            out = out + part
        end if
    end for
    return out
end function

function ratingText(value as String) as String
    if value = "" then return ""
    n = Val(value)
    if n > 5 then n = n / 2
    if n <= 0 then return ""
    stars = ""
    for i = 1 to 5
        if i <= Int(n + 0.5) then stars = stars + "★" else stars = stars + "☆"
    end for
    return stars
end function

function isScalarTextValue(value as Dynamic) as Boolean
    if value = invalid then return false
    valueType = Type(value)
    if valueType = "roAssociativeArray" or valueType = "roArray" then return false
    return true
end function

sub setupSeasons(item as Dynamic)
    m.seasons = getSeasonLabels(item)
    clampFocusState()
    renderSeasonButtons()
end sub

function getSeasonLabels(item as Dynamic) as Object
    labels = []
    if item <> invalid and Type(item) = "roAssociativeArray" then
        if item.DoesExist("seasons") and item.seasons <> invalid and Type(item.seasons) = "roArray" then
            for each season in item.seasons
                label = firstText(season, ["name", "title", "season", "season_number"])
                if label <> "" then
                    n = Val(label)
                    if n > 0 then label = "TEMPORADA " + n.ToStr()
                    if LCase(Left(label, 6)) = "season" then label = "TEMPORADA" + Mid(label, 7)
                    labels.Push(UCase(label))
                end if
            end for
        end if
    end if
    return labels
end function

sub renderSeasonButtons()
    while m.seasonsGroup.GetChildCount() > 0
        m.seasonsGroup.RemoveChildIndex(0)
    end while
    m.seasonNodes = []
    x = 0
    for i = 0 to m.seasons.Count() - 1
        group = CreateObject("roSGNode", "Group")
        group.translation = [x, 0]
        bg = CreateObject("roSGNode", "Rectangle")
        bg.width = 172
        bg.height = 44
        bg.color = "#1F2937"
        border = CreateObject("roSGNode", "Rectangle")
        border.translation = [-3, -3]
        border.width = 178
        border.height = 50
        border.color = "#5CE08A"
        border.opacity = 0
        label = CreateObject("roSGNode", "Label")
        label.text = m.seasons[i]
        label.width = 172
        label.height = 44
        label.horizAlign = "center"
        label.vertAlign = "center"
        label.font = "font:MediumBoldSystemFont"
        group.AppendChild(border)
        group.AppendChild(bg)
        group.AppendChild(label)
        m.seasonsGroup.AppendChild(group)
        m.seasonNodes.Push({ group: group, bg: bg, border: border, label: label })
        x = x + 190
    end for
    if m.seasons.Count() > 0 then m.seasonTitle.text = "TEMPORADAS"
end sub

sub setupEpisodes(item as Dynamic)
    updateSelectedSeason()
    m.episodes = getEpisodesForSelectedSeason(item)
    clampFocusState()
    ensureEpisodeVisible()
    updateSelectedEpisodeFromIndex()
    renderEpisodes(m.episodes)
end sub

function getEpisodesForSelectedSeason(item as Dynamic) as Object
    episodes = []
    if item = invalid or Type(item) <> "roAssociativeArray" then return episodes
    if item.DoesExist("seasons") and item.seasons <> invalid and Type(item.seasons) = "roArray" and item.seasons.Count() > m.selectedSeasonIndex then
        season = item.seasons[m.selectedSeasonIndex]
        if season <> invalid and Type(season) = "roAssociativeArray" and season.DoesExist("episodes") and Type(season.episodes) = "roArray" then
            for each ep in season.episodes
                if ep <> invalid then episodes.Push(ep)
            end for
        end if
    end if
    if episodes.Count() = 0 and (not item.DoesExist("seasons") or item.seasons = invalid or Type(item.seasons) <> "roArray" or item.seasons.Count() = 0) and item.DoesExist("episodes") and item.episodes <> invalid and Type(item.episodes) = "roArray" then
        for each ep in item.episodes
            if ep <> invalid then episodes.Push(ep)
        end for
    end if
    return episodes
end function

sub renderEpisodes(episodes as Object)
    while m.episodesGroup.GetChildCount() > 0
        m.episodesGroup.RemoveChildIndex(0)
    end while
    m.episodeNodes = []
    hasNoEpisodes = true
    if episodes <> invalid and episodes.Count() > 0 then hasNoEpisodes = false
    m.episodesMessageLabel.visible = hasNoEpisodes
    if hasNoEpisodes then
        m.episodesMessageLabel.text = "Nenhum episódio disponível."
        return
    end if
    lastIndex = m.episodeWindowStart + m.maxEpisodeCards - 1
    if lastIndex > episodes.Count() - 1 then lastIndex = episodes.Count() - 1
    for i = m.episodeWindowStart to lastIndex
        episode = episodes[i]
        visibleIndex = i - m.episodeWindowStart
        group = CreateObject("roSGNode", "Group")
        group.translation = [visibleIndex * (m.episodeW + m.episodeGap), 0]
        border = CreateObject("roSGNode", "Rectangle")
        border.translation = [-4, -4]
        border.width = m.episodeW + 8
        border.height = m.episodeH + 8
        border.color = "#5CE08A"
        border.opacity = 0
        bg = CreateObject("roSGNode", "Rectangle")
        bg.width = m.episodeW
        bg.height = m.episodeH
        bg.color = "#111827"
        poster = CreateObject("roSGNode", "Poster")
        poster.width = m.episodeW
        poster.height = m.episodeH - 48
        poster.loadDisplayMode = "scaleToZoom"
        poster.uri = getEpisodeImage(episode)
        label = CreateObject("roSGNode", "Label")
        label.translation = [10, m.episodeH - 44]
        label.width = m.episodeW - 20
        label.height = 38
        label.font = "font:SmallBoldSystemFont"
        label.color = "#FFFFFF"
        label.wrap = true
        label.text = getEpisodeTitle(episode, i)
        group.AppendChild(border)
        group.AppendChild(bg)
        group.AppendChild(poster)
        group.AppendChild(label)
        m.episodesGroup.AppendChild(group)
        m.episodeNodes.Push({ group: group, border: border, bg: bg, label: label })
    end for
end sub

function getEpisodeTitle(episode as Dynamic, index as Integer) as String
    title = firstText(episode, ["title", "name"])
    if title = "" then title = "Episódio " + (index + 1).ToStr()
    return title
end function

function getEpisodeUrl(episode as Dynamic) as String
    streamUrl = firstText(episode, ["stream_url", "streamUrl", "url", "direct_source", "episode_url", "playUrl", "direct_url", "directUrl", "playbackUrl", "movie_url"])
    if streamUrl <> "" then return streamUrl
    return buildXtreamEpisodeUrl(episode)
end function

function buildXtreamEpisodeUrl(episode as Dynamic) as String
    episodeId = firstText(episode, ["id", "episode_id"])
    if episodeId = "" then return ""
    dns = normalizeSeriesDns(m.top.dns)
    username = safeText(m.top.username)
    password = safeText(m.top.password)
    if dns = "" or username = "" or password = "" then return ""
    extension = getEpisodeExtension(episode)
    if extension = "" then extension = "mp4"
    if Left(extension, 1) = "." then extension = Mid(extension, 2)
    return dns + "/series/" + escapeSeriesPathValue(username) + "/" + escapeSeriesPathValue(password) + "/" + escapeSeriesPathValue(episodeId) + "." + escapeSeriesPathValue(extension)
end function

function getEpisodeExtension(episode as Dynamic) as String
    extension = firstText(episode, ["container_extension", "containerExtension", "extension", "stream_extension", "streamExtension"])
    if extension <> "" then return extension
    for each field in ["stream_url", "streamUrl", "url", "direct_source", "episode_url", "playUrl"]
        candidate = firstText(episode, [field])
        extension = extensionFromUrl(candidate)
        if extension <> "" then return extension
    end for
    return ""
end function

function extensionFromUrl(url as String) as String
    if url = "" then return ""
    cleanUrl = url
    queryPos = Instr(1, cleanUrl, "?")
    if queryPos > 0 then cleanUrl = Left(cleanUrl, queryPos - 1)
    slashPos = 0
    for i = Len(cleanUrl) to 1 step -1
        if Mid(cleanUrl, i, 1) = "/" then
            slashPos = i
            exit for
        end if
    end for
    dotPos = 0
    for i = Len(cleanUrl) to slashPos + 1 step -1
        if Mid(cleanUrl, i, 1) = "." then
            dotPos = i
            exit for
        end if
    end for
    if dotPos <= 0 or dotPos = Len(cleanUrl) then return ""
    return Mid(cleanUrl, dotPos + 1)
end function

function normalizeSeriesDns(dns as Dynamic) as String
    normalized = safeText(dns)
    if normalized = "" then return ""
    lowerDns = LCase(normalized)
    if Left(lowerDns, 7) <> "http://" and Left(lowerDns, 8) <> "https://" then normalized = "http://" + normalized
    while Right(normalized, 1) = "/"
        normalized = Left(normalized, Len(normalized) - 1)
    end while
    return normalized
end function

function escapeSeriesPathValue(value as Dynamic) as String
    text = safeText(value)
    if text = "" then return ""
    result = ""
    safeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
    for i = 1 to Len(text)
        ch = Mid(text, i, 1)
        if Instr(1, safeChars, ch) > 0 then
            result = result + ch
        else
            code = ch.ToInt()
            hex = intToHex(code)
            if Len(hex) = 1 then hex = "0" + hex
            result = result + "%" + UCase(hex)
        end if
    end for
    return result
end function

function intToHex(n as Integer) as String
    if n = 0 then return "0"
    digits = "0123456789ABCDEF"
    result = ""
    while n > 0
        result = Mid(digits, (n mod 16) + 1, 1) + result
        n = Int(n / 16)
    end while
    return result
end function

function maskSeriesUrl(url as String) as String
    username = safeText(m.top.username)
    password = safeText(m.top.password)
    masked = url
    if username <> "" then masked = masked.Replace("/" + username + "/", "/****/")
    if password <> "" then masked = masked.Replace("/" + password + "/", "/****/")
    return masked
end function

function getSelectedSeason() as Dynamic
    if m.item = invalid or Type(m.item) <> "roAssociativeArray" then return invalid
    if not m.item.DoesExist("seasons") or m.item.seasons = invalid or Type(m.item.seasons) <> "roArray" then return invalid
    if m.selectedSeasonIndex < 0 or m.selectedSeasonIndex >= m.item.seasons.Count() then return invalid
    return m.item.seasons[m.selectedSeasonIndex]
end function

function isPlayableEpisode(episode as Dynamic) as Boolean
    if episode = invalid or Type(episode) <> "roAssociativeArray" then return false
    if episode.DoesExist("episodes") and episode.episodes <> invalid then return false
    return getEpisodeUrl(episode) <> ""
end function

sub updateSelectedSeason()
    m.selectedSeason = getSelectedSeason()
    print "SERIES_DETAILS selectedSeason="; firstText(m.selectedSeason, ["name", "title", "season", "season_number", "number"])
end sub

sub updateSelectedEpisodeFromIndex()
    m.selectedEpisode = invalid
    if m.episodes <> invalid and m.selectedEpisodeIndex >= 0 and m.selectedEpisodeIndex < m.episodes.Count() then
        episode = m.episodes[m.selectedEpisodeIndex]
        if episode <> invalid and Type(episode) = "roAssociativeArray" and (not episode.DoesExist("episodes") or episode.episodes = invalid) then m.selectedEpisode = episode
    end if
    print "SERIES_DETAILS selectedEpisode="; getEpisodeTitle(m.selectedEpisode, m.selectedEpisodeIndex)
end sub

function getEpisodeImage(episode as Dynamic) as String
    image = firstText(episode, ["cover", "image", "info", "movie_image", "stream_icon"])
    if image = "" then image = m.poster.uri
    return image
end function

sub updateContinueButton()
    if m.continueEpisode <> invalid then
        epNum = firstText(m.continueEpisode, ["episode_num", "episode", "episode_number"])
        if epNum = "" then epNum = "?"
        m.continueButtonLabel.text = "CONTINUAR EP " + epNum
        m.continueButtonGroup.visible = true
    else
        m.continueButtonGroup.visible = false
        if m.selectedArea = 1 then m.selectedArea = 0
    end if
end sub

sub setContinueEpisode(episode as Dynamic)
    m.continueEpisode = episode
    updateContinueButton()
    updateFocus()
end sub

sub updateFocus()
    updateContinueButton()
    clampFocusState()
    logFocusState()
    m.playButtonFocus.opacity = 0
    m.continueButtonFocus.opacity = 0
    m.playButtonBg.color = "#1F2937"
    m.continueButtonBg.color = "#1F2937"
    m.backButton.color = "#FFFFFF"
    if m.selectedArea = 0 then
        m.playButtonFocus.opacity = 0.95
        m.playButtonBg.color = "#256D3F"
    else if m.selectedArea = 1 then
        m.continueButtonFocus.opacity = 0.95
        m.continueButtonBg.color = "#256D3F"
    end if

    for i = 0 to m.seasonNodes.Count() - 1
        m.seasonNodes[i].border.opacity = 0
        m.seasonNodes[i].bg.color = "#1F2937"
        if m.selectedArea = 2 and i = m.selectedSeasonIndex then
            m.seasonNodes[i].border.opacity = 0.95
            m.seasonNodes[i].bg.color = "#263A5E"
        end if
    end for

    for i = 0 to m.episodeNodes.Count() - 1
        m.episodeNodes[i].border.opacity = 0
        m.episodeNodes[i].bg.color = "#111827"
        if m.selectedArea = 3 and i = (m.selectedEpisodeIndex - m.episodeWindowStart) then
            m.episodeNodes[i].border.opacity = 0.95
            m.episodeNodes[i].bg.color = "#203454"
        end if
    end for
    if m.selectedArea = 4 then m.backButton.color = "#5CE08A"
    if m.seasons.Count() > 0 then m.seasonTitle.text = "TEMPORADAS"
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    clampFocusState()
    if key = "left" then
        if m.focusArea = "posterButton" and m.selectedArea = 1 then
            m.selectedArea = 0
        else if m.focusArea = "seasons" and m.selectedSeasonIndex > 0 then
            m.selectedSeasonIndex = m.selectedSeasonIndex - 1
            m.selectedEpisodeIndex = 0
            m.episodeWindowStart = 0
            setupEpisodes(m.item)
        else if m.focusArea = "episodes" and m.selectedEpisodeIndex > 0 then
            m.selectedEpisodeIndex = m.selectedEpisodeIndex - 1
            ensureEpisodeVisible()
            updateSelectedEpisodeFromIndex()
            renderEpisodes(m.episodes)
        end if
        updateFocus()
        return true
    else if key = "right" then
        if m.focusArea = "posterButton" and m.selectedArea = 0 and m.continueEpisode <> invalid then
            m.selectedArea = 1
        else if m.focusArea = "seasons" and m.selectedSeasonIndex < m.seasons.Count() - 1 then
            m.selectedSeasonIndex = m.selectedSeasonIndex + 1
            m.selectedEpisodeIndex = 0
            m.episodeWindowStart = 0
            setupEpisodes(m.item)
        else if m.focusArea = "episodes" and m.selectedEpisodeIndex < m.episodes.Count() - 1 then
            m.selectedEpisodeIndex = m.selectedEpisodeIndex + 1
            ensureEpisodeVisible()
            updateSelectedEpisodeFromIndex()
            renderEpisodes(m.episodes)
        end if
        updateFocus()
        return true
    else if key = "up" then
        if m.focusArea = "back" then
            if hasEpisodes() then
                m.selectedArea = 3
            else if hasSeasons() then
                m.selectedArea = 2
            else
                m.selectedArea = 0
            end if
        else if m.focusArea = "episodes" then
            m.selectedArea = 2
        else if m.focusArea = "seasons" then
            m.selectedArea = 0
        end if
        updateFocus()
        return true
    else if key = "down" then
        if m.focusArea = "posterButton" then
            moveFocusToFirstSeason()
        else if m.focusArea = "seasons" then
            moveFocusToEpisodes()
        else if m.focusArea = "episodes" then
            m.selectedArea = 4
        end if
        updateFocus()
        return true
    else if key = "OK" then
        if m.selectedArea = 0 then
            openFirstEpisode()
        else if m.selectedArea = 1 then
            openContinueEpisode()
        else if m.selectedArea = 2 then
            m.selectedEpisodeIndex = 0
            m.episodeWindowStart = 0
            setupEpisodes(m.item)
            updateFocus()
        else if m.selectedArea = 3 then
            openSelectedEpisode()
        else if m.selectedArea = 4 then
            m.top.backRequested = true
        end if
        return true
    else if key = "back" then
        m.top.backRequested = true
        return true
    end if
    return false
end function

sub moveFocusToFirstSeason()
    if not hasSeasons() then
        m.selectedArea = 0
        return
    end if
    m.selectedArea = 2
    clampFocusState()
    m.selectedEpisodeIndex = 0
    m.episodeWindowStart = 0
    setupEpisodes(m.item)
end sub

sub moveFocusToEpisodes()
    if m.episodes = invalid or m.episodes.Count() = 0 then setupEpisodes(m.item)
    if not hasEpisodes() then return
    m.selectedArea = 3
    m.selectedEpisodeIndex = 0
    m.episodeWindowStart = 0
    updateSelectedEpisodeFromIndex()
    clampFocusState()
end sub

function hasSeasons() as Boolean
    return m.seasons <> invalid and m.seasons.Count() > 0
end function

function hasEpisodes() as Boolean
    return m.episodes <> invalid and m.episodes.Count() > 0
end function

sub clampFocusState()
    if m.seasons = invalid then m.seasons = []
    if m.episodes = invalid then m.episodes = []
    if m.selectedSeasonIndex < 0 then m.selectedSeasonIndex = 0
    if m.seasons.Count() = 0 then
        m.selectedSeasonIndex = 0
        if m.selectedArea = 2 then m.selectedArea = 0
    else if m.selectedSeasonIndex >= m.seasons.Count() then
        m.selectedSeasonIndex = m.seasons.Count() - 1
    end if
    if m.selectedEpisodeIndex < 0 then m.selectedEpisodeIndex = 0
    if m.episodes.Count() = 0 then
        m.selectedEpisodeIndex = 0
        if m.selectedArea = 3 then m.selectedArea = 2
        if m.seasons.Count() = 0 and m.selectedArea = 2 then m.selectedArea = 0
    else if m.selectedEpisodeIndex >= m.episodes.Count() then
        m.selectedEpisodeIndex = m.episodes.Count() - 1
    end if
    if m.selectedArea = 1 and m.continueEpisode = invalid then m.selectedArea = 0
    if m.selectedArea = 0 or m.selectedArea = 1 then
        m.focusArea = "posterButton"
    else if m.selectedArea = 2 then
        m.focusArea = "seasons"
    else if m.selectedArea = 3 then
        m.focusArea = "episodes"
    else if m.selectedArea = 4 then
        m.focusArea = "back"
    else
        m.selectedArea = 0
        m.focusArea = "posterButton"
    end if
end sub

sub logFocusState()
    seasonCount = 0
    episodeCount = 0
    if m.seasons <> invalid then seasonCount = m.seasons.Count()
    if m.episodes <> invalid then episodeCount = m.episodes.Count()
    print "SERIES_DETAILS_FOCUS selectedSeasonIndex="; m.selectedSeasonIndex; " seasons.count="; seasonCount; " episodes.count="; episodeCount; " focusArea="; m.focusArea
end sub

sub ensureEpisodeVisible()
    clampFocusState()
    if m.selectedEpisodeIndex < m.episodeWindowStart then m.episodeWindowStart = m.selectedEpisodeIndex
    if m.selectedEpisodeIndex >= m.episodeWindowStart + m.maxEpisodeCards then m.episodeWindowStart = m.selectedEpisodeIndex - m.maxEpisodeCards + 1
    if m.episodeWindowStart < 0 then m.episodeWindowStart = 0
end sub

sub openFirstEpisode()
    if m.episodes = invalid or m.episodes.Count() = 0 then setupEpisodes(m.item)
    m.selectedEpisodeIndex = 0
    openSelectedEpisode()
end sub

sub openContinueEpisode()
    if m.continueEpisode = invalid then return
    emitEpisodeSelected(m.continueEpisode, 0)
end sub

sub openSelectedEpisode()
    if m.episodes = invalid or m.episodes.Count() = 0 then return
    clampFocusState()
    if m.selectedEpisodeIndex >= m.episodes.Count() then return
    updateSelectedEpisodeFromIndex()
    emitEpisodeSelected(m.selectedEpisode, m.selectedEpisodeIndex)
end sub


sub emitEpisodeSelected(episode as Dynamic, index as Integer)
    streamUrl = getEpisodeUrl(episode)
    if streamUrl = "" or not isPlayableEpisode(episode) then
        showMessage("Episódio sem link disponível.")
        return
    end if
    print "SERIES_PLAYER_URL="; maskSeriesUrl(streamUrl)
    title = getEpisodeTitle(episode, index)
    selected = {}
    if episode <> invalid and Type(episode) = "roAssociativeArray" then
        for each k in episode
            selected[k] = episode[k]
        end for
    end if
    selected.title = title
    selected.streamUrl = streamUrl
    m.top.episodeSelected = selected
end sub
