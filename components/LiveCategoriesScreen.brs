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
    m.focusIndex = 0
    m.firstVisibleIndex = 0

    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.safeX = Int(width * 0.06)
    m.safeTop = Int(height * 0.07)
    m.safeBottom = Int(height * 0.08)
    m.contentWidth = width - (m.safeX * 2)
    if m.contentWidth > 860 then m.contentWidth = 860
    m.contentX = Int((width - m.contentWidth) / 2)

    if height <= 720 then
        m.itemHeight = 58
        m.cardHeight = 50
        m.titleY = m.safeTop
        m.subtitleY = m.titleY + 58
        m.listY = m.subtitleY + 58
        m.footerGap = 44
    else
        m.itemHeight = 70
        m.cardHeight = 58
        m.titleY = m.safeTop
        m.subtitleY = m.titleY + 74
        m.listY = m.subtitleY + 72
        m.footerGap = 58
    end if

    hintY = height - m.safeBottom - 28
    if hintY < m.listY + m.cardHeight then hintY = m.listY + m.cardHeight + 12
    availableListHeight = hintY - m.listY - m.footerGap
    m.maxVisibleItems = Int(availableListHeight / m.itemHeight)
    if m.maxVisibleItems < 1 then m.maxVisibleItems = 1

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
    m.statusLabel.translation = [m.contentX, m.listY + Int(availableListHeight / 2)]

    m.categoriesGroup.translation = [m.contentX, m.listY]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, hintY]
end sub

sub show()
    configureLayout()
    ensureFocusIsVisible()
    renderVisibleItems()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
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
    m.focusIndex = 0
    m.firstVisibleIndex = 0

    if m.categories.Count() = 0 then
        showMessage("Nenhuma categoria de TV ao vivo foi encontrada.")
        return
    end if

    m.statusLabel.text = ""
    renderVisibleItems()
end sub

sub showMessage(message as String)
    clearCategoryNodes()
    m.categories = []
    m.focusIndex = 0
    m.firstVisibleIndex = 0
    m.statusLabel.text = message
    m.statusLabel.color = "#FFCC66"
end sub

function normalizeCategories(categories as Dynamic) as Object
    if categories = invalid then return []
    if Type(categories) = "roArray" then return categories
    return []
end function

sub renderVisibleItems()
    clearCategoryNodes()
    if m.categories.Count() = 0 then return

    ensureFocusIsVisible()
    lastIndex = m.firstVisibleIndex + m.maxVisibleItems - 1
    if lastIndex >= m.categories.Count() then lastIndex = m.categories.Count() - 1

    for i = m.firstVisibleIndex to lastIndex
        item = createCategoryItem(m.categories[i], i - m.firstVisibleIndex, i)
        m.categoriesGroup.AppendChild(item)
        m.itemNodes.Push(item)
    end for

    updateFocus()
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
        if m.categories.Count() > 0 and m.focusIndex >= 0 and m.focusIndex < m.categories.Count() then
            m.top.categorySelected = m.categories[m.focusIndex]
        end if
        return true
    end if

    return false
end function

sub moveFocus(direction as Integer)
    if m.categories.Count() = 0 then return

    nextIndex = m.focusIndex + direction
    if nextIndex < 0 then nextIndex = m.categories.Count() - 1
    if nextIndex >= m.categories.Count() then nextIndex = 0
    m.focusIndex = nextIndex

    oldFirstVisibleIndex = m.firstVisibleIndex
    ensureFocusIsVisible()
    if oldFirstVisibleIndex <> m.firstVisibleIndex then
        renderVisibleItems()
    else
        updateFocus()
    end if
end sub

sub ensureFocusIsVisible()
    if m.categories.Count() = 0 then
        m.focusIndex = 0
        m.firstVisibleIndex = 0
        return
    end if

    if m.focusIndex < 0 then m.focusIndex = 0
    if m.focusIndex >= m.categories.Count() then m.focusIndex = m.categories.Count() - 1
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0

    maxFirstIndex = m.categories.Count() - m.maxVisibleItems
    if maxFirstIndex < 0 then maxFirstIndex = 0

    if m.focusIndex < m.firstVisibleIndex then
        m.firstVisibleIndex = m.focusIndex
    else if m.focusIndex >= m.firstVisibleIndex + m.maxVisibleItems then
        m.firstVisibleIndex = m.focusIndex - m.maxVisibleItems + 1
    end if

    if m.firstVisibleIndex > maxFirstIndex then m.firstVisibleIndex = maxFirstIndex
end sub

sub updateFocus()
    for i = 0 to m.itemNodes.Count() - 1
        selected = (m.firstVisibleIndex + i) = m.focusIndex
        background = m.itemNodes[i].FindNode("itemBackground")
        accent = m.itemNodes[i].FindNode("itemAccent")
        label = m.itemNodes[i].FindNode("itemLabel")

        if selected then
            background.color = "#0B3A5E"
            background.opacity = 1.0
            accent.opacity = 1.0
            label.color = "#FFFFFF"
        else
            background.color = "#111827"
            background.opacity = 0.86
            accent.opacity = 0.45
            label.color = "#F8FAFC"
        end if
    end for
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
