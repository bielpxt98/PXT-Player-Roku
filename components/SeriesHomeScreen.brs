sub Init()
    m.background = m.top.FindNode("background") : m.headerBar = m.top.FindNode("headerBar") : m.titleLabel = m.top.FindNode("titleLabel")
    m.leftPanel = m.top.FindNode("leftPanel") : m.divider = m.top.FindNode("divider")
    m.categoriesTitle = m.top.FindNode("categoriesTitle") : m.seriesTitle = m.top.FindNode("seriesTitle")
    m.categoriesGroup = m.top.FindNode("categoriesGroup") : m.seriesGroup = m.top.FindNode("seriesGroup") : m.messageLabel = m.top.FindNode("messageLabel")
    m.selectedTitleBar = m.top.FindNode("selectedTitleBar") : m.selectedTitleLabel = m.top.FindNode("selectedTitleLabel") : m.hintLabel = m.top.FindNode("hintLabel")
    m.searchEntry = { isSearch: true, category_name: "Pesquisar", name: "Pesquisar" }
    m.categories = [m.searchEntry] : m.allSeries = [] : m.filteredSeries = [] : m.activePane = "categories" : m.categoryIndex = 0 : m.seriesIndex = 0
    m.categoryWindow = 9 : m.columns = 5 : m.visibleRows = 3
    layoutScreen() : hide()
end sub

sub layoutScreen()
    r = getDisplayResolution() : w = r.width : h = r.height
    m.margin = 48 : if h <= 720 then m.margin = 32
    m.headerH = 78 : m.footerH = 54
    m.panelY = m.headerH : m.panelH = h - m.headerH - m.footerH
    m.leftW = 270 : if w <= 1280 then m.leftW = 220
    m.gridX = m.margin + m.leftW + 28 : m.gridY = m.panelY + 34
    m.gridW = w - m.gridX - m.margin : m.gridH = m.panelH - 94
    m.categoryX = m.margin + 18 : m.categoryY = m.panelY + 76
    m.categoryW = m.leftW - 36 : m.categoryItemH = 48
    m.posterW = 176 : m.posterH = 260 : m.posterGapX = 38 : m.posterGapY = 34
    if h <= 720 then m.posterW = 126 : m.posterH = 186 : m.posterGapX = 26 : m.posterGapY = 22 : m.categoryItemH = 42
    m.columns = Int((m.gridW + m.posterGapX) / (m.posterW + m.posterGapX))
    if m.columns < 1 then m.columns = 1
    if m.columns > 6 then m.columns = 6
    if h <= 720 and m.columns > 5 then m.columns = 5
    if m.columns > 1 then m.posterGapX = Int((m.gridW - (m.columns * m.posterW)) / (m.columns - 1))
    if m.posterGapX < 20 then m.posterGapX = 20
    m.itemH = m.posterH + m.posterGapY
    m.visibleRows = Int(m.gridH / m.itemH)
    if m.visibleRows < 2 then m.visibleRows = 2
    if m.visibleRows > 3 then m.visibleRows = 3
    m.categoryWindow = Int((m.panelH - 92) / m.categoryItemH)
    if m.categoryWindow < 1 then m.categoryWindow = 1

    m.background.width = w : m.background.height = h
    m.headerBar.width = w : m.headerBar.height = m.headerH
    m.titleLabel.translation = [0, 20] : m.titleLabel.width = w : m.titleLabel.height = 42 : m.titleLabel.font = "font:LargeBoldSystemFont"
    m.leftPanel.translation = [m.margin, m.panelY] : m.leftPanel.width = m.leftW : m.leftPanel.height = m.panelH
    m.divider.translation = [m.margin + m.leftW, m.panelY] : m.divider.width = 2 : m.divider.height = m.panelH
    m.categoriesTitle.translation = [m.margin + 18, m.panelY + 24] : m.categoriesTitle.font = "font:MediumBoldSystemFont"
    m.seriesTitle.translation = [m.gridX, m.panelY + 20] : m.seriesTitle.width = m.gridW : m.seriesTitle.font = "font:SmallSystemFont"
    m.categoriesGroup.translation = [m.categoryX, m.categoryY]
    m.seriesGroup.translation = [m.gridX, m.gridY]
    m.messageLabel.translation = [m.gridX, m.gridY + Int(m.gridH / 2)] : m.messageLabel.width = m.gridW : m.messageLabel.height = 44 : m.messageLabel.font = "font:MediumSystemFont"
    m.selectedTitleBar.translation = [m.gridX, h - m.footerH + 6] : m.selectedTitleBar.width = m.gridW : m.selectedTitleBar.height = 30
    m.selectedTitleLabel.translation = [m.gridX + 14, h - m.footerH + 5] : m.selectedTitleLabel.width = m.gridW - 28 : m.selectedTitleLabel.height = 34 : m.selectedTitleLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, h - 30] : m.hintLabel.width = w : m.hintLabel.font = "font:SmallSystemFont"
end sub
sub show()
    m.top.visible = true : m.top.SetFocus(true) : renderAll()
end sub
sub hide()
    m.top.visible = false
end sub
sub resetSelection()
    focusSearchEntry()
end sub
sub setCategories(items as Object)
    m.categories = [m.searchEntry]
    if items <> invalid then
        for each category in items
            m.categories.Push(category)
        end for
    end if
    renderCategories()
end sub
sub setSeries(items as Object)
    m.allSeries = normalizeArray(items) : applyFilter()
end sub
sub setLoading(isLoading as Boolean)
    if isLoading then showMessage("Carregando...") else showMessage("")
end sub
sub showMessage(message as String)
    m.messageLabel.text = message
end sub
sub applyFilter()
    m.filteredSeries = []
    for each item in m.allSeries
        m.filteredSeries.Push(item)
    end for
    if m.seriesIndex >= m.filteredSeries.Count() then m.seriesIndex = m.filteredSeries.Count() - 1
    if m.seriesIndex < 0 then m.seriesIndex = 0
    renderSeries()
end sub
sub renderAll()
    renderCategories() : renderSeries() : updateFocus()
end sub
sub renderCategories()
    clearGroup(m.categoriesGroup)
    first = m.categoryIndex - Int(m.categoryWindow / 2)
    if first < 0 then first = 0
    last = first + m.categoryWindow - 1
    if last >= m.categories.Count() then last = m.categories.Count() - 1
    y = 0

    for i = first to last
        item = CreateObject("roSGNode", "Group") : item.translation = [0, y]
        bg = CreateObject("roSGNode", "Rectangle") : bg.width = m.categoryW : bg.height = m.categoryItemH - 8 : bg.color = "#061F36" : bg.opacity = 0.0
        label = CreateObject("roSGNode", "Label") : label.translation = [14, 0] : label.width = m.categoryW - 24 : label.height = m.categoryItemH - 8 : label.vertAlign = "center" : label.font = "font:SmallSystemFont" : label.color = "#C9D4E5" : label.text = getCategoryName(m.categories[i])
        item.AppendChild(bg) : item.AppendChild(label) : m.categoriesGroup.AppendChild(item)
        y = y + m.categoryItemH
    end for

    updateFocus()
end sub
sub renderSeries()
    clearGroup(m.seriesGroup) : m.messageLabel.text = "" : m.selectedTitleLabel.text = "" : m.selectedTitleBar.opacity = 0.0
    count = m.filteredSeries.Count() : if count = 0 then m.messageLabel.text = "Nenhuma série encontrada." : updateFocus() : return
    m.firstSeriesIndex = Int(m.seriesIndex / m.columns) * m.columns
    first = m.firstSeriesIndex
    last = first + (m.columns * m.visibleRows) - 1 : if last >= count then last = count - 1
    for i = first to last
        visual = i - first : col = visual mod m.columns : row = Int(visual / m.columns)
        g = CreateObject("roSGNode", "Group") : g.translation = [col * (m.posterW + m.posterGapX), row * m.itemH]
        border = CreateObject("roSGNode", "Rectangle") : border.id = "posterFocus" : border.translation = [-5, -5] : border.width = m.posterW + 10 : border.height = m.posterH + 10 : border.color = "#38BDF8" : border.opacity = 0.0
        p = CreateObject("roSGNode", "Poster") : p.width = m.posterW : p.height = m.posterH : p.loadDisplayMode = "scaleToFill" : p.uri = getSeriesCover(m.filteredSeries[i])
        g.AppendChild(border) : g.AppendChild(p) : m.seriesGroup.AppendChild(g)
    end for
    updateFocus()
end sub
sub updateFocus()
    colorCategoryNodes(m.categoriesGroup, m.activePane = "categories", getVisibleCategorySelectionIndex()) : colorSeriesNodes()
end sub
sub colorCategoryNodes(group as Object, active as Boolean, selected as Integer)
    for i = 0 to group.GetChildCount() - 1
        node = group.GetChild(i) : bg = node.GetChild(0) : label = node.GetChild(1)
        bg.opacity = 0.0 : label.color = "#C9D4E5" : node.scale = [1.0, 1.0]
        if i = selected then
            bg.opacity = 1.0 : label.color = "#FFFFFF"
            if active then node.scale = [1.03, 1.03]
        end if
    end for
end sub
sub colorSeriesNodes()
    selectedVisual = m.seriesIndex - m.firstSeriesIndex
    for i = 0 to m.seriesGroup.GetChildCount() - 1
        node = m.seriesGroup.GetChild(i) : border = node.GetChild(0)
        border.opacity = 0.0 : node.scale = [1.0, 1.0]
        if m.activePane = "series" and i = selectedVisual then
            border.opacity = 1.0 : node.scale = [1.035, 1.035]
        end if
    end for
    if m.activePane = "series" and m.filteredSeries.Count() > 0 then
        m.selectedTitleBar.opacity = 0.88 : m.selectedTitleLabel.text = getSeriesName(m.filteredSeries[m.seriesIndex])
    else
        m.selectedTitleBar.opacity = 0.0 : m.selectedTitleLabel.text = ""
    end if
end sub
function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then m.top.backRequested = true : return true
    if key = "left" then cyclePane(-1) : return true
    if key = "right" then cyclePane(1) : return true
    if key = "up" then moveSelection(-1) : return true
    if key = "down" then moveSelection(1) : return true
    if key = "OK" then activateSelection() : return true
    return false
end function
sub cyclePane(delta as Integer)
    panes = ["categories", "series"]
    idx = 0
    for i = 0 to panes.Count() - 1
        if panes[i] = m.activePane then idx = i
    end for
    idx = idx + delta
    if idx < 0 then idx = panes.Count() - 1
    if idx >= panes.Count() then idx = 0
    m.activePane = panes[idx]
    updateFocus()
end sub
sub moveSelection(delta as Integer)
    if m.activePane = "categories" and m.categories.Count() > 0 then
        m.categoryIndex = clamp(m.categoryIndex + delta, 0, m.categories.Count() - 1)
        renderCategories()
    else if m.activePane = "series" and m.filteredSeries.Count() > 0 then
        m.seriesIndex = clamp(m.seriesIndex + (delta * m.columns), 0, m.filteredSeries.Count() - 1)
        renderSeries()
    end if
end sub
sub activateSelection()
    if m.activePane = "categories" and m.categories.Count() > 0 then
        if isSearchEntry(m.categories[m.categoryIndex]) then
            m.top.searchRequested = true
            return
        end if
        m.top.categorySelected = m.categories[m.categoryIndex]
    else if m.activePane = "series" and m.filteredSeries.Count() > 0 then
        m.top.seriesSelected = m.filteredSeries[m.seriesIndex]
    end if
end sub
sub focusSearchEntry()
    m.activePane = "categories" : m.categoryIndex = 0 : m.seriesIndex = 0
    renderCategories()
end sub

function isSearchEntry(category as Dynamic) as Boolean
    return category <> invalid and category.isSearch = true
end function

function getVisibleCategorySelectionIndex() as Integer
    first = m.categoryIndex - Int(m.categoryWindow / 2)
    if first < 0 then first = 0
    return m.categoryIndex - first
end function

function clamp(v as Integer, lo as Integer, hi as Integer) as Integer
    if v < lo then return lo
    if v > hi then return hi
    return v
end function
sub clearGroup(group as Object)
    while group.GetChildCount() > 0
        group.RemoveChildIndex(0)
    end while
end sub
function normalizeArray(items as Dynamic) as Object
    if items <> invalid and Type(items) = "roArray" then return items
    return []
end function
function getDisplayResolution() as Object
    d = CreateObject("roDeviceInfo") : s = d.GetDisplaySize() : return { width: s.w, height: s.h }
end function
function getCategoryName(c as Dynamic) as String
    if c <> invalid and c.category_name <> invalid then return c.category_name.ToStr()
    if c <> invalid and c.name <> invalid then return c.name.ToStr()
    return "Categoria"
end function
function getSeriesName(item as Dynamic) as String
    if item <> invalid and item.name <> invalid then return item.name.ToStr()
    if item <> invalid and item.title <> invalid then return item.title.ToStr()
    return "Série"
end function
function getSeriesCover(item as Dynamic) as String
    if item <> invalid and item.cover <> invalid then return item.cover.ToStr()
    if item <> invalid and item.series_image <> invalid then return item.series_image.ToStr()
    return ""
end function
