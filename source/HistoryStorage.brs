' Lightweight local viewing history storage for PXT Player.
function LoadViewingHistory() as Object
    section = CreateObject("roRegistrySection", "PXTPlayerHistory")
    json = section.Read("items")
    if json = invalid or Type(json) <> "String" or json.Trim() = "" then return createEmptyViewingHistory()

    data = ParseJson(json)
    if data = invalid or Type(data) <> "roAssociativeArray" then return createEmptyViewingHistory()

    return normalizeViewingHistory(data)
end function

sub SaveViewingHistory(history as Object)
    section = CreateObject("roRegistrySection", "PXTPlayerHistory")
    section.Write("items", FormatJson(normalizeViewingHistory(history)))
    section.Flush()
end sub

sub UpsertMovieHistory(movie as Dynamic, position as Integer, duration as Dynamic)
    if movie = invalid then return
    history = normalizeViewingHistory(LoadViewingHistory())
    key = "movie:" + historyContentId(movie, "stream_id")
    item = {
        type: "movie",
        key: key,
        id: historyContentId(movie, "stream_id"),
        url: historyUrl(movie),
        title: historyTitle(movie, "Filme"),
        poster: historyPoster(movie),
        position: position,
        duration: historyInt(duration),
        updatedAt: historyNowIso(),
        content: minimalMovieContent(movie)
    }
    upsertHistoryItem(history.movies, item, 5)
    SaveViewingHistory(history)
end sub

sub UpsertSeriesHistory(series as Dynamic, season as Dynamic, episode as Dynamic, position as Integer, duration as Dynamic)
    if episode = invalid then return
    history = normalizeViewingHistory(LoadViewingHistory())
    item = {
        type: "series",
        key: "episode:" + historyContentId(episode, "id"),
        id: historyContentId(episode, "id"),
        url: historyUrl(episode),
        title: historyTitle(episode, "Episódio"),
        poster: historyPoster(series),
        seriesTitle: historyTitle(series, "Série"),
        seasonNumber: historySeasonNumber(season),
        episodeNumber: historyEpisodeNumber(episode),
        position: position,
        duration: historyInt(duration),
        updatedAt: historyNowIso(),
        series: minimalSeriesContent(series),
        season: minimalSeasonContent(season),
        content: minimalEpisodeContent(episode)
    }
    upsertHistoryItem(history.series, item, 5)
    SaveViewingHistory(history)
end sub

function GetHistoryPosition(historyType as String, item as Dynamic) as Integer
    keyPrefix = historyType + ":"
    if historyType = "episode" then keyPrefix = "episode:"
    key = keyPrefix + historyContentId(item, "stream_id")
    if historyType = "episode" then key = keyPrefix + historyContentId(item, "id")
    history = LoadViewingHistory()
    for each bucket in [history.movies, history.series]
        for each entry in bucket
            if entry.key <> invalid and entry.key.ToStr() = key and entry.position <> invalid then return historyInt(entry.position)
        end for
    end for
    return 0
end function

function createEmptyViewingHistory() as Object
    return { movies: [], series: [] }
end function

function normalizeViewingHistory(data as Dynamic) as Object
    history = createEmptyViewingHistory()
    if data = invalid or Type(data) <> "roAssociativeArray" then return history
    if data.movies <> invalid and Type(data.movies) = "roArray" then history.movies = limitHistory(data.movies, 5)
    if data.series <> invalid and Type(data.series) = "roArray" then history.series = limitHistory(data.series, 5)
    return history
end function

sub upsertHistoryItem(bucket as Object, item as Object, maxItems as Integer)
    if bucket = invalid or Type(bucket) <> "roArray" or item = invalid then return
    if item.key = invalid or item.key.ToStr() = "" then return
    for i = bucket.Count() - 1 to 0 step -1
        if bucket[i] <> invalid and bucket[i].key <> invalid and bucket[i].key.ToStr() = item.key.ToStr() then bucket.Delete(i)
    end for
    bucket.Insert(0, item)
    while bucket.Count() > maxItems
        bucket.Delete(bucket.Count() - 1)
    end while
end sub

function limitHistory(items as Object, maxItems as Integer) as Object
    limited = []
    for each item in items
        if limited.Count() >= maxItems then exit for
        limited.Push(item)
    end for
    return limited
end function

function minimalMovieContent(movie as Dynamic) as Object
    return { stream_id: historyContentId(movie, "stream_id"), name: historyTitle(movie, "Filme"), title: historyTitle(movie, "Filme"), stream_icon: historyPoster(movie), cover: historyPoster(movie), url: historyUrl(movie), streamUrl: historyUrl(movie), category_id: historyCategoryId(movie) }
end function

function minimalSeriesContent(series as Dynamic) as Object
    return { series_id: historyContentId(series, "series_id"), name: historyTitle(series, "Série"), title: historyTitle(series, "Série"), series_image: historyPoster(series), cover: historyPoster(series), category_id: historyCategoryId(series) }
end function

function minimalSeasonContent(season as Dynamic) as Object
    return { season_number: historySeasonNumber(season), number: historySeasonNumber(season) }
end function

function minimalEpisodeContent(episode as Dynamic) as Object
    return { id: historyContentId(episode, "id"), episode_id: historyContentId(episode, "id"), title: historyTitle(episode, "Episódio"), name: historyTitle(episode, "Episódio"), streamUrl: historyUrl(episode), url: historyUrl(episode), episode_num: historyEpisodeNumber(episode) }
end function

function historyContentId(item as Dynamic, primaryField as String) as String
    if item = invalid then return ""
    if primaryField = "stream_id" and item.stream_id <> invalid then return item.stream_id.ToStr()
    if primaryField = "series_id" and item.series_id <> invalid then return item.series_id.ToStr()
    if primaryField = "id" and item.id <> invalid then return item.id.ToStr()
    if item.episode_id <> invalid then return item.episode_id.ToStr()
    if item.stream_id <> invalid then return item.stream_id.ToStr()
    if item.id <> invalid then return item.id.ToStr()
    if item.series_id <> invalid then return item.series_id.ToStr()
    url = historyUrl(item)
    if url <> "" then return url
    return historyTitle(item, "")
end function

function historyTitle(item as Dynamic, fallback as String) as String
    if item = invalid then return fallback
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return fallback
end function

function historyUrl(item as Dynamic) as String
    if item = invalid then return ""
    if item.streamUrl <> invalid and item.streamUrl.ToStr().Trim() <> "" then return item.streamUrl.ToStr()
    if item.url <> invalid and item.url.ToStr().Trim() <> "" then return item.url.ToStr()
    if item.direct_source <> invalid and item.direct_source.ToStr().Trim() <> "" then return item.direct_source.ToStr()
    return ""
end function

function historyPoster(item as Dynamic) as String
    if item = invalid then return ""
    for each field in ["stream_icon", "cover", "movie_image", "series_image", "poster", "cover_big"]
        if item.DoesExist(field) and item[field] <> invalid and item[field].ToStr().Trim() <> "" then return item[field].ToStr()
    end for
    return ""
end function

function historyCategoryId(item as Dynamic) as String
    if item = invalid then return ""
    if item.category_id <> invalid then return item.category_id.ToStr()
    return ""
end function

function historySeasonNumber(season as Dynamic) as String
    if season = invalid then return ""
    if season.season_number <> invalid then return season.season_number.ToStr()
    if season.number <> invalid then return season.number.ToStr()
    return ""
end function

function historyEpisodeNumber(episode as Dynamic) as String
    if episode = invalid then return ""
    if episode.episode_num <> invalid then return episode.episode_num.ToStr()
    if episode.episode_number <> invalid then return episode.episode_number.ToStr()
    return ""
end function

function historyInt(value as Dynamic) as Integer
    if value = invalid then return 0
    return Int(value)
end function

function historyNowIso() as String
    dt = CreateObject("roDateTime")
    dt.Mark()
    return dt.ToISOString()
end function
