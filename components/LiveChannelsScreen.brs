' Clean Live TV screen: title, categories panel and channels panel only.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.leftPanel = m.top.FindNode("leftPanel")
    m.rightPanel = m.top.FindNode("rightPanel")
    m.categoriesTitle = m.top.FindNode("categoriesTitle")
    m.channelsTitle = m.top.FindNode("channelsTitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.categoriesGroup = m.top.FindNode("categoriesGroup")
    m.channelsGroup = m.top.FindNode("channelsGroup")
    m.hintLabel = m.top.FindNode("hintLabel")
    m.progressiveLoadTimer = m.top.FindNode("progressiveLoadTimer")
    m.progressiveLoadTimer.ObserveField("fire", "onProgressiveLoadTimerFire")

    m.account = invalid
    m.categories = []
    m.channels = []
    m.allChannels = []
    m.initialRenderLimit = 50 : m.progressiveBatchSize = 25 : m.renderLimit = 50
    m.categoryNodes = []
    m.channelNodes = []
    m.selectedCategoryIndex = 0
    m.firstVisibleCategoryIndex = 0
    m.selectedChannelIndex = 0
    m.firstVisibleChannelIndex = 0
    m.activePane = "categories"

    configureLayout()
end sub

sub configureLayout()
    r = getDisplayResolution() : w = r.width : h = r.height
    m.margin = 72 : m.titleH = 118 : m.footerH = 54 : m.gap = 18
    if h <= 720 then m.margin = 48 : m.titleH = 92 : m.footerH = 42 : m.gap = 14

    m.panelY = m.titleH
    m.panelH = h - m.titleH - m.footerH - 18
    m.contentW = w - (m.margin * 2)
    m.leftW = Int(m.contentW * 0.34)
    if m.leftW < 280 then m.leftW = 280
    m.rightX = m.margin + m.leftW + m.gap
    m.rightW = m.contentW - m.leftW - m.gap
    m.headerH = 58
    m.itemH = 54
    if h <= 720 then m.headerH = 48 : m.itemH = 44
    m.listY = m.panelY + m.headerH
    m.listH = m.panelH - m.headerH
    m.visibleCount = Int(m.listH / m.itemH)
    if m.visibleCount < 1 then m.visibleCount = 1

    m.background.width = w : m.background.height = h
    m.title.translation = [0, 34] : m.title.width = w : m.title.font = "font:LargeBoldSystemFont"
    if h <= 720 then m.title.translation = [0, 24]

    m.leftPanel.translation = [m.margin, m.panelY] : m.leftPanel.width = m.leftW : m.leftPanel.height = m.panelH
    m.rightPanel.translation = [m.rightX, m.panelY] : m.rightPanel.width = m.rightW : m.rightPanel.height = m.panelH
    m.categoriesTitle.translation = [m.margin + 18, m.panelY + 18] : m.categoriesTitle.font = "font:MediumBoldSystemFont"
    m.channelsTitle.translation = [m.rightX + 18, m.panelY + 18] : m.channelsTitle.font = "font:MediumBoldSystemFont"
    m.statusLabel.translation = [m.rightX + 18, m.listY + Int(m.listH / 2)] : m.statusLabel.width = m.rightW - 36 : m.statusLabel.font = "font:MediumSystemFont"
    m.categoriesGroup.translation = [m.margin + 18, m.listY]
    m.channelsGroup.translation = [m.rightX + 18, m.listY]
    m.hintLabel.translation = [0, h - 38] : m.hintLabel.width = w : m.hintLabel.font = "font:SmallSystemFont"
end sub

sub show(category as Dynamic)
    configureLayout()
    if category <> invalid then syncSelectedCategory(category)
    renderCategories()
    renderChannels()
    updateFocus()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub setAccount(account as Object)
    m.account = account
end sub

sub resetSelection()
    m.selectedCategoryIndex = 0 : m.firstVisibleCategoryIndex = 0
    m.selectedChannelIndex = 0 : m.firstVisibleChannelIndex = 0
    m.activePane = "categories"
end sub

sub focusCategories()
    m.activePane = "categories" : updateFocus()
end sub

sub focusChannels()
    if m.channels.Count() > 0 then
        m.activePane = "channels"
        m.selectedChannelIndex = 0
        m.firstVisibleChannelIndex = 0
        renderChannels()
    end if
    updateFocus()
end sub

sub setCategories(categories as Object)
    m.categories = normalizeArray(categories)
    updateCategoryWindow()
    renderCategories()
    updateFocus()
end sub

sub setLoading(isLoading as Boolean)
    if m.progressiveLoadTimer <> invalid then m.progressiveLoadTimer.control = "stop"
    clearChannelNodes()
    m.channels = [] : m.allChannels = [] : m.renderLimit = m.initialRenderLimit
    m.selectedChannelIndex = 0 : m.firstVisibleChannelIndex = 0
    if isLoading then
        m.statusLabel.color = "#B8C3D6" : m.statusLabel.text = "Carregando canais..."
    else
        m.statusLabel.text = ""
    end if
    updateFocus()
end sub

sub setChannels(channels as Object)
    if m.progressiveLoadTimer <> invalid then m.progressiveLoadTimer.control = "stop"
    m.allChannels = normalizeArray(channels) : m.renderLimit = m.initialRenderLimit
    rebuildVisibleChannels()
    m.selectedChannelIndex = 0 : m.firstVisibleChannelIndex = 0
    if m.channels.Count() = 0 then
        showMessage("Nenhum canal foi encontrado nesta categoria.")
        return
    end if
    m.statusLabel.text = ""
    renderChannels()
    updateFocus()
    if m.channels.Count() < m.allChannels.Count() and m.progressiveLoadTimer <> invalid then m.progressiveLoadTimer.control = "start"
end sub

sub onProgressiveLoadTimerFire()
    if m.allChannels = invalid or m.channels.Count() >= m.allChannels.Count() then
        if m.progressiveLoadTimer <> invalid then m.progressiveLoadTimer.control = "stop"
        return
    end if
    m.renderLimit = m.renderLimit + m.progressiveBatchSize
    rebuildVisibleChannels()
    renderChannels() : updateFocus()
end sub

sub rebuildVisibleChannels()
    m.channels = []
    if m.allChannels = invalid then return
    last = m.renderLimit - 1
    if last >= m.allChannels.Count() then last = m.allChannels.Count() - 1
    if last < 0 then return
    for i = 0 to last
        if i >= 0 then m.channels.Push(m.allChannels[i])
    end for
end sub

sub showMessage(message as String)
    clearChannelNodes()
    m.channels = []
    m.selectedChannelIndex = 0 : m.firstVisibleChannelIndex = 0
    m.statusLabel.color = "#FFCC66" : m.statusLabel.text = message
    updateFocus()
end sub

sub restoreSelectedChannel(channel as Dynamic)
    if channel <> invalid and m.channels.Count() > 0 then
        id = getChannelId(channel) : name = getChannelName(channel)
        for i = 0 to m.channels.Count() - 1
            if getChannelId(m.channels[i]) = id or getChannelName(m.channels[i]) = name then m.selectedChannelIndex = i : exit for
        end for
        updateChannelWindow() : renderChannels() : m.activePane = "channels"
    end if
    updateFocus()
end sub

sub renderCategories()
    clearCategoryNodes()
    if m.categories.Count() = 0 then return
    updateCategoryWindow()
    lastIndex = m.firstVisibleCategoryIndex + m.visibleCount - 1
    if lastIndex >= m.categories.Count() then lastIndex = m.categories.Count() - 1
    for visualIndex = 0 to lastIndex - m.firstVisibleCategoryIndex
        realIndex = m.firstVisibleCategoryIndex + visualIndex
        node = createTextItem(getCategoryName(m.categories[realIndex]), visualIndex, m.leftW - 36)
        m.categoriesGroup.AppendChild(node) : m.categoryNodes.Push(node)
    end for
end sub

sub renderChannels()
    clearChannelNodes()
    if m.channels.Count() = 0 then return
    updateChannelWindow()
    lastIndex = m.firstVisibleChannelIndex + m.visibleCount - 1
    if lastIndex >= m.channels.Count() then lastIndex = m.channels.Count() - 1
    for visualIndex = 0 to lastIndex - m.firstVisibleChannelIndex
        realIndex = m.firstVisibleChannelIndex + visualIndex
        node = createTextItem(getChannelName(m.channels[realIndex]), visualIndex, m.rightW - 36)
        m.channelsGroup.AppendChild(node) : m.channelNodes.Push(node)
    end for
end sub

function createTextItem(text as String, visibleIndex as Integer, itemW as Integer) as Object
    item = CreateObject("roSGNode", "Group") : item.translation = [0, visibleIndex * m.itemH]
    bg = CreateObject("roSGNode", "Rectangle") : bg.id = "itemBackground" : bg.width = itemW : bg.height = m.itemH - 8 : bg.color = "#111827" : bg.opacity = 0.0
    label = CreateObject("roSGNode", "Label") : label.id = "itemLabel" : label.translation = [14, 0] : label.width = itemW - 28 : label.height = m.itemH - 8 : label.vertAlign = "center" : label.font = "font:SmallSystemFont" : label.color = "#C9D4E5" : label.text = text
    item.AppendChild(bg) : item.AppendChild(label)
    return item
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then
        if m.activePane = "channels" then
            m.activePane = "categories"
            updateFocus()
        else
            m.top.backRequested = true
        end if
        return true
    else if key = "left" then
        if m.activePane = "channels" then
            m.activePane = "categories"
            updateFocus()
        end if
        return true
    else if key = "right" then
        if m.activePane = "categories" then
            focusChannels()
        end if
        return true
    else if key = "up" then
        if m.activePane = "categories" then
            moveCategory(-1)
        else
            moveChannel(-1)
        end if
        return true
    else if key = "down" then
        if m.activePane = "categories" then
            moveCategory(1)
        else
            moveChannel(1)
        end if
        return true
    else if key = "options" then
        m.top.searchRequested = true
        return true
    else if key = "play" or key = "pause" or key = "replay" then
        toggleSelectedChannelFavorite()
        return true
    else if key = "OK" then
        if m.activePane = "categories" then
            if m.channels.Count() > 0 then
                focusChannels()
            else if m.categories.Count() > 0 then
                m.top.categorySelected = m.categories[m.selectedCategoryIndex]
            end if
        else if m.channels.Count() > 0 then
            m.top.channelSelected = m.channels[m.selectedChannelIndex]
        end if
        return true
    end if
    return false
end function

sub toggleSelectedChannelFavorite()
    if m.channels.Count() = 0 then return
    if m.selectedChannelIndex < 0 or m.selectedChannelIndex >= m.channels.Count() then return
    m.top.channelFavoriteToggled = m.channels[m.selectedChannelIndex]
end sub

sub moveCategory(direction as Integer)
    if m.categories.Count() = 0 then return
    oldId = ""
    if m.selectedCategoryIndex >= 0 and m.selectedCategoryIndex < m.categories.Count() then
        oldId = getCategoryId(m.categories[m.selectedCategoryIndex])
    end if
    m.selectedCategoryIndex = m.selectedCategoryIndex + direction
    updateCategoryWindow()
    renderCategories()
    updateFocus()
    newId = getCategoryId(m.categories[m.selectedCategoryIndex])
    if newId <> oldId then m.top.categorySelected = m.categories[m.selectedCategoryIndex]
end sub

sub moveChannel(direction as Integer)
    if m.channels.Count() = 0 then return
    m.selectedChannelIndex = m.selectedChannelIndex + direction
    updateChannelWindow()
    renderChannels()
    updateFocus()
end sub

sub updateCategoryWindow()
    updateWindow("category")
end sub

sub updateChannelWindow()
    updateWindow("channel")
end sub

sub updateWindow(kind as String)
    if kind = "category" then
        count = m.categories.Count() : selected = m.selectedCategoryIndex : first = m.firstVisibleCategoryIndex
    else
        count = m.channels.Count() : selected = m.selectedChannelIndex : first = m.firstVisibleChannelIndex
    end if
    if count = 0 then
        selected = 0
        first = 0
    else
        if selected < 0 then selected = 0
        if selected >= count then selected = count - 1
        if selected < first then first = selected
        if selected >= first + m.visibleCount then first = selected - m.visibleCount + 1
        maxFirst = count - m.visibleCount : if maxFirst < 0 then maxFirst = 0
        if first > maxFirst then first = maxFirst
    end if
    if kind = "category" then
        m.selectedCategoryIndex = selected : m.firstVisibleCategoryIndex = first
    else
        m.selectedChannelIndex = selected : m.firstVisibleChannelIndex = first
    end if
end sub

sub updateFocus()
    for i = 0 to m.categoryNodes.Count() - 1
        applyItemFocus(m.categoryNodes[i], m.firstVisibleCategoryIndex + i = m.selectedCategoryIndex, m.activePane = "categories")
    end for
    for i = 0 to m.channelNodes.Count() - 1
        applyItemFocus(m.channelNodes[i], m.firstVisibleChannelIndex + i = m.selectedChannelIndex, m.activePane = "channels")
    end for
    m.top.SetFocus(true)
end sub

sub applyItemFocus(node as Object, selected as Boolean, active as Boolean)
    bg = node.FindNode("itemBackground") : label = node.FindNode("itemLabel")
    bg.opacity = 0.0 : label.color = "#C9D4E5" : node.scale = [1.0, 1.0]
    if selected then
        bg.opacity = 1.0 : bg.color = "#0B5CAD" : label.color = "#FFFFFF"
        if active then node.scale = [1.03, 1.03]
    end if
end sub

sub clearCategoryNodes()
    while m.categoriesGroup.GetChildCount() > 0 : m.categoriesGroup.RemoveChildIndex(0) : end while
    m.categoryNodes = []
end sub

sub clearChannelNodes()
    while m.channelsGroup.GetChildCount() > 0 : m.channelsGroup.RemoveChildIndex(0) : end while
    m.channelNodes = []
end sub

sub syncSelectedCategory(category as Dynamic)
    id = getCategoryId(category)
    for i = 0 to m.categories.Count() - 1
        if getCategoryId(m.categories[i]) = id then m.selectedCategoryIndex = i : exit for
    end for
    updateCategoryWindow()
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

function getChannelId(channel as Dynamic) as String
    if channel = invalid then return ""
    if channel.stream_id <> invalid then return channel.stream_id.ToStr()
    if channel.id <> invalid then return channel.id.ToStr()
    return ""
end function

function getChannelName(channel as Dynamic) as String
    if channel = invalid then return "Canal sem nome"
    if channel.name <> invalid and channel.name.ToStr().Trim() <> "" then return channel.name.ToStr()
    if channel.title <> invalid and channel.title.ToStr().Trim() <> "" then return channel.title.ToStr()
    return "Canal sem nome"
end function

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()
    return { width: displaySize.w, height: displaySize.h }
end function
