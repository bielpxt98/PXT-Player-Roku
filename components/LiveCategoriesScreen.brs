' Live TV category list screen.
' This screen displays category metadata and notifies MainScene when a category is selected.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.categoriesPanel = m.top.FindNode("categoriesPanel")
    m.channelsPanel = m.top.FindNode("channelsPanel")
    m.categoriesTitle = m.top.FindNode("categoriesTitle")
    m.channelsTitle = m.top.FindNode("channelsTitle")
    m.emptyChannelsLabel = m.top.FindNode("emptyChannelsLabel")
    m.categoriesGroup = m.top.FindNode("categoriesGroup")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.categories = []
    m.itemNodes = []
    m.itemRefs = []
    m.selectedIndex = 0
    m.firstVisibleIndex = 0

    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    ' Use the real display size, but keep fixed safe-area reservations so the
    ' list never renders under the title or footer on different TV resolutions.
    m.safeMarginX = 72
    m.titleReservedHeight = 150
    m.footerReservedHeight = 86
    if height <= 720 then
        m.safeMarginX = 48
        m.titleReservedHeight = 124
        m.footerReservedHeight = 70
    end if

    m.contentX = m.safeMarginX
    m.contentWidth = width - (m.safeMarginX * 2)
    if m.contentWidth < 320 then
        m.contentX = 0
        m.contentWidth = width
    end if

    m.titleY = 42
    m.subtitleY = 100
    if height <= 720 then
        m.titleY = 28
        m.subtitleY = 78
    end if

    m.listY = m.titleReservedHeight
    m.footerY = height - m.footerReservedHeight + 18
    m.listHeight = m.footerY - m.listY - 20
    if m.listHeight < 80 then m.listHeight = 80

    if height <= 720 then
        m.itemHeight = 56
        m.cardHeight = 48
    else
        m.itemHeight = 68
        m.cardHeight = 58
    end if

    m.visibleItemCount = Int(m.listHeight / m.itemHeight)
    if m.visibleItemCount < 1 then m.visibleItemCount = 1

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, m.titleY]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, m.subtitleY]

    m.columnGap = 14
    m.categoryPanelWidth = Int(m.contentWidth * 0.36)
    m.channelPanelWidth = m.contentWidth - m.categoryPanelWidth - m.columnGap
    m.channelPanelX = m.contentX + m.categoryPanelWidth + m.columnGap

    m.statusLabel.width = m.categoryPanelWidth
    m.statusLabel.font = "font:MediumSystemFont"
    m.statusLabel.translation = [m.contentX, m.listY + Int(m.listHeight / 2)]

    layoutPanel(m.categoriesPanel, m.contentX, m.listY, m.categoryPanelWidth, m.listHeight)
    layoutPanel(m.channelsPanel, m.channelPanelX, m.listY, m.channelPanelWidth, m.listHeight)

    setupColumnTitle(m.categoriesTitle, m.contentX, m.listY, m.categoryPanelWidth)
    setupColumnTitle(m.channelsTitle, m.channelPanelX, m.listY, m.channelPanelWidth)

    m.emptyChannelsLabel.width = m.channelPanelWidth
    m.emptyChannelsLabel.font = "font:SmallSystemFont"
    m.emptyChannelsLabel.translation = [m.channelPanelX, m.listY + Int(m.listHeight / 2)]

    m.categoriesGroup.translation = [m.contentX + 14, m.listY + 54]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, m.footerY]
end sub

sub layoutPanel(panel as Object, x as Integer, y as Integer, w as Integer, h as Integer)
    panel.width = w
    panel.height = h
    panel.translation = [x, y]
end sub

sub setupColumnTitle(label as Object, x as Integer, y as Integer, w as Integer)
    label.width = w - 36
    label.font = "font:MediumBoldSystemFont"
    label.translation = [x + 18, y + 14]
end sub

sub show()
    configureLayout()
    resetSelection()
    updateVisibleWindow()
    renderList()
    updateFocus()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub resetSelection()
    m.selectedIndex = 0
    m.firstVisibleIndex = 0
end sub


sub setLoading(isLoading as Boolean)
    clearCategoryNodes()
    if isLoading then
        m.statusLabel.text = "Carregando categorias de TV ao vivo..."
        m.statusLabel.color = "#B8C3D6"
    else
        m.statusLabel.text = ""
    end if
end sub

sub setCategories(categories as Object)
    m.categories = addSearchEntry(normalizeCategories(categories), "BUSCAR CANAL")
    resetSelection()

    if m.categories.Count() = 0 then
        showMessage("Nenhuma categoria de TV ao vivo foi encontrada.")
        return
    end if

    m.statusLabel.text = ""
    updateVisibleWindow()
    renderList()
    updateFocus()
end sub

sub showMessage(message as String)
    clearCategoryNodes()
    m.categories = []
    resetSelection()
    m.statusLabel.text = message
    m.statusLabel.color = "#FFCC66"
end sub

function normalizeCategories(categories as Dynamic) as Object
    if categories = invalid then return []
    if Type(categories) = "roArray" then return categories
    return []
end function

sub renderList()
    clearCategoryNodes()
    if m.categories.Count() = 0 then return

    lastIndex = m.firstVisibleIndex + m.visibleItemCount - 1
    if lastIndex >= m.categories.Count() then lastIndex = m.categories.Count() - 1

    for visualIndex = 0 to lastIndex - m.firstVisibleIndex
        realIndex = m.firstVisibleIndex + visualIndex
        item = createCategoryItem(m.categories[realIndex], visualIndex, realIndex)
        m.categoriesGroup.AppendChild(item)
        m.itemNodes.Push(item)
        m.itemRefs.Push(m.lastItemRefs)
    end for
end sub

function createCategoryItem(category as Object, visibleIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group")
    item.translation = [0, visibleIndex * m.itemHeight]
    item.id = "categoryItem" + absoluteIndex.ToStr()

    background = CreateObject("roSGNode", "Rectangle")
    background.id = "itemBackground"
    background.width = m.categoryPanelWidth - 28
    background.height = m.cardHeight
    background.color = "#111827"
    background.opacity = 0.86

    accent = CreateObject("roSGNode", "Rectangle")
    accent.id = "itemAccent"
    accent.width = 6
    accent.height = m.cardHeight
    accent.color = "#009DFF"
    accent.opacity = 0.0

    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel"
    label.width = m.categoryPanelWidth - 54
    label.height = m.cardHeight
    label.translation = [22, 0]
    label.vertAlign = "center"
    label.color = "#F8FAFC"
    label.font = "font:MediumSystemFont"
    label.text = getCategoryName(category)
    if isSearchEntry(category) then
        background.color = "#0B3A5E"
        accent.opacity = 1.0
        label.text = "🔎  " + label.text
    end if

    item.AppendChild(background)
    item.AppendChild(accent)
    item.AppendChild(label)
    m.lastItemRefs = { background: background, accent: accent, label: label }
    return item
end function

function addSearchEntry(categories as Object, label as String) as Object
    items = []
    items.Push({ isSearch: true, category_name: label, name: label })
    for each category in categories
        items.Push(category)
    end for
    return items
end function

function isSearchEntry(category as Dynamic) as Boolean
    return category <> invalid and category.isSearch = true
end function

function getCategoryName(category as Dynamic) as String
    if category = invalid then return "Categoria sem nome"
    if category.category_name <> invalid and category.category_name.ToStr().Trim() <> "" then return category.category_name.ToStr()
    if category.name <> invalid and category.name.ToStr().Trim() <> "" then return category.name.ToStr()
    return "Categoria sem nome"
end function

function getCategoryLogTitle(category as Dynamic) as String
    if category = invalid then return ""
    if category.title <> invalid and category.title.ToStr().Trim() <> "" then return category.title.ToStr()
    return getCategoryName(category)
end function

sub clearCategoryNodes()
    while m.categoriesGroup.GetChildCount() > 0
        m.categoriesGroup.RemoveChildIndex(0)
    end while
    m.itemNodes = []
    m.itemRefs = []
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back" then
        m.top.backRequested = true
        return true
    else if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
        return true
    else if key = "OK" then
        if m.categories.Count() > 0 and m.selectedIndex >= 0 and m.selectedIndex < m.categories.Count() then
            if isSearchEntry(m.categories[m.selectedIndex]) then
                m.top.searchRequested = true
            else
                m.top.categorySelected = m.categories[m.selectedIndex]
            end if
        end if
        return true
    end if

    return false
end function

sub moveFocus(direction as Integer)
    handleUpDown(direction)
end sub

sub handleUpDown(direction as Integer)
    if m.categories.Count() = 0 then return

    oldSelected = m.selectedIndex
    oldFirst = m.firstVisibleIndex

    if direction > 0 then
        m.selectedIndex = m.selectedIndex + 1
    else if direction < 0 then
        m.selectedIndex = m.selectedIndex - 1
    else
        return
    end if

    updateVisibleWindow()

    if oldSelected <> m.selectedIndex or oldFirst <> m.firstVisibleIndex then
        renderList()
    end if

    updateFocus()
end sub

sub updateVisibleWindow()
    if m.categories.Count() = 0 then
        m.selectedIndex = 0
        m.firstVisibleIndex = 0
        return
    end if

    if m.selectedIndex < 0 then m.selectedIndex = 0
    if m.selectedIndex >= m.categories.Count() then m.selectedIndex = m.categories.Count() - 1
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0

    maxFirstIndex = m.categories.Count() - m.visibleItemCount
    if maxFirstIndex < 0 then maxFirstIndex = 0

    if m.selectedIndex < m.firstVisibleIndex then
        m.firstVisibleIndex = m.selectedIndex
    else if m.selectedIndex >= m.firstVisibleIndex + m.visibleItemCount then
        m.firstVisibleIndex = m.selectedIndex - m.visibleItemCount + 1
    end if

    if m.firstVisibleIndex > maxFirstIndex then m.firstVisibleIndex = maxFirstIndex
end sub

sub updateFocus()
    selectedIndex = -1

    ' Keep a single manual highlight: reset every visible item before
    ' applying the selectedIndex state to exactly one realIndex.
    for i = 0 to m.itemNodes.Count() - 1
        realIndex = m.firstVisibleIndex + i
        refs = m.itemRefs[i]

        m.itemNodes[i].scale = [1.0, 1.0]
        if refs.background <> invalid then
            refs.background.color = "#111827"
            refs.background.opacity = 0.86
        end if
        if refs.accent <> invalid then refs.accent.opacity = 0.0
        if refs.label <> invalid then refs.label.color = "#F8FAFC"

        if realIndex = m.selectedIndex then selectedIndex = i
    end for

    if selectedIndex >= 0 then
        refs = m.itemRefs[selectedIndex]
        m.itemNodes[selectedIndex].scale = [1.02, 1.02]
        if refs.background <> invalid then
            refs.background.color = "#0B3A5E"
            refs.background.opacity = 1.0
        end if
        if refs.accent <> invalid then refs.accent.opacity = 0.0
        if refs.label <> invalid then refs.label.color = "#FFFFFF"
    end if
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
