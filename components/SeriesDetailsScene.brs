sub Init()
    m.background = m.top.FindNode("background")
    m.heroOverlay = m.top.FindNode("heroOverlay")
    m.poster = m.top.FindNode("poster")
    m.posterBorder = m.top.FindNode("posterBorder")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.synopsisTitle = m.top.FindNode("synopsisTitle")
    m.synopsisLabel = m.top.FindNode("synopsisLabel")
    m.genreLabel = m.top.FindNode("genreLabel")
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
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.selectedArea = 0 ' 0 jogar, 1 continuar, 2 temporada, 3 episódios
    m.selectedSeasonIndex = 0
    m.selectedEpisodeIndex = 0
    m.episodeWindowStart = 0
    m.maxEpisodeCards = 5
    m.seasons = []
    m.episodes = []
    m.seasonNodes = []
    m.episodeNodes = []
    m.item = invalid
    configureLayout()
end sub

sub configureLayout()
    deviceInfo = CreateObject("roDeviceInfo")
    size = deviceInfo.GetDisplaySize()
    w = size.w
    h = size.h
    m.background.width = w
    m.background.height = h

    marginX = 76
    topY = 54
    posterW = 270
    posterH = 405
    heroH = 535
    buttonW = 132
    buttonH = 58
    episodeW = 154
    episodeH = 206
    episodeGap = 24
    if h <= 720 then
        marginX = 48
        topY = 34
        posterW = 205
        posterH = 308
        heroH = 438
        buttonW = 116
        buttonH = 50
        episodeW = 124
        episodeH = 166
        episodeGap = 18
    end if

    m.marginX = marginX
    m.posterW = posterW
    m.posterH = posterH
    m.episodeW = episodeW
    m.episodeH = episodeH
    m.episodeGap = episodeGap

    m.heroOverlay.translation = [marginX - 24, topY - 24]
    m.heroOverlay.width = w - (marginX * 2) + 48
    m.heroOverlay.height = heroH

    m.poster.translation = [marginX, topY]
    m.poster.width = posterW
    m.poster.height = posterH
    m.posterBorder.translation = [marginX - 3, topY - 3]
    m.posterBorder.width = posterW + 6
    m.posterBorder.height = posterH + 6

    contentX = marginX + posterW + 58
    contentW = w - contentX - marginX
    m.titleLabel.translation = [contentX, topY + 4]
    m.titleLabel.width = contentW
    m.titleLabel.height = 70
    m.titleLabel.font = "font:LargeBoldSystemFont"

    m.synopsisTitle.translation = [contentX, topY + 95]
    m.synopsisTitle.width = contentW
    m.synopsisTitle.font = "font:MediumBoldSystemFont"
    m.synopsisLabel.translation = [contentX, topY + 132]
    m.synopsisLabel.width = contentW
    m.synopsisLabel.height = 158
    m.synopsisLabel.font = "font:MediumSystemFont"
    m.genreLabel.translation = [contentX, topY + 310]
    m.genreLabel.width = contentW
    m.genreLabel.height = 54
    m.genreLabel.font = "font:MediumBoldSystemFont"

    m.actionsGroup.translation = [marginX, topY + posterH + 30]
    setupActionButton(m.playButtonGroup, m.playButtonBg, m.playButtonFocus, m.playButtonLabel, 0, buttonW, buttonH)
    setupActionButton(m.continueButtonGroup, m.continueButtonBg, m.continueButtonFocus, m.continueButtonLabel, buttonW + 18, buttonW + 42, buttonH)

    seasonY = topY + 430
    if h <= 720 then seasonY = topY + 360
    m.seasonTitle.translation = [contentX, seasonY]
    m.seasonTitle.width = contentW
    m.seasonTitle.font = "font:MediumBoldSystemFont"
    m.seasonsGroup.translation = [contentX, seasonY + 42]

    episodesY = seasonY + 88
    m.episodesGroup.translation = [contentX, episodesY]
    m.episodesMessageLabel.translation = [contentX, episodesY + 38]
    m.episodesMessageLabel.width = contentW
    m.episodesMessageLabel.height = 80
    m.episodesMessageLabel.font = "font:MediumSystemFont"
    m.loadingLabel.translation = [contentX, episodesY + 38]
    m.loadingLabel.width = contentW
    m.loadingLabel.font = "font:MediumSystemFont"
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
    m.episodeWindowStart = 0
    configureLayout()
    populate(item)
    setLoading(false)
    updateFocus()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub focusEpisodes()
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
    if genres = "" then genres = "Não informado"
    m.genreLabel.text = "Gêneros: " + genres
    setupSeasons(item)
    setupEpisodes(item)
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
    return merged
end function

function firstText(item as Dynamic, keys as Object) as String
    if item = invalid or Type(item) <> "roAssociativeArray" then return ""
    for each k in keys
        if item.DoesExist(k) and item[k] <> invalid and item[k].ToStr().Trim() <> "" then return item[k].ToStr().Trim()
    end for
    return ""
end function

sub setupSeasons(item as Dynamic)
    m.seasons = getSeasonLabels(item)
    if m.selectedSeasonIndex >= m.seasons.Count() then m.selectedSeasonIndex = 0
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
    if labels.Count() = 0 then labels.Push("TEMPORADA 1")
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
        bg.color = "#172033"
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
    if m.seasons.Count() > 0 then m.seasonTitle.text = m.seasons[m.selectedSeasonIndex]
end sub

sub setupEpisodes(item as Dynamic)
    m.episodes = getEpisodesForSelectedSeason(item)
    if m.selectedEpisodeIndex >= m.episodes.Count() then m.selectedEpisodeIndex = 0
    ensureEpisodeVisible()
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
    if episodes.Count() = 0 and item.DoesExist("episodes") and item.episodes <> invalid and Type(item.episodes) = "roArray" then
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
        poster.height = m.episodeH - 54
        poster.loadDisplayMode = "scaleToZoom"
        poster.uri = getEpisodeImage(episode)
        label = CreateObject("roSGNode", "Label")
        label.translation = [8, m.episodeH - 50]
        label.width = m.episodeW - 16
        label.height = 44
        label.font = "font:SmallBoldSystemFont"
        label.color = "#FFFFFF"
        label.wrap = true
        label.text = getEpisodeCardTitle(episode, i)
        group.AppendChild(border)
        group.AppendChild(bg)
        group.AppendChild(poster)
        group.AppendChild(label)
        m.episodesGroup.AppendChild(group)
        m.episodeNodes.Push({ group: group, border: border, bg: bg, label: label })
    end for
end sub

function getEpisodeCardTitle(episode as Dynamic, index as Integer) as String
    season = m.selectedSeasonIndex + 1
    epNum = firstText(episode, ["episode_num", "episode", "episode_number"])
    if epNum = "" then epNum = (index + 1).ToStr()
    return "S" + season.ToStr() + " E" + epNum
end function

function getEpisodeTitle(episode as Dynamic, index as Integer) as String
    title = firstText(episode, ["title", "name"])
    if title = "" then title = "Episódio " + (index + 1).ToStr()
    return title
end function

function getEpisodeUrl(episode as Dynamic) as String
    return firstText(episode, ["streamUrl", "url", "direct_url", "movie_url"])
end function

function getEpisodeImage(episode as Dynamic) as String
    image = firstText(episode, ["cover", "image", "info", "movie_image", "stream_icon"])
    if image = "" then image = m.poster.uri
    return image
end function

sub updateFocus()
    m.playButtonFocus.opacity = 0
    m.continueButtonFocus.opacity = 0
    m.playButtonBg.color = "#1F2937"
    m.continueButtonBg.color = "#1F2937"
    if m.selectedArea = 0 then
        m.playButtonFocus.opacity = 0.95
        m.playButtonBg.color = "#256D3F"
    else if m.selectedArea = 1 then
        m.continueButtonFocus.opacity = 0.95
        m.continueButtonBg.color = "#256D3F"
    end if

    for i = 0 to m.seasonNodes.Count() - 1
        m.seasonNodes[i].border.opacity = 0
        m.seasonNodes[i].bg.color = "#172033"
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
    if m.seasons.Count() > 0 then m.seasonTitle.text = m.seasons[m.selectedSeasonIndex]
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "left" then
        if m.selectedArea = 1 then
            m.selectedArea = 0
        else if m.selectedArea = 2 and m.selectedSeasonIndex > 0 then
            m.selectedSeasonIndex = m.selectedSeasonIndex - 1
            m.selectedEpisodeIndex = 0
            m.episodeWindowStart = 0
            setupEpisodes(m.item)
        else if m.selectedArea = 3 and m.selectedEpisodeIndex > 0 then
            m.selectedEpisodeIndex = m.selectedEpisodeIndex - 1
            ensureEpisodeVisible()
            renderEpisodes(m.episodes)
        end if
        updateFocus()
        return true
    else if key = "right" then
        if m.selectedArea = 0 then
            m.selectedArea = 1
        else if m.selectedArea = 2 and m.selectedSeasonIndex < m.seasons.Count() - 1 then
            m.selectedSeasonIndex = m.selectedSeasonIndex + 1
            m.selectedEpisodeIndex = 0
            m.episodeWindowStart = 0
            setupEpisodes(m.item)
        else if m.selectedArea = 3 and m.selectedEpisodeIndex < m.episodes.Count() - 1 then
            m.selectedEpisodeIndex = m.selectedEpisodeIndex + 1
            ensureEpisodeVisible()
            renderEpisodes(m.episodes)
        end if
        updateFocus()
        return true
    else if key = "up" then
        if m.selectedArea = 3 then
            m.selectedArea = 2
        else if m.selectedArea = 2 then
            m.selectedArea = 0
        end if
        updateFocus()
        return true
    else if key = "down" then
        if m.selectedArea = 0 or m.selectedArea = 1 then
            if m.seasons.Count() > 1 then
                m.selectedArea = 2
            else
                m.selectedArea = 3
            end if
        else if m.selectedArea = 2 then
            m.selectedArea = 3
        end if
        updateFocus()
        return true
    else if key = "OK" then
        if m.selectedArea = 0 or m.selectedArea = 1 then
            openFirstEpisode()
        else if m.selectedArea = 2 then
            setupEpisodes(m.item)
            m.selectedArea = 3
            updateFocus()
        else if m.selectedArea = 3 then
            openSelectedEpisode()
        end if
        return true
    else if key = "back" then
        m.top.backRequested = true
        return true
    end if
    return false
end function

sub ensureEpisodeVisible()
    if m.selectedEpisodeIndex < m.episodeWindowStart then m.episodeWindowStart = m.selectedEpisodeIndex
    if m.selectedEpisodeIndex >= m.episodeWindowStart + m.maxEpisodeCards then m.episodeWindowStart = m.selectedEpisodeIndex - m.maxEpisodeCards + 1
    if m.episodeWindowStart < 0 then m.episodeWindowStart = 0
end sub

sub openFirstEpisode()
    if m.episodes = invalid or m.episodes.Count() = 0 then setupEpisodes(m.item)
    m.selectedEpisodeIndex = 0
    openSelectedEpisode()
end sub

sub openSelectedEpisode()
    if m.episodes = invalid or m.episodes.Count() = 0 then return
    episode = m.episodes[m.selectedEpisodeIndex]
    streamUrl = getEpisodeUrl(episode)
    if streamUrl = "" then
        showMessage("Episódio sem link disponível.")
        return
    end if
    title = getEpisodeTitle(episode, m.selectedEpisodeIndex)
    m.top.episodeSelected = { title: title, streamUrl: streamUrl }
end sub
