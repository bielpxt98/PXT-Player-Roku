sub Init()
    m.panelBg = m.top.FindNode("panelBg") : m.backLabel = m.top.FindNode("backLabel") : m.brandLabel = m.top.FindNode("brandLabel") : m.headerLine = m.top.FindNode("headerLine")
    m.poster = m.top.FindNode("poster") : m.titleLabel = m.top.FindNode("titleLabel") : m.genreLabel = m.top.FindNode("genreLabel") : m.yearLabel = m.top.FindNode("yearLabel") : m.ratingLabel = m.top.FindNode("ratingLabel")
    m.synopsisTitle = m.top.FindNode("synopsisTitle") : m.synopsisLabel = m.top.FindNode("synopsisLabel") : m.seasonLine = m.top.FindNode("seasonLine") : m.seasonsTitle = m.top.FindNode("seasonsTitle")
    m.seasonsGroup = m.top.FindNode("seasonsGroup") : m.episodesLine = m.top.FindNode("episodesLine") : m.episodesTitle = m.top.FindNode("episodesTitle") : m.episodesGroup = m.top.FindNode("episodesGroup")
    m.messageLabel = m.top.FindNode("messageLabel") : m.hintLabel = m.top.FindNode("hintLabel")
    m.series = invalid : m.details = invalid : m.seasons = [] : m.episodes = [] : m.activePane = "seasons" : m.seasonIndex = 0 : m.episodeIndex = 0
    layoutScreen() : hide()
end sub
sub layoutScreen()
    r = getDisplayResolution() : w = r.width : h = r.height : m.panelBg.width = w : m.panelBg.height = h
    m.backLabel.translation = [54, 24] : m.backLabel.font = "font:MediumBoldSystemFont" : m.brandLabel.translation = [w - 334, 24] : m.brandLabel.width = 280 : m.brandLabel.font = "font:MediumBoldSystemFont"
    m.headerLine.translation = [54, 74] : m.headerLine.width = w - 108
    m.poster.translation = [74, 104] : m.poster.width = 210 : m.poster.height = 300
    x = 320 : m.titleLabel.translation = [x, 104] : m.titleLabel.width = w - x - 70 : m.titleLabel.height = 42 : m.titleLabel.font = "font:LargeBoldSystemFont"
    m.genreLabel.translation = [x, 158] : m.genreLabel.width = w - x - 70 : m.genreLabel.font = "font:MediumSystemFont" : m.yearLabel.translation = [x, 202] : m.yearLabel.font = "font:MediumSystemFont" : m.ratingLabel.translation = [x, 246] : m.ratingLabel.font = "font:MediumSystemFont"
    m.synopsisTitle.translation = [x, 302] : m.synopsisTitle.font = "font:MediumBoldSystemFont" : m.synopsisLabel.translation = [x, 340] : m.synopsisLabel.width = w - x - 84 : m.synopsisLabel.height = 112 : m.synopsisLabel.font = "font:MediumSystemFont"
    m.seasonLine.translation = [54, 432] : m.seasonLine.width = w - 108 : m.seasonsTitle.translation = [74, 450] : m.seasonsTitle.font = "font:MediumBoldSystemFont" : m.seasonsGroup.translation = [74, 492]
    m.episodesLine.translation = [54, 540] : m.episodesLine.width = w - 108 : m.episodesTitle.translation = [74, 558] : m.episodesTitle.font = "font:MediumBoldSystemFont" : m.episodesGroup.translation = [74, 600]
    m.messageLabel.translation = [0, h - 94] : m.messageLabel.width = w : m.messageLabel.font = "font:MediumSystemFont" : m.hintLabel.translation = [0, h - 38] : m.hintLabel.width = w : m.hintLabel.font = "font:SmallSystemFont"
end sub
sub show(series as Dynamic)
    m.series = series : m.top.visible = true : m.top.SetFocus(true) : renderHeader(series) : clearLists() : showMessage("Carregando temporadas...")
end sub
sub hide()
    m.top.visible = false
end sub
sub setLoading(isLoading as Boolean)
    if isLoading then showMessage("Carregando temporadas...") else showMessage("")
end sub
sub showMessage(message as String)
    m.messageLabel.text = message
end sub
sub setDetails(details as Object)
    m.details = details : renderHeader(details) : m.seasons = normalizeSeriesSeasons(details) : m.seasonIndex = 0 : m.episodeIndex = 0
    if m.seasons.Count() = 0 then showMessage("Esta série não possui temporadas ou episódios disponíveis.") else showMessage("")
    selectSeason() : renderSeasons() : renderEpisodes() : updateFocus()
end sub
sub renderHeader(data as Dynamic)
    info = data : if data <> invalid and data.info <> invalid then info = data.info
    m.titleLabel.text = valueOr(getField(info, "name"), valueOr(getField(m.series, "name"), "Série"))
    m.genreLabel.text = "Gênero: " + valueOr(getField(info, "genre"), "Não informado")
    m.yearLabel.text = "Ano: " + valueOr(getField(info, "releaseDate"), valueOr(getField(info, "year"), "Não informado"))
    m.ratingLabel.text = "Nota: " + valueOr(getField(info, "rating"), "Não informado")
    m.synopsisLabel.text = valueOr(getField(info, "plot"), valueOr(getField(info, "description"), "Não informado"))
    m.poster.uri = valueOr(getField(info, "cover"), valueOr(getField(m.series, "cover"), valueOr(getField(m.series, "series_image"), "")))
end sub
sub clearLists()
    m.seasons = [] : m.episodes = [] : clearGroup(m.seasonsGroup) : clearGroup(m.episodesGroup)
end sub
sub selectSeason()
    if m.seasons.Count() = 0 then m.episodes = [] : return
    if m.seasonIndex >= m.seasons.Count() then m.seasonIndex = m.seasons.Count() - 1
    m.episodes = getSeasonEpisodes(m.seasons[m.seasonIndex])
end sub
sub renderSeasons()
    clearGroup(m.seasonsGroup)
    for i = 0 to m.seasons.Count() - 1
        label = CreateObject("roSGNode", "Label") : label.translation = [i * 210, 0] : label.width = 200 : label.height = 36 : label.font = "font:MediumSystemFont" : label.text = seasonName(m.seasons[i]) : label.color = "#DDE6F3" : m.seasonsGroup.AppendChild(label)
    end for
end sub
sub renderEpisodes()
    clearGroup(m.episodesGroup)
    maxItems = 6 : if m.episodes.Count() < maxItems then maxItems = m.episodes.Count()
    for i = 0 to maxItems - 1
        ep = m.episodes[i] : label = CreateObject("roSGNode", "Label") : label.translation = [0, i * 42] : label.width = 820 : label.height = 38 : label.font = "font:MediumSystemFont" : label.color = "#DDE6F3" : label.text = episodeLabel(ep) : m.episodesGroup.AppendChild(label)
    end for
end sub
sub updateFocus()
    for i = 0 to m.seasonsGroup.GetChildCount() - 1 : m.seasonsGroup.GetChild(i).color = "#DDE6F3" : if m.activePane = "seasons" and i = m.seasonIndex then m.seasonsGroup.GetChild(i).color = "#38BDF8"
    end for
    for i = 0 to m.episodesGroup.GetChildCount() - 1 : m.episodesGroup.GetChild(i).color = "#DDE6F3" : if m.activePane = "episodes" and i = m.episodeIndex then m.episodesGroup.GetChild(i).color = "#38BDF8"
    end for
end sub
function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then m.top.backRequested = true : return true
    if key = "left" or key = "right" then
        if m.activePane = "seasons" then
            m.activePane = "episodes"
        else
            m.activePane = "seasons"
        end if
        updateFocus()
        return true
    end if
    if key = "up" then move(-1) : return true
    if key = "down" then move(1) : return true
    if key = "OK" then activate() : return true
    return false
end function
sub move(delta as Integer)
    if m.activePane = "seasons" and m.seasons.Count() > 0 then
        m.seasonIndex = clamp(m.seasonIndex + delta, 0, m.seasons.Count() - 1)
        selectSeason()
        m.episodeIndex = 0
        renderSeasons()
        renderEpisodes()
    else if m.activePane = "episodes" and m.episodes.Count() > 0 then
        m.episodeIndex = clamp(m.episodeIndex + delta, 0, m.episodes.Count() - 1)
    end if
    updateFocus()
end sub
sub activate()
    if m.activePane = "seasons" then
        selectSeason()
        renderEpisodes()
        m.activePane = "episodes"
        updateFocus()
    else if m.activePane = "episodes" and m.episodes.Count() > 0 then
        m.top.episodeSelected = m.episodes[m.episodeIndex]
    end if
end sub
function normalizeSeriesSeasons(data as Dynamic) as Object
    result = [] : if data = invalid or Type(data) <> "roAssociativeArray" then return result
    episodesBySeason = invalid : if data.DoesExist("episodes") and Type(data.episodes) = "roAssociativeArray" then episodesBySeason = data.episodes
    if data.DoesExist("seasons") and Type(data.seasons) = "roArray" then
        for each s in data.seasons
            season = s : if Type(season) <> "roAssociativeArray" then season = {}
            n = getSeasonNumber(season) : season.episodes = getEpisodesForSeason(episodesBySeason, n) : result.Push(season)
        end for
    else if episodesBySeason <> invalid then
        for each k in episodesBySeason : result.Push({ name: "Temporada " + k.ToStr(), season_number: k.ToStr(), episodes: getEpisodesForSeason(episodesBySeason, k) }) : end for
    end if
    return result
end function
function getEpisodesForSeason(map as Dynamic, number as Dynamic) as Object
    if map = invalid then return []
    key = number.ToStr() : if map.DoesExist(key) and Type(map[key]) = "roArray" then return map[key]
    return []
end function
function getSeasonEpisodes(season as Dynamic) as Object
    if season <> invalid and season.episodes <> invalid and Type(season.episodes) = "roArray" then return season.episodes
    return []
end function
function seasonName(season as Dynamic) as String
    name = valueOr(getField(season, "name"), valueOr(getField(season, "title"), "")) : if name <> "" then return name
    return "Temporada " + valueOr(getField(season, "season_number"), "")
end function
function episodeLabel(ep as Dynamic) as String
    num = valueOr(getField(ep, "episode_num"), valueOr(getField(ep, "episode_number"), "")) : title = valueOr(getField(ep, "title"), valueOr(getField(ep, "name"), "Episódio"))
    prefix = "" : if num <> "" then prefix = "E" + num + " - "
    duration = valueOr(getField(ep, "duration"), "") : if duration <> "" then return prefix + title + "              " + duration
    return prefix + title
end function
function getField(obj as Dynamic, key as String) as Dynamic
    if obj <> invalid and Type(obj) = "roAssociativeArray" and obj.DoesExist(key) then return obj[key]
    return invalid
end function
function valueOr(v as Dynamic, fallback as String) as String
    if v <> invalid and v.ToStr().Trim() <> "" then return v.ToStr()
    return fallback
end function
function getSeasonNumber(season as Dynamic) as String
    return valueOr(getField(season, "season_number"), valueOr(getField(season, "number"), ""))
end function
function clamp(v as Integer, lo as Integer, hi as Integer) as Integer
    if v < lo then return lo
    if v > hi then return hi
    return v
end function
sub clearGroup(group as Object)
    while group.GetChildCount() > 0 : group.RemoveChildIndex(0) : end while
end sub
function getDisplayResolution() as Object
    d = CreateObject("roDeviceInfo") : s = d.GetDisplaySize() : return { width: s.w, height: s.h }
end function
