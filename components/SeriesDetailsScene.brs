sub Init()
    m.screenBg = m.top.FindNode("screenBg")
    m.background = m.top.FindNode("background")
    m.headerPanel = m.top.FindNode("headerPanel")
    m.posterShadow = m.top.FindNode("posterShadow")
    m.posterBackplate = m.top.FindNode("posterBackplate")
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
    m.episodesDivider = m.top.FindNode("episodesDivider")
    m.episodesTitle = m.top.FindNode("episodesTitle")
    m.episodesMoreLabel = m.top.FindNode("episodesMoreLabel")
    m.episodesGroup = m.top.FindNode("episodesGroup")
    m.episodesMessageLabel = m.top.FindNode("episodesMessageLabel")
    m.footerDivider = m.top.FindNode("footerDivider")
    m.footerActionDot = m.top.FindNode("footerActionDot")
    m.footerActionsLabel = m.top.FindNode("footerActionsLabel")
    m.backButton = m.top.FindNode("backButton")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.selectedArea = 0 ' 0 jogar, 1 continuar, 2 temporada, 3 episódios, 4 voltar
    m.focusArea = "posterButton"
    m.selectedSeasonIndex = 0
    m.selectedEpisodeIndex = 0
    m.selectedSeason = invalid
    m.selectedEpisode = invalid
    m.episodeWindowStart = 0
    m.maxEpisodeCards = 6
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
    m.screenBg.width = w
    m.screenBg.height = h
    m.background.width = w
    m.background.height = h

    marginX = 72
    topY = 46
    headerH = 620
    posterW = 320
    posterH = 480
    buttonW = 148
    continueButtonW = 166
    buttonH = 54
    episodeW = 230
    thumbH = 132
    episodeH = 214
    episodeGap = 22
    if h <= 720 then
        marginX = 42
        topY = 30
        headerH = 430
        posterW = 238
        posterH = 356
        buttonW = 112
        continueButtonW = 124
        buttonH = 44
        episodeW = 170
        thumbH = 96
        episodeH = 142
        episodeGap = 16
    end if

    m.marginX = marginX
    m.posterW = posterW
    m.posterH = posterH
    m.episodeW = episodeW
    m.thumbH = thumbH
    m.episodeH = episodeH
    m.episodeGap = episodeGap

    m.headerPanel.translation = [marginX - 18, topY - 18]
    m.headerPanel.width = w - (marginX * 2) + 36
    m.headerPanel.height = headerH

    posterX = marginX
    posterY = topY + 18
    m.posterShadow.translation = [posterX + 8, posterY + 10]
    m.posterShadow.width = posterW
    m.posterShadow.height = posterH
    m.posterBackplate.translation = [posterX - 3, posterY - 3]
    m.posterBackplate.width = posterW + 6
    m.posterBackplate.height = posterH + 6
    m.poster.translation = [posterX, posterY]
    m.poster.width = posterW
    m.poster.height = posterH

    contentX = posterX + posterW + 56
    contentW = w - contentX - marginX
    if h <= 720 then
        contentX = posterX + posterW + 42
        contentW = w - contentX - marginX
    end if
    m.titleLabel.translation = [contentX, topY + 18]
    m.titleLabel.width = contentW
    m.titleLabel.height = 64
    m.titleLabel.font = "font:LargeBoldSystemFont"

    m.ratingGenreLabel.translation = [contentX, topY + 88]
    m.ratingGenreLabel.width = contentW
    m.ratingGenreLabel.height = 34
    m.ratingGenreLabel.font = "font:MediumSystemFont"

    m.synopsisTitle.translation = [contentX, topY + 138]
    m.synopsisTitle.width = contentW
    m.synopsisTitle.font = "font:MediumBoldSystemFont"
    m.synopsisLabel.translation = [contentX, topY + 174]
    m.synopsisLabel.width = contentW
    m.synopsisLabel.height = 172
    m.synopsisLabel.font = "font:MediumSystemFont"
    if h <= 720 then
        m.titleLabel.translation = [contentX, topY + 10]
        m.titleLabel.height = 48
        m.ratingGenreLabel.translation = [contentX, topY + 66]
        m.synopsisTitle.translation = [contentX, topY + 108]
        m.synopsisLabel.translation = [contentX, topY + 138]
        m.synopsisLabel.height = 126
    end if

    seasonY = topY + 382
    if h <= 720 then seasonY = topY + 282
    m.seasonTitle.translation = [contentX, seasonY]
    m.seasonTitle.width = contentW
    m.seasonTitle.font = "font:MediumBoldSystemFont"
    m.seasonsGroup.translation = [contentX, seasonY + 38]

    ' Botões agora ficam embaixo do poster principal, como player moderno.
    actionsY = posterY + posterH + 28
    if h <= 720 then actionsY = posterY + posterH + 18
    m.actionsGroup.translation = [posterX, actionsY]
    actionGap = 18
    if h <= 720 then actionGap = 12
    setupActionButton(m.playButtonGroup, m.playButtonBg, m.playButtonFocus, m.playButtonLabel, 0, buttonW, buttonH)
    setupActionButton(m.continueButtonGroup, m.continueButtonBg, m.continueButtonFocus, m.continueButtonLabel, buttonW + actionGap, continueButtonW, buttonH)

    episodesTitleY = topY + headerH + 22
    m.episodesDivider.translation = [marginX, episodesTitleY - 16]
    m.episodesDivider.width = w - (marginX * 2)
    m.episodesDivider.height = 2
    m.episodesTitle.translation = [marginX, episodesTitleY]
    m.episodesTitle.width = 260
    m.episodesTitle.font = "font:MediumBoldSystemFont"
    m.episodesMoreLabel.translation = [w - marginX - 46, episodesTitleY]
    m.episodesMoreLabel.width = 46
    m.episodesMoreLabel.height = 32
    m.episodesMoreLabel.font = "font:MediumBoldSystemFont"
    episodesY = episodesTitleY + 42
    if h <= 720 then episodesY = episodesTitleY + 38
    m.episodesGroup.translation = [marginX, episodesY]
    m.maxEpisodeCards = Int((w - (marginX * 2) + episodeGap) / (episodeW + episodeGap))
    if m.maxEpisodeCards < 1 then m.maxEpisodeCards = 1
    if h <= 720 and m.maxEpisodeCards > 6 then m.maxEpisodeCards = 6
    if h > 720 and m.maxEpisodeCards > 6 then m.maxEpisodeCards = 6
    m.episodesMessageLabel.translation = [marginX, episodesY + 30]
    m.episodesMessageLabel.width = w - (marginX * 2)
    m.episodesMessageLabel.height = 80
    m.episodesMessageLabel.font = "font:MediumSystemFont"
    m.loadingLabel.translation = [marginX, episodesY + 30]
    m.loadingLabel.width = w - (marginX * 2)
    m.loadingLabel.font = "font:MediumSystemFont"

    footerY = h - 64
    m.footerDivider.translation = [marginX, footerY - 16]
    m.footerDivider.width = w - (marginX * 2)
    m.footerDivider.height = 2
    m.footerActionDot.translation = [marginX, footerY + 17]
    m.footerActionDot.width = 12
    m.footerActionDot.height = 12
    m.footerActionsLabel.translation = [marginX + 22, footerY]
    m.footerActionsLabel.width = 160
    m.footerActionsLabel.height = 46
    m.footerActionsLabel.font = "font:MediumBoldSystemFont"
    m.backButton.translation = [w - marginX - 190, footerY]
    m.backButton.width = 190
    m.backButton.height = 46
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
    if item <> invalid and Type(item) = "roAssociativeArray" then m.item = normalizeSeriesDetailsForPlayback(item)
    genres = firstText(m.item, ["genre", "genres"])
    rating = firstText(m.item, ["rating", "rating_5based", "vote_average"])
    year = firstText(m.item, ["releaseDate", "release_date", "year", "releasedate"])
    if Len(year) >= 4 then year = Left(year, 4)
    seasonCountText = ""
    if m.item <> invalid and Type(m.item) = "roAssociativeArray" and m.item.DoesExist("seasons") and m.item.seasons <> invalid and Type(m.item.seasons) = "roArray" and m.item.seasons.Count() > 0 then
        seasonCountText = m.item.seasons.Count().ToStr() + " Temporada"
        if m.item.seasons.Count() <> 1 then seasonCountText = seasonCountText + "s"
    end if
    meta = joinText([year, seasonCountText, genres, ratingText(rating)], " • ")
    m.ratingGenreLabel.text = meta
    m.ratingGenreLabel.visible = meta <> ""
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
                    if n > 0 then label = "Temporada " + n.ToStr()
                    if LCase(Left(label, 6)) = "season" then label = "Temporada" + Mid(label, 7)
                    if LCase(Left(label, 9)) = "temporada" then label = "Temporada" + Mid(label, 10)
                    labels.Push(label)
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
        bg.width = 176
        bg.height = 44
        bg.color = "#0B1424"
        border = CreateObject("roSGNode", "Rectangle")
        border.translation = [-3, -3]
        border.width = 182
        border.height = 50
        border.color = "#2F80ED"
        border.opacity = 0.65
        label = CreateObject("roSGNode", "Label")
        label.text = m.seasons[i]
        label.width = 176
        label.height = 44
        label.horizAlign = "center"
        label.vertAlign = "center"
        label.font = "font:MediumBoldSystemFont"
        group.AppendChild(border)
        group.AppendChild(bg)
        group.AppendChild(label)
        m.seasonsGroup.AppendChild(group)
        m.seasonNodes.Push({ group: group, bg: bg, border: border, label: label })
        x = x + 192
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
    m.episodesMoreLabel.visible = (not hasNoEpisodes) and (m.episodeWindowStart + m.maxEpisodeCards < episodes.Count())
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
        border.color = "#2F80ED"
        border.opacity = 0
        bg = CreateObject("roSGNode", "Rectangle")
        bg.width = m.episodeW
        bg.height = m.episodeH
        bg.color = "#0B1424"
        thumbBg = CreateObject("roSGNode", "Rectangle")
        thumbBg.width = m.episodeW
        thumbBg.height = m.thumbH
        thumbBg.color = "#2B3446"
        titleLabel = CreateObject("roSGNode", "Label")
        titleLabel.translation = [10, m.thumbH + 10]
        titleLabel.width = m.episodeW - 20
        titleLabel.height = 52
        titleLabel.font = "font:SmallBoldSystemFont"
        titleLabel.color = "#FFFFFF"
        titleLabel.wrap = true
        titleLabel.text = getEpisodeTitle(episode, i)
        durationLabel = CreateObject("roSGNode", "Label")
        durationLabel.translation = [10, m.thumbH + 66]
        durationLabel.width = m.episodeW - 20
        durationLabel.height = 24
        durationLabel.font = "font:SmallSystemFont"
        durationLabel.color = "#B8C3D6"
        durationLabel.text = getEpisodeDuration(episode)
        group.AppendChild(border)
        group.AppendChild(bg)
        group.AppendChild(thumbBg)
        imageUri = getEpisodeImage(episode)
        if imageUri <> "" then
            poster = CreateObject("roSGNode", "Poster")
            poster.width = m.episodeW
            poster.height = m.thumbH
            poster.loadDisplayMode = "scaleToZoom"
            poster.uri = imageUri
            group.AppendChild(poster)
        end if
        group.AppendChild(titleLabel)
        group.AppendChild(durationLabel)
        m.episodesGroup.AppendChild(group)
        m.episodeNodes.Push({ group: group, border: border, bg: bg, titleLabel: titleLabel, durationLabel: durationLabel })
    end for
end sub

function getEpisodeDuration(episode as Dynamic) as String
    duration = firstText(episode, ["duration", "duration_secs", "runtime", "episode_run_time"])
    if duration = "" then return "45 min"
    if Instr(1, duration, ":") > 0 or Instr(1, LCase(duration), "min") > 0 then return duration
    seconds = Val(duration)
    if seconds > 300 then return Int(seconds / 60).ToStr() + " min"
    return duration + " min"
end function

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
    ' debug removido para reduzir lentidão no Roku
end sub

sub updateSelectedEpisodeFromIndex()
    m.selectedEpisode = invalid
    if m.episodes <> invalid and m.selectedEpisodeIndex >= 0 and m.selectedEpisodeIndex < m.episodes.Count() then
        episode = m.episodes[m.selectedEpisodeIndex]
        if episode <> invalid and Type(episode) = "roAssociativeArray" and (not episode.DoesExist("episodes") or episode.episodes = invalid) then m.selectedEpisode = episode
    end if
    ' debug removido para reduzir lentidão no Roku
end sub

function getEpisodeImage(episode as Dynamic) as String
    image = firstText(episode, ["cover", "image", "movie_image", "stream_icon", "info_movie_image", "thumbnail", "thumb", "cover_big", "backdrop_path"] )
    if image <> "" then return image
    if episode <> invalid and Type(episode) = "roAssociativeArray" then
        for each nestedKey in ["info", "movie_data", "metadata"]
            if episode.DoesExist(nestedKey) and episode[nestedKey] <> invalid and Type(episode[nestedKey]) = "roAssociativeArray" then
                image = firstText(episode[nestedKey], ["cover", "image", "movie_image", "stream_icon", "info_movie_image", "thumbnail", "thumb", "cover_big", "backdrop_path"] )
                if image <> "" then return image
            end if
        end for
    end if
    return ""
end function

sub updateContinueButton()
    if m.continueEpisode <> invalid then
        m.continueButtonLabel.text = "Continuar"
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
    m.playButtonFocus.color = "#8CC8FF"
    m.continueButtonFocus.color = "#2F80ED"
    m.playButtonBg.color = "#2F80ED"
    m.continueButtonBg.color = "#0B1424"
    m.backButton.color = "#FFFFFF"
    if m.selectedArea = 0 then
        m.playButtonFocus.opacity = 0.95
        m.playButtonBg.color = "#4DA3FF"
    else if m.selectedArea = 1 then
        m.continueButtonFocus.opacity = 0.95
        m.continueButtonBg.color = "#193A63"
    end if

    for i = 0 to m.seasonNodes.Count() - 1
        m.seasonNodes[i].border.opacity = 0.65
        m.seasonNodes[i].bg.color = "#0B1424"
        if i = m.selectedSeasonIndex then
            m.seasonNodes[i].bg.color = "#2F80ED"
        end if
        if m.selectedArea = 2 and i = m.selectedSeasonIndex then
            m.seasonNodes[i].border.opacity = 0.95
        end if
    end for

    for i = 0 to m.episodeNodes.Count() - 1
        m.episodeNodes[i].border.opacity = 0
        m.episodeNodes[i].bg.color = "#0B1424"
        m.episodeNodes[i].group.scale = [1.0, 1.0]
        if m.selectedArea = 3 and i = (m.selectedEpisodeIndex - m.episodeWindowStart) then
            m.episodeNodes[i].border.opacity = 0.95
            m.episodeNodes[i].bg.color = "#12243D"
            m.episodeNodes[i].group.scale = [1.04, 1.04]
        end if
    end for
    if m.selectedArea = 4 then m.backButton.color = "#2F80ED"
    if m.seasons.Count() > 0 then m.seasonTitle.text = "TEMPORADAS"
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    clampFocusState()
    if key = "left" then
        if m.focusArea = "posterButton" and m.selectedArea = 1 then
            m.selectedArea = 0
        else if m.focusArea = "seasons" then
            ' Temporadas ficam ao lado dos botões: esquerda sempre volta
            ' para Continuar, se existir, ou Jogar.
            if m.continueEpisode <> invalid then m.selectedArea = 1 else m.selectedArea = 0
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
        else if m.focusArea = "posterButton" and hasSeasons() then
            ' Depois de Jogar/Continuar, direita entra nas temporadas.
            m.selectedArea = 2
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
            ' De Jogar/Continuar para baixo vai direto aos episódios.
            moveFocusToEpisodes()
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
    ' debug removido para reduzir lentidão no Roku
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
    ' print "SERIES_PLAYER_URL="; maskSeriesUrl(streamUrl)
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
