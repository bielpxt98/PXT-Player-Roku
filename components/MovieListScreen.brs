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
    m.movieTitlesGroup = m.top.FindNode("movieTitlesGroup")
    m.hintLabel = m.top.FindNode("hintLabel")
    m.progressiveLoadTimer = m.top.FindNode("progressiveLoadTimer")
    m.progressiveLoadTimer.ObserveField("fire", "onProgressiveLoadTimerFire")
    m.initialRenderLimit = 50 : m.progressiveBatchSize = 25 : m.renderLimit = 50
    m.categories = [] : m.movies = [] : m.allMovie = []
    m.categoryNodes = [] : m.itemNodes = []
    m.selectedCategoryIndex = 0 : m.firstVisibleCategoryIndex = 0
    m.selectedIndex = 0 : m.firstVisibleRow = 0 : m.activePane = "grid"
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
    m.rows = 3
    m.visibleItemCount = m.columns * m.rows
    if m.visibleItemCount > 15 then m.visibleItemCount = 15
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
    m.movieTitlesGroup.translation = [m.gridX, m.gridY]
    m.moviesGrid.itemSize = [m.posterW, m.posterH]
    m.moviesGrid.itemSpacing = [m.posterGapX, m.posterGapY]
    m.moviesGrid.numColumns = m.columns
    m.moviesGrid.numRows = m.rows
    m.hintLabel.translation = [0, h - 34] : m.hintLabel.width = w : m.hintLabel.font = "font:SmallSystemFont"
end sub

sub show(category as Dynamic)
    configureLayout()
    if category <> invalid then syncSelectedCategory(category)
    resetGridSelection()
    renderCategories() : renderGrid() : updateFocus()
    m.top.visible = true : m.top.SetFocus(true)
end sub

sub focusCategories()
    m.activePane = "categories"
    updateFocus()
end sub

sub focusMovies()
    if m.movies.Count() > 0 then
        m.activePane = "grid"
        updateFocus()
    end if
end sub

sub hide()
    m.top.visible = false
end sub

sub resetSelection()
    m.selectedCategoryIndex = 0 : m.firstVisibleCategoryIndex = 0 : resetGridSelection()
end sub

sub resetGridSelection()
    m.selectedIndex = 0 : m.firstVisibleRow = 0
    resetGridFocusToFirstItem()
end sub

sub setCategories(categories as Object)
    m.categories = normalizeArray(categories)
    renderCategories() : updateFocus()
end sub

sub setLoading(isLoading as Boolean)
    if m.progressiveLoadTimer <> invalid then m.progressiveLoadTimer.control = "stop"
    clearGridNodes()
    m.movies = [] : m.allMovie = [] : m.renderLimit = m.initialRenderLimit
    if isLoading then m.statusLabel.text = "Carregando filmes..." else m.statusLabel.text = ""
end sub

sub setMovies(items as Object)
    if m.progressiveLoadTimer <> invalid then m.progressiveLoadTimer.control = "stop"
    clearGridNodes()
    m.statusLabel.text = ""
    m.allMovie = normalizeArray(items) : m.renderLimit = m.initialRenderLimit
    rebuildVisibleMovies()
    if m.movies.Count() = 0 then showMessage("Nenhum item foi encontrado nesta categoria.") : return
    m.statusLabel.text = "" : resetGridFocusToFirstItem() : renderGrid() : updateFocus()
    if m.movies.Count() < m.allMovie.Count() and m.progressiveLoadTimer <> invalid then m.progressiveLoadTimer.control = "start"
end sub

sub onProgressiveLoadTimerFire()
    if m.allMovie = invalid or m.movies.Count() >= m.allMovie.Count() then
        if m.progressiveLoadTimer <> invalid then m.progressiveLoadTimer.control = "stop"
        return
    end if
    m.renderLimit = m.renderLimit + m.progressiveBatchSize
    rebuildVisibleMovies()
    renderGrid() : updateFocus()
end sub

sub rebuildVisibleMovies()
    m.movies = []
    if m.allMovie = invalid then return
    last = m.renderLimit - 1
    if last >= m.allMovie.Count() then last = m.allMovie.Count() - 1
    if last < 0 then return
    for i = 0 to last
        if i >= 0 then m.movies.Push(m.allMovie[i])
    end for
end sub

sub showMessage(message as String)
    clearGridNodes() : m.movies = [] : m.allMovie = [] : resetGridFocusToFirstItem()
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
        m.categoriesGroup.AppendChild(node) : m.categoryNodes.Push(node)
    end for
end sub

function createCategoryItem(category as Object, visibleIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group") : item.translation = [0, visibleIndex * m.categoryItemH]
    bg = CreateObject("roSGNode", "Rectangle") : bg.id = "itemBackground" : bg.width = m.categoryW : bg.height = m.categoryItemH - 8 : bg.color = "#111827" : bg.opacity = 0.35
    label = CreateObject("roSGNode", "Label") : label.id = "itemLabel" : label.translation = [14, 0] : label.width = m.categoryW - 24 : label.height = m.categoryItemH - 8 : label.vertAlign = "center" : label.font = "font:SmallSystemFont" : label.color = "#C9D4E5" : label.text = getCategoryName(category)
    item.AppendChild(bg) : item.AppendChild(label) : return item
end function

sub renderGrid()
    clearGridNodes()
    m.statusLabel.text = ""
    if m.movies.Count() = 0 then return

    content = CreateObject("roSGNode", "ContentNode")
    for each movie in m.movies
        node = content.CreateChild("ContentNode")
        node.title = getMovieName(movie)
        coverUrl = getMovieCover(movie)
        node.HDPosterUrl = coverUrl
        node.SDPosterUrl = coverUrl
        node.url = coverUrl
    end for

    m.moviesGrid.content = content
    m.moviesGrid.visible = true
    resetGridFocusToFirstItem()
    renderMovieTitles()
end sub

function createPosterItem(itemData as Object, visualIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group") : col = visualIndex mod m.columns : row = Int(visualIndex / m.columns)
    item.translation = [col * (m.posterW + m.posterGapX), row * m.itemH]
    bg = CreateObject("roSGNode", "Rectangle") : bg.id = "posterFocus" : bg.translation = [-6, -6] : bg.width = m.posterW + 12 : bg.height = m.posterH + 12 : bg.color = "#063B66" : bg.opacity = 0.0
    poster = CreateObject("roSGNode", "Poster") : poster.id = "poster" : poster.width = m.posterW : poster.height = m.posterH : poster.loadDisplayMode = "scaleToFill" : poster.uri = getMovieCover(itemData)
    label = CreateObject("roSGNode", "Label") : label.id = "itemLabel" : label.translation = [0, m.posterH + m.titleOffsetY] : label.width = m.posterW : label.height = m.titleH : label.font = "font:SmallSystemFont" : label.color = "#DDE6F3" : label.text = getMovieName(itemData) : label.horizAlign = "center" : label.vertAlign = "top"
    item.AppendChild(bg) : item.AppendChild(poster) : item.AppendChild(label) : return item
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
            if (m.selectedIndex mod m.columns) = 0 then
                m.activePane = "categories" : updateFocus()
            else
                moveGrid(-1, 0)
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
            if (m.selectedIndex mod m.columns) < m.columns - 1 and m.selectedIndex < m.movies.Count() - 1 then moveGrid(1, 0)
        end if
        return true
    end if
    if key = "up" then
        if m.activePane = "categories" then
            if m.selectedCategoryIndex = 0 then
                m.activePane = "search" : updateFocus()
            else
                moveCategory(-1)
            end if
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
        if m.movies.Count() > 0 then m.top.movieFavoriteToggled = m.movies[m.selectedIndex]
        return true
    end if
    if key = "OK" then
        if m.activePane = "search" then
            m.top.searchRequested = true
        else if m.activePane = "categories" then
            if m.categories.Count() > 0 then m.top.categorySelected = m.categories[m.selectedCategoryIndex]
        else if m.movies.Count() > 0 then
            m.top.movieSelected = m.movies[m.selectedIndex]
        end if
        return true
    end if
    return false
end function

sub moveCategory(direction as Integer)
    if m.categories.Count() = 0 then return
    m.selectedCategoryIndex = m.selectedCategoryIndex + direction : updateCategoryWindow() : renderCategories() : updateFocus()
end sub

sub moveGrid(dx as Integer, dy as Integer)
    if m.movies.Count() = 0 then return
    m.selectedIndex = m.selectedIndex + (dy * m.columns) + dx : updateGridWindow() : m.moviesGrid.jumpToItem = m.selectedIndex : renderMovieTitles() : updateFocus()
end sub

sub updateCategoryWindow()
    if m.selectedCategoryIndex < 0 then m.selectedCategoryIndex = 0
    if m.selectedCategoryIndex >= m.categories.Count() then m.selectedCategoryIndex = m.categories.Count() - 1
    if m.firstVisibleCategoryIndex < 0 then m.firstVisibleCategoryIndex = 0
    if m.selectedCategoryIndex < m.firstVisibleCategoryIndex then m.firstVisibleCategoryIndex = m.selectedCategoryIndex
    if m.selectedCategoryIndex >= m.firstVisibleCategoryIndex + m.visibleCategoryCount then m.firstVisibleCategoryIndex = m.selectedCategoryIndex - m.visibleCategoryCount + 1
end sub

sub updateGridWindow()
    if m.selectedIndex < 0 then m.selectedIndex = 0
    if m.selectedIndex >= m.movies.Count() then m.selectedIndex = m.movies.Count() - 1
    row = Int(m.selectedIndex / m.columns)
    if row < m.firstVisibleRow then m.firstVisibleRow = row
    if row >= m.firstVisibleRow + m.rows then m.firstVisibleRow = row - m.rows + 1
    if m.firstVisibleRow < 0 then m.firstVisibleRow = 0
end sub

sub updateFocus()
    if m.activePane = "search" then
        m.searchBar.color = "#061F36" : m.searchLabel.color = "#FFFFFF"
    else
        m.searchBar.color = "#101722" : m.searchLabel.color = "#DDE6F3"
    end if
    for i = 0 to m.categoryNodes.Count() - 1
        realIndex = m.firstVisibleCategoryIndex + i : bg = m.categoryNodes[i].FindNode("itemBackground") : label = m.categoryNodes[i].FindNode("itemLabel")
        bg.opacity = 0.0 : label.color = "#C9D4E5"
        if realIndex = m.selectedCategoryIndex then bg.opacity = 1.0 : bg.color = "#0B5CAD" : label.color = "#FFFFFF"
        if realIndex = m.selectedCategoryIndex and m.activePane = "categories" then m.categoryNodes[i].scale = [1.03, 1.03] else m.categoryNodes[i].scale = [1.0, 1.0]
    end for
    m.top.SetFocus(true)
end sub

sub resetGridFocusToFirstItem()
    m.selectedIndex = 0
    m.firstVisibleRow = 0
    if m.moviesGrid <> invalid then
        m.moviesGrid.jumpToItem = 0
    end if
end sub

sub renderMovieTitles()
    clearMovieTitleNodes()
    if m.movies.Count() = 0 then return
    startIndex = m.firstVisibleRow * m.columns
    maxItems = m.columns * m.rows
    for visualIndex = 0 to maxItems - 1
        movieIndex = startIndex + visualIndex
        if movieIndex >= m.movies.Count() then exit for
        col = visualIndex mod m.columns
        row = Int(visualIndex / m.columns)
        label = CreateObject("roSGNode", "Label")
        label.translation = [col * (m.posterW + m.posterGapX), row * (m.posterH + m.posterGapY) + m.posterH + m.titleOffsetY]
        label.width = m.posterW
        label.height = m.titleH
        label.font = "font:SmallSystemFont"
        label.color = "#FFFFFF"
        label.horizAlign = "center"
        label.vertAlign = "top"
        label.maxLines = 1
        label.text = getEllipsizedText(getMovieName(m.movies[movieIndex]), 24)
        m.movieTitlesGroup.AppendChild(label)
    end for
end sub

sub clearMovieTitleNodes()
    if m.movieTitlesGroup = invalid then return
    while m.movieTitlesGroup.GetChildCount() > 0
        m.movieTitlesGroup.RemoveChildIndex(0)
    end while
end sub

function getEllipsizedText(value as String, maxChars as Integer) as String
    if value.Len() <= maxChars then return value
    if maxChars <= 3 then return Left(value, maxChars)
    return Left(value, maxChars - 3) + "..."
end function

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
end sub

sub clearGridNodes()
    clearMovieTitleNodes()
    emptyContent = CreateObject("roSGNode", "ContentNode")
    m.moviesGrid.content = emptyContent
    m.moviesGrid.jumpToItem = 0
    m.moviesGrid.visible = false
    m.itemNodes = []
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

function getMovieLogTitle(item as Dynamic) as String
    return getMovieName(item)
end function

function getMovieCover(item as Dynamic) as String
    if item = invalid then return ""
    if item.stream_icon <> invalid and item.stream_icon.ToStr().Trim() <> "" then return item.stream_icon.ToStr()
    if item.cover <> invalid and item.cover.ToStr().Trim() <> "" then return item.cover.ToStr()
    if item.movie_image <> invalid and item.movie_image.ToStr().Trim() <> "" then return item.movie_image.ToStr()
    if item.logo <> invalid and item.logo.ToStr().Trim() <> "" then return item.logo.ToStr()
    return ""
end function

function getDisplayResolution() as Object
    d = CreateObject("roDeviceInfo") : s = d.GetDisplaySize()
    return { width: s.w, height: s.h }
end function
