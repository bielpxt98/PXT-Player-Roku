' Local viewing history storage for PXT Player.
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

sub UpsertMovieHistory(movie as Dynamic, position as Integer)
    if movie = invalid then return
    history = LoadViewingHistory()
    if history = invalid then history = createEmptyViewingHistory()
    history = normalizeViewingHistory(history)
    item = { type: "movie", key: "movie:" + historyContentId(movie, "stream_id"), title: historyTitle(movie, "Filme"), position: position, content: movie }
    upsertHistoryItem(history.continueWatching, item)
    upsertHistoryItem(history.movies, item)
    SaveViewingHistory(history)
end sub

sub UpsertSeriesHistory(series as Dynamic, season as Dynamic, episode as Dynamic, position as Integer)
    if episode = invalid then return
    history = LoadViewingHistory()
    if history = invalid then history = createEmptyViewingHistory()
    history = normalizeViewingHistory(history)
    item = {
        type: "series",
        key: "episode:" + historyContentId(episode, "id"),
        title: historyTitle(episode, "Episódio"),
        seriesTitle: historyTitle(series, "Série"),
        seasonNumber: historySeasonNumber(season),
        episodeNumber: historyEpisodeNumber(episode),
        position: position,
        series: series,
        season: season,
        content: episode
    }
    upsertHistoryItem(history.continueWatching, item)
    upsertHistoryItem(history.series, item)
    SaveViewingHistory(history)
end sub

function GetHistoryPosition(historyType as String, item as Dynamic) as Integer
    keyPrefix = historyType + ":"
    if historyType = "episode" then keyPrefix = "episode:"
    key = keyPrefix + historyContentId(item, "stream_id")
    if historyType = "episode" then key = keyPrefix + historyContentId(item, "id")
    for each bucket in [LoadViewingHistory().continueWatching, LoadViewingHistory().movies, LoadViewingHistory().series]
        for each entry in bucket
            if entry.key <> invalid and entry.key.ToStr() = key and entry.position <> invalid then return entry.position
        end for
    end for
    return 0
end function

function createEmptyViewingHistory() as Object
    return { continueWatching: [], movies: [], series: [] }
end function

function normalizeViewingHistory(data as Dynamic) as Object
    history = createEmptyViewingHistory()

    if data = invalid or Type(data) <> "roAssociativeArray" then return history

    if data.continueWatching <> invalid and Type(data.continueWatching) = "roArray" then
        history.continueWatching = limitHistory(data.continueWatching)
    end if

    if data.movies <> invalid and Type(data.movies) = "roArray" then
        history.movies = limitHistory(data.movies)
    end if

    if data.series <> invalid and Type(data.series) = "roArray" then
        history.series = limitHistory(data.series)
    end if

    return history
end function

sub upsertHistoryItem(bucket as Object, item as Object)
    if bucket = invalid or Type(bucket) <> "roArray" then return
    if item = invalid then return
    if item.key = invalid or item.key.ToStr() = "" then return

    for i = bucket.Count() - 1 to 0 step -1
        if bucket[i] <> invalid and bucket[i].key <> invalid and bucket[i].key.ToStr() = item.key.ToStr() then
            bucket.Delete(i)
        end if
    end for

    bucket.Insert(0, item)

    while bucket.Count() > 20
        bucket.Delete(bucket.Count() - 1)
    end while
end sub

function limitHistory(items as Object) as Object
    limited = []
    for each item in items
        if limited.Count() >= 20 then exit for
        limited.Push(item)
    end for
    return limited
end function

function historyContentId(item as Dynamic, primaryField as String) as String
    if item = invalid then return ""
    if primaryField = "stream_id" and item.stream_id <> invalid then return item.stream_id.ToStr()
    if primaryField = "id" and item.id <> invalid then return item.id.ToStr()
    if item.episode_id <> invalid then return item.episode_id.ToStr()
    if item.stream_id <> invalid then return item.stream_id.ToStr()
    if item.id <> invalid then return item.id.ToStr()
    if item.series_id <> invalid then return item.series_id.ToStr()
    return historyTitle(item, "")
end function

function historyTitle(item as Dynamic, fallback as String) as String
    if item = invalid then return fallback
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return fallback
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
