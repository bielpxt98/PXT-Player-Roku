' Safe local viewing history storage for PXT Player.
' All history helpers are defensive: invalid input returns empty/default data and
' history writes must never block movie or series playback.

function GetMovieHistory() as Object
    return loadHistoryBucket("movies")
end function

sub SaveMovieHistory(history as Object)
    saveHistoryBucket("movies", history)
end sub

sub UpsertMovieHistory(movie as Dynamic, position as Dynamic, duration as Dynamic)
    if isHistoryObject(movie) = false then return

    id = historyContentId(movie, "stream_id")
    key = "movie:" + id
    if key = "movie:" then return

    safePosition = historyInt(position)
    existingPosition = GetHistoryPosition("movie", movie)
    if safePosition = 0 and existingPosition > 0 then safePosition = existingPosition

    item = {
        type: "movie",
        key: key,
        id: id,
        url: historyUrl(movie),
        title: historyTitle(movie, ""),
        poster: historyPoster(movie),
        position: safePosition,
        duration: historyInt(duration),
        updatedAt: historyNowIso(),
        content: minimalMovieContent(movie)
    }

    SaveMovieHistory(upsertLimitedHistoryItem(GetMovieHistory(), item, 5))
end sub

function GetSeriesHistory() as Object
    return loadHistoryBucket("series")
end function

sub SaveSeriesHistory(history as Object)
    saveHistoryBucket("series", history)
end sub

sub UpsertSeriesHistory(series as Dynamic, season as Dynamic, episode as Dynamic, position as Dynamic, duration as Dynamic)
    if isHistoryObject(episode) = false then return

    id = historyContentId(episode, "id")
    key = "episode:" + id
    if key = "episode:" then return

    safePosition = historyInt(position)
    existingPosition = GetHistoryPosition("episode", episode)
    if safePosition = 0 and existingPosition > 0 then safePosition = existingPosition

    item = {
        type: "series",
        key: key,
        id: id,
        url: historyUrl(episode),
        title: historyTitle(episode, ""),
        poster: historyPoster(series),
        seriesTitle: historyTitle(series, ""),
        seasonNumber: historySeasonNumber(season),
        episodeNumber: historyEpisodeNumber(episode),
        position: safePosition,
        duration: historyInt(duration),
        updatedAt: historyNowIso(),
        series: minimalSeriesContent(series),
        season: minimalSeasonContent(season),
        content: minimalEpisodeContent(episode)
    }

    SaveSeriesHistory(upsertLimitedHistoryItem(GetSeriesHistory(), item, 5))
end sub

function LoadViewingHistory() as Object
    return { movies: GetMovieHistory(), series: GetSeriesHistory() }
end function

sub SaveViewingHistory(history as Object)
    if isHistoryObject(history) = false then return
    SaveMovieHistory(history.movies)
    SaveSeriesHistory(history.series)
end sub


function GetLastSeriesEpisode(series as Dynamic) as Dynamic
    if isHistoryObject(series) = false then return invalid
    seriesId = historyContentId(series, "series_id")
    if seriesId = "" then seriesId = historyContentId(series, "id")
    history = GetSeriesHistory()
    if Type(history) <> "roArray" then return invalid
    for each entry in history
        if isHistoryObject(entry) then
            entrySeriesId = ""
            if entry.series <> invalid then
                entrySeriesId = historyContentId(entry.series, "series_id")
                if entrySeriesId = "" then entrySeriesId = historyContentId(entry.series, "id")
            end if
            if seriesId <> "" and entrySeriesId = seriesId then return entry.content
        end if
    end for
    return invalid
end function

function GetHistoryPosition(historyType as String, item as Dynamic) as Integer
    if isHistoryObject(item) = false then return 0
    keyPrefix = "movie:"
    keyId = historyContentId(item, "stream_id")
    if historyType = "episode" then
        keyPrefix = "episode:"
        keyId = historyContentId(item, "id")
    end if
    key = keyPrefix + keyId
    if keyId = "" then return 0

    buckets = [GetMovieHistory(), GetSeriesHistory()]
    for each bucket in buckets
        if Type(bucket) = "roArray" then
            for each entry in bucket
                if isHistoryObject(entry) then
                    if historyText(entry, "key") = key then return historyInt(entry.position)
                end if
            end for
        end if
    end for
    return 0
end function

function loadHistoryBucket(name as String) as Object
    section = CreateObject("roRegistrySection", "PXTPlayerHistory")
    json = section.Read(name)

    ' Backward-compatible migration from the previous combined key.
    if json <> invalid then
        if Type(json) = "String" then
            if json.Trim() <> "" then
                data = ParseJson(json)
                return limitHistory(data, 5)
            end if
        end if
    end if

    legacy = section.Read("items")
    if legacy <> invalid then
        if Type(legacy) = "String" then
            if legacy.Trim() <> "" then
                legacyData = ParseJson(legacy)
                if isHistoryObject(legacyData) then
                    if legacyData.DoesExist(name) then return limitHistory(legacyData[name], 5)
                end if
            end if
        end if
    end if
    return []
end function

sub saveHistoryBucket(name as String, history as Object)
    section = CreateObject("roRegistrySection", "PXTPlayerHistory")
    section.Write(name, FormatJson(limitHistory(history, 5)))
    section.Flush()
end sub

function upsertLimitedHistoryItem(history as Dynamic, item as Dynamic, maxItems as Integer) as Object
    result = []
    if isHistoryObject(item) = false then return limitHistory(history, maxItems)
    itemKey = historyText(item, "key")
    if itemKey = "" then return limitHistory(history, maxItems)

    result.Push(item)
    copied = 1
    if Type(history) = "roArray" then
        for each existing in history
            if copied >= maxItems then exit for
            if isHistoryObject(existing) then
                if historyText(existing, "key") <> itemKey then
                    result.Push(existing)
                    copied = copied + 1
                end if
            end if
        end for
    end if
    return result
end function

function limitHistory(items as Dynamic, maxItems as Integer) as Object
    limited = []
    copied = 0
    if Type(items) <> "roArray" then return limited
    for each item in items
        if copied >= maxItems then exit for
        if item <> invalid then
            limited.Push(item)
            copied = copied + 1
        end if
    end for
    return limited
end function

function minimalMovieContent(movie as Dynamic) as Object
    return { stream_id: historyContentId(movie, "stream_id"), name: historyTitle(movie, ""), title: historyTitle(movie, ""), stream_icon: historyPoster(movie), cover: historyPoster(movie), url: historyUrl(movie), streamUrl: historyUrl(movie), category_id: historyCategoryId(movie) }
end function

function minimalSeriesContent(series as Dynamic) as Object
    return { series_id: historyContentId(series, "series_id"), name: historyTitle(series, ""), title: historyTitle(series, ""), series_image: historyPoster(series), cover: historyPoster(series), category_id: historyCategoryId(series) }
end function

function minimalSeasonContent(season as Dynamic) as Object
    return { season_number: historySeasonNumber(season), number: historySeasonNumber(season) }
end function

function minimalEpisodeContent(episode as Dynamic) as Object
    return { id: historyContentId(episode, "id"), episode_id: historyContentId(episode, "id"), title: historyTitle(episode, ""), name: historyTitle(episode, ""), streamUrl: historyUrl(episode), url: historyUrl(episode), episode_num: historyEpisodeNumber(episode) }
end function

function isHistoryObject(item as Dynamic) as Boolean
    if item = invalid then return false
    return Type(item) = "roAssociativeArray"
end function

function historyText(item as Dynamic, field as String) as String
    if isHistoryObject(item) = false then return ""
    if item.DoesExist(field) = false then return ""
    if item[field] = invalid then return ""
    return item[field].ToStr()
end function

function historyContentId(item as Dynamic, primaryField as String) as String
    if isHistoryObject(item) = false then return ""
    if primaryField <> "" then
        if item.DoesExist(primaryField) then
            if item[primaryField] <> invalid then return item[primaryField].ToStr()
        end if
    end if
    for each field in ["episode_id", "stream_id", "id", "series_id"]
        if item.DoesExist(field) then
            if item[field] <> invalid then return item[field].ToStr()
        end if
    end for
    url = historyUrl(item)
    if url <> "" then return url
    return historyTitle(item, "")
end function

function historyTitle(item as Dynamic, fallback as String) as String
    title = historyText(item, "name").Trim()
    if title <> "" then return title
    title = historyText(item, "title").Trim()
    if title <> "" then return title
    return fallback
end function

function historyUrl(item as Dynamic) as String
    for each field in ["streamUrl", "url", "direct_source"]
        value = historyText(item, field).Trim()
        if value <> "" then return value
    end for
    return ""
end function

function historyPoster(item as Dynamic) as String
    for each field in ["stream_icon", "cover", "movie_image", "series_image", "poster", "cover_big"]
        value = historyText(item, field).Trim()
        if value <> "" then return value
    end for
    return ""
end function

function historyCategoryId(item as Dynamic) as String
    return historyText(item, "category_id")
end function

function historySeasonNumber(season as Dynamic) as String
    value = historyText(season, "season_number")
    if value <> "" then return value
    return historyText(season, "number")
end function

function historyEpisodeNumber(episode as Dynamic) as String
    value = historyText(episode, "episode_num")
    if value <> "" then return value
    return historyText(episode, "episode_number")
end function

function historyInt(value as Dynamic) as Integer
    if value = invalid then return 0
    text = value.ToStr()
    if text = "" then return 0
    number = Int(Val(text))
    if number < 0 then return 0
    return number
end function

function historyNowIso() as String
    dt = CreateObject("roDateTime")
    dt.Mark()
    return dt.ToISOString()
end function
