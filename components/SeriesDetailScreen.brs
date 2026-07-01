sub Init()
    m.background = m.top.FindNode("background")
    m.poster = m.top.FindNode("poster")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.ratingLabel = m.top.FindNode("ratingLabel")
    m.genreLabel = m.top.FindNode("genreLabel")
    m.synopsisLabel = m.top.FindNode("synopsisLabel")
    m.buttonBg = m.top.FindNode("buttonBg")
    m.seasonsButton = m.top.FindNode("seasonsButton")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.hintLabel = m.top.FindNode("hintLabel")
    m.item = invalid
    configureLayout()
end sub

sub configureLayout()
    size = CreateObject("roDeviceInfo").GetDisplaySize()
    w = size.w : h = size.h
    margin = 92 : posterW = 260 : posterH = 390 : topY = 90
    if h <= 720 then margin = 56 : posterW = 190 : posterH = 285 : topY = 56
    m.background.width = w : m.background.height = h
    m.poster.translation = [margin, topY] : m.poster.width = posterW : m.poster.height = posterH
    contentX = margin + posterW + 70 : contentW = w - contentX - margin
    m.titleLabel.translation = [contentX, topY + 8] : m.titleLabel.width = contentW : m.titleLabel.height = 86 : m.titleLabel.font = "font:LargeBoldSystemFont"
    m.ratingLabel.translation = [contentX, topY + 108] : m.ratingLabel.width = contentW : m.ratingLabel.height = 36 : m.ratingLabel.font = "font:MediumBoldSystemFont"
    m.genreLabel.translation = [contentX, topY + 154] : m.genreLabel.width = contentW : m.genreLabel.height = 42 : m.genreLabel.font = "font:MediumSystemFont"
    m.synopsisLabel.translation = [contentX, topY + 214] : m.synopsisLabel.width = contentW : m.synopsisLabel.height = 132 : m.synopsisLabel.font = "font:MediumSystemFont"
    btnW = 310 : btnH = 58 : btnX = Int((w - btnW) / 2) : btnY = h - 150
    m.buttonBg.translation = [btnX, btnY] : m.buttonBg.width = btnW : m.buttonBg.height = btnH
    m.seasonsButton.translation = [btnX, btnY] : m.seasonsButton.width = btnW : m.seasonsButton.height = btnH : m.seasonsButton.font = "font:MediumBoldSystemFont"
    m.statusLabel.translation = [margin, btnY - 46] : m.statusLabel.width = w - margin * 2 : m.statusLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, h - 36] : m.hintLabel.width = w : m.hintLabel.font = "font:SmallSystemFont"
end sub

sub show(item as Dynamic)
    m.item = item
    configureLayout()
    populate(item)
    m.buttonBg.color = "#0B3A5E" : m.seasonsButton.color = "#FFFFFF"
    m.statusLabel.text = ""
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub setLoading(isLoading as Boolean)
    if isLoading then
        m.statusLabel.text = "Carregando temporadas em segundo plano..."
    else
        m.statusLabel.text = ""
    end if
end sub

sub setDetails(details as Dynamic)
    if details <> invalid then
        m.item = mergeItem(m.item, details)
        populate(m.item)
    end if
    setLoading(false)
end sub

sub populate(item as Dynamic)
    m.titleLabel.text = firstText(item, ["name", "title"])
    m.poster.uri = firstText(item, ["cover", "movie_image", "stream_icon", "cover_big", "poster"])
    m.ratingLabel.text = ratingText(firstText(item, ["rating", "rating_5based"]))
    m.genreLabel.text = firstText(item, ["genre", "category_name", "category"])
    m.synopsisLabel.text = shortenText(firstText(item, ["plot", "description", "overview"]), 240)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    normalizedKey = normalizeKey(key)
    if normalizedKey = "back" or normalizedKey = "left" then m.top.backRequested = true : return true
    if normalizedKey = "OK" or normalizedKey = "right" then m.top.playRequested = true : return true
    if normalizedKey = "options" then
        if m.item <> invalid then m.top.favoriteToggled = m.item
        return true
    end if
    return false
end function

function mergeItem(base as Dynamic, details as Dynamic) as Object
    result = {}
    if base <> invalid and Type(base) = "roAssociativeArray" then
        for each k in base
            result[k] = base[k]
        end for
    end if
    info = details
    if details <> invalid and Type(details) = "roAssociativeArray" and details.DoesExist("info") and Type(details.info) = "roAssociativeArray" then
        info = details.info
    end if
    if info <> invalid and Type(info) = "roAssociativeArray" then
        for each k in info
            result[k] = info[k]
        end for
    end if
    return result
end function

function firstText(item as Dynamic, keys as Object) as String
    if item = invalid or Type(item) <> "roAssociativeArray" then return ""
    for each k in keys
        if item.DoesExist(k) and item[k] <> invalid and item[k].ToStr().Trim() <> "" then return item[k].ToStr()
    end for
    return ""
end function

function ratingText(value as String) as String
    if value = "" then return "★★★★★"
    return "★★★★★  " + value
end function

function shortenText(text as String, maxLen as Integer) as String
    text = text.Trim()
    if Len(text) <= maxLen then return text
    return Left(text, maxLen - 3) + "..."
end function
