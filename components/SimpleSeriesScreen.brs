' Minimal Series screen prepared for fixed navigation and the future category list.
sub Init()
    m.top.visible = false
    m.top.SetFocus(false)

    m.selectedIndex = 0
    m.selectedSeriesIndex = 0
    m.firstVisibleSeriesIndex = 0
    m.seriesNodes = []
    m.seriesNodeRefs = []
    m.seriesItems = []
    m.activePanel = "categories"
    m.fixedItems = ["PESQUISAR", "FAVORITOS", "ÚLTIMOS", "ASSISTIDOS"]

    m.background = m.top.FindNode("background")
    m.panel = m.top.FindNode("panel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.topDivider = m.top.FindNode("topDivider")
    m.categoriesTitleLabel = m.top.FindNode("categoriesTitleLabel")
    m.seriesTitleLabel = m.top.FindNode("seriesTitleLabel")
    m.verticalDivider = m.top.FindNode("verticalDivider")
    m.categoryFocus = m.top.FindNode("categoryFocus")
    m.seriesGridGroup = m.top.FindNode("seriesGridGroup")
    m.searchLabel = m.top.FindNode("searchLabel")
    m.favoritesLabel = m.top.FindNode("favoritesLabel")
    m.recentLabel = m.top.FindNode("recentLabel")
    m.watchedLabel = m.top.FindNode("watchedLabel")
    m.emptyMessageLabel = m.top.FindNode("emptyMessageLabel")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.bottomDivider = m.top.FindNode("bottomDivider")
    m.helpLabel = m.top.FindNode("helpLabel")

    m.titleLabel.font = "font:LargeBoldSystemFont"
    m.categoriesTitleLabel.font = "font:MediumBoldSystemFont"
    m.seriesTitleLabel.font = "font:MediumBoldSystemFont"
    m.emptyMessageLabel.font = "font:MediumSystemFont"
    m.helpLabel.font = "font:SmallSystemFont"
    m.statusLabel.font = "font:SmallSystemFont"

    m.searchLabel.font = "font:MediumBoldSystemFont"
    m.favoritesLabel.font = "font:MediumSystemFont"
    m.recentLabel.font = "font:MediumSystemFont"
    m.watchedLabel.font = "font:MediumSystemFont"

    configureLayout()
    updateNavigationState()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.screenWidth = width
    m.screenHeight = height
    m.safeMarginX = Int(width * 0.055)
    if m.safeMarginX < 48 then m.safeMarginX = 48
    m.safeMarginY = Int(height * 0.055)
    if m.safeMarginY < 36 then m.safeMarginY = 36

    m.titleHeight = 96
    m.footerHeight = 84
    if height <= 720 then
        m.titleHeight = 76
        m.footerHeight = 64
    end if

    m.panelX = m.safeMarginX
    m.panelY = m.safeMarginY
    m.panelWidth = width - (m.safeMarginX * 2)
    m.panelHeight = height - (m.safeMarginY * 2)
    if m.panelWidth < 320 then
        m.panelX = 0
        m.panelWidth = width
    end if
    if m.panelHeight < 240 then
        m.panelY = 0
        m.panelHeight = height
    end if

    m.headerBottomY = m.panelY + m.titleHeight
    m.footerTopY = m.panelY + m.panelHeight - m.footerHeight
    contentHeight = m.footerTopY - m.headerBottomY
    m.leftPanelWidth = Int(m.panelWidth * 0.28)
    if m.leftPanelWidth < 260 then m.leftPanelWidth = 260
    if m.leftPanelWidth > Int(m.panelWidth * 0.36) then m.leftPanelWidth = Int(m.panelWidth * 0.36)
    m.rightPanelX = m.panelX + m.leftPanelWidth
    m.rightPanelWidth = m.panelWidth - m.leftPanelWidth

    m.background.translation = [0, 0]
    m.background.width = width
    m.background.height = height

    m.panel.translation = [m.panelX, m.panelY]
    m.panel.width = m.panelWidth
    m.panel.height = m.panelHeight

    m.titleLabel.translation = [m.panelX, m.panelY]
    m.titleLabel.width = m.panelWidth
    m.titleLabel.height = m.titleHeight

    m.topDivider.translation = [m.panelX, m.headerBottomY]
    m.topDivider.width = m.panelWidth

    titleY = m.headerBottomY + 32
    if height <= 720 then titleY = m.headerBottomY + 20
    m.categoriesTitleLabel.translation = [m.panelX + 42, titleY]
    m.categoriesTitleLabel.width = m.leftPanelWidth - 72
    m.seriesTitleLabel.translation = [m.rightPanelX + 42, titleY]
    m.seriesTitleLabel.width = m.rightPanelWidth - 84

    m.verticalDivider.translation = [m.rightPanelX, m.headerBottomY]
    m.verticalDivider.height = contentHeight

    m.itemHeight = 66
    m.focusHeight = 54
    if height <= 720 then
        m.itemHeight = 54
        m.focusHeight = 46
    end if
    m.firstItemY = titleY + 86
    if m.firstItemY + (m.fixedItems.Count() * m.itemHeight) > m.footerTopY - 20 then
        m.firstItemY = titleY + 58
    end if

    m.categoryFocus.width = m.leftPanelWidth - 76
    m.categoryFocus.height = m.focusHeight
    m.categoryFocus.translation = [m.panelX + 32, m.firstItemY]

    labels = [m.searchLabel, m.favoritesLabel, m.recentLabel, m.watchedLabel]
    for i = 0 to labels.Count() - 1
        labels[i].translation = [m.panelX + 56, m.firstItemY + (i * m.itemHeight) + 6]
        labels[i].width = m.leftPanelWidth - 100
        labels[i].height = m.focusHeight
    end for

    m.gridX = m.rightPanelX + 42
    m.gridY = titleY + 76
    m.gridWidth = m.rightPanelWidth - 84
    m.gridBottom = m.footerTopY - 34
    configureSeriesGridMetrics()
    m.seriesGridGroup.translation = [m.gridX, m.gridY]

    messageWidth = m.rightPanelWidth - 96
    messageHeight = 164
    messageX = m.rightPanelX + 48
    messageY = m.headerBottomY + Int((contentHeight - messageHeight) / 2) - 20
    m.emptyMessageLabel.translation = [messageX, messageY]
    m.emptyMessageLabel.width = messageWidth
    m.emptyMessageLabel.height = messageHeight
    m.statusLabel.translation = [messageX, messageY + messageHeight]
    m.statusLabel.width = messageWidth
    m.statusLabel.height = 56

    m.bottomDivider.translation = [m.panelX, m.footerTopY]
    m.bottomDivider.width = m.panelWidth
    m.helpLabel.translation = [m.panelX + 42, m.footerTopY + 20]
    m.helpLabel.width = m.panelWidth - 84
    m.helpLabel.height = m.footerHeight - 20
end sub

sub show()
    configureLayout()
    m.top.visible = true
    m.top.SetFocus(true)
    m.selectedIndex = 0
    m.selectedSeriesIndex = 0
    m.firstVisibleSeriesIndex = 0
    m.seriesNodes = []
    m.seriesNodeRefs = []
    m.activePanel = "categories"
    m.statusLabel.text = ""
    renderSeriesGrid()
    updateNavigationState()
end sub

sub hide()
    m.top.visible = false
    m.top.SetFocus(false)
end sub

sub setSeries(series as Object)
    if series = invalid or Type(series) <> "roArray" then
        m.seriesItems = []
    else
        m.seriesItems = series
    end if
    m.selectedSeriesIndex = 0
    m.firstVisibleSeriesIndex = 0
    updateSeriesWindow()
    renderSeriesGrid()
    updateNavigationState()
end sub

sub updateNavigationState()
    labels = [m.searchLabel, m.favoritesLabel, m.recentLabel, m.watchedLabel]

    m.categoryFocus.translation = [m.panelX + 32, m.firstItemY + (m.selectedIndex * m.itemHeight)]

    for i = 0 to labels.Count() - 1
        if i = m.selectedIndex and m.activePanel = "categories" then
            labels[i].text = "> " + m.fixedItems[i]
            labels[i].color = "#FFFFFF"
            labels[i].font = "font:MediumBoldSystemFont"
        else
            labels[i].text = "  " + m.fixedItems[i]
            labels[i].color = "#B9C4CF"
            labels[i].font = "font:MediumSystemFont"
        end if
    end for

    if m.activePanel = "series" then
        m.categoryFocus.opacity = 0.35
    else
        m.categoryFocus.opacity = 0.95
    end if
    updateSeriesFocus()
end sub

sub showPendingMessage()
    m.statusLabel.text = "Função será ativada na próxima etapa."
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
    clearSeriesNodes()
    if m.seriesItems.Count() = 0 then
        m.emptyMessageLabel.visible = true
        return
    end if
    m.emptyMessageLabel.visible = false
    visibleCount = m.seriesColumns * m.seriesRows
    lastIndex = m.firstVisibleSeriesIndex + visibleCount - 1
    if lastIndex >= m.seriesItems.Count() then lastIndex = m.seriesItems.Count() - 1
    for visualIndex = 0 to lastIndex - m.firstVisibleSeriesIndex
        itemIndex = m.firstVisibleSeriesIndex + visualIndex
        node = createSeriesItem(m.seriesItems[itemIndex], visualIndex, itemIndex)
        m.seriesGridGroup.AppendChild(node)
        m.seriesNodes.Push(node)
        m.seriesNodeRefs.Push(m.lastSeriesRefs)
    end for
end sub

function createSeriesItem(series as Object, visualIndex as Integer, itemIndex as Integer) as Object
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
    poster.uri = getSeriesPoster(series)

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
    m.lastSeriesRefs = { background: background, poster: poster, title: title }
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
    if oldFirst <> m.firstVisibleSeriesIndex then renderSeriesGrid()
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
        if m.activePanel = "series" and realIndex = m.selectedSeriesIndex then
            refs.background.color = "#0078D7"
            refs.background.opacity = 1.0
            refs.title.color = "#FFFFFF"
        end if
    end for
end sub

sub clearSeriesNodes()
    while m.seriesGridGroup.GetChildCount() > 0
        m.seriesGridGroup.RemoveChildIndex(0)
    end while
    m.seriesNodes = []
    m.seriesNodeRefs = []
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press <> true then return false

    if key = "back" then
        m.top.backRequested = true
        return true
    else if key = "up" then
        if m.activePanel = "categories" then
            m.selectedIndex = m.selectedIndex - 1
            if m.selectedIndex < 0 then m.selectedIndex = m.fixedItems.Count() - 1
        else
            moveSeriesFocus(-m.seriesColumns)
        end if
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "down" then
        if m.activePanel = "categories" then
            m.selectedIndex = m.selectedIndex + 1
            if m.selectedIndex >= m.fixedItems.Count() then m.selectedIndex = 0
        else
            moveSeriesFocus(m.seriesColumns)
        end if
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "right" then
        if m.activePanel = "categories" then
            m.activePanel = "series"
        else
            moveSeriesFocus(1)
        end if
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "left" then
        if m.activePanel = "series" and (m.selectedSeriesIndex mod m.seriesColumns) > 0 then
            moveSeriesFocus(-1)
        else
            m.activePanel = "categories"
        end if
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "OK" then
        showPendingMessage()
        return true
    end if

    return false
end function
