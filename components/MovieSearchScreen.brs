' Clean movie-only search screen. Uses only movies already loaded in memory/cache.
sub Init()
    m.overlay = m.top.FindNode("overlay")
    m.title = m.top.FindNode("title")
    m.inputBackground = m.top.FindNode("inputBackground")
    m.queryLabel = m.top.FindNode("queryLabel")
    m.messageLabel = m.top.FindNode("messageLabel")
    m.resultsGroup = m.top.FindNode("resultsGroup")
    m.keyboardGroup = m.top.FindNode("keyboardGroup")
    m.hintLabel = m.top.FindNode("hintLabel")
    m.allMovies = [] : m.results = [] : m.query = "" : m.pendingQuery = ""
    m.focusArea = "keyboard" : m.keyRow = 0 : m.keyCol = 0 : m.posterIndex = 0 : m.selectedResultIndex = 0 : m.resultOffset = 0
    m.rows = [ ["A","B","C","D","E","F","G","H","I","J","K","L","M"], ["N","O","P","Q","R","S","T","U","V","W","X","Y","Z"], ["0","1","2","3","4","5","6","7","8","9"], ["ESPAÇO","APAGAR","LIMPAR","FECHAR"] ]
    m.keyNodes = [] : m.posterNodes = []
    m.posterPlaceholderUri = "" : m.posterUriCache = {} : m.catalogLoading = false
    m.posterLoadTimer = CreateObject("roSGNode", "Timer")
    m.posterLoadTimer.duration = 0.05
    m.posterLoadTimer.repeat = false
    m.posterLoadTimer.ObserveField("fire", "onPosterLoadTimerFire")
    m.maxMovies = 60 : m.maxResults = 40
    m.debounceTimer = CreateObject("roSGNode", "Timer")
    m.debounceTimer.duration = 0.4
    m.debounceTimer.repeat = false
    m.debounceTimer.ObserveField("fire", "onDebounceTimerFire")
    configureLayout()
end sub

sub configureLayout()
    size = CreateObject("roDeviceInfo").GetDisplaySize()
    m.screenW = size.w : m.screenH = size.h
    m.marginX = 72 : if m.screenH <= 720 then m.marginX = 48
    m.contentW = m.screenW - (m.marginX * 2)
    m.overlay.width = m.screenW : m.overlay.height = m.screenH
    m.title.width = m.screenW : m.title.height = 48 : m.title.translation = [0, 28] : m.title.font = "font:LargeBoldSystemFont"
    m.inputBackground.translation = [m.marginX, 92] : m.inputBackground.width = m.contentW : m.inputBackground.height = 48
    m.queryLabel.translation = [m.marginX + 18, 99] : m.queryLabel.width = m.contentW - 36 : m.queryLabel.height = 36 : m.queryLabel.font = "font:MediumBoldSystemFont"
    m.resultsTop = 168 : m.keyboardTop = m.screenH - 224
    if m.screenH <= 720 then m.resultsTop = 142 : m.keyboardTop = m.screenH - 174
    m.resultsGroup.translation = [m.marginX, m.resultsTop]
    m.keyboardGroup.translation = [m.marginX, m.keyboardTop]
    m.messageLabel.translation = [m.marginX, m.resultsTop + 60] : m.messageLabel.width = m.contentW : m.messageLabel.font = "font:MediumSystemFont"
    m.hintLabel.width = m.screenW : m.hintLabel.translation = [0, m.screenH - 32] : m.hintLabel.font = "font:SmallSystemFont"
    m.keyGap = 8 : m.keyH = 34 : if m.screenH <= 720 then m.keyGap = 6 : m.keyH = 28
    m.keyW = Int((m.contentW - (12 * m.keyGap)) / 13)
    m.posterGap = 28 : if m.screenH <= 720 then m.posterGap = 18
    m.posterW = Int((m.contentW - (4 * m.posterGap)) / 5)
    m.posterH = m.keyboardTop - m.resultsTop - 26
    if m.posterH < 170 then m.posterH = 170
end sub

sub show()
    configureLayout()
    PRINT "SEARCH_OPEN"
    m.top.visible = true : m.top.SetFocus(true)
    m.query = "" : m.pendingQuery = "" : m.queryLabel.text = "Buscar: "
    m.focusArea = "keyboard" : m.keyRow = 0 : m.keyCol = 0 : m.posterIndex = 0 : m.selectedResultIndex = 0 : m.resultOffset = 0
    renderKeyboard()
    applyFilter()
end sub

sub hide()
    m.top.visible = false
end sub

sub setMovies(items as Object)
    m.allMovies = normalizeArray(items)
    PRINT "SEARCH_CACHE_HIT"
    applyFilter()
end sub

sub showMessage(message as String)
    clearPosters()
    m.messageLabel.text = message
end sub

sub applyFilter()
    m.results = []
    m.posterIndex = 0 : m.selectedResultIndex = 0 : m.resultOffset = 0
    if m.allMovies.Count() = 0 then
        showMessage("Nenhum filme carregado ainda.")
        return
    end if
    needle = normalizeText(m.query)
    firstWordMatches = []
    secondWordMatches = []
    otherWordMatches = []
    for each movie in m.allMovies
        rank = prefixMatchRank(getMovieName(movie), needle)
        if rank = 1 then
            firstWordMatches.Push(movie)
        else if rank = 2 then
            secondWordMatches.Push(movie)
        else if rank = 3 then
            otherWordMatches.Push(movie)
        end if
    end for
    appendLimitedResults(firstWordMatches)
    appendLimitedResults(secondWordMatches)
    appendLimitedResults(otherWordMatches)
    if m.results.Count() = 0 then
        showMessage("Nenhum filme encontrado.")
        PRINT "SEARCH_RESULTS_UPDATED"
        if m.focusArea = "posters" then m.focusArea = "keyboard"
    else
        updateSearchLoadingMessage()
        if m.selectedResultIndex >= m.results.Count() then m.selectedResultIndex = m.results.Count() - 1
        m.posterIndex = m.selectedResultIndex
        syncResultOffset()
        renderPosters()
        PRINT "SEARCH_RESULTS_UPDATED"
    end if
    updateFocus()
end sub

sub appendLimitedResults(items as Object)
    for each item in items
        if m.results.Count() >= m.maxResults then exit for
        m.results.Push(item)
    end for
end sub

sub renderPosters()
    clearPosters()
    syncResultOffset()
    maxRender = getVisibleResultCount()
    for i = 0 to maxRender - 1
        resultIndex = m.resultOffset + i
        movie = m.results[resultIndex]
        group = CreateObject("roSGNode", "Group") : group.translation = [i * (m.posterW + m.posterGap), 0]
        bg = CreateObject("roSGNode", "Rectangle") : bg.id = "posterBg" : bg.width = m.posterW : bg.height = m.posterH : bg.color = "#101827" : bg.opacity = 0.92
        poster = CreateObject("roSGNode", "Poster") : poster.width = 120 : poster.height = 180 : poster.translation = [Int((m.posterW - 120) / 2), 6] : poster.loadDisplayMode = "scaleToFit" : poster.uri = m.posterPlaceholderUri
        label = CreateObject("roSGNode", "Label") : label.id = "posterLabel" : label.width = m.posterW - 10 : label.height = 36 : label.translation = [5, m.posterH - 42] : label.horizAlign = "center" : label.vertAlign = "center" : label.color = "#FFFFFF" : label.font = "font:SmallBoldSystemFont" : label.text = getMovieName(movie)
        group.AppendChild(bg) : group.AppendChild(poster) : group.AppendChild(label)
        m.resultsGroup.AppendChild(group) : m.posterNodes.Push({ group: group, bg: bg, poster: poster, label: label, movie: movie, resultIndex: resultIndex })
    end for
    scheduleVisiblePosterLoads()
end sub

sub refreshVisiblePosters()
    syncResultOffset()
    visibleCount = getVisibleResultCount()
    if m.posterNodes.Count() <> visibleCount then
        renderPosters()
        return
    end if
    for i = 0 to visibleCount - 1
        resultIndex = m.resultOffset + i
        movie = m.results[resultIndex]
        node = m.posterNodes[i]
        node.movie = movie
        node.resultIndex = resultIndex
        node.label.text = getMovieName(movie)
        if node.poster <> invalid then node.poster.uri = m.posterPlaceholderUri
    end for
    scheduleVisiblePosterLoads()
end sub

sub syncResultOffset()
    if m.results.Count() <= 0 then m.selectedResultIndex = 0 : m.posterIndex = 0 : m.resultOffset = 0 : return
    if m.selectedResultIndex < 0 then m.selectedResultIndex = 0
    if m.selectedResultIndex > m.results.Count() - 1 then m.selectedResultIndex = m.results.Count() - 1
    if m.selectedResultIndex > m.resultOffset + 4 then m.resultOffset = m.selectedResultIndex - 4
    if m.selectedResultIndex < m.resultOffset then m.resultOffset = m.selectedResultIndex
    if m.resultOffset < 0 then m.resultOffset = 0
    maxOffset = m.results.Count() - 5
    if maxOffset < 0 then maxOffset = 0
    if m.resultOffset > maxOffset then m.resultOffset = maxOffset
    m.posterIndex = m.selectedResultIndex
end sub

function getVisibleResultCount() as Integer
    count = m.results.Count() - m.resultOffset
    if count > 5 then count = 5
    if count < 0 then count = 0
    return count
end function

sub clearPosters()
    if m.posterLoadTimer <> invalid then m.posterLoadTimer.control = "stop"
    for each node in m.posterNodes
        if node.poster <> invalid then node.poster.uri = m.posterPlaceholderUri
    end for
    while m.resultsGroup.GetChildCount() > 0 : m.resultsGroup.RemoveChildIndex(0) : end while
    m.posterNodes = []
end sub

sub renderKeyboard()
    while m.keyboardGroup.GetChildCount() > 0 : m.keyboardGroup.RemoveChildIndex(0) : end while
    m.keyNodes = []
    for r = 0 to m.rows.Count() - 1
        nodes = []
        for c = 0 to m.rows[r].Count() - 1
            labelText = m.rows[r][c]
            keyW = m.keyW
            if r = 2 then keyW = Int((m.contentW - (9 * m.keyGap)) / 10)
            if r = 3 then keyW = Int((m.contentW - (3 * m.keyGap)) / 4)
            g = CreateObject("roSGNode", "Group") : g.translation = [c * (keyW + m.keyGap), r * (m.keyH + m.keyGap)]
            bg = CreateObject("roSGNode", "Rectangle") : bg.id = "keyBg" : bg.width = keyW : bg.height = m.keyH : bg.color = "#101A2C" : bg.opacity = 0.92
            lb = CreateObject("roSGNode", "Label") : lb.id = "keyLabel" : lb.width = keyW : lb.height = m.keyH : lb.horizAlign = "center" : lb.vertAlign = "center" : lb.color = "#EAF2FF" : lb.font = "font:SmallBoldSystemFont" : lb.text = labelText
            g.AppendChild(bg) : g.AppendChild(lb) : m.keyboardGroup.AppendChild(g) : nodes.Push({ bg: bg, label: lb })
        end for
        m.keyNodes.Push(nodes)
    end for
    updateFocus()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then m.top.backRequested = true : return true
    if key = "OK" then activate() : return true
    if key = "up" or key = "down" or key = "left" or key = "right" then moveFocus(key) : updateFocus() : return true
    return false
end function

sub moveFocus(key as String)
    if m.focusArea = "posters" then
        if key = "down" then m.focusArea = "keyboard" : return
        oldOffset = m.resultOffset
        if key = "left" and m.selectedResultIndex > 0 then m.selectedResultIndex = m.selectedResultIndex - 1
        if key = "right" and m.selectedResultIndex < m.results.Count() - 1 then m.selectedResultIndex = m.selectedResultIndex + 1
        syncResultOffset()
        if oldOffset <> m.resultOffset then refreshVisiblePosters()
        return
    end if
    if key = "up" and m.keyRow = 0 and m.results.Count() > 0 then m.focusArea = "posters" : m.selectedResultIndex = nearestPosterIndexForKeyCol(m.keyCol) : syncResultOffset() : refreshVisiblePosters() : return
    if key = "left" and m.keyCol > 0 then m.keyCol = m.keyCol - 1
    if key = "right" and m.keyCol < m.rows[m.keyRow].Count() - 1 then m.keyCol = m.keyCol + 1
    if key = "up" and m.keyRow > 0 then moveKeyboardVertical(-1)
    if key = "down" and m.keyRow < m.rows.Count() - 1 then moveKeyboardVertical(1)
end sub

sub moveKeyboardVertical(direction as Integer)
    targetX = keyCenterX(m.keyRow, m.keyCol)
    m.keyRow = m.keyRow + direction
    m.keyCol = nearestKeyColForX(m.keyRow, targetX)
end sub

function keyCenterX(row as Integer, col as Integer) as Integer
    keyW = m.keyW
    if row = 2 then keyW = Int((m.contentW - (9 * m.keyGap)) / 10)
    if row = 3 then keyW = Int((m.contentW - (3 * m.keyGap)) / 4)
    return Int((col * (keyW + m.keyGap)) + (keyW / 2))
end function

function nearestKeyColForX(row as Integer, targetX as Integer) as Integer
    bestCol = 0
    bestDistance = Abs(keyCenterX(row, 0) - targetX)
    for c = 1 to m.rows[row].Count() - 1
        distance = Abs(keyCenterX(row, c) - targetX)
        if distance < bestDistance then
            bestDistance = distance
            bestCol = c
        end if
    end for
    return bestCol
end function

function nearestPosterIndexForKeyCol(col as Integer) as Integer
    if m.results.Count() <= 0 then return 0
    targetX = keyCenterX(0, col)
    bestIndex = m.resultOffset
    bestDistance = Abs(posterCenterX(0) - targetX)
    visibleCount = getVisibleResultCount()
    for i = 1 to visibleCount - 1
        distance = Abs(posterCenterX(i) - targetX)
        if distance < bestDistance then
            bestDistance = distance
            bestIndex = m.resultOffset + i
        end if
    end for
    return bestIndex
end function

function posterCenterX(index as Integer) as Integer
    return Int((index * (m.posterW + m.posterGap)) + (m.posterW / 2))
end function

sub activate()
    if m.focusArea = "posters" and m.results.Count() > 0 then
        m.top.movieSelected = m.results[m.selectedResultIndex]
        return
    end if

    key = m.rows[m.keyRow][m.keyCol]
    if key = "ESPAÇO" then
        m.query = m.query + " "
    else if key = "APAGAR" then
        if Len(m.query) > 0 then m.query = Left(m.query, Len(m.query) - 1)
    else if key = "LIMPAR" then
        m.query = ""
    else if key = "FECHAR" then
        m.top.backRequested = true
    else
        m.query = m.query + key
    end if
    m.queryLabel.text = "Buscar: " + m.query
    scheduleFilter()
end sub

sub scheduleFilter()
    m.pendingQuery = m.query
    m.debounceTimer.control = "stop"
    m.debounceTimer.control = "start"
end sub

sub onDebounceTimerFire()
    m.query = m.pendingQuery
    applyFilter()
end sub

sub updateFocus()
    for r = 0 to m.keyNodes.Count() - 1
        for c = 0 to m.keyNodes[r].Count() - 1
            focused = m.focusArea = "keyboard" and r = m.keyRow and c = m.keyCol
            if focused then
                m.keyNodes[r][c].bg.color = "#2F80ED"
                m.keyNodes[r][c].label.color = "#FFFFFF"
            else
                m.keyNodes[r][c].bg.color = "#101A2C"
                m.keyNodes[r][c].label.color = "#EAF2FF"
            end if
        end for
    end for
    for i = 0 to m.posterNodes.Count() - 1
        visibleIndex = m.selectedResultIndex - m.resultOffset
        focused = m.focusArea = "posters" and i = visibleIndex
        if focused then m.posterNodes[i].bg.color = "#2F80ED" else m.posterNodes[i].bg.color = "#101827"
    end for
end sub

function normalizeArray(value as Dynamic) as Object
    if value <> invalid and Type(value) = "roArray" then return value
    return []
end function

function normalizeText(value as Dynamic) as String
    text = LCase(value.ToStr().Trim())
    repl = { "á":"a", "à":"a", "â":"a", "ã":"a", "é":"e", "ê":"e", "í":"i", "ó":"o", "ô":"o", "õ":"o", "ú":"u", "ç":"c", "-":" ", ".":" ", "_":" " }
    for each k in repl : text = text.Replace(k, repl[k]) : end for
    while Instr(1, text, "  ") > 0 : text = text.Replace("  ", " ") : end while
    return text.Trim()
end function

function prefixMatchRank(title as Dynamic, needle as String) as Integer
    if needle = "" then return 1
    words = normalizeText(title).Tokenize(" ")
    for i = 0 to words.Count() - 1
        word = words[i]
        if Len(word) >= Len(needle) and Left(word, Len(needle)) = needle then
            if i = 0 then return 1
            if i = 1 then return 2
            return 3
        end if
    end for
    return 0
end function

sub setCatalogLoading(isLoading as Boolean)
    m.catalogLoading = isLoading
    updateSearchLoadingMessage()
end sub

sub updateSearchLoadingMessage()
    if m.catalogLoading = true then
        m.messageLabel.text = "Buscando mais resultados..."
    else
        m.messageLabel.text = ""
    end if
end sub

function getMovieName(movie as Dynamic) as String
    if movie = invalid then return "Sem nome"
    if movie.name <> invalid and movie.name.ToStr().Trim() <> "" then return movie.name.ToStr()
    if movie.title <> invalid and movie.title.ToStr().Trim() <> "" then return movie.title.ToStr()
    return "Sem nome"
end function

function getMovieImage(movie as Dynamic) as String
    if movie = invalid then return ""
    key = getMovieCacheKey(movie)
    if key <> "" and m.posterUriCache[key] <> invalid then return m.posterUriCache[key]

    uri = ""
    if movie.stream_icon <> invalid and movie.stream_icon.ToStr().Trim() <> "" then uri = movie.stream_icon.ToStr()
    if uri = "" and movie.cover <> invalid and movie.cover.ToStr().Trim() <> "" then uri = movie.cover.ToStr()
    if uri = "" and movie.poster <> invalid and movie.poster.ToStr().Trim() <> "" then uri = movie.poster.ToStr()
    uri = normalizeMovieCardImageUri(uri)
    if key <> "" then m.posterUriCache[key] = uri
    return uri
end function

sub scheduleVisiblePosterLoads()
    if m.posterLoadTimer = invalid then return
    m.posterLoadTimer.control = "stop"
    m.posterLoadTimer.control = "start"
end sub

sub onPosterLoadTimerFire()
    for each node in m.posterNodes
        if node.poster <> invalid and node.movie <> invalid then node.poster.uri = getMovieImage(node.movie)
    end for
end sub

function getMovieCacheKey(movie as Dynamic) as String
    if movie = invalid then return ""
    if movie.stream_id <> invalid then return "stream_" + movie.stream_id.ToStr()
    if movie.id <> invalid then return "id_" + movie.id.ToStr()
    return getMovieName(movie)
end function

function normalizeMovieCardImageUri(uri as Dynamic) as String
    if uri = invalid then return ""
    value = uri.ToStr().Trim()
    if value = "" then return ""
    value = value.Replace("/w780/", "/w185/")
    value = value.Replace("/w500/", "/w185/")
    value = value.Replace("/original/", "/w185/")
    return value
end function

function limitMovieBatch(items as Object, maxItems as Integer) as Object
    limited = []
    if items = invalid then return limited
    for each item in items
        if limited.Count() >= maxItems then exit for
        limited.Push(item)
    end for
    return limited
end function
