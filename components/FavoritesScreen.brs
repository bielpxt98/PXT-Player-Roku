' Favorites screen with locally saved live, movie, and series favorites.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.favoritesGroup = m.top.FindNode("favoritesGroup")
    m.hintLabel = m.top.FindNode("hintLabel")
    m.items = []
    m.itemNodes = []
    m.selectedIndex = 0
    m.firstVisibleIndex = 0
    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height
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
    m.titleY = 42
    m.subtitleY = 100
    if height <= 720 then
        m.titleY = 28
        m.subtitleY = 78
    end if
    m.listY = m.titleReservedHeight
    m.footerY = height - m.footerReservedHeight + 18
    m.listHeight = m.footerY - m.listY - 20
    if m.listHeight < 96 then m.listHeight = 96
    m.itemHeight = 76
    m.cardHeight = 64
    if height <= 720 then
        m.itemHeight = 64
        m.cardHeight = 54
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
    m.favoritesGroup.translation = [m.contentX, m.listY]
    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, m.footerY]
end sub

sub show()
    configureLayout()
    m.top.visible = true
    m.top.SetFocus(true)
    updateVisibleWindow()
    renderList()
    updateFocus()
end sub

sub hide()
    m.top.visible = false
end sub

sub setFavorites(favorites as Object)
    m.items = flattenFavorites(favorites)
    m.selectedIndex = 0
    m.firstVisibleIndex = 0
    if m.items.Count() = 0 then
        clearFavoriteNodes()
        m.statusLabel.text = "Nenhum favorito salvo neste dispositivo."
        m.statusLabel.color = "#FFCC66"
        return
    end if
    m.statusLabel.text = ""
    updateVisibleWindow()
    renderList()
    updateFocus()
end sub

function flattenFavorites(favorites as Dynamic) as Object
    items = []
    appendSection(items, "TV AO VIVO", favorites.live)
    appendSection(items, "FILMES", favorites.movies)
    appendSection(items, "SÉRIES", favorites.series)
    return items
end function

sub appendSection(items as Object, title as String, entries as Dynamic)
    if entries = invalid or Type(entries) <> "roArray" or entries.Count() = 0 then return
    items.Push({ isHeader: true, title: title })
    for each entry in entries
        items.Push(entry)
    end for
end sub

sub renderList()
    clearFavoriteNodes()
    if m.items.Count() = 0 then return
    lastIndex = m.firstVisibleIndex + m.visibleItemCount - 1
    if lastIndex >= m.items.Count() then lastIndex = m.items.Count() - 1
    for visualIndex = 0 to lastIndex - m.firstVisibleIndex
        realIndex = m.firstVisibleIndex + visualIndex
        node = createFavoriteItem(m.items[realIndex], visualIndex, realIndex)
        m.favoritesGroup.AppendChild(node)
        m.itemNodes.Push(node)
    end for
end sub

function createFavoriteItem(favorite as Object, visibleIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group")
    item.translation = [0, visibleIndex * m.itemHeight]
    item.id = "favoriteItem" + absoluteIndex.ToStr()
    background = CreateObject("roSGNode", "Rectangle")
    background.id = "itemBackground"
    background.width = m.contentWidth
    background.height = m.cardHeight
    background.color = "#111827"
    background.opacity = 0.86
    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel"
    label.width = m.contentWidth - 48
    label.height = m.cardHeight
    label.translation = [24, 0]
    label.vertAlign = "center"
    label.color = "#F8FAFC"
    label.font = "font:MediumSystemFont"
    if favorite.isHeader = true then
        background.opacity = 0.0
        label.color = "#FFCC66"
        label.text = favorite.title
    else
        label.text = favorite.title
    end if
    item.AppendChild(background)
    item.AppendChild(label)
    return item
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    normalizedKey = normalizeKey(key)
    if normalizedKey = "back" then
        m.top.backRequested = true
        return true
    end if
    if normalizedKey = "up" then
        moveFocus(-1)
        return true
    end if
    if normalizedKey = "down" then
        moveFocus(1)
        return true
    end if
    if normalizedKey = "OK" then
        if canSelectIndex(m.selectedIndex) then m.top.favoriteSelected = m.items[m.selectedIndex]
        return true
    end if
    return false
end function

sub moveFocus(direction as Integer)
    if m.items.Count() = 0 then return
    nextIndex = m.selectedIndex
    for i = 0 to m.items.Count() - 1
        nextIndex = nextIndex + direction
        if nextIndex < 0 then nextIndex = m.items.Count() - 1
        if nextIndex >= m.items.Count() then nextIndex = 0
        if canSelectIndex(nextIndex) then exit for
    end for
    m.selectedIndex = nextIndex
    previousFirstVisibleIndex = m.firstVisibleIndex
    updateVisibleWindow()
    if m.firstVisibleIndex <> previousFirstVisibleIndex then renderList()
    updateFocus()
end sub

function canSelectIndex(index as Integer) as Boolean
    if index < 0 or index >= m.items.Count() then return false
    return m.items[index].isHeader <> true
end function

sub updateVisibleWindow()
    if m.items.Count() = 0 then
        m.selectedIndex = 0
        m.firstVisibleIndex = 0
        return
    end if
    if not canSelectIndex(m.selectedIndex) then
        moveFocus(1)
        return
    end if
    maxFirstIndex = m.items.Count() - m.visibleItemCount
    if maxFirstIndex < 0 then maxFirstIndex = 0
    if m.selectedIndex < m.firstVisibleIndex then m.firstVisibleIndex = m.selectedIndex
    if m.selectedIndex >= m.firstVisibleIndex + m.visibleItemCount then m.firstVisibleIndex = m.selectedIndex - m.visibleItemCount + 1
    if m.firstVisibleIndex > maxFirstIndex then m.firstVisibleIndex = maxFirstIndex
end sub

sub updateFocus()
    for i = 0 to m.itemNodes.Count() - 1
        realIndex = m.firstVisibleIndex + i
        bg = m.itemNodes[i].FindNode("itemBackground")
        label = m.itemNodes[i].FindNode("itemLabel")
        if m.items[realIndex].isHeader = true then
            bg.opacity = 0.0
            label.color = "#FFCC66"
        else
            bg.color = "#111827"
            bg.opacity = 0.86
            label.color = "#F8FAFC"
        end if
        if realIndex = m.selectedIndex then
            bg.color = "#0B3A5E"
            bg.opacity = 1.0
            label.color = "#FFFFFF"
        end if
    end for
end sub

sub clearFavoriteNodes()
    while m.favoritesGroup.GetChildCount() > 0
        m.favoritesGroup.RemoveChildIndex(0)
    end while
    m.itemNodes = []
end sub
