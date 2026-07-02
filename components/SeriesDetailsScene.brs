sub Init()
    m.background = m.top.FindNode("background")
    m.poster = m.top.FindNode("poster")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.metaLabel = m.top.FindNode("metaLabel")
    m.synopsisTitle = m.top.FindNode("synopsisTitle")
    m.synopsisLabel = m.top.FindNode("synopsisLabel")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.buttonsGroup = m.top.FindNode("buttonsGroup")
    m.seasonsButton = m.top.FindNode("seasonsButton")
    m.backButton = m.top.FindNode("backButton")
    m.selectedButton = 0
    m.item = invalid
    configureLayout()
end sub

sub configureLayout()
    deviceInfo = CreateObject("roDeviceInfo")
    size = deviceInfo.GetDisplaySize()
    w = size.w
    h = size.h
    m.background.width = w
    m.background.height = h
    marginX = 80
    topY = 70
    posterW = 300
    posterH = 450
    if h <= 720 then
        marginX = 50
        topY = 40
        posterW = 210
        posterH = 315
    end if
    m.poster.translation = [marginX, topY]
    m.poster.width = posterW
    m.poster.height = posterH
    contentX = marginX + posterW + 55
    contentW = w - contentX - marginX
    m.titleLabel.translation = [contentX, topY + 5]
    m.titleLabel.width = contentW
    m.titleLabel.font = "font:LargeBoldSystemFont"
    m.metaLabel.translation = [contentX, topY + 85]
    m.metaLabel.width = contentW
    m.metaLabel.font = "font:MediumSystemFont"
    m.synopsisTitle.translation = [contentX, topY + 155]
    m.synopsisTitle.width = contentW
    m.synopsisTitle.font = "font:MediumBoldSystemFont"
    m.synopsisLabel.translation = [contentX, topY + 195]
    m.synopsisLabel.width = contentW
    m.synopsisLabel.height = 260
    m.synopsisLabel.font = "font:MediumSystemFont"
    m.loadingLabel.translation = [contentX, topY + 500]
    m.loadingLabel.width = contentW
    m.loadingLabel.font = "font:MediumSystemFont"
    m.buttonsGroup.translation = [marginX, h - 105]
    setupButton(m.seasonsButton, 0, 220)
    setupButton(m.backButton, 250, 170)
end sub

sub setupButton(button as Object, x as Integer, width as Integer)
    button.translation = [x, 0]
    button.width = width
    button.height = 54
    button.font = "font:MediumBoldSystemFont"
end sub

sub show(item as Dynamic)
    m.item = item
    m.selectedButton = 0
    configureLayout()
    populate(item)
    setLoading(false)
    updateButtons()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub setLoading(isLoading as Boolean)
    if isLoading then m.loadingLabel.text = "Carregando detalhes..."
    m.loadingLabel.visible = isLoading
end sub

sub showMessage(message as String)
    m.loadingLabel.text = message
    m.loadingLabel.visible = message <> ""
end sub

sub setDetails(details as Dynamic)
    if details <> invalid then populate(mergeItem(m.item, details))
    setLoading(false)
end sub

sub populate(item as Dynamic)
    title = firstText(item, ["name", "title"])
    year = getYear(firstText(item, ["releasedate", "releaseDate", "year"] ))
    if year <> "" then title = title + " (" + year + ")"
    m.titleLabel.text = title
    image = firstText(item, ["cover", "series_image", "stream_icon", "cover_big", "backdrop_path"])
    m.poster.uri = image
    meta = joinText([firstText(item, ["genre"]), firstText(item, ["year", "releaseDate", "releasedate"])], " • ")
    m.metaLabel.text = meta
    m.metaLabel.visible = meta <> ""
    desc = firstText(item, ["description", "plot", "overview", "synopsis"])
    if desc = "" then desc = "Informações disponíveis no catálogo."
    m.synopsisLabel.text = desc
    m.synopsisTitle.visible = true
    m.synopsisLabel.visible = true
end sub

function mergeItem(base as Dynamic, details as Dynamic) as Object
    merged = {}
    if base <> invalid and Type(base) = "roAssociativeArray" then
        for each k in base
            merged[k] = base[k]
        end for
    end if
    info = details
    if details <> invalid and Type(details) = "roAssociativeArray" and details.info <> invalid then info = details.info
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
        if item.DoesExist(k) and item[k] <> invalid and item[k].ToStr().Trim() <> "" then return item[k].ToStr().Trim()
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

function getYear(value as String) as String
    if Len(value) >= 4 then return Left(value, 4)
    return value
end function

function durationText(value as String) as String
    if value = "" then return ""
    if Instr(1, value, ":") > 0 then return value
    return value
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

sub updateButtons()
    buttons = [m.seasonsButton, m.backButton]
    for i = 0 to buttons.Count() - 1
        buttons[i].color = "#FFFFFF"
        if i = m.selectedButton then buttons[i].color = "#5CE08A"
    end for
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "left" then
        if m.selectedButton > 0 then
            m.selectedButton = m.selectedButton - 1
            updateButtons()
        end if
        return true
    else if key = "right" then
        if m.selectedButton < 1 then
            m.selectedButton = m.selectedButton + 1
            updateButtons()
        end if
        return true
    else if key = "OK" then
        if m.selectedButton = 0 then
            showMessage("Episódios serão carregados ao reproduzir uma temporada.")
        else
            m.top.backRequested = true
        end if
        return true
    else if key = "back" then
        m.top.backRequested = true
        return true
    end if
    return false
end function
