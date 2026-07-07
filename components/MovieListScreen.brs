sub Init()
    m.background = m.top.FindNode("background")
    m.searchBar = m.top.FindNode("searchBar")
    m.searchLabel = m.top.FindNode("searchLabel")
    m.leftPanel = m.top.FindNode("leftPanel")
    m.divider = m.top.FindNode("divider")
    m.categoriesTitle = m.top.FindNode("categoriesTitle")
    m.subtitle = m.top.FindNode("subtitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.categoriesGroup = m.top.FindNode("categoriesGroup")
    m.moviesGrid = m.top.FindNode("moviesGrid")
    m.hintLabel = m.top.FindNode("hintLabel")
    m.searchEntry = { isSearch: true, category_name: "PESQUISAR", name: "PESQUISAR" }
    m.favoritesEntry = { isFavorites: true, category_name: "FAVORITOS", name: "FAVORITOS" }
    m.recentEntry = { isRecent: true, category_name: "ÚLTIMOS ASSISTIDOS", name: "ÚLTIMOS ASSISTIDOS" }
    m.categories = [m.searchEntry, m.favoritesEntry, m.recentEntry] : m.movies = [] : m.allMovie = []
    m.categoryNodes = [] : m.categoryRefs = []
    m.movieNodes = [] : m.movieRefs = [] : m.preloadPosters = []
    m.batchSize = 60 : m.loadedMovieCount = 0
    m.posterPlaceholderUri = "" : m.posterUriCache = {}
    m.posterLoadTimer = CreateObject("roSGNode", "Timer")
    m.posterLoadTimer.duration = 0.05
    m.posterLoadTimer.repeat = false
    m.posterLoadTimer.ObserveField("fire", "onPosterLoadTimerFire")
    m.selectedCategoryIndex = 0 : m.firstVisibleCategoryIndex = 0
    m.selectedMovieIndex = 0 : m.firstVisibleMovieIndex = 0 : m.activePane = "categories"
    configureLayout()
end sub

sub configureLayout()
    r = getDisplayResolution() : w = r.width : h = r.height
    m.margin = 48 : if h <= 720 then m.margin = 32
    m.searchH = 76 : m.footerH = 46
    m.panelY = m.searchH : m.panelH = h - m.searchH - m.footerH
    m.leftW = 310 : if w <= 1280 then m.leftW = 250
    m.gridX = m.margin + m.leftW + 28 : m.gridY = m.panelY + 34
    m.gridW = w - m.gridX - m.margin : m.gridH = m.panelH - 54
    m.categoryX = m.margin + 18 : m.categoryY = m.panelY + 72
    m.categoryW = m.leftW - 36 : m.categoryItemH = 52
    m.posterW = 178 : m.posterH = 264
    m.posterGapX = 56 : m.posterGapY = 54
    m.titleOffsetY = 10 : m.titleH = 42
    if h <= 720 then m.posterW = 120 : m.posterH = 178 : m.posterGapX = 32 : m.posterGapY = 24 : m.titleOffsetY = 6 : m.titleH = 30 : m.categoryItemH = 44
    m.columns = Int((m.gridW + m.posterGapX) / (m.posterW + m.posterGapX)) : if m.columns < 1 then m.columns = 1
    if m.columns > 5 then m.columns = 5
    if h <= 720 and m.columns > 4 then m.columns = 4
    if m.columns > 1 then m.posterGapX = Int((m.gridW - (m.columns * m.posterW)) / (m.columns - 1))
    if m.posterGapX < 24 then m.posterGapX = 24
    m.itemH = m.posterH + m.titleOffsetY + m.titleH + m.posterGapY
    m.rows = 2
    m.visibleItemCount = m.columns * m.rows
    if m.visibleItemCount > 10 then m.visibleItemCount = 10
    m.visibleCategoryCount = Int((m.panelH - 90) / m.categoryItemH) : if m.visibleCategoryCount < 1 then m.visibleCategoryCount = 1
    m.background.width = w : m.background.height = h
    m.searchBar.width = w : m.searchBar.height = m.searchH
    m.searchLabel.translation = [m.margin, 0] : m.searchLabel.width = w - (m.margin * 2) : m.searchLabel.height = m.searchH : m.searchLabel.font = "font:MediumSystemFont"
    m.leftPanel.translation = [m.margin, m.panelY] : m.leftPanel.width = m.leftW : m.leftPanel.height = m.panelH
    m.divider.translation = [m.margin + m.leftW, m.panelY] : m.divider.width = 2 : m.divider.height = m.panelH
    m.categoriesTitle.translation = [m.margin + 18, m.panelY + 24] : m.categoriesTitle.font = "font:MediumBoldSystemFont"
    m.subtitle.translation = [m.gridX, m.panelY + 22] : m.subtitle.width = m.gridW : m.subtitle.font = "font:SmallSystemFont"
    m.statusLabel.translation = [m.gridX, m.gridY + Int(m.gridH / 2)] : m.statusLabel.width = m.gridW : m.statusLabel.font = "font:MediumSystemFont"
    m.categoriesGroup.translation = [m.categoryX, m.categoryY]
    m.moviesGrid.translation = [m.gridX, m.gridY]
    m.hintLabel.translation = [0, h - 34] : m.hintLabel.width = w : m.hintLabel.font = "font:SmallSystemFont"
end sub

sub show(category as Dynamic)
    if category <> invalid then syncSelectedCategory(category)
    if m.activePane = "" then m.activePane = "categories"
    renderCategories() : renderGrid() : updateFocus()
    m.top.visible = true : m.top.SetFocus(true)
end sub

sub focusCategories()
    m.activePane = "categories"
    updateFocus()
end sub

sub focusSearchCategory()
    m.activePane = "categories"
    m.selectedCategoryIndex = 0
    m.firstVisibleCategoryIndex = 0
    updateCategoryWindow()
    renderCategories()
    updateFocus()
end sub

sub hide()
    m.top.visible = false
end sub

sub resetSelection()
    m.selectedCategoryIndex = 0 : m.firstVisibleCategoryIndex = 0 : resetGridSelection()
    m.activePane = "categories"
end sub

sub resetGridSelection()
    m.selectedMovieIndex = 0 : m.firstVisibleMovieIndex = 0
    resetGridFocusToFirstItem()
end sub

sub setCategories(categories as Object)
    m.categories = getFixedCategories()
    for each category in normalizeArray(categories)
        m.categories.Push(category)
    end for
    renderCategories() : updateFocus()
end sub

function getFixedCategories() as Object
    return [m.searchEntry, m.favoritesEntry, m.recentEntry]
end function

function isSearchEntry(category as Dynamic) as Boolean
    return category <> invalid and category.isSearch = true
end function

sub setLoading(isLoading as Boolean)
    clearGridNodes()
    if isLoading then m.statusLabel.text = "Carregando filmes..." else m.statusLabel.text = ""
end sub

sub setMovies(items as Object)
    m.allMovie = normalizeArray(items)
    m.loadedMovieCount = 0
    m.movies = []
    if m.allMovie.Count() = 0 then showMessage("Nenhum item foi encontrado nesta categoria.") : return
    appendMovieBatch()
    m.statusLabel.text = ""
    resetGridSelection()
    m.activePane = "grid"
    renderGrid()
    updateFocus()
end sub

sub showMessage(message as String)
    clearGridNodes() : m.movies = [] : m.loadedMovieCount = 0 : resetGridSelection()
    m.statusLabel.color = "#FFCC66" : m.statusLabel.text = message
end sub

function normalizeArray(items as Dynamic) as Object
    if items = invalid then return []
    if Type(items) = "roArray" then return items
    return []
end function

sub renderCategories()
    clearCategoryNodes()
    if m.categories.Count() = 0 then return
    updateCategoryWindow()
    lastIndex = m.firstVisibleCategoryIndex + m.visibleCategoryCount - 1
    if lastIndex >= m.categories.Count() then lastIndex = m.categories.Count() - 1
    for visualIndex = 0 to lastIndex - m.firstVisibleCategoryIndex
        realIndex = m.firstVisibleCategoryIndex + visualIndex
        node = createCategoryItem(m.categories[realIndex], visualIndex, realIndex)
        m.categoriesGroup.AppendChild(node) : m.categoryNodes.Push(node) : m.categoryRefs.Push(m.lastCategoryRefs)
    end for
end sub

function createCategoryItem(category as Object, visibleIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group") : item.translation = [0, visibleIndex * m.categoryItemH]
    bg = CreateObject("roSGNode", "Rectangle") : bg.id = "itemBackground" : bg.width = m.categoryW : bg.height = m.categoryItemH - 8 : bg.color = "#111827" : bg.opacity = 0.0
    label = CreateObject("roSGNode", "Label") : label.id = "itemLabel" : label.translation = [14, 0] : label.width = m.categoryW - 24 : label.height = m.categoryItemH - 8 : label.vertAlign = "center" : label.font = "font:SmallSystemFont" : label.color = "#C9D4E5" : label.text = getCategoryName(category)
    item.AppendChild(bg) : item.AppendChild(label) : m.lastCategoryRefs = { background: bg, label: label } : return item
end function

sub renderGrid()
    ensureGridCards()
    updateGridCards()
end sub

sub ensureGridCards()
    if m.movieNodes.Count() = m.visibleItemCount then return
    clearGridNodes()
    for visualIndex = 0 to m.visibleItemCount - 1
        node = createPosterItem(invalid, visualIndex, -1)
        m.moviesGrid.AppendChild(node)
        m.movieNodes.Push(node)
        m.movieRefs.Push(m.lastMovieRefs)
    end for
end sub

sub updateGridCards()
    if m.movies.Count() = 0 then
        for each node in m.movieNodes
            node.visible = false
        end for
        m.moviesGrid.visible = false
        return
    end if
    updateGridWindow()
    for visualIndex = 0 to m.movieNodes.Count() - 1
        realIndex = m.firstVisibleMovieIndex + visualIndex
        refs = m.movieRefs[visualIndex]
        node = m.movieNodes[visualIndex]
        if realIndex < m.movies.Count() then
            itemData = m.movies[realIndex]
            node.visible = true
            refs.itemData = itemData : refs.absoluteIndex = realIndex
            refs.label.text = getMovieName(itemData)
            refs.poster.uri = m.posterPlaceholderUri
        else
            node.visible = false
            refs.itemData = invalid : refs.absoluteIndex = -1
            refs.label.text = "" : refs.poster.uri = m.posterPlaceholderUri
        end if
    end for
    m.moviesGrid.visible = true
    scheduleVisiblePosterLoads()
end sub

sub ensurePreloadPosters(maxCount as Integer)
    if m.preloadPosters = invalid then m.preloadPosters = []
    while m.preloadPosters.Count() < maxCount
        poster = CreateObject("roSGNode", "Poster")
        poster.width = 1 : poster.height = 1
        poster.opacity = 0.0 : poster.visible = false
        poster.loadDisplayMode = "scaleToFill"
        poster.uri = m.posterPlaceholderUri
        m.moviesGrid.AppendChild(poster)
        m.preloadPosters.Push(poster)
    end while
end sub

sub updatePreloadPosters()
    maxPreload = 10
    ensurePreloadPosters(maxPreload)
    startIndex = m.firstVisibleMovieIndex + m.visibleItemCount
    for i = 0 to m.preloadPosters.Count() - 1
        uri = ""
        itemIndex = startIndex + i
        if i < maxPreload and itemIndex < m.movies.Count() then uri = getMovieCover(m.movies[itemIndex])
        if uri <> "" then m.preloadPosters[i].uri = uri else m.preloadPosters[i].uri = m.posterPlaceholderUri
    end for
end sub

function createPosterItem(itemData as Dynamic, visualIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group") : col = visualIndex mod m.columns : row = Int(visualIndex / m.columns)
    item.translation = [col * (m.posterW + m.posterGapX), row * m.itemH]
    bg = CreateObject("roSGNode", "Rectangle") : bg.id = "posterFocus" : bg.translation = [-6, -6] : bg.width = m.posterW + 12 : bg.height = m.posterH + 12 : bg.color = "#063B66" : bg.opacity = 0.0
    poster = CreateObject("roSGNode", "Poster") : poster.id = "poster" : poster.width = m.posterW : poster.height = m.posterH : poster.loadDisplayMode = "scaleToFill" : poster.uri = m.posterPlaceholderUri
    label = CreateObject("roSGNode", "Label") : label.id = "itemLabel" : label.translation = [0, m.posterH + m.titleOffsetY] : label.width = m.posterW : label.height = m.titleH : label.font = "font:SmallSystemFont" : label.color = "#DDE6F3" : label.text = getMovieName(itemData) : label.horizAlign = "center" : label.vertAlign = "top"
    item.AppendChild(bg) : item.AppendChild(poster) : item.AppendChild(label)
    m.lastMovieRefs = { background: bg, poster: poster, label: label, itemData: itemData, absoluteIndex: absoluteIndex }
    return item
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then
        if m.activePane = "grid" or m.activePane = "search" then
            m.activePane = "categories" : updateFocus()
        else
            m.top.backRequested = true
        end if
        return true
    end if
    if key = "left" then
        if m.activePane = "grid" then
            if (m.selectedMovieIndex mod m.columns) > 0 then
                moveGrid(-1, 0)
            else
                m.activePane = "categories" : updateFocus()
            end if
        else if m.activePane = "search" then
            m.activePane = "categories" : updateFocus()
        end if
        return true
    end if
    if key = "right" then
        if m.activePane = "categories" or m.activePane = "search" then
            if m.movies.Count() > 0 then m.activePane = "grid" : updateFocus()
        else
            if (m.selectedMovieIndex mod m.columns) < m.columns - 1 and m.selectedMovieIndex < m.movies.Count() - 1 then moveGrid(1, 0)
        end if
        return true
    end if
    if key = "up" then
        if m.activePane = "categories" then
            moveCategory(-1)
        else if m.activePane = "grid" then
            moveGrid(0, -1)
        end if
        return true
    end if
    if key = "down" then
        if m.activePane = "search" then
            m.activePane = "categories" : updateFocus()
        else if m.activePane = "categories" then
            moveCategory(1)
        else
            moveGrid(0, 1)
        end if
        return true
    end if
    if key = "options" then
        if m.movies.Count() > 0 then m.top.movieFavoriteToggled = m.movies[m.selectedMovieIndex]
        return true
    end if
    if key = "OK" then
        if m.activePane = "search" then
            m.top.searchRequested = true
        else if m.activePane = "categories" then
            if m.categories.Count() > 0 then
                if isSearchEntry(m.categories[m.selectedCategoryIndex]) then
                    m.top.searchRequested = true
                else
                    m.top.categorySelected = m.categories[m.selectedCategoryIndex]
                end if
            end if
        else if m.movies.Count() > 0 then
            m.top.movieSelected = m.movies[m.selectedMovieIndex]
        end if
        return true
    end if
    return false
end function

sub moveCategory(direction as Integer)
    if m.categories.Count() = 0 then return
    oldSelected = m.selectedCategoryIndex
    oldFirst = m.firstVisibleCategoryIndex
    m.selectedCategoryIndex = m.selectedCategoryIndex + direction
    updateCategoryWindow()
    if oldSelected <> m.selectedCategoryIndex or oldFirst <> m.firstVisibleCategoryIndex then renderCategories()
    updateFocus()
end sub

sub moveGrid(dx as Integer, dy as Integer)
    if m.movies.Count() = 0 then return
    oldSelected = m.selectedMovieIndex
    oldFirst = m.firstVisibleMovieIndex
    targetIndex = m.selectedMovieIndex + (dy * m.columns) + dx
    if targetIndex >= m.movies.Count() - m.columns then appendMovieBatch()
    m.selectedMovieIndex = targetIndex
    updateGridWindow()
    appendMovieBatchIfNeeded()
    if oldFirst <> m.firstVisibleMovieIndex then updateGridCards()
    updateFocus()
end sub

sub updateCategoryWindow()
    if m.selectedCategoryIndex < 0 then m.selectedCategoryIndex = 0
    if m.selectedCategoryIndex >= m.categories.Count() then m.selectedCategoryIndex = m.categories.Count() - 1
    if m.firstVisibleCategoryIndex < 0 then m.firstVisibleCategoryIndex = 0
    if m.selectedCategoryIndex < m.firstVisibleCategoryIndex then m.firstVisibleCategoryIndex = m.selectedCategoryIndex
    if m.selectedCategoryIndex >= m.firstVisibleCategoryIndex + m.visibleCategoryCount then m.firstVisibleCategoryIndex = m.selectedCategoryIndex - m.visibleCategoryCount + 1
end sub

sub updateGridWindow()
    if m.movies.Count() = 0 then
        m.selectedMovieIndex = 0
        m.firstVisibleMovieIndex = 0
        return
    end if
    if m.selectedMovieIndex < 0 then m.selectedMovieIndex = 0
    if m.selectedMovieIndex >= m.movies.Count() then m.selectedMovieIndex = m.movies.Count() - 1
    if m.firstVisibleMovieIndex < 0 then m.firstVisibleMovieIndex = 0

    selectedRow = Int(m.selectedMovieIndex / m.columns)
    firstVisibleRow = Int(m.firstVisibleMovieIndex / m.columns)
    if selectedRow < firstVisibleRow then
        m.firstVisibleMovieIndex = selectedRow * m.columns
    else if selectedRow >= firstVisibleRow + m.rows then
        m.firstVisibleMovieIndex = (selectedRow - m.rows + 1) * m.columns
    end if

    maxFirstRow = Int((m.movies.Count() - 1) / m.columns) - m.rows + 1
    if maxFirstRow < 0 then maxFirstRow = 0
    maxFirst = maxFirstRow * m.columns
    if m.firstVisibleMovieIndex > maxFirst then m.firstVisibleMovieIndex = maxFirst
end sub

sub updateMovieFocus()
    ensureSelectedMovieVisible()

    for i = 0 to m.movieNodes.Count() - 1
        realIndex = m.firstVisibleMovieIndex + i
        refs = m.movieRefs[i]
        if refs.background <> invalid then refs.background.opacity = 0.0
        if refs.label <> invalid then refs.label.color = "#DDE6F3"
        if realIndex = m.selectedMovieIndex then
            if refs.background <> invalid then
                refs.background.opacity = 1.0
                if m.activePane = "grid" then refs.background.color = "#0A6FB5" else refs.background.color = "#063B66"
            end if
            if refs.label <> invalid and m.activePane = "grid" then refs.label.color = "#FFFFFF"
        end if
        if realIndex = m.selectedMovieIndex and m.activePane = "grid" then m.movieNodes[i].scale = [1.04, 1.04] else m.movieNodes[i].scale = [1.0, 1.0]
    end for
end sub

sub updateFocus()
    if m.movies.Count() > 0 then ensureSelectedMovieVisible()

    if m.activePane = "search" then
        m.searchBar.color = "#061F36" : m.searchLabel.color = "#FFFFFF"
    else
        m.searchBar.color = "#101722" : m.searchLabel.color = "#DDE6F3"
    end if
    for i = 0 to m.categoryNodes.Count() - 1
        realIndex = m.firstVisibleCategoryIndex + i
        refs = m.categoryRefs[i]
        if refs.background <> invalid then refs.background.opacity = 0.0
        if refs.label <> invalid then refs.label.color = "#C9D4E5"
        if realIndex = m.selectedCategoryIndex then
            if refs.background <> invalid then
                refs.background.opacity = 1.0
                refs.background.color = "#061F36"
            end if
            if refs.label <> invalid then refs.label.color = "#FFFFFF"
        end if
        if realIndex = m.selectedCategoryIndex and m.activePane = "categories" then m.categoryNodes[i].scale = [1.03, 1.03] else m.categoryNodes[i].scale = [1.0, 1.0]
    end for
    updateMovieFocus()
    m.top.SetFocus(true)
end sub

sub resetGridFocusToFirstItem()
    m.selectedMovieIndex = 0
    m.firstVisibleMovieIndex = 0
end sub

sub ensureSelectedMovieVisible()
    if m.movies.Count() = 0 then return

    updateGridWindow()
    visibleIndex = m.selectedMovieIndex - m.firstVisibleMovieIndex
    if visibleIndex < 0 or visibleIndex >= m.movieNodes.Count() then
        m.firstVisibleMovieIndex = m.selectedMovieIndex
        updateGridWindow()
        renderGrid()
    end if
end sub

function getState() as Object
    return {
        selectedCategoryIndex: m.selectedCategoryIndex,
        firstVisibleCategoryIndex: m.firstVisibleCategoryIndex,
        selectedIndex: m.selectedMovieIndex,
        firstVisibleRow: Int(m.firstVisibleMovieIndex / m.columns),
        activePane: m.activePane,
        movies: m.movies,
        allMovies: m.allMovie,
        loadedMovieCount: m.loadedMovieCount
    }
end function

sub restoreState(state as Dynamic)
    if state = invalid then return
    if state.allMovies <> invalid then m.allMovie = normalizeArray(state.allMovies)
    if state.movies <> invalid then m.movies = normalizeArray(state.movies)
    if state.loadedMovieCount <> invalid then m.loadedMovieCount = state.loadedMovieCount else m.loadedMovieCount = m.movies.Count()
    if state.selectedCategoryIndex <> invalid then m.selectedCategoryIndex = state.selectedCategoryIndex
    if state.firstVisibleCategoryIndex <> invalid then m.firstVisibleCategoryIndex = state.firstVisibleCategoryIndex
    if state.selectedIndex <> invalid then m.selectedMovieIndex = state.selectedIndex
    if state.firstVisibleRow <> invalid then m.firstVisibleMovieIndex = state.firstVisibleRow * m.columns
    if state.activePane <> invalid then m.activePane = state.activePane else m.activePane = "grid"
    updateCategoryWindow() : updateGridWindow()
    renderCategories() : renderGrid()
    updateFocus()
end sub

function getSelectedIndex() as Integer
    return m.selectedMovieIndex
end function

function getFirstVisibleIndex() as Integer
    return m.firstVisibleMovieIndex
end function

sub restoreMovieSelection(selectedIndex as Integer, firstVisibleIndex as Integer)
    m.selectedMovieIndex = selectedIndex
    m.firstVisibleMovieIndex = firstVisibleIndex
    m.activePane = "grid"
    updateGridWindow()
    renderGrid()
    updateFocus()
end sub

sub syncSelectedCategory(category as Dynamic)
    id = getCategoryId(category)
    for i = 0 to m.categories.Count() - 1
        if getCategoryId(m.categories[i]) = id then m.selectedCategoryIndex = i : exit for
    end for
end sub

sub clearCategoryNodes()
    while m.categoriesGroup.GetChildCount() > 0
        m.categoriesGroup.RemoveChildIndex(0)
    end while
    m.categoryNodes = []
    m.categoryRefs = []
end sub

sub clearGridNodes()
    if m.posterLoadTimer <> invalid then m.posterLoadTimer.control = "stop"
    for each refs in m.movieRefs
        if refs.poster <> invalid then refs.poster.uri = m.posterPlaceholderUri
    end for
    for each poster in m.preloadPosters
        if poster <> invalid then poster.uri = m.posterPlaceholderUri
    end for
    while m.moviesGrid.GetChildCount() > 0
        m.moviesGrid.RemoveChildIndex(0)
    end while
    m.moviesGrid.visible = false
    m.movieNodes = []
    m.movieRefs = []
    m.preloadPosters = []
end sub

function getCategoryId(category as Dynamic) as String
    if category = invalid then return ""
    if category.category_id <> invalid then return category.category_id.ToStr()
    if category.id <> invalid then return category.id.ToStr()
    return ""
end function

function getCategoryName(category as Dynamic) as String
    if category = invalid then return "Categoria"
    if category.category_name <> invalid and category.category_name.ToStr().Trim() <> "" then return category.category_name.ToStr()
    if category.name <> invalid and category.name.ToStr().Trim() <> "" then return category.name.ToStr()
    return "Categoria"
end function

function getMovieName(item as Dynamic) as String
    if item = invalid then return "Filme sem nome"
    if item.name <> invalid and item.name.ToStr().Trim() <> "" then return item.name.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return "Filme sem nome"
end function

sub appendMovieBatch()
    if m.allMovie = invalid then return
    nextLimit = m.loadedMovieCount + m.batchSize
    if nextLimit > m.allMovie.Count() then nextLimit = m.allMovie.Count()
    if nextLimit <= m.loadedMovieCount then return
    for i = m.loadedMovieCount to nextLimit - 1
        m.movies.Push(m.allMovie[i])
    end for
    m.loadedMovieCount = nextLimit
end sub

sub appendMovieBatchIfNeeded()
    if m.allMovie = invalid or m.loadedMovieCount >= m.allMovie.Count() then return
    if m.selectedMovieIndex >= m.movies.Count() - (m.columns * 2) then appendMovieBatch()
end sub

function getMovieLogTitle(item as Dynamic) as String
    return getMovieName(item)
end function

function getMovieCover(item as Dynamic) as String
    if item = invalid then return ""
    key = getMovieCacheKey(item)
    if key <> "" and m.posterUriCache[key] <> invalid then return m.posterUriCache[key]

    uri = ""
    if item.stream_icon <> invalid and item.stream_icon.ToStr().Trim() <> "" then uri = item.stream_icon.ToStr()
    if uri = "" and item.cover <> invalid and item.cover.ToStr().Trim() <> "" then uri = item.cover.ToStr()
    if uri = "" and item.movie_image <> invalid and item.movie_image.ToStr().Trim() <> "" then uri = item.movie_image.ToStr()
    if uri = "" and item.logo <> invalid and item.logo.ToStr().Trim() <> "" then uri = item.logo.ToStr()
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
    for each refs in m.movieRefs
        if refs.poster <> invalid and refs.itemData <> invalid then
            refs.poster.uri = getMovieCover(refs.itemData)
        end if
    end for
    updatePreloadPosters()
end sub

function getMovieCacheKey(item as Dynamic) as String
    if item = invalid then return ""
    if item.stream_id <> invalid then return "stream_" + item.stream_id.ToStr()
    if item.id <> invalid then return "id_" + item.id.ToStr()
    return getMovieName(item)
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

function getDisplayResolution() as Object
    d = CreateObject("roDeviceInfo") : s = d.GetDisplaySize()
    return { width: s.w, height: s.h }
end function
