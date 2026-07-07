' Lightweight local search index storage for movies and series.
function LoadSearchIndexCache(account as Dynamic) as Object
    section = CreateObject("roRegistrySection", "PXTPlayerSearchIndex")
    key = buildUserSearchIndexCacheKey(account)
    json = readChunkedRegistryValue(section, key)
    if json = invalid or json.Trim() = "" then json = readChunkedRegistryValue(section, "cache_v4")
    if json = invalid or json.Trim() = "" then json = section.Read("cache_v2")
    if json <> invalid and json.Trim() <> "" then
        trimmed = json.Trim()
        if Left(trimmed, 1) = "{" and Right(trimmed, 1) = "}" then
            data = ParseJson(trimmed)
            if data <> invalid and Type(data) = "roAssociativeArray" then return normalizeSearchIndexCache(data)
        end if
    end if
    return createEmptySearchIndexCache()
end function

sub SaveSearchIndexCache(cache as Object, account as Dynamic)
    ' Disabled heavy registry writes. Saving the search/catalog cache here can
    ' serialize tens of thousands of items and freeze the Roku render thread
    ' with runtime error &h23. The backend now owns the big search catalog;
    ' the Roku keeps only in-memory results during the current session.
    ' skip heavy cache save silently
end sub

sub DeleteSearchIndexCache(account as Dynamic)
    section = CreateObject("roRegistrySection", "PXTPlayerSearchIndex")
    key = buildUserSearchIndexCacheKey(account)
    deleteChunkedRegistryValue(section, key)
    deleteChunkedRegistryValue(section, "cache_v4")
    if section.Exists("cache_v2") then section.Delete("cache_v2")
    section.Flush()
end sub

function limitSearchIndexCacheForRegistry(cache as Object) as Object
    cache.movieCategories = limitRegistryArray(cache.movieCategories, 200)
    cache.seriesCategories = limitRegistryArray(cache.seriesCategories, 200)
    cache.movies = compactCatalogItems(cache.movies, 120, "movies")
    cache.series = compactCatalogItems(cache.series, 120, "series")
    cache.lastMovieSearchResults = compactCatalogItems(cache.lastMovieSearchResults, 120, "movies")
    cache.lastSeriesSearchResults = compactCatalogItems(cache.lastSeriesSearchResults, 120, "series")
    cache.lastWatchedMovies = compactCatalogItems(cache.lastWatchedMovies, 80, "movies")
    cache.movieCategoryPreviewCache = compactPreviewCache(cache.movieCategoryPreviewCache, "movies")
    cache.seriesCategoryPreviewCache = compactPreviewCache(cache.seriesCategoryPreviewCache, "series")
    cache.movieSearchIndex = []
    cache.seriesSearchIndex = []
    return cache
end function

function limitRegistryArray(items as Dynamic, maxItems as Integer) as Object
    result = []
    if items = invalid or Type(items) <> "roArray" then return result
    for each item in items
        if result.Count() >= maxItems then exit for
        result.Push(item)
    end for
    return result
end function

function mergeSearchIndexCacheForSave(existing as Dynamic, fresh as Object) as Object
    if existing = invalid or Type(existing) <> "roAssociativeArray" then return fresh
    if fresh.movieCategories.Count() = 0 and existing.movieCategories.Count() > 0 then fresh.movieCategories = existing.movieCategories
    if fresh.seriesCategories.Count() = 0 and existing.seriesCategories.Count() > 0 then fresh.seriesCategories = existing.seriesCategories
    if fresh.movies.Count() = 0 and existing.movies.Count() > 0 then fresh.movies = existing.movies
    if fresh.series.Count() = 0 and existing.series.Count() > 0 then fresh.series = existing.series
    if fresh.movieCategoryPreviewCache.Count() = 0 and existing.movieCategoryPreviewCache.Count() > 0 then fresh.movieCategoryPreviewCache = existing.movieCategoryPreviewCache
    if fresh.seriesCategoryPreviewCache.Count() = 0 and existing.seriesCategoryPreviewCache.Count() > 0 then fresh.seriesCategoryPreviewCache = existing.seriesCategoryPreviewCache
    if fresh.lastMovieSearchResults.Count() = 0 and existing.lastMovieSearchResults.Count() > 0 then fresh.lastMovieSearchResults = existing.lastMovieSearchResults
    if fresh.lastSeriesSearchResults.Count() = 0 and existing.lastSeriesSearchResults.Count() > 0 then fresh.lastSeriesSearchResults = existing.lastSeriesSearchResults
    if fresh.lastWatchedMovies.Count() = 0 and existing.lastWatchedMovies.Count() > 0 then fresh.lastWatchedMovies = existing.lastWatchedMovies
    return fresh
end function

function readChunkedRegistryValue(section as Object, prefix as String) as Dynamic
    chunksKey = prefix + "_chunks"
    if section.Exists(chunksKey) then
        countText = section.Read(chunksKey)
        count = countText.ToInt()
        payload = ""
        for i = 0 to count - 1
            partKey = prefix + "_" + i.ToStr()
            if section.Exists(partKey) then payload = payload + section.Read(partKey)
        end for
        return payload
    end if
    if section.Exists(prefix) then return section.Read(prefix)
    return invalid
end function

sub writeChunkedRegistryValue(section as Object, prefix as String, payload as String)
    deleteChunkedRegistryValue(section, prefix)
    ' Bigger chunks = fewer registry Write() calls for the same payload,
    ' which cuts down the odds of tripping the runtime execution timeout
    ' (&h23) when a large cache is saved.
    maxChars = 6000
    cursor = 1
    chunkCount = 0
    while cursor <= Len(payload)
        section.Write(prefix + "_" + chunkCount.ToStr(), Mid(payload, cursor, maxChars))
        cursor = cursor + maxChars
        chunkCount = chunkCount + 1
    end while
    section.Write(prefix + "_chunks", chunkCount.ToStr())
end sub

sub deleteChunkedRegistryValue(section as Object, prefix as String)
    if section.Exists(prefix) then section.Delete(prefix)
    chunkCount = 0
    if section.Exists(prefix + "_chunks") then
        countText = section.Read(prefix + "_chunks")
        chunkCount = countText.ToInt()
        section.Delete(prefix + "_chunks")
    end if
    ' Clear at least the previous chunk count, plus some headroom in case an
    ' older build wrote more/smaller chunks under the same prefix.
    maxIndex = chunkCount + 50
    if maxIndex < 99 then maxIndex = 99
    for i = 0 to maxIndex
        key = prefix + "_" + i.ToStr()
        if section.Exists(key) then section.Delete(key)
    end for
end sub

function compactPreviewCache(cache as Dynamic, kind as String) as Object
    result = []
    if cache = invalid or Type(cache) <> "roArray" then return result
    for each preview in cache
        if result.Count() >= 80 then exit for
        if preview <> invalid and preview.items <> invalid and Type(preview.items) = "roArray" then
            categoryId = ""
            categoryName = ""
            if preview.categoryId <> invalid then categoryId = preview.categoryId.ToStr()
            if preview.categoryName <> invalid then categoryName = preview.categoryName.ToStr()
            result.Push({ categoryId: categoryId, categoryName: categoryName, items: compactCatalogItems(preview.items, 10, kind) })
        end if
    end for
    return result
end function

function compactCatalogItems(items as Dynamic, maxItems as Integer, kind as String) as Object
    result = []
    if items = invalid or Type(items) <> "roArray" then return result
    for each item in items
        if result.Count() >= maxItems then exit for
        compact = compactCatalogItem(item, kind)
        if compact <> invalid then result.Push(compact)
    end for
    return result
end function

function compactCatalogItem(item as Dynamic, kind as String) as Dynamic
    if item = invalid or Type(item) <> "roAssociativeArray" then return invalid
    title = searchIndexTitle(item)
    if title = "" then return invalid
    id = searchIndexStreamId(kind, item)
    poster = searchIndexPoster(item)
    categoryId = searchIndexField(item, "category_id")
    if categoryId = "" then categoryId = searchIndexField(item, "categoryId")
    result = { id: id, title: title, name: title, category_id: categoryId, categoryId: categoryId, type: kind }
    if kind = "series" then
        result.series_id = id
        result.cover = poster
        result.series_image = poster
    else
        result.stream_id = id
        result.stream_icon = poster
    end if
    if poster <> "" then result.poster = poster
    year = searchIndexField(item, "year")
    if year <> "" then result.year = year
    rating = searchIndexField(item, "rating")
    if rating <> "" then result.rating = rating
    return result
end function

function createEmptySearchIndexCache() as Object
    return { liveCategories: [], liveChannels: [], movieCategories: [], movies: [], seriesCategories: [], series: [], seriesInfo: {}, movieSearchIndex: [], seriesSearchIndex: [], movieCategoryPreviewCache: [], seriesCategoryPreviewCache: [], lastMovieSearchResults: [], lastSeriesSearchResults: [], lastWatchedMovies: [], accountKey: "", updatedAt: "" }
end function

function normalizeSearchIndexCache(data as Dynamic) as Object
    normalized = createEmptySearchIndexCache()
    if data = invalid or Type(data) <> "roAssociativeArray" then return normalized
    if data.liveCategories <> invalid and Type(data.liveCategories) = "roArray" then normalized.liveCategories = data.liveCategories
    if data.liveChannels <> invalid and Type(data.liveChannels) = "roArray" then normalized.liveChannels = data.liveChannels
    if data.movieCategories <> invalid and Type(data.movieCategories) = "roArray" then normalized.movieCategories = data.movieCategories
    if data.movies <> invalid and Type(data.movies) = "roArray" then normalized.movies = data.movies
    if data.seriesCategories <> invalid and Type(data.seriesCategories) = "roArray" then normalized.seriesCategories = data.seriesCategories
    if data.series <> invalid and Type(data.series) = "roArray" then normalized.series = data.series
    if data.seriesInfo <> invalid and Type(data.seriesInfo) = "roAssociativeArray" then normalized.seriesInfo = data.seriesInfo
    if data.movieSearchIndex <> invalid and Type(data.movieSearchIndex) = "roArray" then normalized.movieSearchIndex = data.movieSearchIndex
    if data.seriesSearchIndex <> invalid and Type(data.seriesSearchIndex) = "roArray" then normalized.seriesSearchIndex = data.seriesSearchIndex
    if data.movieCategoryPreviewCache <> invalid and Type(data.movieCategoryPreviewCache) = "roArray" then normalized.movieCategoryPreviewCache = data.movieCategoryPreviewCache
    if data.seriesCategoryPreviewCache <> invalid and Type(data.seriesCategoryPreviewCache) = "roArray" then normalized.seriesCategoryPreviewCache = data.seriesCategoryPreviewCache
    if data.lastMovieSearchResults <> invalid and Type(data.lastMovieSearchResults) = "roArray" then normalized.lastMovieSearchResults = data.lastMovieSearchResults
    if data.lastSeriesSearchResults <> invalid and Type(data.lastSeriesSearchResults) = "roArray" then normalized.lastSeriesSearchResults = data.lastSeriesSearchResults
    if data.lastWatchedMovies <> invalid and Type(data.lastWatchedMovies) = "roArray" then normalized.lastWatchedMovies = data.lastWatchedMovies
    if data.accountKey <> invalid then normalized.accountKey = data.accountKey.ToStr()
    if data.updatedAt <> invalid then normalized.updatedAt = data.updatedAt.ToStr()
    return normalized
end function

function BuildMovieSearchIndexItems(items as Dynamic, categoryId as String) as Object
    ' Do not build a full search index on the render thread.
    ' Large Xtream lists can trigger runtime error &h23 (execution timeout).
    ' MovieSearchScreen receives the raw movie list and filters it itself.
    return []
end function

function BuildSeriesSearchIndexItems(items as Dynamic, categoryId as String) as Object
    ' Do not build a full search index on the render thread.
    ' SeriesSearchScreen receives the raw series list and filters it itself.
    return []
end function

function CreateSearchIndexItem(kind as String, item as Dynamic, categoryId as String) as Dynamic
    if item = invalid or Type(item) <> "roAssociativeArray" then return invalid
    title = searchIndexTitle(item)
    if title = "" then return invalid
    streamId = searchIndexStreamId(kind, item)
    return {
        id: streamId,
        title: title,
        normalizedTitle: LCase(title),
        poster: searchIndexPoster(item),
        categoryId: categoryId,
        streamId: streamId,
        year: searchIndexField(item, "year"),
        rating: searchIndexField(item, "rating")
    }
end function

function NormalizeSearchText(value as Dynamic) as String
    ' Fast path only. Accent normalization on the render thread caused &h23 timeouts
    ' on large movie/series lists. Search screens can still filter by lowercase text.
    if value = invalid then return ""
    return LCase(value.ToStr().Trim())
end function
function searchIndexTitle(item as Object) as String
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return ""
end function

function searchIndexStreamId(kind as String, item as Object) as String
    if kind = "series" and item.series_id <> invalid then return item.series_id.ToStr()
    if item.stream_id <> invalid then return item.stream_id.ToStr()
    if item.id <> invalid then return item.id.ToStr()
    return searchIndexTitle(item)
end function

function searchIndexPoster(item as Object) as String
    if item.stream_icon <> invalid and item.stream_icon.ToStr().Trim() <> "" then return item.stream_icon.ToStr()
    if item.cover <> invalid and item.cover.ToStr().Trim() <> "" then return item.cover.ToStr()
    if item.poster <> invalid and item.poster.ToStr().Trim() <> "" then return item.poster.ToStr()
    if item.series_image <> invalid and item.series_image.ToStr().Trim() <> "" then return item.series_image.ToStr()
    return ""
end function

function searchIndexField(item as Object, fieldName as String) as String
    if item.DoesExist(fieldName) and item[fieldName] <> invalid then return item[fieldName].ToStr()
    return ""
end function


function buildUserSearchIndexCacheKey(account as Dynamic) as String
    if account = invalid or Type(account) <> "roAssociativeArray" then return "cache_v2"
    dns = "" : username = ""
    if account.dns <> invalid then dns = account.dns.ToStr()
    if account.username <> invalid then username = account.username.ToStr()
    base = LCase(dns.Trim() + "|" + username.Trim())
    if base = "|" then return "cache_v2"
    return "user_cache_v3_" + safeRegistryKey(base)
end function

function safeRegistryKey(value as String) as String
    result = ""
    for i = 1 to Len(value)
        ch = Mid(value, i, 1)
        code = Asc(ch)
        if (code >= 48 and code <= 57) or (code >= 97 and code <= 122) then
            result = result + ch
        else
            result = result + "_" + code.ToStr() + "_"
        end if
    end for
    return result
end function

function isSearchIndexCacheEmpty(cache as Dynamic) as Boolean
    if cache = invalid or Type(cache) <> "roAssociativeArray" then return true
    fields = ["liveCategories", "liveChannels", "movieCategories", "movies", "seriesCategories", "series", "movieCategoryPreviewCache", "seriesCategoryPreviewCache", "lastMovieSearchResults", "lastSeriesSearchResults", "lastWatchedMovies"]
    for each field in fields
        if cache[field] <> invalid and Type(cache[field]) = "roArray" and cache[field].Count() > 0 then return false
    end for
    return true
end function
