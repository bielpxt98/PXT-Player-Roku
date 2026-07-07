' Minimal Series screen prepared for fixed navigation and the future category list.
sub Init()
    m.top.visible = false
    m.top.SetFocus(false)

    m.selectedIndex = 0
    m.selectedSeriesIndex = 0
    m.firstVisibleSeriesIndex = 0
    m.seriesNodes = []
    m.seriesNodeRefs = []
    m.preloadPosters = []
    m.seriesItems = []
    m.allSeriesItems = []
    m.categories = []
    m.categoryItems = []
    m.firstVisibleCategoryIndex = 0
    m.activePanel = "categories"
    m.fixedItems = ["PESQUISAR", "FAVORITOS"]
    m.previewCache = []
    m.currentCategoryId = ""
    m.isLoading = false

    m.background = m.top.FindNode("background")
    m.overlay = m.top.FindNode("overlay")
    m.panel = m.top.FindNode("panel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.topDivider = m.top.FindNode("topDivider")
    m.categoriesTitleLabel = m.top.FindNode("categoriesTitleLabel")
    m.seriesTitleLabel = m.top.FindNode("seriesTitleLabel")
    m.verticalDivider = m.top.FindNode("verticalDivider")
    m.categoryFocus = m.top.FindNode("categoryFocus")
    m.categoriesGroup = m.top.FindNode("categoriesGroup")
    m.categoryLabelNodes = []
    m.seriesGridGroup = m.top.FindNode("seriesGridGroup")
    m.searchLabel = m.top.FindNode("searchLabel")
    m.favoritesLabel = m.top.FindNode("favoritesLabel")
    m.categoryLabel4 = m.top.FindNode("categoryLabel4")
    m.emptyMessageLabel = m.top.FindNode("emptyMessageLabel")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.bottomDivider = m.top.FindNode("bottomDivider")
    m.helpLabel = m.top.FindNode("helpLabel")

    m.titleLabel.visible = false
    m.topDivider.visible = false
    m.categoriesTitleLabel.font = "font:MediumBoldSystemFont"
    m.seriesTitleLabel.font = "font:SmallSystemFont"
    m.emptyMessageLabel.font = "font:MediumSystemFont"
    m.helpLabel.font = "font:SmallSystemFont"
    m.statusLabel.font = "font:SmallSystemFont"

    m.searchLabel.font = "font:MediumBoldSystemFont"
    m.favoritesLabel.font = "font:MediumSystemFont"
    m.categoryLabel4.font = "font:MediumSystemFont"

    configureLayout()
    ensureNavigationLayoutDefaults()
    updateNavigationState()
end sub

sub configureLayout()
    resolution = getSeriesDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.screenWidth = width
    m.screenHeight = height
    m.margin = 48
    if height <= 720 then m.margin = 32
    m.searchHeight = 76
    m.footerHeight = 46
    m.panelX = m.margin
    m.panelY = m.searchHeight
    m.panelHeight = height - m.searchHeight - m.footerHeight
    m.panelH = m.panelHeight
    m.leftPanelWidth = 310
    if width <= 1280 then m.leftPanelWidth = 250
    m.leftW = m.leftPanelWidth
    m.panelW = m.leftPanelWidth
    m.rightPanelX = m.margin + m.leftPanelWidth
    m.rightX = m.rightPanelX
    m.rightPanelWidth = width - m.rightPanelX - m.margin
    m.rightW = m.rightPanelWidth
    m.categoryX = m.margin + 18
    m.categoryY = m.panelY + 72
    m.categoryWidth = m.leftPanelWidth - 36
    m.itemHeight = 52
    m.focusHeight = 44
    if height <= 720 then
        m.itemHeight = 44
        m.focusHeight = 36
    end if

    m.background.translation = [0, 0]
    m.background.width = width
    m.background.height = height
    m.overlay.translation = [0, 0]
    m.overlay.width = width
    m.overlay.height = height
    m.overlay.opacity = 0.58

    m.panel.translation = [m.margin, m.panelY]
    m.panel.width = m.leftPanelWidth
    m.panel.height = m.panelHeight
    m.panel.color = "#0B111B"
    m.panel.opacity = 0.82

    m.titleLabel.visible = false
    m.topDivider.visible = false

    m.categoriesTitleLabel.text = "Categorias"
    m.categoriesTitleLabel.translation = [m.margin + 18, m.panelY + 24]
    m.categoriesTitleLabel.width = m.leftPanelWidth - 36
    m.categoriesTitleLabel.height = 42

    m.seriesTitleLabel.text = "SÉRIES"
    m.seriesTitleLabel.translation = [m.rightPanelX + 28, m.panelY + 22]
    m.seriesTitleLabel.width = m.rightPanelWidth
    m.seriesTitleLabel.height = 42
    m.seriesTitleLabel.horizAlign = "right"
    m.seriesTitleLabel.color = "#9FAEC4"

    m.verticalDivider.translation = [m.margin + m.leftPanelWidth, m.panelY]
    m.verticalDivider.width = 2
    m.verticalDivider.height = m.panelHeight
    m.verticalDivider.color = "#1D2A3A"
    m.verticalDivider.opacity = 1.0

    m.firstItemY = m.categoryY
    m.categoryFocus.width = m.categoryWidth
    m.categoryFocus.height = m.focusHeight
    m.categoryFocus.translation = [m.categoryX, m.firstItemY]

    updateCategoryItems()
    m.categoriesGroup.translation = [m.categoryX + 14, m.firstItemY]
    m.visibleCategoryCount = Int((m.panelHeight - 92) / m.itemHeight)
    if m.visibleCategoryCount < 3 then m.visibleCategoryCount = 3
    buildCategoryLabels()

    m.gridX = m.rightPanelX + 28
    m.gridY = m.panelY + 34
    m.gridWidth = m.rightPanelWidth
    m.gridBottom = height - m.footerHeight - 34
    configureSeriesGridMetrics()
    m.seriesGridGroup.translation = [m.gridX, m.gridY]

    messageWidth = m.gridWidth
    messageHeight = 164
    messageX = m.gridX
    messageY = m.gridY + Int((m.panelHeight - messageHeight) / 2)
    m.emptyMessageLabel.translation = [messageX, messageY]
    m.emptyMessageLabel.width = messageWidth
    m.emptyMessageLabel.height = messageHeight
    m.statusLabel.translation = [messageX, messageY + messageHeight]
    m.statusLabel.width = messageWidth
    m.statusLabel.height = 56

    m.bottomDivider.visible = false
    m.helpLabel.text = "←/→ alternar painel • OK selecionar • VOLTAR Home"
    m.helpLabel.translation = [0, height - 34]
    m.helpLabel.width = width
    m.helpLabel.height = 34
    m.helpLabel.horizAlign = "center"
    m.helpLabel.color = "#7D8CA3"
end sub

function getSeriesDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()
    return {
        width: displaySize.w,
        height: displaySize.h
    }
end function

sub show()
    configureLayout()
    ensureNavigationLayoutDefaults()
    m.top.visible = true
    m.top.SetFocus(true)
    if m.categories <> invalid and m.categories.Count() > 0 then
        m.selectedIndex = m.fixedItems.Count()
    else
        m.selectedIndex = 0
    end if
    m.firstVisibleCategoryIndex = 0
    m.selectedSeriesIndex = 0
    m.firstVisibleSeriesIndex = 0
    m.seriesNodes = []
    m.seriesNodeRefs = []
    m.preloadPosters = []
    m.activePanel = "categories"
    m.statusLabel.text = ""
    renderSeriesGrid()
    ensureNavigationLayoutDefaults()
    updateNavigationState()
end sub

sub hide()
    m.top.visible = false
    m.top.SetFocus(false)
end sub

sub focusSearchCategory()
    m.activePanel = "categories"
    m.selectedIndex = 0
    m.firstVisibleCategoryIndex = 0
    updateNavigationState()
end sub

sub setSeries(series as Object)
    m.isLoading = false
    if series = invalid or Type(series) <> "roArray" then
        m.allSeriesItems = []
    else
        m.allSeriesItems = series
    end if
    if m.currentCategoryId <> "" then
        m.seriesItems = filterSeriesItems(m.allSeriesItems, m.currentCategoryId)
        if m.seriesItems.Count() = 0 then m.seriesItems = getSeriesPreviewItems(m.currentCategoryId)
    else
        m.seriesItems = m.allSeriesItems
    end if
    m.selectedSeriesIndex = 0
    m.firstVisibleSeriesIndex = 0
    updateSeriesWindow()
    renderSeriesGrid()
    ensureNavigationLayoutDefaults()
    updateNavigationState()
end sub

sub setLoading(isLoading as Boolean)
    m.isLoading = isLoading
    if isLoading = true then
        m.emptyMessageLabel.text = "Carregando séries..."
        m.statusLabel.text = ""
    end if
    renderSeriesGrid()
end sub


sub setPreviewCache(cache as Object)
    if cache = invalid or Type(cache) <> "roArray" then m.previewCache = [] else m.previewCache = cache
end sub


sub setCategories(categories as Object)
    if categories = invalid or Type(categories) <> "roArray" then
        m.categories = []
    else
        m.categories = categories
    end if
    updateCategoryItems()
    updateNavigationState()
end sub

sub updateCategoryItems()
    m.categoryItems = []
    for each item in m.fixedItems
        m.categoryItems.Push({ label: item, fixed: true })
    end for
    if m.categories <> invalid and m.categories.Count() > 0 then
        for each category in m.categories
            m.categoryItems.Push({ label: getCategoryName(category), fixed: false, category: category })
        end for
    end if
    if m.categoryItems.Count() = 0 then
        m.selectedIndex = 0
    else if m.selectedIndex >= m.categoryItems.Count() then
        m.selectedIndex = 0
    end if
    if m.firstVisibleCategoryIndex = invalid then m.firstVisibleCategoryIndex = 0
end sub

sub buildCategoryLabels()
    if m.categoriesGroup = invalid then return
    while m.categoriesGroup.GetChildCount() > 0
        m.categoriesGroup.RemoveChildIndex(0)
    end while
    m.categoryLabelNodes = []
    count = m.visibleCategoryCount
    if count = invalid or count < 1 then count = 10
    for i = 0 to count - 1
        label = CreateObject("roSGNode", "Label")
        label.translation = [0, i * m.itemHeight]
        label.width = m.categoryWidth - 24
        label.height = m.focusHeight
        label.vertAlign = "center"
        label.font = "font:MediumSystemFont"
        label.color = "#B9C4CF"
        m.categoriesGroup.AppendChild(label)
        m.categoryLabelNodes.Push(label)
    end for
end sub

function getCategoryName(category as Dynamic) as String
    if category <> invalid then
        if category.category_name <> invalid then return category.category_name.ToStr()
        if category.name <> invalid then return category.name.ToStr()
    end if
    return "Categoria"
end function

function getCategoryIdValue(category as Dynamic) as String
    if category <> invalid then
        if category.category_id <> invalid then return category.category_id.ToStr()
        if category.id <> invalid then return category.id.ToStr()
    end if
    return ""
end function

sub filterSeriesByCategory(category as Dynamic)
    categoryId = getCategoryIdValue(category)
    m.currentCategoryId = categoryId
    filtered = []
    fullMatches = []
    if categoryId = "" then
        fullMatches = m.allSeriesItems
    else
        fullMatches = filterSeriesItems(m.allSeriesItems, categoryId)
    end if
    if fullMatches.Count() > 0 then
        filtered = fullMatches
    else
        preview = getSeriesPreviewItems(categoryId)
        if preview.Count() > 0 then filtered = preview
        if category <> invalid then m.top.categoryLoadRequested = category
    end if
    m.seriesItems = filtered
    m.selectedSeriesIndex = 0
    m.firstVisibleSeriesIndex = 0
    updateSeriesWindow()
    renderSeriesGrid()
    m.activePanel = "grid"
end sub


sub handleCategoryOk()
    if m.categoryItems = invalid or m.selectedIndex < 0 or m.selectedIndex >= m.categoryItems.Count() then return

    selected = m.categoryItems[m.selectedIndex]
    label = ""
    if selected.label <> invalid then label = selected.label.ToStr()

    if selected.fixed = true then
        if label = "PESQUISAR" then
            m.activePanel = "search"
            m.statusLabel.text = ""
            updateNavigationState()
            m.top.searchRequested = true
            return
        end if

        m.currentCategoryId = ""
        m.isLoading = false
        m.seriesItems = []
        m.selectedSeriesIndex = 0
        m.firstVisibleSeriesIndex = 0
        renderSeriesGrid()
        if label = "FAVORITOS" then
            m.statusLabel.text = "Nenhuma série favorita encontrada."
        else
            m.statusLabel.text = ""
        end if
        updateNavigationState()
        return
    end if

    filterSeriesByCategory(selected.category)
    m.top.categorySelected = selected.category
    m.statusLabel.text = ""
    updateNavigationState()
end sub

sub openSelectedSeries()
    if m.seriesItems = invalid or m.seriesItems.Count() = 0 then return
    if m.selectedSeriesIndex < 0 or m.selectedSeriesIndex >= m.seriesItems.Count() then return
    selectedSeries = m.seriesItems[m.selectedSeriesIndex]
    if selectedSeries <> invalid then m.top.seriesSelected = selectedSeries
end sub

sub ensureNavigationLayoutDefaults()
    if m.panelX = invalid then m.panelX = 0
    if m.firstItemY = invalid then m.firstItemY = 180
    if m.itemHeight = invalid then m.itemHeight = 56
end sub

sub updateNavigationState()
    if m.panelX = invalid or m.firstItemY = invalid or m.itemHeight = invalid then
        return
    end if

    updateCategoryItems()
    buildCategoryLabels()
    labels = m.categoryLabelNodes
    visibleCategoryCount = labels.Count()
    if m.selectedIndex < m.firstVisibleCategoryIndex then m.firstVisibleCategoryIndex = m.selectedIndex
    if m.selectedIndex >= m.firstVisibleCategoryIndex + visibleCategoryCount then m.firstVisibleCategoryIndex = m.selectedIndex - visibleCategoryCount + 1
    maxFirstCategory = m.categoryItems.Count() - visibleCategoryCount
    if maxFirstCategory < 0 then maxFirstCategory = 0
    if m.firstVisibleCategoryIndex > maxFirstCategory then m.firstVisibleCategoryIndex = maxFirstCategory

    focusRow = m.selectedIndex - m.firstVisibleCategoryIndex
    m.categoryFocus.translation = [m.panelX + 32, m.firstItemY + (focusRow * m.itemHeight)]

    for i = 0 to labels.Count() - 1
        itemIndex = m.firstVisibleCategoryIndex + i
        labelText = ""
        isSelected = itemIndex = m.selectedIndex
        if m.categoryItems <> invalid and itemIndex < m.categoryItems.Count() then labelText = m.categoryItems[itemIndex].label
        if isSelected and m.activePanel = "categories" then
            labels[i].text = "> " + labelText
            labels[i].color = "#FFFFFF"
            labels[i].font = "font:MediumBoldSystemFont"
        else
            labels[i].text = "  " + labelText
            labels[i].color = "#B9C4CF"
            labels[i].font = "font:MediumSystemFont"
        end if
    end for

    if m.activePanel = "grid" then
        m.categoryFocus.opacity = 0.35
    else
        m.categoryFocus.opacity = 0.95
    end if
    updateSeriesFocus()
end sub

sub configureSeriesGridMetrics()
    m.seriesColumns = 5
    m.seriesRows = 2
    m.posterWidth = Int((m.gridWidth - (m.seriesColumns - 1) * 28) / m.seriesColumns)
    if m.posterWidth > 184 then m.posterWidth = 184
    if m.posterWidth < 116 then m.posterWidth = 116
    m.posterHeight = Int(m.posterWidth * 1.45)
    m.seriesGapX = 28
    m.seriesGapY = 34
    m.seriesCardWidth = m.posterWidth + 16
    m.seriesCardHeight = m.posterHeight + 62
    if m.gridY + (m.seriesRows * m.seriesCardHeight) + m.seriesGapY > m.gridBottom then
        m.seriesCardHeight = Int((m.gridBottom - m.gridY - m.seriesGapY) / 2)
        m.posterHeight = m.seriesCardHeight - 62
        m.posterWidth = Int(m.posterHeight / 1.45)
        m.seriesCardWidth = m.posterWidth + 16
    end if
end sub

sub renderSeriesGrid()
    ensureSeriesCards()
    updateSeriesCards()
end sub

sub ensureSeriesCards()
    visibleCount = m.seriesColumns * m.seriesRows
    if m.seriesNodes.Count() = visibleCount then return
    clearSeriesNodes()
    for visualIndex = 0 to visibleCount - 1
        node = createSeriesItem(invalid, visualIndex, -1)
        m.seriesGridGroup.AppendChild(node)
        m.seriesNodes.Push(node)
        m.seriesNodeRefs.Push(m.lastSeriesRefs)
    end for
end sub

sub updateSeriesCards()
    if m.seriesItems.Count() = 0 then
        for each node in m.seriesNodes
            node.visible = false
        end for
        m.emptyMessageLabel.visible = true
        if m.isLoading = true then
            m.emptyMessageLabel.text = "Carregando séries..."
        else
            m.emptyMessageLabel.text = "Nenhuma série encontrada."
        end if
        return
    end if
    m.emptyMessageLabel.visible = false
    for visualIndex = 0 to m.seriesNodes.Count() - 1
        itemIndex = m.firstVisibleSeriesIndex + visualIndex
        refs = m.seriesNodeRefs[visualIndex]
        node = m.seriesNodes[visualIndex]
        if itemIndex < m.seriesItems.Count() then
            series = m.seriesItems[itemIndex]
            node.visible = true
            refs.series = series : refs.itemIndex = itemIndex
            refs.poster.uri = resizeTmdbSeriesPoster(getSeriesPoster(series))
            refs.title.text = getSeriesName(series)
        else
            node.visible = false
            refs.series = invalid : refs.itemIndex = -1
            refs.poster.uri = "" : refs.title.text = ""
        end if
    end for
    updateSeriesPreloadPosters()
end sub

sub ensureSeriesPreloadPosters(maxCount as Integer)
    if m.preloadPosters = invalid then m.preloadPosters = []
    while m.preloadPosters.Count() < maxCount
        poster = CreateObject("roSGNode", "Poster")
        poster.width = 1 : poster.height = 1
        poster.opacity = 0.0 : poster.visible = false
        poster.uri = ""
        m.seriesGridGroup.AppendChild(poster)
        m.preloadPosters.Push(poster)
    end while
end sub

sub updateSeriesPreloadPosters()
    maxPreload = 10
    ensureSeriesPreloadPosters(maxPreload)
    visibleCount = m.seriesColumns * m.seriesRows
    startIndex = m.firstVisibleSeriesIndex + visibleCount
    for i = 0 to m.preloadPosters.Count() - 1
        uri = ""
        itemIndex = startIndex + i
        if i < maxPreload and itemIndex < m.seriesItems.Count() then uri = resizeTmdbSeriesPoster(getSeriesPoster(m.seriesItems[itemIndex]))
        m.preloadPosters[i].uri = uri
    end for
end sub

function createSeriesItem(series as Dynamic, visualIndex as Integer, itemIndex as Integer) as Object
    row = Int(visualIndex / m.seriesColumns)
    col = visualIndex - (row * m.seriesColumns)
    item = CreateObject("roSGNode", "Group")
    item.id = "seriesItem" + itemIndex.ToStr()
    item.translation = [col * (m.seriesCardWidth + m.seriesGapX), row * (m.seriesCardHeight + m.seriesGapY)]

    background = CreateObject("roSGNode", "Rectangle")
    background.id = "seriesBackground"
    background.width = m.seriesCardWidth
    background.height = m.seriesCardHeight
    background.color = "#111827"
    background.opacity = 0.88

    poster = CreateObject("roSGNode", "Poster")
    poster.id = "seriesPoster"
    poster.translation = [8, 8]
    poster.width = m.posterWidth
    poster.height = m.posterHeight
    poster.uri = resizeTmdbSeriesPoster(getSeriesPoster(series))

    title = CreateObject("roSGNode", "Label")
    title.id = "seriesName"
    title.translation = [8, m.posterHeight + 12]
    title.width = m.posterWidth
    title.height = 42
    title.color = "#DDE7F0"
    title.font = "font:SmallSystemFont"
    title.wrap = true
    title.maxLines = 2
    title.text = getSeriesName(series)

    item.AppendChild(background)
    item.AppendChild(poster)
    item.AppendChild(title)
    m.lastSeriesRefs = { background: background, poster: poster, title: title, series: series, itemIndex: itemIndex }
    return item
end function

function getSeriesName(series as Dynamic) as String
    if series <> invalid then
        if series.name <> invalid then return series.name.ToStr()
        if series.title <> invalid then return series.title.ToStr()
    end if
    return "Série"
end function

function getSeriesPoster(series as Dynamic) as String
    if series <> invalid then
        if series.cover <> invalid then return series.cover.ToStr()
        if series.series_image <> invalid then return series.series_image.ToStr()
        if series.stream_icon <> invalid then return series.stream_icon.ToStr()
    end if
    return ""
end function

sub moveSeriesFocus(delta as Integer)
    if m.seriesItems.Count() = 0 then return
    nextIndex = m.selectedSeriesIndex + delta
    if nextIndex < 0 then nextIndex = 0
    if nextIndex >= m.seriesItems.Count() then nextIndex = m.seriesItems.Count() - 1
    oldFirst = m.firstVisibleSeriesIndex
    m.selectedSeriesIndex = nextIndex
    updateSeriesWindow()
    if oldFirst <> m.firstVisibleSeriesIndex then updateSeriesCards()
end sub

sub updateSeriesWindow()
    if m.seriesItems.Count() = 0 then
        m.selectedSeriesIndex = 0
        m.firstVisibleSeriesIndex = 0
        return
    end if
    visibleCount = m.seriesColumns * m.seriesRows
    if m.selectedSeriesIndex < m.firstVisibleSeriesIndex then m.firstVisibleSeriesIndex = m.selectedSeriesIndex
    if m.selectedSeriesIndex >= m.firstVisibleSeriesIndex + visibleCount then m.firstVisibleSeriesIndex = m.selectedSeriesIndex - visibleCount + 1
    maxFirst = m.seriesItems.Count() - visibleCount
    if maxFirst < 0 then maxFirst = 0
    if m.firstVisibleSeriesIndex > maxFirst then m.firstVisibleSeriesIndex = maxFirst
end sub

sub updateSeriesFocus()
    for i = 0 to m.seriesNodeRefs.Count() - 1
        realIndex = m.firstVisibleSeriesIndex + i
        refs = m.seriesNodeRefs[i]
        refs.background.color = "#111827"
        refs.background.opacity = 0.88
        refs.title.color = "#DDE7F0"
        if m.activePanel = "grid" and realIndex = m.selectedSeriesIndex then
            refs.background.color = "#0078D7"
            refs.background.opacity = 1.0
            refs.title.color = "#FFFFFF"
        end if
    end for
end sub

sub clearSeriesNodes()
    for each poster in m.preloadPosters
        if poster <> invalid then poster.uri = ""
    end for
    while m.seriesGridGroup.GetChildCount() > 0
        m.seriesGridGroup.RemoveChildIndex(0)
    end while
    m.seriesNodes = []
    m.seriesNodeRefs = []
    m.preloadPosters = []
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press <> true then return false

    if key = "back" then
        m.top.backRequested = true
        return true
    else if key = "up" then
        if m.activePanel = "categories" then
            m.selectedIndex = m.selectedIndex - 1
            if m.categoryItems.Count() = 0 then
                m.selectedIndex = 0
            else if m.selectedIndex < 0 then
                m.selectedIndex = m.categoryItems.Count() - 1
            end if
        else
            moveSeriesFocus(-m.seriesColumns)
        end if
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "down" then
        if m.activePanel = "categories" then
            m.selectedIndex = m.selectedIndex + 1
            if m.categoryItems.Count() = 0 then
                m.selectedIndex = 0
            else if m.selectedIndex >= m.categoryItems.Count() then
                m.selectedIndex = 0
            end if
        else
            moveSeriesFocus(m.seriesColumns)
        end if
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "right" then
        if m.activePanel = "categories" then
            m.activePanel = "grid"
        else
            moveSeriesFocus(1)
        end if
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "left" then
        if m.activePanel = "grid" and (m.selectedSeriesIndex mod m.seriesColumns) > 0 then
            moveSeriesFocus(-1)
        else
            m.activePanel = "categories"
        end if
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "OK" then
        if m.activePanel = "categories" then
            handleCategoryOk()
            return true
        end if

        if m.activePanel = "grid" then
            openSelectedSeries()
            m.statusLabel.text = ""
            updateNavigationState()
            return true
        end if

        return true
    end if

    return false
end function


function getSeriesPreviewItems(categoryId as String) as Object
    if m.previewCache = invalid or Type(m.previewCache) <> "roArray" then return []
    for each preview in m.previewCache
        if preview <> invalid and preview.categoryId <> invalid and preview.categoryId.ToStr() = categoryId and preview.items <> invalid and Type(preview.items) = "roArray" then return preview.items
    end for
    return []
end function


function filterSeriesItems(items as Dynamic, categoryId as String) as Object
    filtered = []
    if items = invalid or Type(items) <> "roArray" then return filtered
    for each series in items
        if series <> invalid and series.category_id <> invalid and series.category_id.ToStr() = categoryId then filtered.Push(series)
    end for
    return filtered
end function


function normalizeRecentSeriesItems(items as Dynamic) as Object
    recent = []
    if items = invalid or Type(items) <> "roArray" then return recent
    for each item in items
        if item <> invalid then
            title = "Episódio"
            if item.title <> invalid then title = item.title.ToStr()
            seriesTitle = "Série"
            if item.seriesTitle <> invalid then seriesTitle = item.seriesTitle.ToStr()
            poster = ""
            if item.poster <> invalid then poster = item.poster.ToStr()
            recent.Push({
                isHistoryEpisode: true,
                name: seriesTitle + " • " + title,
                title: seriesTitle + " • " + title,
                cover: poster,
                series_image: poster,
                series: item.series,
                episode: item.content
            })
        end if
    end for
    return recent
end function


function resizeTmdbSeriesPoster(uri as Dynamic) as String
    if uri = invalid then return ""
    text = uri.ToStr().Trim()
    if text = "" then return ""
    text = text.Replace("/w780/", "/w342/")
    text = text.Replace("/original/", "/w342/")
    return text
end function
