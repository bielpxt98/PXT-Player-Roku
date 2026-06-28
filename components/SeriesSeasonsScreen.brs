' Simple, safe seasons screen.
' Keep this screen intentionally small while the richer Series flow is repaired.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.seasonsGroup = m.top.FindNode("seasonsGroup")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.seasons = []
    m.itemNodes = []
    m.selectedIndex = 0
    m.firstVisibleIndex = 0

    configureLayout()
end sub

sub configureLayout()
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()
    width = displaySize.w
    height = displaySize.h

    m.margin = 80
    m.cardWidth = 150
    m.cardHeight = 76
    m.gap = 28
    if height <= 720 then
        m.margin = 48
        m.cardWidth = 128
        m.cardHeight = 62
        m.gap = 20
    end if

    m.contentWidth = width - (m.margin * 2)
    m.columns = Int((m.contentWidth + m.gap) / (m.cardWidth + m.gap))
    if m.columns < 1 then m.columns = 1
    m.rows = 3
    m.visibleItemCount = m.columns * m.rows

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.translation = [0, 76]
    m.title.font = "font:LargeBoldSystemFont"
    m.title.text = "TEMPORADAS"

    m.subtitle.width = width
    m.subtitle.translation = [0, 132]
    m.subtitle.font = "font:MediumSystemFont"

    m.seasonsGroup.translation = [m.margin, 220]

    if height <= 720 then
        m.title.translation = [0, 44]
        m.subtitle.translation = [0, 92]
        m.seasonsGroup.translation = [m.margin, 166]
    end if

    m.statusLabel.width = m.contentWidth
    m.statusLabel.translation = [m.margin, m.seasonsGroup.translation[1] + 110]
    m.statusLabel.font = "font:MediumSystemFont"

    m.hintLabel.width = width
    m.hintLabel.translation = [0, height - 36]
    m.hintLabel.font = "font:SmallSystemFont"
end sub

sub show(series as Dynamic)
    configureLayout()
    m.subtitle.text = getSeriesName(series)
    resetSelection()
    renderList()
    updateFocus()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub resetSelection()
    m.selectedIndex = 0
    m.firstVisibleIndex = 0
end sub

sub setLoading(isLoading as Boolean)
    clearSeasonNodes()
    if isLoading then
        m.statusLabel.color = "#B8C3D6"
        m.statusLabel.text = "Carregando temporadas..."
    else
        m.statusLabel.text = ""
    end if
end sub

sub setSeasons(seasons as Object)
    if seasons <> invalid and Type(seasons) = "roArray" then
        m.seasons = seasons
    else
        m.seasons = []
    end if

    resetSelection()

    if m.seasons.Count() = 0 then
        showMessage("Temporadas indisponíveis.")
        return
    end if

    m.statusLabel.text = ""
    renderList()
    updateFocus()
end sub

sub showMessage(message as String)
    clearSeasonNodes()
    m.seasons = []
    m.statusLabel.color = "#FFCC66"
    m.statusLabel.text = message
end sub

sub renderList()
    clearSeasonNodes()
    if m.seasons.Count() = 0 then return

    lastIndex = m.firstVisibleIndex + m.visibleItemCount - 1
    if lastIndex >= m.seasons.Count() then lastIndex = m.seasons.Count() - 1

    for index = m.firstVisibleIndex to lastIndex
        visualIndex = index - m.firstVisibleIndex
        column = visualIndex mod m.columns
        row = Int(visualIndex / m.columns)

        item = CreateObject("roSGNode", "Group")
        item.translation = [column * (m.cardWidth + m.gap), row * (m.cardHeight + m.gap)]

        background = CreateObject("roSGNode", "Rectangle")
        background.id = "itemBackground"
        background.width = m.cardWidth
        background.height = m.cardHeight
        background.color = "#111827"
        background.opacity = 0.95

        label = CreateObject("roSGNode", "Label")
        label.id = "itemLabel"
        label.width = m.cardWidth
        label.height = m.cardHeight
        label.horizAlign = "center"
        label.vertAlign = "center"
        label.font = "font:MediumBoldSystemFont"
        label.color = "#FFFFFF"
        label.text = getSeasonNumberText(m.seasons[index])

        item.AppendChild(background)
        item.AppendChild(label)
        m.seasonsGroup.AppendChild(item)
        m.itemNodes.Push(item)
    end for
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back" or key = "left" then
        m.top.backRequested = true
        return true
    else if key = "right" then
        moveFocus(1)
        return true
    else if key = "up" then
        moveFocus(0 - m.columns)
        return true
    else if key = "down" then
        moveFocus(m.columns)
        return true
    else if key = "OK" then
        if m.seasons.Count() > 0 and m.selectedIndex >= 0 and m.selectedIndex < m.seasons.Count() then
            m.top.seasonSelected = m.seasons[m.selectedIndex]
        end if
        return true
    end if

    return false
end function

sub moveFocus(delta as Integer)
    if m.seasons.Count() = 0 then return

    previousFirstVisibleIndex = m.firstVisibleIndex
    m.selectedIndex = m.selectedIndex + delta

    if m.selectedIndex < 0 then m.selectedIndex = 0
    if m.selectedIndex >= m.seasons.Count() then m.selectedIndex = m.seasons.Count() - 1

    if m.selectedIndex < m.firstVisibleIndex then
        m.firstVisibleIndex = m.selectedIndex
    else if m.selectedIndex >= m.firstVisibleIndex + m.visibleItemCount then
        m.firstVisibleIndex = m.selectedIndex - m.visibleItemCount + 1
    end if

    if previousFirstVisibleIndex <> m.firstVisibleIndex then renderList()
    updateFocus()
end sub

sub updateFocus()
    for index = 0 to m.itemNodes.Count() - 1
        realIndex = m.firstVisibleIndex + index
        background = m.itemNodes[index].FindNode("itemBackground")

        if realIndex = m.selectedIndex then
            background.color = "#0B3A5E"
            m.itemNodes[index].scale = [1.08, 1.08]
        else
            background.color = "#111827"
            m.itemNodes[index].scale = [1.0, 1.0]
        end if
    end for
end sub

sub clearSeasonNodes()
    while m.seasonsGroup.GetChildCount() > 0
        m.seasonsGroup.RemoveChildIndex(0)
    end while
    m.itemNodes = []
end sub

function getSeasonNumberText(season as Dynamic) as String
    if season <> invalid and Type(season) = "roAssociativeArray" then
        if season.DoesExist("season_number") and season.season_number <> invalid and season.season_number.ToStr().Trim() <> "" then
            return "Temporada " + season.season_number.ToStr()
        end if
        if season.DoesExist("name") and season.name <> invalid and season.name.ToStr().Trim() <> "" then
            return season.name.ToStr()
        end if
    end if

    return "Temporada"
end function

function getSeriesName(series as Dynamic) as String
    if series <> invalid and Type(series) = "roAssociativeArray" then
        if series.DoesExist("name") and series.name <> invalid and series.name.ToStr().Trim() <> "" then
            return series.name.ToStr()
        end if
        if series.DoesExist("title") and series.title <> invalid and series.title.ToStr().Trim() <> "" then
            return series.title.ToStr()
        end if
    end if

    return "Série"
end function
