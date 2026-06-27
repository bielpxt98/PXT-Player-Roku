' Local favorites storage for PXT Player.
function LoadFavorites() as Object
    section = CreateObject("roRegistrySection", "PXTPlayerFavorites")
    json = section.Read("items")
    if json <> invalid and json.Trim() <> "" then
        data = ParseJson(json)
        if data <> invalid and Type(data) = "roAssociativeArray" then return normalizeFavoritesData(data)
    end if
    return createEmptyFavoritesData()
end function

sub SaveFavorites(favorites as Object)
    section = CreateObject("roRegistrySection", "PXTPlayerFavorites")
    section.Write("items", FormatJson(normalizeFavoritesData(favorites)))
    section.Flush()
end sub

function ToggleFavorite(favoriteType as String, item as Dynamic) as Boolean
    favorites = LoadFavorites()
    key = GetFavoriteKey(favoriteType, item)
    if key = "" then return false

    bucket = getFavoritesBucket(favorites, favoriteType)
    for i = 0 to bucket.Count() - 1
        if bucket[i].key <> invalid and bucket[i].key.ToStr() = key then
            bucket.Delete(i)
            SaveFavorites(favorites)
            return false
        end if
    end for

    bucket.Push(CreateFavoriteItem(favoriteType, item))
    SaveFavorites(favorites)
    return true
end function

function CreateFavoriteItem(favoriteType as String, item as Dynamic) as Object
    return {
        type: favoriteType,
        key: GetFavoriteKey(favoriteType, item),
        title: GetFavoriteTitle(favoriteType, item),
        content: item
    }
end function

function GetFavoriteKey(favoriteType as String, item as Dynamic) as String
    if item = invalid then return ""
    itemId = ""
    if favoriteType = "live" or favoriteType = "movie" then
        if item.stream_id <> invalid then itemId = item.stream_id.ToStr()
        if itemId = "" and item.id <> invalid then itemId = item.id.ToStr()
    else if favoriteType = "series" then
        if item.series_id <> invalid then itemId = item.series_id.ToStr()
        if itemId = "" and item.id <> invalid then itemId = item.id.ToStr()
    else if favoriteType = "episode" then
        if item.id <> invalid then itemId = item.id.ToStr()
        if itemId = "" and item.episode_id <> invalid then itemId = item.episode_id.ToStr()
        if itemId = "" and item.stream_id <> invalid then itemId = item.stream_id.ToStr()
    end if
    if itemId = "" then itemId = GetFavoriteTitle(favoriteType, item)
    if itemId = "" then return ""
    return favoriteType + ":" + itemId
end function

function GetFavoriteTitle(favoriteType as String, item as Dynamic) as String
    if item = invalid then return "Favorito"
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    if item.episode_num <> invalid and item.episode_num.ToStr().Trim() <> "" then return "Episódio " + item.episode_num.ToStr()
    if favoriteType = "live" then return "Canal favorito"
    if favoriteType = "movie" then return "Filme favorito"
    if favoriteType = "episode" then return "Episódio favorito"
    return "Série favorita"
end function

function createEmptyFavoritesData() as Object
    return { live: [], movies: [], series: [] }
end function

function normalizeFavoritesData(data as Dynamic) as Object
    normalized = createEmptyFavoritesData()
    if data = invalid or Type(data) <> "roAssociativeArray" then return normalized
    if data.live <> invalid and Type(data.live) = "roArray" then normalized.live = data.live
    if data.movies <> invalid and Type(data.movies) = "roArray" then normalized.movies = data.movies
    if data.series <> invalid and Type(data.series) = "roArray" then normalized.series = data.series
    return normalized
end function

function getFavoritesBucket(favorites as Object, favoriteType as String) as Object
    if favoriteType = "live" then return favorites.live
    if favoriteType = "movie" then return favorites.movies
    return favorites.series
end function
