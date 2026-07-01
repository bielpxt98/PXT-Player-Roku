' Lightweight local search index storage for movies and series.
function LoadSearchIndexCache() as Object
    section = CreateObject("roRegistrySection", "PXTPlayerSearchIndex")
    json = section.Read("cache")
    if json <> invalid and json.Trim() <> "" then
        data = ParseJson(json)
        if data <> invalid and Type(data) = "roAssociativeArray" then return normalizeSearchIndexCache(data)
    end if
    return createEmptySearchIndexCache()
end function

sub SaveSearchIndexCache(cache as Object)
    section = CreateObject("roRegistrySection", "PXTPlayerSearchIndex")
    section.Write("cache", FormatJson(normalizeSearchIndexCache(cache)))
    section.Flush()
end sub

function createEmptySearchIndexCache() as Object
    return { movieCategories: [], seriesCategories: [], movieSearchIndex: [], seriesSearchIndex: [], updatedAt: "" }
end function

function normalizeSearchIndexCache(data as Dynamic) as Object
    normalized = createEmptySearchIndexCache()
    if data = invalid or Type(data) <> "roAssociativeArray" then return normalized
    if data.movieCategories <> invalid and Type(data.movieCategories) = "roArray" then normalized.movieCategories = data.movieCategories
    if data.seriesCategories <> invalid and Type(data.seriesCategories) = "roArray" then normalized.seriesCategories = data.seriesCategories
    if data.movieSearchIndex <> invalid and Type(data.movieSearchIndex) = "roArray" then normalized.movieSearchIndex = data.movieSearchIndex
    if data.seriesSearchIndex <> invalid and Type(data.seriesSearchIndex) = "roArray" then normalized.seriesSearchIndex = data.seriesSearchIndex
    if data.updatedAt <> invalid then normalized.updatedAt = data.updatedAt.ToStr()
    return normalized
end function

function BuildMovieSearchIndexItems(items as Dynamic, categoryId as String) as Object
    indexed = []
    if items = invalid or Type(items) <> "roArray" then return indexed
    for each item in items
        entry = CreateSearchIndexItem("movie", item, categoryId)
        if entry <> invalid then indexed.Push(entry)
    end for
    return indexed
end function

function BuildSeriesSearchIndexItems(items as Dynamic, categoryId as String) as Object
    indexed = []
    if items = invalid or Type(items) <> "roArray" then return indexed
    for each item in items
        entry = CreateSearchIndexItem("series", item, categoryId)
        if entry <> invalid then indexed.Push(entry)
    end for
    return indexed
end function

function CreateSearchIndexItem(kind as String, item as Dynamic, categoryId as String) as Dynamic
    if item = invalid or Type(item) <> "roAssociativeArray" then return invalid
    title = searchIndexTitle(item)
    if title = "" then return invalid
    streamId = searchIndexStreamId(kind, item)
    return {
        id: streamId,
        title: title,
        normalizedTitle: NormalizeSearchText(title),
        poster: searchIndexPoster(item),
        categoryId: categoryId,
        streamId: streamId,
        year: searchIndexField(item, "year"),
        rating: searchIndexField(item, "rating")
    }
end function

function NormalizeSearchText(value as Dynamic) as String
    text = LCase(value.ToStr().Trim())
    while Instr(1, text, "  ") > 0
        text = text.Replace("  ", " ")
    end while
    replacements = {
        "á":"a", "à":"a", "â":"a", "ã":"a", "ä":"a", "å":"a",
        "é":"e", "è":"e", "ê":"e", "ë":"e",
        "í":"i", "ì":"i", "î":"i", "ï":"i",
        "ó":"o", "ò":"o", "ô":"o", "õ":"o", "ö":"o",
        "ú":"u", "ù":"u", "û":"u", "ü":"u",
        "ç":"c", "ñ":"n", "ý":"y", "ÿ":"y",
        "-":" ", ".":" ", ",":" ", ":":" ", ";":" ", "_":" "
    }
    for each key in replacements
        text = text.Replace(key, replacements[key])
    end for
    while Instr(1, text, "  ") > 0
        text = text.Replace("  ", " ")
    end while
    return text.Trim()
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
