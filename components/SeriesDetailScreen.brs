sub Init()
    m.background = m.top.FindNode("background")
    m.poster = m.top.FindNode("poster")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.metaLabel = m.top.FindNode("metaLabel")
    m.ratingLabel = m.top.FindNode("ratingLabel")
    m.synopsisLabel = m.top.FindNode("synopsisLabel")
    m.episodesTitle = m.top.FindNode("episodesTitle")
    m.episodesStatus = m.top.FindNode("episodesStatus")
    m.episodesGroup = m.top.FindNode("episodesGroup")
    m.buttonsGroup = m.top.FindNode("buttonsGroup")
    m.watchButton = m.top.FindNode("watchButton")
    m.continueButton = m.top.FindNode("continueButton")
    m.backButton = m.top.FindNode("backButton")
    m.item = invalid
    m.continueEntry = invalid
    m.season = invalid
    m.episodes = []
    m.renderedCount = 0
    m.batchSize = 10
    m.focusArea = "buttons"
    m.selectedButton = 0
    m.selectedEpisode = 0
    m.hasMoreCard = false
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
    topY = 58
    posterW = 330
    posterH = 495
    if h <= 720 then
        marginX = 48
        topY = 34
        posterW = 230
        posterH = 345
    end if

    m.poster.translation = [marginX, topY]
    m.poster.width = posterW
    m.poster.height = posterH

    contentX = marginX + posterW + 54
    contentW = w - contentX - marginX
    m.titleLabel.translation = [contentX, topY + 6]
    m.titleLabel.width = contentW
    m.titleLabel.height = 86
    m.titleLabel.font = "font:LargeBoldSystemFont"

    m.metaLabel.translation = [contentX, topY + 106]
    m.metaLabel.width = contentW
    m.metaLabel.height = 38
    m.metaLabel.font = "font:MediumSystemFont"

    m.ratingLabel.translation = [contentX, topY + 152]
    m.ratingLabel.width = contentW
    m.ratingLabel.font = "font:MediumBoldSystemFont"

    m.synopsisLabel.translation = [contentX, topY + 205]
    m.synopsisLabel.width = contentW
    m.synopsisLabel.height = 118
    m.synopsisLabel.font = "font:MediumSystemFont"

    m.episodesTitle.translation = [contentX, topY + 360]
    m.episodesTitle.width = contentW
    m.episodesTitle.font = "font:MediumBoldSystemFont"

    m.episodesStatus.translation = [contentX, topY + 408]
    m.episodesStatus.width = contentW
    m.episodesStatus.font = "font:MediumSystemFont"

    m.episodesGroup.translation = [contentX, topY + 405]
    m.buttonsGroup.translation = [marginX, h - 92]
    setupButton(m.watchButton, 0, 330)
    setupButton(m.continueButton, 355, 210)
    setupButton(m.backButton, 590, 160)
end sub

sub setupButton(button as Object, x as Integer, width as Integer)
    button.translation = [x, 0]
    button.width = width
    button.height = 54
    button.font = "font:MediumBoldSystemFont"
end sub

sub show(item as Dynamic)
    m.item = item
    m.continueEntry = findContinueEntry(item)
    m.season = invalid
    m.episodes = []
    m.renderedCount = 0
    m.focusArea = "buttons"
    m.selectedButton = 0
    m.selectedEpisode = 0
    m.hasMoreCard = false
    configureLayout()
    clearEpisodeNodes()
    populate(item)
    setLoading(false)
    updateButtons()
    m.top.visible = true
    if m.top.visible = true then m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub setLoading(isLoading as Boolean)
    if isLoading = true and m.episodes.Count() = 0 then
        m.episodesStatus.text = "Temporadas serão carregadas em instantes."
        m.episodesStatus.visible = true
    end if
end sub

sub setDetails(details as Dynamic)
    if details <> invalid then
        m.item = mergeItem(m.item, details)
        populate(m.item)
        setFirstSeason(details)
    end if
    setLoading(false)
end sub

sub populate(item as Dynamic)
    title = firstText(item, ["name", "title"])
    m.titleLabel.text = title
    m.poster.uri = firstText(item, ["movie_image", "cover", "stream_icon", "cover_big", "backdrop_path"])

    meta = joinText([firstText(item, ["genre"]), shortCountText()], " • ")
    m.metaLabel.text = meta
    m.metaLabel.visible = meta <> ""

    rating = firstText(item, ["rating", "rating_5based"])
    m.ratingLabel.text = ratingText(rating)
    m.ratingLabel.visible = m.ratingLabel.text <> ""

    desc = shortenText(firstText(item, ["description", "plot"]), 260)
    m.synopsisLabel.text = desc
    m.synopsisLabel.visible = desc <> ""
    updateButtons()
end sub

sub setFirstSeason(details as Dynamic)
    seasons = normalizeSeasons(details)
    if seasons.Count() = 0 then
        m.episodes = []
        clearEpisodeNodes()
        m.episodesStatus.text = "Episódios indisponíveis no momento."
        m.episodesStatus.visible = true
        updateButtons()
        return
    end if

    m.season = seasons[0]
    m.episodes = seasonEpisodes(m.season)
    m.renderedCount = 0
    m.selectedEpisode = 0
    clearEpisodeNodes()
    renderMoreEpisodes()
    updateButtons()
end sub

sub renderMoreEpisodes()
    clearEpisodeNodes()
    if m.episodes.Count() = 0 then
        m.episodesStatus.text = "Episódios indisponíveis no momento."
        m.episodesStatus.visible = true
        return
    end if

    nextCount = m.renderedCount + m.batchSize
    if nextCount > m.episodes.Count() then nextCount = m.episodes.Count()
    m.renderedCount = nextCount
    m.episodesStatus.visible = false

    for i = 0 to m.renderedCount - 1
        m.episodesGroup.AppendChild(createEpisodeCard(m.episodes[i], i))
    end for

    m.hasMoreCard = m.renderedCount < m.episodes.Count()
    if m.hasMoreCard then m.episodesGroup.AppendChild(createMoreCard(m.renderedCount))
end sub

function createEpisodeCard(episode as Dynamic, index as Integer) as Object
    group = CreateObject("roSGNode", "Group")
    group.translation = [(index mod 5) * 150, Int(index / 5) * 126]
    bg = CreateObject("roSGNode", "Rectangle")
    bg.id = "episodeBg"
    bg.width = 132
    bg.height = 96
    bg.color = "#141A26"
    group.AppendChild(bg)
    image = CreateObject("roSGNode", "Poster")
    image.width = 132
    image.height = 72
    image.loadDisplayMode = "scaleToFill"
    image.uri = firstText(episode, ["movie_image", "cover", "image", "info"])
    group.AppendChild(image)
    label = CreateObject("roSGNode", "Label")
    label.id = "episodeLabel"
    label.translation = [8, 70]
    label.width = 116
    label.height = 24
    label.font = "font:SmallBoldSystemFont"
    label.color = "#FFFFFF"
    label.text = episodeCode(episode, index)
    group.AppendChild(label)
    return group
end function

function createMoreCard(index as Integer) as Object
    group = CreateObject("roSGNode", "Group")
    group.translation = [(index mod 5) * 150, Int(index / 5) * 126]
    bg = CreateObject("roSGNode", "Rectangle")
    bg.id = "episodeBg"
    bg.width = 132
    bg.height = 96
    bg.color = "#141A26"
    group.AppendChild(bg)
    label = CreateObject("roSGNode", "Label")
    label.id = "episodeLabel"
    label.translation = [8, 30]
    label.width = 116
    label.height = 34
    label.font = "font:SmallBoldSystemFont"
    label.color = "#FFFFFF"
    label.horizAlign = "center"
    label.text = "+ episódios"
    group.AppendChild(label)
    return group
end function

sub clearEpisodeNodes()
    while m.episodesGroup.GetChildCount() > 0
        m.episodesGroup.RemoveChildIndex(0)
    end while
end sub

sub updateButtons()
    m.watchButton.text = "ASSISTIR PRIMEIRO EPISÓDIO"
    if m.episodes.Count() = 0 then m.watchButton.text = "TEMPORADAS"
    m.continueButton.visible = m.continueEntry <> invalid
    buttons = visibleButtons()
    if m.selectedButton >= buttons.Count() then m.selectedButton = buttons.Count() - 1
    for i = 0 to buttons.Count() - 1
        buttons[i].color = "#FFFFFF"
        if m.focusArea = "buttons" and i = m.selectedButton then buttons[i].color = "#5CE08A"
    end for
    updateEpisodeFocus()
end sub

sub updateEpisodeFocus()
    childCount = m.episodesGroup.GetChildCount()
    for i = 0 to childCount - 1
        card = m.episodesGroup.GetChild(i)
        bg = card.FindNode("episodeBg")
        label = card.FindNode("episodeLabel")
        if bg <> invalid then bg.color = "#141A26"
        if label <> invalid then label.color = "#FFFFFF"
        if m.focusArea = "episodes" and i = m.selectedEpisode then
            if bg <> invalid then bg.color = "#1F7A4D"
            if label <> invalid then label.color = "#E9FFF2"
        end if
    end for
end sub

function visibleButtons() as Object
    buttons = [m.watchButton]
    if m.continueButton.visible = true then buttons.Push(m.continueButton)
    buttons.Push(m.backButton)
    return buttons
end function

function normalizeSeasons(data as Dynamic) as Object
    data = unwrapDetails(data)
    if data = invalid or Type(data) <> "roAssociativeArray" then return []
    seasons = []
    if data.DoesExist("seasons") and Type(data.seasons) = "roArray" then
        for each season in data.seasons
            if season <> invalid and Type(season) = "roAssociativeArray" then seasons.Push(season)
        end for
    end if
    if seasons.Count() = 0 and data.DoesExist("episodes") and Type(data.episodes) = "roAssociativeArray" then
        for each k in data.episodes
            if Type(data.episodes[k]) = "roArray" then seasons.Push({ season_number: k, episodes: data.episodes[k] })
        end for
    end if
    return seasons
end function

function unwrapDetails(data as Dynamic) as Dynamic
    if data = invalid or Type(data) <> "roAssociativeArray" then return data
    if data.DoesExist("episodes") or data.DoesExist("seasons") then return data
    if data.DoesExist("data") then return unwrapDetails(data.data)
    if data.DoesExist("result") then return unwrapDetails(data.result)
    if data.DoesExist("response") then return unwrapDetails(data.response)
    return data
end function

function seasonEpisodes(season as Dynamic) as Object
    if season <> invalid and Type(season) = "roAssociativeArray" and season.DoesExist("episodes") and Type(season.episodes) = "roArray" then return season.episodes
    return []
end function

function shortCountText() as String
    if m.season = invalid then return ""
    seasonNumber = firstText(m.season, ["season_number", "number"])
    if seasonNumber = "" then seasonNumber = "1"
    return "Temporada " + seasonNumber + " • " + m.episodes.Count().ToStr() + " episódios"
end function

function episodeCode(episode as Dynamic, index as Integer) as String
    s = "1"
    if m.season <> invalid then s = firstText(m.season, ["season_number", "number"])
    if s = "" then s = "1"
    e = firstText(episode, ["episode_num", "episode_number", "number"])
    if e = "" then e = (index + 1).ToStr()
    return "S" + s + " E" + e
end function

function findContinueEntry(series as Dynamic) as Dynamic
    history = LoadViewingHistory()
    seriesId = firstText(series, ["series_id", "id"])
    for each entry in history.series
        if entry <> invalid and Type(entry) = "roAssociativeArray" and entry.series <> invalid then
            if firstText(entry.series, ["series_id", "id"]) = seriesId then return entry
        end if
    end for
    return invalid
end function

function mergeItem(base as Dynamic, details as Dynamic) as Object
    merged = {}
    if base <> invalid and Type(base) = "roAssociativeArray" then
        for each k in base
            merged[k] = base[k]
        end for
    end if
    info = unwrapDetails(details)
    if info <> invalid and Type(info) = "roAssociativeArray" and info.DoesExist("info") and info.info <> invalid then info = info.info
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
        if item.DoesExist(k) and item[k] <> invalid then
            value = item[k]
            if Type(value) = "roAssociativeArray" then
                nested = firstText(value, ["movie_image", "cover", "image"])
                if nested <> "" then return nested
            else if value.ToStr().Trim() <> "" then
                return value.ToStr().Trim()
            end if
        end if
    end for
    return ""
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

function shortenText(value as String, maxLen as Integer) as String
    text = value.Trim()
    if Len(text) <= maxLen then return text
    return Left(text, maxLen - 1) + "…"
end function

function ratingText(value as String) as String
    if value = "" then return ""
    n = Val(value)
    if n > 5 then n = n / 2
    stars = ""
    for i = 1 to 5
        if i <= Int(n + 0.5) then stars = stars + "★" else stars = stars + "☆"
    end for
    return stars
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then
        m.top.backRequested = true
        return true
    end if

    if m.focusArea = "episodes" then return handleEpisodeKeys(key)
    return handleButtonKeys(key)
end function

function handleButtonKeys(key as String) as Boolean
    buttons = visibleButtons()
    if key = "left" then
        if m.selectedButton > 0 then m.selectedButton = m.selectedButton - 1
        updateButtons()
        return true
    else if key = "right" then
        if m.selectedButton < buttons.Count() - 1 then m.selectedButton = m.selectedButton + 1
        updateButtons()
        return true
    else if key = "up" then
        if m.episodesGroup.GetChildCount() > 0 then
            m.focusArea = "episodes"
            m.selectedEpisode = 0
            updateButtons()
        end if
        return true
    else if key = "OK" then
        selected = buttons[m.selectedButton]
        if selected = m.backButton then
            m.top.backRequested = true
        else if selected = m.continueButton and m.continueEntry <> invalid then
            m.top.episodeSelected = m.continueEntry.content
        else if m.episodes.Count() > 0 then
            m.top.episodeSelected = m.episodes[0]
        else
            m.top.playRequested = true
        end if
        return true
    end if
    return false
end function

function handleEpisodeKeys(key as String) as Boolean
    count = m.episodesGroup.GetChildCount()
    if key = "down" then
        m.focusArea = "buttons"
        updateButtons()
        return true
    else if key = "left" then
        if m.selectedEpisode > 0 then m.selectedEpisode = m.selectedEpisode - 1
        updateEpisodeFocus()
        return true
    else if key = "right" then
        if m.selectedEpisode < count - 1 then m.selectedEpisode = m.selectedEpisode + 1
        updateEpisodeFocus()
        return true
    else if key = "up" then
        if m.selectedEpisode >= 5 then m.selectedEpisode = m.selectedEpisode - 5
        updateEpisodeFocus()
        return true
    else if key = "OK" then
        if m.hasMoreCard and m.selectedEpisode = count - 1 then
            renderMoreEpisodes()
            updateEpisodeFocus()
        else if m.selectedEpisode < m.episodes.Count() then
            m.top.episodeSelected = m.episodes[m.selectedEpisode]
        end if
        return true
    end if
    return false
end function
