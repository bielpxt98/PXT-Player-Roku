' Lightweight local search index storage for movies and series.
function LoadSearchIndexCache() as Object
    section = CreateObject("roRegistrySection", "PXTPlayerSearchIndex")
    json = section.Read("cache_v2")
    if json <> invalid and json.Trim() <> "" then
        trimmed = json.Trim()
        ' Avoid ParseJson runtime crash when an old registry write was truncated.
        if Left(trimmed, 1) = "{" and Right(trimmed, 1) = "}" then
            data = ParseJson(trimmed)
            if data <> invalid and Type(data) = "roAssociativeArray" then return normalizeSearchIndexCache(data)
        end if
    end if
    return createEmptySearchIndexCache()
end function

sub SaveSearchIndexCache(cache as Object)
    section = CreateObject("roRegistrySection", "PXTPlayerSearchIndex")
    section.Write("cache_v2", FormatJson(limitSearchIndexCacheForRegistry(normalizeSearchIndexCache(cache))))
    section.Flush()
end sub

function limitSearchIndexCacheForRegistry(cache as Object) as Object
    ' Registry is only for lightweight startup data. Keep a small global preview
    ' so Search opens instantly next time, but never persist 30k+ item catalogs.
    cache.movies = limitRegistryArray(cache.movies, 1000)
    cache.series = limitRegistryArray(cache.series, 1000)
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

function createEmptySearchIndexCache() as Object
    return { liveCategories: [], liveChannels: [], movieCategories: [], movies: [], seriesCategories: [], series: [], seriesInfo: {}, movieSearchIndex: [], seriesSearchIndex: [], movieCategoryPreviewCache: [], seriesCategoryPreviewCache: [], updatedAt: "" }
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
