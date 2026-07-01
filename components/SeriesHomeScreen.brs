sub Init()
    m.panelBg = m.top.FindNode("panelBg") : m.titleLabel = m.top.FindNode("titleLabel") : m.dividerTop = m.top.FindNode("dividerTop")
    m.categoriesTitle = m.top.FindNode("categoriesTitle") : m.seriesTitle = m.top.FindNode("seriesTitle")
    m.categoriesGroup = m.top.FindNode("categoriesGroup") : m.seriesGroup = m.top.FindNode("seriesGroup") : m.messageLabel = m.top.FindNode("messageLabel")
    m.searchBg = m.top.FindNode("searchBg") : m.searchLabel = m.top.FindNode("searchLabel") : m.searchFieldBg = m.top.FindNode("searchFieldBg") : m.searchText = m.top.FindNode("searchText")
    m.keyboardGroup = m.top.FindNode("keyboardGroup") : m.hintLabel = m.top.FindNode("hintLabel")
    m.categories = [] : m.allSeries = [] : m.filteredSeries = [] : m.query = "" : m.activePane = "categories" : m.categoryIndex = 0 : m.seriesIndex = 0 : m.keyboardIndex = 0
    m.columns = 3 : m.visibleRows = 3 : m.categoryWindow = 9 : m.keyboard = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9","ESPAÇO","APAGAR","LIMPAR"]
    layoutScreen() : renderKeyboard() : hide()
end sub
sub layoutScreen()
    r = getDisplayResolution() : w = r.width : h = r.height : margin = 54
    m.panelBg.width = w : m.panelBg.height = h : m.titleLabel.translation = [0, 24] : m.titleLabel.width = w : m.titleLabel.height = 44 : m.titleLabel.font = "font:LargeBoldSystemFont"
    m.dividerTop.translation = [margin, 82] : m.dividerTop.width = w - margin * 2
    m.categoriesTitle.translation = [76, 104] : m.categoriesTitle.font = "font:MediumBoldSystemFont" : m.seriesTitle.translation = [360, 104] : m.seriesTitle.font = "font:MediumBoldSystemFont"
    m.categoriesGroup.translation = [76, 146] : m.seriesGroup.translation = [360, 146]
    m.messageLabel.translation = [330, 310] : m.messageLabel.width = w - 420 : m.messageLabel.height = 44 : m.messageLabel.font = "font:MediumSystemFont"
    m.searchBg.translation = [54, h - 210] : m.searchBg.width = w - 108 : m.searchBg.height = 58
    m.searchLabel.translation = [78, h - 195] : m.searchLabel.font = "font:MediumBoldSystemFont" : m.searchFieldBg.translation = [190, h - 197] : m.searchFieldBg.width = w - 270 : m.searchFieldBg.height = 34
    m.searchText.translation = [202, h - 193] : m.searchText.width = w - 294 : m.searchText.height = 30 : m.searchText.font = "font:MediumSystemFont"
    m.keyboardGroup.translation = [76, h - 138] : m.hintLabel.translation = [0, h - 38] : m.hintLabel.width = w : m.hintLabel.font = "font:SmallSystemFont"
end sub
sub show()
    m.top.visible = true : m.top.SetFocus(true) : renderAll()
end sub
sub hide()
    m.top.visible = false
end sub
sub resetSelection()
    m.activePane = "categories" : m.categoryIndex = 0 : m.seriesIndex = 0 : m.keyboardIndex = 0 : m.query = "" : updateSearchText()
end sub
sub setCategories(items as Object)
    m.categories = [{ category_id: "", category_name: "Todas" }]
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
    q = LCase(m.query) : m.filteredSeries = []
    for each item in m.allSeries
        if q = "" or Instr(1, LCase(getSeriesName(item)), q) > 0 then m.filteredSeries.Push(item)
    end for
    if m.seriesIndex >= m.filteredSeries.Count() then m.seriesIndex = m.filteredSeries.Count() - 1
    if m.seriesIndex < 0 then m.seriesIndex = 0
    renderSeries()
end sub
sub renderAll()
    renderCategories() : renderSeries() : updateSearchText() : updateFocus()
end sub
sub renderCategories()
    clearGroup(m.categoriesGroup)
    first = m.categoryIndex - 4
    if first < 0 then first = 0
    last = first + m.categoryWindow - 1
    if last >= m.categories.Count() then last = m.categories.Count() - 1
    y = 0

    for i = first to last
        label = CreateObject("roSGNode", "Label")
        label.width = 250
        label.height = 34
        label.translation = [0, y]
        label.font = "font:MediumSystemFont"
        label.color = "#DDE6F3"
        prefix = "  "
        if i = m.categoryIndex then prefix = "> "
        label.text = prefix + getCategoryName(m.categories[i])
        m.categoriesGroup.AppendChild(label)
        y = y + 38
    end for

    updateFocus()
end sub
sub renderSeries()
    clearGroup(m.seriesGroup) : m.messageLabel.text = "" : maxItems = 50 : count = m.filteredSeries.Count() : if count = 0 then m.messageLabel.text = "Nenhuma série encontrada." : updateFocus() : return
    if count < maxItems then maxItems = count
    first = Int(m.seriesIndex / m.columns) * m.columns : if first > maxItems - 1 then first = 0
    last = first + (m.columns * m.visibleRows) - 1 : if last >= maxItems then last = maxItems - 1
    for i = first to last
        visual = i - first : col = visual mod m.columns : row = Int(visual / m.columns)
        g = CreateObject("roSGNode", "Group") : g.translation = [col * 190, row * 126]
        p = CreateObject("roSGNode", "Poster") : p.width = 124 : p.height = 82 : p.loadDisplayMode = "scaleToFill" : p.uri = getSeriesCover(m.filteredSeries[i])
        l = CreateObject("roSGNode", "Label") : l.translation = [0, 86] : l.width = 170 : l.height = 34 : l.font = "font:SmallSystemFont" : l.color = "#DDE6F3" : l.text = getSeriesName(m.filteredSeries[i])
        g.AppendChild(p) : g.AppendChild(l) : m.seriesGroup.AppendChild(g)
    end for
    updateFocus()
end sub
sub renderKeyboard()
    clearGroup(m.keyboardGroup)
    for i = 0 to m.keyboard.Count() - 1
        col = i mod 13 : row = Int(i / 13) : label = CreateObject("roSGNode", "Label") : label.translation = [col * 84, row * 36] : label.width = 110 : label.height = 32 : label.font = "font:MediumSystemFont" : label.color = "#DDE6F3" : label.text = m.keyboard[i] : m.keyboardGroup.AppendChild(label)
    end for
end sub
sub updateFocus()
    colorNodes(m.categoriesGroup, m.activePane = "categories", m.categoryIndex) : colorNodes(m.seriesGroup, m.activePane = "series", m.seriesIndex mod (m.columns * m.visibleRows)) : colorNodes(m.keyboardGroup, m.activePane = "keyboard", m.keyboardIndex)
    m.searchFieldBg.opacity = 0.32 : if m.activePane = "search" then m.searchFieldBg.opacity = 0.46
end sub
sub colorNodes(group as Object, active as Boolean, selected as Integer)
    for i = 0 to group.GetChildCount() - 1
        node = group.GetChild(i) : target = node : if node.GetChildCount() > 1 then target = node.GetChild(1)
        target.color = "#DDE6F3" : if active and i = selected then target.color = "#38BDF8"
    end for
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
    panes = ["categories", "series", "search", "keyboard"]
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
    else if m.activePane = "keyboard" then
        m.keyboardIndex = clamp(m.keyboardIndex + (delta * 13), 0, m.keyboard.Count() - 1)
        updateFocus()
    end if
end sub
sub activateSelection()
    if m.activePane = "categories" and m.categories.Count() > 0 then
        m.top.categorySelected = m.categories[m.categoryIndex]
    else if m.activePane = "series" and m.filteredSeries.Count() > 0 then
        m.top.seriesSelected = m.filteredSeries[m.seriesIndex]
    else if m.activePane = "search" then
        m.activePane = "keyboard"
        updateFocus()
    else if m.activePane = "keyboard" then
        pressKey(m.keyboard[m.keyboardIndex])
    end if
end sub
sub pressKey(k as String)
    if k = "ESPAÇO" then
        m.query = m.query + " "
    else if k = "APAGAR" then
        if Len(m.query) > 0 then m.query = Left(m.query, Len(m.query) - 1)
    else if k = "LIMPAR" then
        m.query = ""
    else
        m.query = m.query + k
    end if
    updateSearchText()
    applyFilter()
end sub
sub updateSearchText()
    m.searchText.text = m.query
end sub
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
