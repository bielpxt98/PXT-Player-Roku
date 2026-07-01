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
    m.resultBatchSize = 20 : m.renderedResultLimit = 20
    m.searchMode = "live"
    m.searchLetters = [ ["A","B","C","D","E","F","G","H","I","J","K","L","M"], ["N","O","P","Q","R","S","T","U","V","W","X","Y","Z"] ]
    m.searchNumbers = ["0","1","2","3","4","5","6","7","8","9"]
    m.searchActions = ["ESPAÇO","APAGAR","LIMPAR","FECHAR"]
    m.keyRows = [m.searchLetters[0], m.searchLetters[1], m.searchNumbers, m.searchActions]
    m.keyNodes = [] : m.keyRefs = [] : m.itemNodes = [] : m.itemRefs = []
    m.searchFocusArea = "input" : m.searchLetterRow = 0 : m.searchLetterCol = 0 : m.searchNumberIndex = 0 : m.searchActionIndex = 0 : m.searchResultIndex = 0 : m.firstVisibleIndex = 0
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
    m.inputTop = 132 : m.inputHeight = 56
    m.resultsTop = m.inputTop + m.inputHeight + 58
    m.keyboardTop = m.resultsTop + 348
    if m.screenH <= 720 then m.inputTop = 104 : m.inputHeight = 46 : m.resultsTop = m.inputTop + m.inputHeight + 42 : m.keyboardTop = m.resultsTop + 228
    m.resultsTitle.translation = [m.marginX, m.resultsTop - 36] : m.resultsTitle.font = "font:MediumBoldSystemFont"
    m.resultsGroup.translation = [m.marginX, m.resultsTop]
    m.inputBackground.translation = [m.marginX, m.inputTop] : m.inputBackground.width = m.contentWidth : m.inputBackground.height = m.inputHeight
    m.searchInput.translation = [m.marginX + 14, m.inputTop + 4] : m.searchInput.width = 2 : m.searchInput.height = 2 : m.searchInput.visible = true
    m.queryMirror.translation = [m.marginX + 20, m.inputTop + 8] : m.queryMirror.width = m.contentWidth - 40 : m.queryMirror.height = m.inputHeight - 14 : m.queryMirror.font = "font:MediumBoldSystemFont"
    m.statusLabel.translation = [m.marginX, m.resultsTop + 112] : m.statusLabel.width = m.contentWidth : m.statusLabel.font = "font:MediumSystemFont"
    m.keyboardGroup.translation = [m.marginX, m.keyboardTop]
    m.hintLabel.width = m.screenW : m.hintLabel.font = "font:SmallSystemFont" : m.hintLabel.translation = [0, m.screenH - 34]
    m.keyGap = 10
    m.keyW = Int((m.contentWidth - 12 * m.keyGap) / 13) : m.keyH = 38
    m.cardGap = 28 : m.cardHeight = 306 : m.resultCols = 5
    m.cardWidth = Int((m.contentWidth - ((m.resultCols - 1) * m.cardGap)) / m.resultCols)
    if m.screenH <= 720 then m.cardGap = 18 : m.cardHeight = 206 : m.keyH = 28 : m.keyGap = 6 : m.keyW = Int((m.contentWidth - 12 * m.keyGap) / 13) : m.cardWidth = Int((m.contentWidth - ((m.resultCols - 1) * m.cardGap)) / m.resultCols)
    m.visibleItemCount = m.resultCols
end sub

sub show(mode as Dynamic)
    if mode = invalid or mode = "all" then mode = "live"
    m.searchMode = mode
    configureLayout()
    configureSearchLabels()
    m.top.visible = true : m.top.SetFocus(true)
    m.searchDebounceTimer.control = "stop"
    m.searchInput.text = "" : m.queryMirror.text = "Buscar: "
    m.searchFocusArea = "input" : m.searchLetterRow = 0 : m.searchLetterCol = 0 : m.searchNumberIndex = 0 : m.searchActionIndex = 0 : m.searchResultIndex = 0 : m.firstVisibleIndex = 0
    renderKeyboard()
    applyFilter()
    updateSearchFocus()
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
    m.subtitle.text = "Buscar: "
end sub

function getSearchTitle() as String
    if m.searchMode = "movies" then return "PESQUISAR FILME"
    if m.searchMode = "series" then return "PESQUISAR"
    return "PESQUISAR CANAL"
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
    m.keyRefs = []
    for r = 0 to m.keyRows.Count() - 1
        rowNodes = []
        rowRefs = []
        for c = 0 to m.keyRows[r].Count() - 1
            keyLabel = m.keyRows[r][c]
            keyW = m.keyW
            if r = 2 then keyW = Int((m.contentWidth - 9 * m.keyGap) / 10)
            if r = 3 then keyW = Int((m.contentWidth - 3 * m.keyGap) / 4)
            g = CreateObject("roSGNode", "Group") : g.translation = [c * (keyW + m.keyGap), r * (m.keyH + m.keyGap)]
            bg = CreateObject("roSGNode", "Rectangle") : bg.id = "keyBackground" : bg.width = keyW : bg.height = m.keyH : bg.color = "#101A2C" : bg.opacity = 0.92
            lb = CreateObject("roSGNode", "Label") : lb.id = "keyLabel" : lb.width = keyW : lb.height = m.keyH : lb.horizAlign = "center" : lb.vertAlign = "center" : lb.color = "#EAF2FF" : lb.font = "font:SmallBoldSystemFont" : lb.text = keyLabel
            g.AppendChild(bg) : g.AppendChild(lb) : m.keyboardGroup.AppendChild(g) : rowNodes.Push(g) : rowRefs.Push({ background: bg, label: lb })
        end for
        m.keyNodes.Push(rowNodes)
        m.keyRefs.Push(rowRefs)
    end for
    updateSearchFocus()
end sub

sub onSearchTextChanged()
    m.queryMirror.text = "Buscar: " + m.searchInput.text
    m.searchDebounceTimer.control = "stop"
    applyFilter()
end sub

sub onSearchDebounceFire()
    applyFilter()
end sub

sub applyFilter()
    query = normalizeSearchQuery(m.searchInput.text)
    oldResults = m.results
    m.results = []
    if m.searchMode = "live" then addMatches("channel", m.channels, query)
    if m.searchMode = "movies" then addMatches("movie", m.movies, query)
    if m.searchMode = "series" then addMatches("series", m.series, query)
    if query = "" then m.results = pickInitialSearchItems(m.results)
    m.searchResultIndex = 0 : m.firstVisibleIndex = 0 : m.renderedResultLimit = m.resultBatchSize
    if m.results.Count() = 0 then
        clearResultNodes() : m.statusLabel.color = "#FFCC66" : m.statusLabel.text = getEmptySearchMessage()
        if m.searchFocusArea = "results" then m.searchFocusArea = "keyboardActions"
        updateSearchFocus()
    else
        m.statusLabel.text = "" : renderResults() : updateSearchFocus()
    end if
end sub

sub addMatches(kind as String, items as Dynamic, query as String)
    startsWithEntries = []
    containsEntries = []
    for each item in normalizeArray(items)
        name = getItemName(item)
        meta = getItemMeta(item)
        lowerName = getSearchableTitle(item, name)
        if query = "" then
            startsWithEntries.Push({ sortKey: lowerName, type: kind, title: name, meta: meta, item: item })
        else if Left(lowerName, Len(query)) = query then
            startsWithEntries.Push({ sortKey: lowerName, type: kind, title: name, meta: meta, item: item })
        else if Instr(1, lowerName, query) > 0 then
            containsEntries.Push({ sortKey: lowerName, type: kind, title: name, meta: meta, item: item })
        end if
    end for
    startsWithEntries.SortBy("sortKey")
    containsEntries.SortBy("sortKey")
    appendSearchEntries(startsWithEntries)
    appendSearchEntries(containsEntries)
end sub

function pickInitialSearchItems(entries as Object) as Object
    picks = []
    if entries = invalid or entries.Count() = 0 then return picks
    seed = CreateObject("roDateTime").AsSeconds()
    start = seed MOD entries.Count()
    i = 0
    while i < entries.Count() and picks.Count() < m.resultCols
        idx = (start + i) MOD entries.Count()
        picks.Push(entries[idx])
        i = i + 1
    end while
    return picks
end function

function getSearchableTitle(item as Dynamic, fallbackName as String) as String
    if item <> invalid and item.normalizedTitle <> invalid and item.normalizedTitle.ToStr().Trim() <> "" then return item.normalizedTitle.ToStr()
    return normalizeSearchQuery(fallbackName)
end function

function normalizeSearchQuery(value as Dynamic) as String
    text = LCase(value.ToStr().Trim())
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

sub appendSearchEntries(entries as Object)
    for each entry in entries
        m.results.Push({ type: entry.type, title: entry.title, meta: entry.meta, item: entry.item })
    end for
end sub

sub renderResults()
    if m.results.Count() = 0 then
        clearResultNodes()
        return
    end if
    updateResultWindow()
    lastIndex = m.firstVisibleIndex + m.visibleItemCount - 1
    maxLoadedIndex = getLoadedResultCount() - 1
    if lastIndex > maxLoadedIndex then lastIndex = maxLoadedIndex
    if lastIndex >= m.results.Count() then lastIndex = m.results.Count() - 1
    neededCount = lastIndex - m.firstVisibleIndex + 1
    if neededCount < 0 then neededCount = 0
    while m.itemNodes.Count() > neededCount
        removeIndex = m.itemNodes.Count() - 1
        m.resultsGroup.RemoveChildIndex(removeIndex)
        m.itemNodes.Delete(removeIndex)
        m.itemRefs.Delete(removeIndex)
    end while
    for visualIndex = 0 to neededCount - 1
        realIndex = m.firstVisibleIndex + visualIndex
        result = m.results[realIndex]
        if visualIndex < m.itemNodes.Count() then
            updateCardResultNode(m.itemNodes[visualIndex], m.itemRefs[visualIndex], result, visualIndex)
        else
            node = createCardResultNode(result, visualIndex)
            m.resultsGroup.AppendChild(node) : m.itemNodes.Push(node) : m.itemRefs.Push(m.lastItemRefs)
        end if
    end for
end sub

function createCardResultNode(result as Object, visualIndex as Integer) as Object
    col = visualIndex MOD m.resultCols : row = Int(visualIndex / m.resultCols)
    group = CreateObject("roSGNode", "Group") : group.translation = [col * (m.cardWidth + m.cardGap), row * (m.cardHeight + 12)]
    bg = CreateObject("roSGNode", "Rectangle") : bg.id = "itemBackground" : bg.width = m.cardWidth : bg.height = m.cardHeight : bg.color = "#101827" : bg.opacity = 0.92
    imageBg = CreateObject("roSGNode", "Rectangle") : imageBg.width = m.cardWidth - 18 : imageBg.height = m.cardHeight - 70 : imageBg.translation = [9, 9] : imageBg.color = "#1C2940"
    poster = CreateObject("roSGNode", "Poster") : poster.id = "itemImage" : poster.width = m.cardWidth - 18 : poster.height = m.cardHeight - 70 : poster.translation = [9, 9] : poster.loadDisplayMode = "scaleToFill" : poster.uri = getItemImage(result.item)
    title = CreateObject("roSGNode", "Label") : title.id = "itemLabel" : title.width = m.cardWidth - 12 : title.height = 30 : title.translation = [6, m.cardHeight - 58] : title.horizAlign = "center" : title.vertAlign = "center" : title.color = "#FFFFFF" : title.font = "font:SmallBoldSystemFont" : title.text = result.title
    meta = CreateObject("roSGNode", "Label") : meta.id = "itemMeta" : meta.width = m.cardWidth - 12 : meta.height = 24 : meta.translation = [6, m.cardHeight - 28] : meta.horizAlign = "center" : meta.vertAlign = "center" : meta.color = "#9FB0C8" : meta.font = "font:TinySystemFont" : meta.text = result.meta
    group.AppendChild(bg) : group.AppendChild(imageBg) : group.AppendChild(poster) : group.AppendChild(title) : group.AppendChild(meta)
    m.lastItemRefs = { background: bg, label: title, meta: meta, poster: poster, imageBg: imageBg, resultKey: getResultKey(result) }
    return group
end function

sub updateCardResultNode(group as Object, refs as Object, result as Object, visualIndex as Integer)
    col = visualIndex MOD m.resultCols : row = Int(visualIndex / m.resultCols)
    group.translation = [col * (m.cardWidth + m.cardGap), row * (m.cardHeight + 12)]
    refs.background.width = m.cardWidth : refs.background.height = m.cardHeight
    refs.imageBg.width = m.cardWidth - 18 : refs.imageBg.height = m.cardHeight - 70
    refs.poster.width = m.cardWidth - 18 : refs.poster.height = m.cardHeight - 70
    refs.label.width = m.cardWidth - 12 : refs.label.translation = [6, m.cardHeight - 58]
    refs.meta.width = m.cardWidth - 12 : refs.meta.translation = [6, m.cardHeight - 28]
    key = getResultKey(result)
    if refs.resultKey = key then return
    refs.resultKey = key
    refs.poster.uri = getItemImage(result.item)
    refs.label.text = result.title
    refs.meta.text = result.meta
end sub

function getResultKey(result as Object) as String
    item = result.item
    if item <> invalid then
        if item.stream_id <> invalid then return result.type + ":" + item.stream_id.ToStr()
        if item.series_id <> invalid then return result.type + ":" + item.series_id.ToStr()
        if item.title <> invalid then return result.type + ":" + item.title.ToStr()
        if item.name <> invalid then return result.type + ":" + item.name.ToStr()
    end if
    return result.type + ":" + result.title
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then m.top.backRequested = true : return true
    if key = "up" or key = "down" or key = "left" or key = "right" then
        moveSearchFocus(key)
        updateSearchFocus()
        return true
    end if
    if key = "OK" then activateFocused() : return true
    if handleRokuKeyboardKey(key) then return true
    return false
end function

sub moveSearchFocus(key as String)
    if m.searchFocusArea = "input" then
        if key = "down" then
            if m.results.Count() > 0 then m.searchFocusArea = "results" else m.searchFocusArea = "keyboardLetters"
        end if
        return
    end if

    if m.searchFocusArea = "keyboardLetters" then
        if key = "right" and m.searchLetterCol < 12 then m.searchLetterCol = m.searchLetterCol + 1
        if key = "left" and m.searchLetterCol > 0 then m.searchLetterCol = m.searchLetterCol - 1
        if key = "up" then
            if m.searchLetterRow = 1 then
                m.searchLetterRow = 0
            else if m.results.Count() > 0 then
                m.searchFocusArea = "results"
            else
                m.searchFocusArea = "input"
            end if
        end if
        if key = "down" then
            if m.searchLetterRow = 0 then
                m.searchLetterRow = 1
            else
                m.searchFocusArea = "keyboardNumbers" : m.searchNumberIndex = nearestNumberIndexForLetterCol(m.searchLetterCol)
            end if
        end if
        return
    end if

    if m.searchFocusArea = "keyboardNumbers" then
        if key = "right" and m.searchNumberIndex < m.searchNumbers.Count() - 1 then m.searchNumberIndex = m.searchNumberIndex + 1
        if key = "left" and m.searchNumberIndex > 0 then m.searchNumberIndex = m.searchNumberIndex - 1
        if key = "up" then
            m.searchFocusArea = "keyboardLetters" : m.searchLetterRow = 1 : m.searchLetterCol = nearestLetterColForNumberIndex(m.searchNumberIndex)
        end if
        if key = "down" then m.searchFocusArea = "keyboardActions" : m.searchActionIndex = nearestActionIndexForNumberIndex(m.searchNumberIndex)
        return
    end if

    if m.searchFocusArea = "keyboardActions" then
        if key = "right" and m.searchActionIndex < m.searchActions.Count() - 1 then m.searchActionIndex = m.searchActionIndex + 1
        if key = "left" and m.searchActionIndex > 0 then m.searchActionIndex = m.searchActionIndex - 1
        if key = "up" then m.searchFocusArea = "keyboardNumbers" : m.searchNumberIndex = nearestNumberIndexForActionIndex(m.searchActionIndex)
        if key = "down" and m.results.Count() > 0 then m.searchFocusArea = "results"
        return
    end if

    if m.searchFocusArea = "results" then
        loadedCount = getLoadedResultCount()
        if loadedCount = 0 then m.searchFocusArea = "keyboardActions" : return
        oldSelected = m.searchResultIndex
        oldFirst = m.firstVisibleIndex
        oldLimit = m.renderedResultLimit
        if key = "left" and m.searchResultIndex > 0 then m.searchResultIndex = m.searchResultIndex - 1
        if key = "right" and m.searchResultIndex < loadedCount - 1 then m.searchResultIndex = m.searchResultIndex + 1
        if key = "up" then m.searchFocusArea = "input"
        if key = "down" then m.searchFocusArea = "keyboardLetters"
        maybeLoadMoreResults()
        updateResultWindow()
        if oldSelected <> m.searchResultIndex or oldFirst <> m.firstVisibleIndex or oldLimit <> m.renderedResultLimit then renderResults()
    end if
end sub

function nearestNumberIndexForLetterCol(col as Integer) as Integer
    idx = Int((col * (m.searchNumbers.Count() - 1) + 6) / 12)
    if idx < 0 then idx = 0
    if idx > m.searchNumbers.Count() - 1 then idx = m.searchNumbers.Count() - 1
    return idx
end function

function nearestLetterColForNumberIndex(idx as Integer) as Integer
    col = Int((idx * 12 + 4) / (m.searchNumbers.Count() - 1))
    if col < 0 then col = 0
    if col > 12 then col = 12
    return col
end function

function nearestActionIndexForNumberIndex(idx as Integer) as Integer
    action = Int((idx * (m.searchActions.Count() - 1) + 4) / (m.searchNumbers.Count() - 1))
    if action < 0 then action = 0
    if action > m.searchActions.Count() - 1 then action = m.searchActions.Count() - 1
    return action
end function

function nearestNumberIndexForActionIndex(idx as Integer) as Integer
    num = Int((idx * (m.searchNumbers.Count() - 1) + 1) / (m.searchActions.Count() - 1))
    if num < 0 then num = 0
    if num > m.searchNumbers.Count() - 1 then num = m.searchNumbers.Count() - 1
    return num
end function

sub activateFocused()
    if m.searchFocusArea = "results" then openSelected() : return
    if m.searchFocusArea = "input" then return
    keyLabel = getFocusedKeyboardLabel()
    if keyLabel = "APAGAR" then
        t = m.searchInput.text : if Len(t) > 0 then m.searchInput.text = Left(t, Len(t) - 1)
    else if keyLabel = "LIMPAR" then
        m.searchInput.text = ""
    else if keyLabel = "FECHAR" then
        m.top.backRequested = true
    else if keyLabel = "ESPAÇO" then
        m.searchInput.text = m.searchInput.text + " "
    else
        m.searchInput.text = m.searchInput.text + keyLabel
    end if
    updateSearchFocus()
end sub

function getFocusedKeyboardLabel() as String
    if m.searchFocusArea = "keyboardLetters" then return m.searchLetters[m.searchLetterRow][m.searchLetterCol]
    if m.searchFocusArea = "keyboardNumbers" then return m.searchNumbers[m.searchNumberIndex]
    if m.searchFocusArea = "keyboardActions" then return m.searchActions[m.searchActionIndex]
    return ""
end function

function handleRokuKeyboardKey(key as String) as Boolean
    if Left(key, 4) = "lit_" then
        m.searchInput.text = m.searchInput.text + Mid(key, 5)
        updateSearchFocus()
        return true
    end if
    if key = "backspace" or key = "delete" then
        t = m.searchInput.text
        if Len(t) > 0 then m.searchInput.text = Left(t, Len(t) - 1)
        updateSearchFocus()
        return true
    end if
    return false
end function

sub updateSearchFocus()
    m.top.SetFocus(true)
    if m.searchFocusArea = "input" then m.inputBackground.color = "#063B66" else m.inputBackground.color = "#0B1220"
    updateKeyboardFocus()
    updateResultFocus()
end sub

sub updateKeyboardFocus()
    for r = 0 to m.keyNodes.Count() - 1
        for c = 0 to m.keyNodes[r].Count() - 1
            refs = m.keyRefs[r][c] : bg = refs.background : lb = refs.label
            selected = false
            if m.searchFocusArea = "keyboardLetters" and r = m.searchLetterRow and c = m.searchLetterCol then selected = true
            if m.searchFocusArea = "keyboardNumbers" and r = 2 and c = m.searchNumberIndex then selected = true
            if m.searchFocusArea = "keyboardActions" and r = 3 and c = m.searchActionIndex then selected = true
            if selected then
                bg.color = "#FFCC00" : bg.opacity = 1.0 : lb.color = "#06111F" : m.keyNodes[r][c].scale = [1.08, 1.08]
            else
                bg.color = "#101A2C" : bg.opacity = 0.92 : lb.color = "#EAF2FF" : m.keyNodes[r][c].scale = [1.0, 1.0]
            end if
        end for
    end for
end sub

sub updateResultFocus()
    for i = 0 to m.itemNodes.Count() - 1
        refs = m.itemRefs[i] : bg = refs.background : lb = refs.label
        realIndex = m.firstVisibleIndex + i
        if m.searchFocusArea = "results" and realIndex = m.searchResultIndex then
            bg.color = "#063B66" : bg.opacity = 1.0 : lb.color = "#FFFFFF"
        else
            bg.color = "#101827" : bg.opacity = 0.92 : lb.color = "#FFFFFF"
        end if
    end for
end sub

sub updateResultWindow()
    loadedCount = getLoadedResultCount()
    if loadedCount = 0 then
        m.searchResultIndex = 0 : m.firstVisibleIndex = 0
        return
    end if
    if m.searchResultIndex < 0 then m.searchResultIndex = 0
    if m.searchResultIndex >= loadedCount then m.searchResultIndex = loadedCount - 1
    if m.searchResultIndex < m.firstVisibleIndex then m.firstVisibleIndex = m.searchResultIndex
    if m.searchResultIndex >= m.firstVisibleIndex + m.visibleItemCount then m.firstVisibleIndex = m.searchResultIndex - m.visibleItemCount + 1
    maxFirst = loadedCount - m.visibleItemCount
    if maxFirst < 0 then maxFirst = 0
    if m.firstVisibleIndex > maxFirst then m.firstVisibleIndex = maxFirst
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0
end sub

function getLoadedResultCount() as Integer
    if m.results.Count() < m.renderedResultLimit then return m.results.Count()
    return m.renderedResultLimit
end function

sub maybeLoadMoreResults()
    if m.results.Count() <= m.renderedResultLimit then return
    if m.searchResultIndex >= m.renderedResultLimit - 4 then
        m.renderedResultLimit = m.renderedResultLimit + m.resultBatchSize
        if m.renderedResultLimit > m.results.Count() then m.renderedResultLimit = m.results.Count()
    end if
end sub

sub openSelected()
    if m.results.Count() = 0 or m.searchResultIndex < 0 or m.searchResultIndex >= m.results.Count() then return
    result = m.results[m.searchResultIndex]
    if result.type = "channel" then m.top.channelSelected = result.item
    if result.type = "movie" then m.top.movieSelected = result.item
    if result.type = "series" then m.top.seriesSelected = result.item
end sub

sub clearResultNodes()
    while m.resultsGroup.GetChildCount() > 0 : m.resultsGroup.RemoveChildIndex(0) : end while
    m.itemNodes = []
    m.itemRefs = []
end sub

function normalizeArray(value as Dynamic) as Object
    if value <> invalid and Type(value) = "roArray" then return value
    return []
end function

function getItemImage(item as Dynamic) as String
    if item = invalid then return ""
    if item.poster <> invalid and item.poster.ToStr().Trim() <> "" then return item.poster.ToStr()
    if item.stream_icon <> invalid and item.stream_icon.ToStr().Trim() <> "" then return item.stream_icon.ToStr()
    if item.cover <> invalid and item.cover.ToStr().Trim() <> "" then return item.cover.ToStr()
    if item.poster <> invalid and item.poster.ToStr().Trim() <> "" then return item.poster.ToStr()
    if item.logo <> invalid and item.logo.ToStr().Trim() <> "" then return item.logo.ToStr()
    if item.capa <> invalid and item.capa.ToStr().Trim() <> "" then return item.capa.ToStr()
    return ""
end function

function getItemName(item as Dynamic) as String
    if item = invalid then return "Sem nome"
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return "Sem nome"
end function

function getItemMeta(item as Dynamic) as String
    parts = []
    if item = invalid then return ""
    if item.year <> invalid and item.year.ToStr().Trim() <> "" then parts.Push(item.year.ToStr())
    if item.rating <> invalid and item.rating.ToStr().Trim() <> "" then parts.Push(item.rating.ToStr())
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
