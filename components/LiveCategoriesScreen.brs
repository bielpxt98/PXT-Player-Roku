' Live TV category list screen.
' This screen only displays category metadata; channels and playback are intentionally out of scope.
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
    m.maxVisibleItems = 8
    m.itemHeight = 70

    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, Int(height * 0.08)]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, Int(height * 0.18)]

    m.statusLabel.width = width
    m.statusLabel.font = "font:MediumSystemFont"
    m.statusLabel.translation = [0, Int(height * 0.44)]

    m.categoriesGroup.translation = [Int((width - 760) / 2), Int(height * 0.26)]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, Int(height * 0.91)]
end sub

sub show()
    m.top.visible = true
    updateFocus()
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
    lastIndex = m.firstVisibleIndex + m.maxVisibleItems - 1
    if lastIndex >= m.categories.Count() then lastIndex = m.categories.Count() - 1

    for i = m.firstVisibleIndex to lastIndex
        item = createCategoryItem(m.categories[i], i - m.firstVisibleIndex)
        m.categoriesGroup.AppendChild(item)
        m.itemNodes.Push(item)
    end for

    updateFocus()
end sub

function createCategoryItem(category as Object, visibleIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group")
    item.translation = [0, visibleIndex * m.itemHeight]

    background = CreateObject("roSGNode", "Rectangle")
    background.id = "itemBackground"
    background.width = 760
    background.height = 58
    background.color = "#111827"
    background.opacity = 0.86

    accent = CreateObject("roSGNode", "Rectangle")
    accent.id = "itemAccent"
    accent.width = 6
    accent.height = 58
    accent.color = "#009DFF"
    accent.opacity = 0.45

    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel"
    label.width = 720
    label.height = 58
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

    if m.focusIndex < m.firstVisibleIndex then
        m.firstVisibleIndex = m.focusIndex
        renderVisibleItems()
    else if m.focusIndex >= m.firstVisibleIndex + m.maxVisibleItems then
        m.firstVisibleIndex = m.focusIndex - m.maxVisibleItems + 1
        renderVisibleItems()
    else
        updateFocus()
    end if
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
