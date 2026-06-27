' Premium in-app search screen for section-scoped live channels, movies, and series.
sub Init()
    m.backgroundImage = m.top.FindNode("backgroundImage")
    m.overlay = m.top.FindNode("overlay")
    m.topGradient = m.top.FindNode("topGradient")
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.inputBackground = m.top.FindNode("inputBackground")
    m.searchInput = m.top.FindNode("searchInput")
    m.searchInput.ObserveField("text", "onSearchTextChanged")
    m.queryMirror = m.top.FindNode("queryMirror")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.searchDebounceTimer = m.top.FindNode("searchDebounceTimer")
    m.searchDebounceTimer.ObserveField("fire", "onSearchDebounceFire")
    m.keyboardGroup = m.top.FindNode("keyboardGroup")
    m.resultsTitle = m.top.FindNode("resultsTitle")
    m.resultsGroup = m.top.FindNode("resultsGroup")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.channels = [] : m.movies = [] : m.series = [] : m.results = []
    m.maxResults = 40
    m.searchMode = "live"
    m.keyRows = [ ["A","B","C","D","E","F","G","H","I","J"], ["K","L","M","N","O","P","Q","R","S","T"], ["U","V","W","X","Y","Z","0","1","2","3"], ["4","5","6","7","8","9","ESPAÇO","APAGAR","LIMPAR","BUSCAR"] ]
    m.keyNodes = [] : m.itemNodes = []
    m.focusZone = "keyboard" : m.selectedKeyRow = 0 : m.selectedKeyCol = 0 : m.selectedIndex = 0 : m.firstVisibleIndex = 0
    configureLayout()
end sub

sub configureLayout()
    size = CreateObject("roDeviceInfo").GetDisplaySize()
    m.screenW = size.w : m.screenH = size.h
    m.marginX = 72 : if m.screenH <= 720 then m.marginX = 48
    m.contentWidth = m.screenW - (m.marginX * 2)
    m.backgroundImage.width = m.screenW : m.backgroundImage.height = m.screenH
    m.overlay.width = m.screenW : m.overlay.height = m.screenH
    m.topGradient.width = m.screenW : m.topGradient.height = 170
    m.title.width = m.screenW : m.title.font = "font:LargeBoldSystemFont" : m.title.translation = [0, 28]
    m.subtitle.width = m.screenW : m.subtitle.font = "font:MediumSystemFont" : m.subtitle.translation = [0, 82]
    m.resultsTitle.translation = [m.marginX, 118] : m.resultsTitle.font = "font:MediumBoldSystemFont"
    m.resultsGroup.translation = [m.marginX, 158]
    m.keyboardTop = m.screenH - 260
    if m.screenH <= 720 then m.keyboardTop = m.screenH - 210
    m.inputBackground.translation = [m.marginX, m.keyboardTop - 58] : m.inputBackground.width = m.contentWidth : m.inputBackground.height = 46
    m.searchInput.translation = [m.marginX + 14, m.keyboardTop - 54] : m.searchInput.width = m.contentWidth - 28 : m.searchInput.height = 40 : m.searchInput.visible = false
    m.queryMirror.translation = [m.marginX + 20, m.keyboardTop - 49] : m.queryMirror.width = m.contentWidth - 40 : m.queryMirror.height = 34 : m.queryMirror.font = "font:MediumBoldSystemFont"
    m.statusLabel.translation = [m.marginX, m.keyboardTop - 104] : m.statusLabel.width = m.contentWidth : m.statusLabel.font = "font:MediumSystemFont"
    m.keyboardGroup.translation = [m.marginX, m.keyboardTop]
    m.hintLabel.width = m.screenW : m.hintLabel.font = "font:SmallSystemFont" : m.hintLabel.translation = [0, m.screenH - 34]
    m.keyGap = 8
    m.keyW = Int((m.contentWidth - 9 * m.keyGap) / 10) : m.keyH = 34
    m.cardWidth = 144 : m.cardHeight = 166 : m.cardGap = 16 : m.cardRowGap = 14
    if m.screenH <= 720 then m.cardWidth = 116 : m.cardHeight = 136 : m.cardGap = 12 : m.cardRowGap = 10 : m.keyH = 28 : m.keyGap = 6 : m.keyW = Int((m.contentWidth - 9 * m.keyGap) / 10)
    m.gridColumns = Int((m.contentWidth + m.cardGap) / (m.cardWidth + m.cardGap))
    if m.gridColumns < 1 then m.gridColumns = 1
    m.gridRows = 2
    m.visibleItemCount = m.gridColumns * m.gridRows
    if m.visibleItemCount > 40 then m.visibleItemCount = 40
end sub

sub show(mode as Dynamic)
    if mode = invalid or mode = "all" then mode = "live"
    m.searchMode = mode
    configureLayout()
    configureSearchLabels()
    m.top.visible = true : m.top.SetFocus(true)
    m.searchDebounceTimer.control = "stop"
    m.searchInput.text = "" : m.queryMirror.text = "Texto digitado: "
    m.focusZone = "keyboard" : m.selectedKeyRow = 0 : m.selectedKeyCol = 0 : m.selectedIndex = 0 : m.firstVisibleIndex = 0
    renderKeyboard()
    applyFilter()
end sub

sub hide()
    m.top.visible = false
end sub

sub setLoading(isLoading as Boolean)
    if isLoading then
        clearResultNodes() : m.statusLabel.color = "#B8C3D6" : m.statusLabel.text = "Carregando conteúdo para busca..."
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
    clearResultNodes() : m.statusLabel.color = "#FFCC66" : m.statusLabel.text = message
end sub

sub configureSearchLabels()
    m.title.text = getSearchTitle()
    m.searchInput.hintText = getSearchHint()
    m.subtitle.text = "Digite pelo teclado do app ou pelo Roku Remote no celular"
end sub

function getSearchTitle() as String
    if m.searchMode = "movies" then return "BUSCAR FILME"
    if m.searchMode = "series" then return "BUSCAR SÉRIE"
    return "BUSCAR CANAL"
end function

function getSearchHint() as String
    if m.searchMode = "movies" then return "Digite o nome do filme"
    if m.searchMode = "series" then return "Digite o nome da série"
    return "Digite o nome do canal"
end function

function getEmptySearchMessage() as String
    if m.searchMode = "movies" then return "Digite para encontrar filmes na sua lista."
    if m.searchMode = "series" then return "Digite para encontrar séries na sua lista."
    return "Digite para encontrar canais ao vivo na sua lista."
end function

sub renderKeyboard()
    while m.keyboardGroup.GetChildCount() > 0 : m.keyboardGroup.RemoveChildIndex(0) : end while
    m.keyNodes = []
    for r = 0 to m.keyRows.Count() - 1
        rowNodes = []
        for c = 0 to m.keyRows[r].Count() - 1
            keyLabel = m.keyRows[r][c]
            g = CreateObject("roSGNode", "Group") : g.translation = [c * (m.keyW + m.keyGap), r * (m.keyH + m.keyGap)]
            bg = CreateObject("roSGNode", "Rectangle") : bg.id = "keyBackground" : bg.width = m.keyW : bg.height = m.keyH : bg.color = "#101A2C" : bg.opacity = 0.92
            lb = CreateObject("roSGNode", "Label") : lb.id = "keyLabel" : lb.width = m.keyW : lb.height = m.keyH : lb.horizAlign = "center" : lb.vertAlign = "center" : lb.color = "#EAF2FF" : lb.font = "font:SmallBoldSystemFont" : lb.text = keyLabel
            g.AppendChild(bg) : g.AppendChild(lb) : m.keyboardGroup.AppendChild(g) : rowNodes.Push(g)
        end for
        m.keyNodes.Push(rowNodes)
    end for
    updateKeyboardFocus()
end sub

sub onSearchTextChanged()
    m.queryMirror.text = "Texto digitado: " + m.searchInput.text
    m.searchDebounceTimer.control = "stop"
    m.searchDebounceTimer.control = "start"
end sub

sub onSearchDebounceFire()
    applyFilter()
end sub

sub applyFilter()
    query = LCase(m.searchInput.text.Trim())
    m.results = []
    if m.searchMode = "live" then addMatches("channel", m.channels, query)
    if m.searchMode = "movies" then addMatches("movie", m.movies, query)
    if m.searchMode = "series" then addMatches("series", m.series, query)
    m.selectedIndex = 0 : m.firstVisibleIndex = 0
    if m.results.Count() = 0 then
        clearResultNodes() : m.statusLabel.color = "#FFCC66" : m.statusLabel.text = "Nenhum resultado encontrado. Tente outro nome."
    else
        m.statusLabel.text = "" : renderResults() : updateResultFocus()
    end if
end sub

sub addMatches(kind as String, items as Dynamic, query as String)
    entries = []
    for each item in normalizeArray(items)
        name = getItemName(item)
        meta = getItemMeta(item)
        if query = "" or Instr(1, LCase(name + " " + meta), query) > 0 then
            entries.Push({ sortKey: LCase(name), type: kind, title: name, meta: meta, item: item })
        end if
    end for
    entries.SortBy("sortKey")
    for each entry in entries
        if m.results.Count() >= m.maxResults then exit for
        m.results.Push({ type: entry.type, title: entry.title, meta: entry.meta, item: entry.item })
    end for
end sub

sub renderResults()
    clearResultNodes()
    if m.results.Count() = 0 then return
    updateResultWindow()
    lastIndex = m.firstVisibleIndex + m.visibleItemCount - 1
    if lastIndex >= m.results.Count() then lastIndex = m.results.Count() - 1
    for i = m.firstVisibleIndex to lastIndex
        node = createCardResultNode(m.results[i], i - m.firstVisibleIndex)
        m.resultsGroup.AppendChild(node) : m.itemNodes.Push(node)
    end for
end sub

function createCardResultNode(result as Object, visualIndex as Integer) as Object
    col = visualIndex mod m.gridColumns
    row = Int(visualIndex / m.gridColumns)
    group = CreateObject("roSGNode", "Group") : group.translation = [col * (m.cardWidth + m.cardGap), row * (m.cardHeight + m.cardRowGap)]
    bg = CreateObject("roSGNode", "Rectangle") : bg.id = "itemBackground" : bg.width = m.cardWidth : bg.height = m.cardHeight : bg.color = "#101827" : bg.opacity = 0.92
    imageBg = CreateObject("roSGNode", "Rectangle") : imageBg.width = m.cardWidth - 18 : imageBg.height = m.cardHeight - 70 : imageBg.translation = [9, 9] : imageBg.color = "#1C2940"
    poster = CreateObject("roSGNode", "Poster") : poster.id = "itemImage" : poster.width = m.cardWidth - 18 : poster.height = m.cardHeight - 70 : poster.translation = [9, 9] : poster.loadDisplayMode = "scaleToFill" : poster.uri = getItemImage(result.item)
    title = CreateObject("roSGNode", "Label") : title.id = "itemLabel" : title.width = m.cardWidth - 12 : title.height = 30 : title.translation = [6, m.cardHeight - 58] : title.horizAlign = "center" : title.vertAlign = "center" : title.color = "#FFFFFF" : title.font = "font:SmallBoldSystemFont" : title.text = result.title
    meta = CreateObject("roSGNode", "Label") : meta.id = "itemMeta" : meta.width = m.cardWidth - 12 : meta.height = 24 : meta.translation = [6, m.cardHeight - 28] : meta.horizAlign = "center" : meta.vertAlign = "center" : meta.color = "#9FB0C8" : meta.font = "font:TinySystemFont" : meta.text = result.meta
    group.AppendChild(bg) : group.AppendChild(imageBg) : group.AppendChild(poster) : group.AppendChild(title) : group.AppendChild(meta)
    return group
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then m.top.backRequested = true : return true
    if key = "up" then moveVertical(-1) : return true
    if key = "down" then moveVertical(1) : return true
    if key = "left" then moveHorizontal(-1) : return true
    if key = "right" then moveHorizontal(1) : return true
    if key = "OK" then activateFocused() : return true
    if handleRokuKeyboardKey(key) then return true
    return false
end function

sub moveVertical(direction as Integer)
    if m.focusZone = "keyboard" then
        nextRow = m.selectedKeyRow + direction
        if nextRow >= 0 and nextRow < m.keyRows.Count() then
            m.selectedKeyRow = nextRow
            if m.selectedKeyCol >= m.keyRows[m.selectedKeyRow].Count() then m.selectedKeyCol = m.keyRows[m.selectedKeyRow].Count() - 1
            updateKeyboardFocus()
        else
            moveZone(direction)
        end if
    else if m.focusZone = "results" and m.results.Count() > 0 then
        nextIndex = m.selectedIndex + (direction * m.gridColumns)
        if nextIndex >= 0 and nextIndex < m.results.Count() then
            m.selectedIndex = nextIndex
            updateResultWindow()
            renderResults()
            updateResultFocus()
        else
            moveZone(direction)
        end if
    else
        moveZone(direction)
    end if
end sub

sub moveZone(direction as Integer)
    if direction < 0 then
        if m.focusZone = "keyboard" and m.results.Count() > 0 then
            m.focusZone = "results"
        else
            m.focusZone = "keyboard"
        end if
    else
        if m.focusZone = "results" then
            m.focusZone = "keyboard"
        else if m.results.Count() > 0 then
            m.focusZone = "results"
        end if
    end if
    updateAllFocus()
end sub

sub moveHorizontal(direction as Integer)
    if m.focusZone = "keyboard" then
        moveKeyboardHorizontal(direction)
        updateKeyboardFocus()
    else if m.focusZone = "results" and m.results.Count() > 0 then
        m.selectedIndex = m.selectedIndex + direction
        if m.selectedIndex < 0 then m.selectedIndex = m.results.Count() - 1
        if m.selectedIndex >= m.results.Count() then m.selectedIndex = 0
        updateResultWindow()
        renderResults()
        updateResultFocus()
    end if
end sub

sub moveKeyboardHorizontal(direction as Integer)
    m.selectedKeyCol = m.selectedKeyCol + direction
    rowCount = m.keyRows[m.selectedKeyRow].Count()
    if m.selectedKeyCol < 0 then m.selectedKeyCol = rowCount - 1
    if m.selectedKeyCol >= rowCount then m.selectedKeyCol = 0
end sub

sub activateFocused()
    if m.focusZone = "results" then openSelected() : return
    keyLabel = m.keyRows[m.selectedKeyRow][m.selectedKeyCol]
    if keyLabel = "APAGAR" then
        t = m.searchInput.text : if Len(t) > 0 then m.searchInput.text = Left(t, Len(t) - 1)
    else if keyLabel = "LIMPAR" then
        m.searchInput.text = ""
    else if keyLabel = "BUSCAR" then
        m.searchDebounceTimer.control = "stop"
        applyFilter()
        if m.results.Count() > 0 then m.focusZone = "results"
    else if keyLabel = "ESPAÇO" then
        m.searchInput.text = m.searchInput.text + " "
    else
        m.searchInput.text = m.searchInput.text + keyLabel
    end if
    updateAllFocus()
end sub

function handleRokuKeyboardKey(key as String) as Boolean
    if Left(key, 4) = "lit_" then
        m.searchInput.text = m.searchInput.text + Mid(key, 5)
        updateAllFocus()
        return true
    end if
    if key = "backspace" or key = "delete" then
        t = m.searchInput.text
        if Len(t) > 0 then m.searchInput.text = Left(t, Len(t) - 1)
        updateAllFocus()
        return true
    end if
    return false
end function

sub updateAllFocus()
    updateKeyboardFocus() : updateResultFocus()
    if m.focusZone = "keyboard" then m.inputBackground.color = "#081E33" else m.inputBackground.color = "#0B1220"
end sub

sub updateKeyboardFocus()
    for r = 0 to m.keyNodes.Count() - 1
        for c = 0 to m.keyNodes[r].Count() - 1
            bg = m.keyNodes[r][c].FindNode("keyBackground") : lb = m.keyNodes[r][c].FindNode("keyLabel")
            if m.focusZone = "keyboard" and r = m.selectedKeyRow and c = m.selectedKeyCol then
                bg.color = "#FFCC00" : bg.opacity = 1.0 : lb.color = "#06111F" : m.keyNodes[r][c].scale = [1.08, 1.08]
            else
                bg.color = "#101A2C" : bg.opacity = 0.92 : lb.color = "#EAF2FF" : m.keyNodes[r][c].scale = [1.0, 1.0]
            end if
        end for
    end for
end sub

sub updateResultFocus()
    for i = 0 to m.itemNodes.Count() - 1
        bg = m.itemNodes[i].FindNode("itemBackground") : lb = m.itemNodes[i].FindNode("itemLabel")
        realIndex = m.firstVisibleIndex + i
        if m.focusZone = "results" and realIndex = m.selectedIndex then
            bg.color = "#063B66" : bg.opacity = 1.0 : lb.color = "#FFFFFF"
        else
            bg.color = "#101827" : bg.opacity = 0.92 : lb.color = "#FFFFFF"
        end if
    end for
end sub

sub updateResultWindow()
    if m.results.Count() = 0 then
        m.selectedIndex = 0 : m.firstVisibleIndex = 0
        return
    end if
    if m.selectedIndex < 0 then m.selectedIndex = 0
    if m.selectedIndex >= m.results.Count() then m.selectedIndex = m.results.Count() - 1
    row = Int(m.selectedIndex / m.gridColumns)
    firstRow = Int(m.firstVisibleIndex / m.gridColumns)
    if row < firstRow then m.firstVisibleIndex = row * m.gridColumns
    if row >= firstRow + m.gridRows then m.firstVisibleIndex = (row - m.gridRows + 1) * m.gridColumns
    maxFirst = m.results.Count() - m.visibleItemCount
    if maxFirst < 0 then maxFirst = 0
    if m.firstVisibleIndex > maxFirst then m.firstVisibleIndex = maxFirst
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0
end sub

sub openSelected()
    if m.results.Count() = 0 or m.selectedIndex < 0 or m.selectedIndex >= m.results.Count() then return
    result = m.results[m.selectedIndex]
    if result.type = "channel" then m.top.channelSelected = result.item
    if result.type = "movie" then m.top.movieSelected = result.item
    if result.type = "series" then m.top.seriesSelected = result.item
end sub

sub clearResultNodes()
    while m.resultsGroup.GetChildCount() > 0 : m.resultsGroup.RemoveChildIndex(0) : end while
    m.itemNodes = []
end sub

function normalizeArray(value as Dynamic) as Object
    if value <> invalid and Type(value) = "roArray" then return value
    return []
end function

function getItemImage(item as Dynamic) as String
    if item = invalid then return ""
    if item.stream_icon <> invalid and item.stream_icon.ToStr().Trim() <> "" then return item.stream_icon.ToStr()
    if item.cover <> invalid and item.cover.ToStr().Trim() <> "" then return item.cover.ToStr()
    if item.poster <> invalid and item.poster.ToStr().Trim() <> "" then return item.poster.ToStr()
    if item.logo <> invalid and item.logo.ToStr().Trim() <> "" then return item.logo.ToStr()
    if item.capa <> invalid and item.capa.ToStr().Trim() <> "" then return item.capa.ToStr()
    return ""
end function

function getItemName(item as Dynamic) as String
    if item = invalid then return "Sem nome"
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return "Sem nome"
end function

function getItemMeta(item as Dynamic) as String
    parts = []
    if item = invalid then return ""
    if item.year <> invalid and item.year.ToStr().Trim() <> "" then parts.Push(item.year.ToStr())
    if item.category_name <> invalid and item.category_name.ToStr().Trim() <> "" then parts.Push(item.category_name.ToStr())
    if item.category <> invalid and item.category.ToStr().Trim() <> "" then parts.Push(item.category.ToStr())
    if item.duration <> invalid and item.duration.ToStr().Trim() <> "" then parts.Push(item.duration.ToStr())
    if parts.Count() = 0 and item.stream_type <> invalid then parts.Push(item.stream_type.ToStr())
    return joinParts(parts, " • ")
end function

function joinParts(parts as Object, separator as String) as String
    text = ""
    for i = 0 to parts.Count() - 1
        if i > 0 then text = text + separator
        text = text + parts[i]
    end for
    return text
end function
