' Live TV category list screen.
' This screen displays category metadata and notifies MainScene when a category is selected.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.categoriesGroup = m.top.FindNode("categoriesGroup")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.categories = []
    m.itemNodes = []
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

    m.statusLabel.width = m.contentWidth
    m.statusLabel.font = "font:MediumSystemFont"
    m.statusLabel.translation = [m.contentX, m.listY + Int(m.listHeight / 2)]

    m.categoriesGroup.translation = [m.contentX, m.listY]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, m.footerY]
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
    logInitialSelection()
end sub

sub logInitialSelection()
    print "INIT selectedIndex="; m.selectedIndex
    print "INIT firstVisibleIndex="; m.firstVisibleIndex
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
    m.categories = normalizeCategories(categories)
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
    end for
end sub

function createCategoryItem(category as Object, visibleIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group")
    item.translation = [0, visibleIndex * m.itemHeight]
    item.id = "categoryItem" + absoluteIndex.ToStr()

    background = CreateObject("roSGNode", "Rectangle")
    background.id = "itemBackground"
    background.width = m.contentWidth
    background.height = m.cardHeight
    background.color = "#111827"
    background.opacity = 0.86

    accent = CreateObject("roSGNode", "Rectangle")
    accent.id = "itemAccent"
    accent.width = 6
    accent.height = m.cardHeight
    accent.color = "#009DFF"
    accent.opacity = 0.45

    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel"
    label.width = m.contentWidth - 40
    label.height = m.cardHeight
    label.translation = [22, 0]
    label.vertAlign = "center"
    label.color = "#F8FAFC"
    label.font = "font:MediumSystemFont"
    label.text = getCategoryName(category)

    item.AppendChild(background)
    item.AppendChild(accent)
    item.AppendChild(label)
    return item
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
            print "OK opening selectedIndex="; m.selectedIndex
            print "OK opening item="; getCategoryLogTitle(m.categories[m.selectedIndex])
            m.top.categorySelected = m.categories[m.selectedIndex]
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

    if direction > 0 then
        m.selectedIndex = m.selectedIndex + 1
    else if direction < 0 then
        m.selectedIndex = m.selectedIndex - 1
    else
        return
    end if

    previousFirstVisibleIndex = m.firstVisibleIndex
    updateVisibleWindow()

    if m.firstVisibleIndex <> previousFirstVisibleIndex then
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
    selectedNode = invalid

    for i = 0 to m.itemNodes.Count() - 1
        realIndex = m.firstVisibleIndex + i
        background = m.itemNodes[i].FindNode("itemBackground")
        accent = m.itemNodes[i].FindNode("itemAccent")
        label = m.itemNodes[i].FindNode("itemLabel")

        m.itemNodes[i].scale = [1.0, 1.0]
        background.color = "#111827"
        background.opacity = 0.86
        accent.opacity = 0.45
        label.color = "#F8FAFC"

        if realIndex = m.selectedIndex then selectedNode = m.itemNodes[i]
    end for

    if selectedNode <> invalid then
        background = selectedNode.FindNode("itemBackground")
        accent = selectedNode.FindNode("itemAccent")
        label = selectedNode.FindNode("itemLabel")

        selectedNode.scale = [1.02, 1.02]
        background.color = "#0B3A5E"
        background.opacity = 1.0
        accent.opacity = 1.0
        label.color = "#FFFFFF"
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
