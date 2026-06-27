' Global search screen for live channels, movies, and series.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.searchInput = m.top.FindNode("searchInput")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.resultsGroup = m.top.FindNode("resultsGroup")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.channels = []
    m.movies = []
    m.series = []
    m.results = []
    m.itemNodes = []
    m.selectedIndex = 0
    m.firstVisibleIndex = 0
    m.searchInput.ObserveField("text", "onSearchTextChanged")
    configureLayout()
end sub

sub configureLayout()
    size = CreateObject("roDeviceInfo").GetDisplaySize()
    width = size.w : height = size.h
    m.marginX = 72
    if height <= 720 then m.marginX = 48
    m.contentWidth = width - (m.marginX * 2)
    m.background.width = width : m.background.height = height
    m.title.width = width : m.title.font = "font:LargeBoldSystemFont" : m.title.translation = [0, 30]
    m.subtitle.width = width : m.subtitle.font = "font:MediumSystemFont" : m.subtitle.translation = [0, 84]
    m.searchInput.translation = [m.marginX, 128]
    m.searchInput.width = m.contentWidth
    m.searchInput.height = 54
    m.statusLabel.width = m.contentWidth : m.statusLabel.font = "font:MediumSystemFont" : m.statusLabel.translation = [m.marginX, 205]
    m.resultsGroup.translation = [m.marginX, 210]
    m.hintLabel.width = width : m.hintLabel.font = "font:SmallSystemFont" : m.hintLabel.translation = [0, height - 58]
    m.itemHeight = 52
    if height <= 720 then m.itemHeight = 44
    m.visibleItemCount = Int((height - 285) / m.itemHeight)
    if m.visibleItemCount < 4 then m.visibleItemCount = 4
end sub

sub show()
    configureLayout()
    m.top.visible = true
    m.top.SetFocus(true)
    m.searchInput.SetFocus(true)
    applyFilter()
end sub

sub hide()
    m.top.visible = false
end sub

sub setLoading(isLoading as Boolean)
    if isLoading then
        clearResultNodes()
        m.statusLabel.color = "#B8C3D6"
        m.statusLabel.text = "Carregando conteúdo para busca..."
    else
        m.statusLabel.text = ""
    end if
end sub

sub setData(data as Object)
    if data = invalid then return
    if data.channels <> invalid then m.channels = normalizeArray(data.channels)
    if data.movies <> invalid then m.movies = normalizeArray(data.movies)
    if data.series <> invalid then m.series = normalizeArray(data.series)
    applyFilter()
end sub

sub showMessage(message as String)
    clearResultNodes()
    m.statusLabel.color = "#FFCC66"
    m.statusLabel.text = message
end sub

sub onSearchTextChanged()
    applyFilter()
end sub

sub applyFilter()
    query = LCase(m.searchInput.text.Trim())
    m.results = []
    if query = "" then
        clearResultNodes()
        m.statusLabel.color = "#B8C3D6"
        m.statusLabel.text = "Digite um termo para buscar em TV ao vivo, filmes e séries."
        return
    end if
    addMatches("header", "Canais", invalid, query)
    addMatches("channel", "", m.channels, query)
    addMatches("header", "Filmes", invalid, query)
    addMatches("movie", "", m.movies, query)
    addMatches("header", "Séries", invalid, query)
    addMatches("series", "", m.series, query)
    removeEmptyHeaders()
    m.selectedIndex = firstSelectableIndex()
    m.firstVisibleIndex = 0
    if m.results.Count() = 0 then
        clearResultNodes()
        m.statusLabel.color = "#FFCC66"
        m.statusLabel.text = "Nenhum resultado encontrado."
    else
        m.statusLabel.text = ""
        renderResults()
        updateFocus()
    end if
end sub

sub addMatches(kind as String, label as String, items as Dynamic, query as String)
    if kind = "header" then
        m.results.Push({ type: kind, title: label })
        return
    end if
    for each item in normalizeArray(items)
        name = getItemName(item)
        if Instr(1, LCase(name), query) > 0 then m.results.Push({ type: kind, title: name, item: item })
    end for
end sub

sub removeEmptyHeaders()
    filtered = []
    for i = 0 to m.results.Count() - 1
        result = m.results[i]
        if result.type <> "header" then
            filtered.Push(result)
        else if i + 1 < m.results.Count() and m.results[i + 1].type <> "header" then
            filtered.Push(result)
        end if
    end for
    m.results = filtered
end sub

function firstSelectableIndex() as Integer
    for i = 0 to m.results.Count() - 1
        if m.results[i].type <> "header" then return i
    end for
    return 0
end function

sub renderResults()
    clearResultNodes()
    lastIndex = m.firstVisibleIndex + m.visibleItemCount - 1
    if lastIndex >= m.results.Count() then lastIndex = m.results.Count() - 1
    for visualIndex = 0 to lastIndex - m.firstVisibleIndex
        realIndex = m.firstVisibleIndex + visualIndex
        node = createResultNode(m.results[realIndex], visualIndex, realIndex)
        m.resultsGroup.AppendChild(node)
        m.itemNodes.Push(node)
    end for
end sub

function createResultNode(result as Object, visualIndex as Integer, realIndex as Integer) as Object
    group = CreateObject("roSGNode", "Group")
    group.translation = [0, visualIndex * m.itemHeight]
    bg = CreateObject("roSGNode", "Rectangle")
    bg.id = "itemBackground" : bg.width = m.contentWidth : bg.height = m.itemHeight - 6 : bg.color = "#111827" : bg.opacity = 0.86
    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel" : label.width = m.contentWidth - 32 : label.height = m.itemHeight - 6 : label.translation = [16, 0] : label.vertAlign = "center"
    if result.type = "header" then
        bg.opacity = 0.0 : label.color = "#5CE08A" : label.font = "font:MediumBoldSystemFont" : label.text = result.title
    else
        label.color = "#F8FAFC" : label.font = "font:MediumSystemFont" : label.text = result.title
    end if
    group.AppendChild(bg) : group.AppendChild(label)
    return group
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then
        m.top.backRequested = true
        return true
    else if key = "up" then
        moveSelection(-1)
        return true
    else if key = "down" then
        moveSelection(1)
        return true
    else if key = "OK" then
        openSelected()
        return true
    end if
    return false
end function

sub moveSelection(direction as Integer)
    if m.results.Count() = 0 then return
    nextIndex = m.selectedIndex
    for stepCount = 0 to m.results.Count() - 1
        nextIndex = nextIndex + direction
        if nextIndex < 0 then nextIndex = m.results.Count() - 1
        if nextIndex >= m.results.Count() then nextIndex = 0
        if m.results[nextIndex].type <> "header" then exit for
    end for
    m.selectedIndex = nextIndex
    updateVisibleWindow()
    renderResults()
    updateFocus()
end sub

sub openSelected()
    if m.results.Count() = 0 or m.selectedIndex < 0 or m.selectedIndex >= m.results.Count() then return
    result = m.results[m.selectedIndex]
    if result.type = "channel" then m.top.channelSelected = result.item
    if result.type = "movie" then m.top.movieSelected = result.item
    if result.type = "series" then m.top.seriesSelected = result.item
end sub

sub updateVisibleWindow()
    maxFirst = m.results.Count() - m.visibleItemCount
    if maxFirst < 0 then maxFirst = 0
    if m.selectedIndex < m.firstVisibleIndex then m.firstVisibleIndex = m.selectedIndex
    if m.selectedIndex >= m.firstVisibleIndex + m.visibleItemCount then m.firstVisibleIndex = m.selectedIndex - m.visibleItemCount + 1
    if m.firstVisibleIndex > maxFirst then m.firstVisibleIndex = maxFirst
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0
end sub

sub updateFocus()
    for i = 0 to m.itemNodes.Count() - 1
        realIndex = m.firstVisibleIndex + i
        bg = m.itemNodes[i].FindNode("itemBackground")
        label = m.itemNodes[i].FindNode("itemLabel")
        if realIndex = m.selectedIndex and m.results[realIndex].type <> "header" then
            bg.color = "#0B3A5E" : bg.opacity = 1.0 : label.color = "#FFFFFF"
        else if m.results[realIndex].type <> "header" then
            bg.color = "#111827" : bg.opacity = 0.86 : label.color = "#F8FAFC"
        end if
    end for
end sub

sub clearResultNodes()
    while m.resultsGroup.GetChildCount() > 0
        m.resultsGroup.RemoveChildIndex(0)
    end while
    m.itemNodes = []
end sub

function normalizeArray(value as Dynamic) as Object
    if value <> invalid and Type(value) = "roArray" then return value
    return []
end function

function getItemName(item as Dynamic) as String
    if item = invalid then return "Sem nome"
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return "Sem nome"
end function
