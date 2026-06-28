' Clean category-only compatibility screen for Live TV.
sub Init()
    m.background = m.top.FindNode("background") : m.title = m.top.FindNode("title")
    m.leftPanel = m.top.FindNode("leftPanel") : m.rightPanel = m.top.FindNode("rightPanel")
    m.categoriesTitle = m.top.FindNode("categoriesTitle") : m.channelsTitle = m.top.FindNode("channelsTitle")
    m.statusLabel = m.top.FindNode("statusLabel") : m.categoriesGroup = m.top.FindNode("categoriesGroup")
    m.emptyChannelsLabel = m.top.FindNode("emptyChannelsLabel") : m.hintLabel = m.top.FindNode("hintLabel")
    m.categories = [] : m.nodes = [] : m.selectedIndex = 0 : m.firstVisibleIndex = 0
    configureLayout()
end sub

sub configureLayout()
    r = getDisplayResolution() : w = r.width : h = r.height
    m.margin = 72 : m.titleH = 118 : m.footerH = 54 : m.gap = 18
    if h <= 720 then m.margin = 48 : m.titleH = 92 : m.footerH = 42 : m.gap = 14
    m.panelY = m.titleH : m.panelH = h - m.titleH - m.footerH - 18 : m.contentW = w - (m.margin * 2)
    m.leftW = Int(m.contentW * 0.34) : if m.leftW < 280 then m.leftW = 280
    m.rightX = m.margin + m.leftW + m.gap : m.rightW = m.contentW - m.leftW - m.gap
    m.headerH = 58 : m.itemH = 54 : if h <= 720 then m.headerH = 48 : m.itemH = 44
    m.listY = m.panelY + m.headerH : m.listH = m.panelH - m.headerH : m.visibleCount = Int(m.listH / m.itemH) : if m.visibleCount < 1 then m.visibleCount = 1
    m.background.width = w : m.background.height = h
    m.title.translation = [0, 34] : m.title.width = w : m.title.font = "font:LargeBoldSystemFont"
    if h <= 720 then m.title.translation = [0, 24]
    m.leftPanel.translation = [m.margin, m.panelY] : m.leftPanel.width = m.leftW : m.leftPanel.height = m.panelH
    m.rightPanel.translation = [m.rightX, m.panelY] : m.rightPanel.width = m.rightW : m.rightPanel.height = m.panelH
    m.categoriesTitle.translation = [m.margin + 18, m.panelY + 18] : m.categoriesTitle.font = "font:MediumBoldSystemFont"
    m.channelsTitle.translation = [m.rightX + 18, m.panelY + 18] : m.channelsTitle.font = "font:MediumBoldSystemFont"
    m.statusLabel.translation = [m.margin + 18, m.listY + Int(m.listH / 2)] : m.statusLabel.width = m.leftW - 36 : m.statusLabel.font = "font:MediumSystemFont"
    m.emptyChannelsLabel.translation = [m.rightX + 18, m.listY + Int(m.listH / 2)] : m.emptyChannelsLabel.width = m.rightW - 36 : m.emptyChannelsLabel.font = "font:MediumSystemFont"
    m.categoriesGroup.translation = [m.margin + 18, m.listY]
    m.hintLabel.translation = [0, h - 38] : m.hintLabel.width = w : m.hintLabel.font = "font:SmallSystemFont"
end sub

sub show()
    configureLayout() : renderList() : updateFocus() : m.top.visible = true : m.top.SetFocus(true)
end sub
sub hide()
    m.top.visible = false
end sub
sub setLoading(isLoading as Boolean)
    clearNodes() : if isLoading then m.statusLabel.text = "Carregando categorias..." else m.statusLabel.text = ""
end sub
sub setCategories(categories as Object)
    m.categories = normalizeArray(categories) : m.selectedIndex = 0 : m.firstVisibleIndex = 0 : m.statusLabel.text = "" : renderList() : updateFocus()
end sub
sub showMessage(message as String)
    clearNodes() : m.categories = [] : m.statusLabel.color = "#FFCC66" : m.statusLabel.text = message
end sub
sub selectCategory(category as Dynamic)
    id = getCategoryId(category)
    for i = 0 to m.categories.Count() - 1
        if getCategoryId(m.categories[i]) = id then m.selectedIndex = i : exit for
    end for
    updateWindow() : renderList() : updateFocus()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then m.top.backRequested = true : return true
    if key = "up" then moveSelection(-1) : return true
    if key = "down" then moveSelection(1) : return true
    if key = "OK" then if m.categories.Count() > 0 then m.top.categorySelected = m.categories[m.selectedIndex] : return true
    return false
end function

sub moveSelection(delta as Integer)
    if m.categories.Count() = 0 then return
    m.selectedIndex = m.selectedIndex + delta : updateWindow() : renderList() : updateFocus()
end sub
sub renderList()
    clearNodes() : if m.categories.Count() = 0 then return
    updateWindow() : lastIndex = m.firstVisibleIndex + m.visibleCount - 1 : if lastIndex >= m.categories.Count() then lastIndex = m.categories.Count() - 1
    for visualIndex = 0 to lastIndex - m.firstVisibleIndex
        node = createItem(getCategoryName(m.categories[m.firstVisibleIndex + visualIndex]), visualIndex)
        m.categoriesGroup.AppendChild(node) : m.nodes.Push(node)
    end for
end sub
function createItem(text as String, visualIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group") : item.translation = [0, visualIndex * m.itemH]
    bg = CreateObject("roSGNode", "Rectangle") : bg.id = "itemBackground" : bg.width = m.leftW - 36 : bg.height = m.itemH - 8 : bg.color = "#111827" : bg.opacity = 0.0
    label = CreateObject("roSGNode", "Label") : label.id = "itemLabel" : label.translation = [14, 0] : label.width = m.leftW - 64 : label.height = m.itemH - 8 : label.vertAlign = "center" : label.font = "font:SmallSystemFont" : label.color = "#C9D4E5" : label.text = text
    item.AppendChild(bg) : item.AppendChild(label) : return item
end function
sub updateWindow()
    if m.categories.Count() = 0 then m.selectedIndex = 0 : m.firstVisibleIndex = 0 : return
    if m.selectedIndex < 0 then m.selectedIndex = 0
    if m.selectedIndex >= m.categories.Count() then m.selectedIndex = m.categories.Count() - 1
    if m.selectedIndex < m.firstVisibleIndex then m.firstVisibleIndex = m.selectedIndex
    if m.selectedIndex >= m.firstVisibleIndex + m.visibleCount then m.firstVisibleIndex = m.selectedIndex - m.visibleCount + 1
end sub
sub updateFocus()
    for i = 0 to m.nodes.Count() - 1
        bg = m.nodes[i].FindNode("itemBackground") : label = m.nodes[i].FindNode("itemLabel")
        bg.opacity = 0.0 : label.color = "#C9D4E5" : m.nodes[i].scale = [1.0, 1.0]
        if m.firstVisibleIndex + i = m.selectedIndex then bg.opacity = 1.0 : bg.color = "#0B5CAD" : label.color = "#FFFFFF" : m.nodes[i].scale = [1.03, 1.03]
    end for
end sub
sub clearNodes()
    while m.categoriesGroup.GetChildCount() > 0 : m.categoriesGroup.RemoveChildIndex(0) : end while
    m.nodes = []
end sub
function normalizeArray(items as Dynamic) as Object
    if items = invalid then return []
    if Type(items) = "roArray" then return items
    return []
end function
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
    if category.title <> invalid and category.title.ToStr().Trim() <> "" then return category.title.ToStr()
    return "Categoria"
end function
function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo") : displaySize = deviceInfo.GetDisplaySize()
    return { width: displaySize.w, height: displaySize.h }
end function
