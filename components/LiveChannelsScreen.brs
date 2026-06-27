' Live TV channel list screen.
' This screen displays channels for one category and notifies MainScene when a
' channel is selected for live playback.
sub Init()
    m.background = m.top.FindNode("background")
    m.topBar = m.top.FindNode("topBar")
    m.currentCategoryLabel = m.top.FindNode("currentCategoryLabel")
    m.dateLabel = m.top.FindNode("dateLabel")
    m.timeLabel = m.top.FindNode("timeLabel")
    m.leftPanelBackground = m.top.FindNode("leftPanelBackground")
    m.rightPanelBackground = m.top.FindNode("rightPanelBackground")
    m.divider = m.top.FindNode("divider")
    m.leftPanelTitle = m.top.FindNode("leftPanelTitle")
    m.middlePanelTitle = m.top.FindNode("middlePanelTitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.categoriesGroup = m.top.FindNode("categoriesGroup")
    m.channelsGroup = m.top.FindNode("channelsGroup")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.account = invalid
    m.categories = []
    m.categoryNodes = []
    m.categorySelectedIndex = 0
    m.categoryFirstVisibleIndex = 0
    m.focusColumn = "categories"
    m.channels = []
    m.allChannel = []
    m.searchQuery = ""
    m.itemNodes = []
    m.selectedIndex = 0
    m.firstVisibleIndex = 0

    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.safeMarginX = 44
    m.safeMarginY = 28
    m.topBarHeight = 70
    m.footerReservedHeight = 46
    if height <= 720 then
        m.safeMarginX = 30
        m.safeMarginY = 18
        m.topBarHeight = 58
        m.footerReservedHeight = 36
    end if

    m.contentX = m.safeMarginX
    m.contentY = m.safeMarginY + m.topBarHeight
    m.contentWidth = width - (m.safeMarginX * 2)
    m.contentHeight = height - m.contentY - m.footerReservedHeight - m.safeMarginY
    if m.contentWidth < 360 then
        m.contentX = 0
        m.contentWidth = width
    end if
    if m.contentHeight < 300 then m.contentHeight = height - m.contentY - m.footerReservedHeight

    m.leftPanelWidth = Int(m.contentWidth * 0.32)
    if m.leftPanelWidth < 260 then m.leftPanelWidth = 260
    if m.leftPanelWidth > 430 then m.leftPanelWidth = 430
    m.dividerWidth = 2
    m.middlePanelX = m.contentX + m.leftPanelWidth + m.dividerWidth
    m.middlePanelWidth = m.contentWidth - m.leftPanelWidth - m.dividerWidth
    m.leftTitleHeight = 44
    m.listY = m.contentY + m.leftTitleHeight
    m.listHeight = m.contentHeight - m.leftTitleHeight
    if m.listHeight < 96 then m.listHeight = 96

    if height <= 720 then
        m.itemHeight = 54
        m.cardHeight = 46
        m.logoSize = 32
        m.logoInset = 7
    else
        m.itemHeight = 64
        m.cardHeight = 54
        m.logoSize = 38
        m.logoInset = 8
    end if

    m.visibleItemCount = Int(m.listHeight / m.itemHeight)
    if m.visibleItemCount < 1 then m.visibleItemCount = 1

    m.background.width = width
    m.background.height = height

    m.topBar.width = m.contentWidth
    m.topBar.height = m.topBarHeight
    m.topBar.translation = [m.contentX, m.safeMarginY]

    m.currentCategoryLabel.width = Int(m.contentWidth * 0.55)
    m.currentCategoryLabel.height = m.topBarHeight
    m.currentCategoryLabel.font = "font:MediumBoldSystemFont"
    m.currentCategoryLabel.translation = [m.contentX + 22, m.safeMarginY]

    m.dateLabel.width = 210
    m.dateLabel.height = m.topBarHeight
    m.dateLabel.font = "font:SmallSystemFont"
    m.dateLabel.translation = [width - m.safeMarginX - 320, m.safeMarginY]

    m.timeLabel.width = 92
    m.timeLabel.height = m.topBarHeight
    m.timeLabel.font = "font:MediumBoldSystemFont"
    m.timeLabel.translation = [width - m.safeMarginX - 110, m.safeMarginY]
    updateHeaderClock()

    m.leftPanelBackground.width = m.leftPanelWidth
    m.leftPanelBackground.height = m.contentHeight
    m.leftPanelBackground.translation = [m.contentX, m.contentY]

    m.rightPanelBackground.width = m.middlePanelWidth
    m.rightPanelBackground.height = m.contentHeight
    m.rightPanelBackground.translation = [m.middlePanelX, m.contentY]

    m.divider.width = m.dividerWidth
    m.divider.height = m.contentHeight
    m.divider.translation = [m.middlePanelX - m.dividerWidth, m.contentY]

    m.leftPanelTitle.width = m.leftPanelWidth - 36
    m.leftPanelTitle.font = "font:MediumBoldSystemFont"
    m.leftPanelTitle.translation = [m.contentX + 18, m.contentY + 12]

    m.middlePanelTitle.width = m.middlePanelWidth - 36
    m.middlePanelTitle.font = "font:MediumBoldSystemFont"
    m.middlePanelTitle.translation = [m.middlePanelX + 18, m.contentY + 12]

    m.statusLabel.width = m.middlePanelWidth - 36
    m.statusLabel.font = "font:MediumSystemFont"
    m.statusLabel.translation = [m.middlePanelX + 18, m.listY + Int(m.listHeight / 2)]

    m.categoriesGroup.translation = [m.contentX + 14, m.listY]
    m.channelsGroup.translation = [m.middlePanelX + 14, m.listY]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, height - m.footerReservedHeight + 12]
end sub





sub updateHeaderClock()
    dateTime = CreateObject("roDateTime")
    dateTime.ToLocalTime()
    m.dateLabel.text = twoDigits(dateTime.GetDayOfMonth()) + "/" + twoDigits(dateTime.GetMonth()) + "/" + dateTime.GetYear().ToStr()
    m.timeLabel.text = twoDigits(dateTime.GetHours()) + ":" + twoDigits(dateTime.GetMinutes())
end sub

function twoDigits(value as Integer) as String
    text = value.ToStr()
    if value < 10 then text = "0" + text
    return text
end function

sub show(category as Dynamic)
    if category <> invalid then
        m.currentCategoryLabel.text = getCategoryName(category)
    else
        m.currentCategoryLabel.text = "Categoria Atual"
    end if

    m.searchQuery = ""
    m.focusColumn = "categories"
    selectCategory(category)
    configureLayout()
    applySearchFilter()
    renderCategories()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub selectCategory(category as Dynamic)
    if category = invalid or m.categories.Count() = 0 then
        m.categorySelectedIndex = 0
        updateCategoryVisibleWindow()
        return
    end if
    categoryId = getCategoryId(category)
    for i = 0 to m.categories.Count() - 1
        if getCategoryId(m.categories[i]) = categoryId then
            m.categorySelectedIndex = i
            updateCategoryVisibleWindow()
            return
        end if
    end for
end sub

sub focusCategories()
    m.focusColumn = "categories"
    updateFocus()
end sub

sub hide()
    m.top.visible = false
end sub

sub setAccount(account as Object)
    m.account = account
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
    clearChannelNodes()
    if isLoading then
        m.channels = []
        m.allChannel = []
        resetSelection()
        m.statusLabel.text = "Carregando canais de TV ao vivo..."
        m.statusLabel.color = "#B8C3D6"
    else
        m.statusLabel.text = ""
    end if
end sub

sub setChannels(channels as Object)
    m.allChannel = normalizeChannels(channels)
    applySearchFilter()

    if m.allChannel.Count() = 0 then
        showMessage("Nenhum canal foi encontrado nesta categoria.")
        return
    end if

    m.statusLabel.text = ""
    m.focusColumn = "channels"
    updateVisibleWindow()
    renderList()
    updateFocus()
end sub

sub setCategories(categories as Object)
    m.categories = normalizeCategories(categories)
    renderCategories()
    updateFocus()
end sub

sub showMessage(message as String)
    clearChannelNodes()
    m.channels = []
    m.allChannel = []
    resetSelection()
    m.statusLabel.text = message
    m.statusLabel.color = "#FFCC66"
end sub

function normalizeChannels(channels as Dynamic) as Object
    if channels = invalid then return []
    if Type(channels) = "roArray" then return channels
    return []
end function

function normalizeCategories(categories as Dynamic) as Object
    if categories = invalid then return []
    if Type(categories) = "roArray" then return categories
    return []
end function

sub renderCategories()
    clearCategoryNodes()
    totalRows = m.categories.Count()
    if totalRows = 0 then return

    lastIndex = m.categoryFirstVisibleIndex + m.visibleItemCount - 1
    if lastIndex >= totalRows then lastIndex = totalRows - 1

    for visualIndex = 0 to lastIndex - m.categoryFirstVisibleIndex
        realIndex = m.categoryFirstVisibleIndex + visualIndex
        item = createCategoryItem(m.categories[realIndex], visualIndex, realIndex)
        m.categoriesGroup.AppendChild(item)
        m.categoryNodes.Push(item)
    end for
end sub





sub clearCategoryNodes()
    while m.categoriesGroup.GetChildCount() > 0
        m.categoriesGroup.RemoveChildIndex(0)
    end while
    m.categoryNodes = []
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back" then
        if m.focusColumn = "channels" then
            m.focusColumn = "categories"
            updateFocus()
        else if m.searchQuery <> "" then
            m.searchQuery = ""
            applySearchFilter()
        else
            m.top.backRequested = true
        end if
        return true
    else if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
        return true
    else if key = "options" then
        if m.channels.Count() > 0 and m.selectedIndex >= 0 and m.selectedIndex < m.channels.Count() then
            m.top.channelFavoriteToggled = m.channels[m.selectedIndex]
            m.statusLabel.color = "#5CE08A"
            m.statusLabel.text = "Canal atualizado nos favoritos."
        end if
        return true
    else if key = "OK" then
        if m.focusColumn = "categories" then
            if m.categories.Count() > 0 and m.categorySelectedIndex >= 0 and m.categorySelectedIndex < m.categories.Count() then
                m.top.categorySelected = m.categories[m.categorySelectedIndex]
                m.focusColumn = "channels"
                resetSelection()
                updateFocus()
            end if
        else if m.channels.Count() > 0 and m.selectedIndex >= 0 and m.selectedIndex < m.channels.Count() then
            itemIndex = m.selectedIndex
            print "OK opening selectedIndex="; itemIndex
            print "OK opening item="; getChannelLogTitle(m.channels[itemIndex])
                    m.top.channelSelected = m.channels[itemIndex]
        end if
        return true
    end if

    return false
end function

sub moveFocus(direction as Integer)
    if m.focusColumn = "categories" then
        handleCategoryUpDown(direction)
    else
        handleUpDown(direction)
    end if
end sub

sub handleCategoryUpDown(direction as Integer)
    if m.categories.Count() = 0 then return

    if direction > 0 then
        m.categorySelectedIndex = m.categorySelectedIndex + 1
    else if direction < 0 then
        m.categorySelectedIndex = m.categorySelectedIndex - 1
    else
        return
    end if

    previousFirstVisibleIndex = m.categoryFirstVisibleIndex
    updateCategoryVisibleWindow()

    if m.categoryFirstVisibleIndex <> previousFirstVisibleIndex then
        renderCategories()
    end if

    updateFocus()
end sub

sub updateCategoryVisibleWindow()
    totalRows = m.categories.Count()
    if totalRows = 0 then
        m.categorySelectedIndex = 0
        m.categoryFirstVisibleIndex = 0
        return
    end if
    if m.categorySelectedIndex < 0 then m.categorySelectedIndex = 0
    if m.categorySelectedIndex >= totalRows then m.categorySelectedIndex = totalRows - 1
    maxFirstIndex = totalRows - m.visibleItemCount
    if maxFirstIndex < 0 then maxFirstIndex = 0
    if m.categorySelectedIndex < m.categoryFirstVisibleIndex then
        m.categoryFirstVisibleIndex = m.categorySelectedIndex
    else if m.categorySelectedIndex >= m.categoryFirstVisibleIndex + m.visibleItemCount then
        m.categoryFirstVisibleIndex = m.categorySelectedIndex - m.visibleItemCount + 1
    end if
    if m.categoryFirstVisibleIndex > maxFirstIndex then m.categoryFirstVisibleIndex = maxFirstIndex
end sub

sub handleUpDown(direction as Integer)
    if m.channels.Count() = 0 then return

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
    totalRows = m.channels.Count()
    if totalRows = 0 then
        m.selectedIndex = 0
        m.firstVisibleIndex = 0
        return
    end if

    if m.selectedIndex < 0 then m.selectedIndex = 0
    if m.selectedIndex >= totalRows then m.selectedIndex = totalRows - 1
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0

    maxFirstIndex = totalRows - m.visibleItemCount
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
    selectedCategoryNode = invalid

    for i = 0 to m.categoryNodes.Count() - 1
        realIndex = m.categoryFirstVisibleIndex + i
        background = m.categoryNodes[i].FindNode("itemBackground")
        accent = m.categoryNodes[i].FindNode("itemAccent")
        label = m.categoryNodes[i].FindNode("itemLabel")

        m.categoryNodes[i].scale = [1.0, 1.0]
        background.color = "#111827"
        background.opacity = 0.86
        accent.opacity = 0.0
        label.color = "#F8FAFC"

        if realIndex = m.categorySelectedIndex then selectedCategoryNode = m.categoryNodes[i]
    end for

    if selectedCategoryNode <> invalid then
        background = selectedCategoryNode.FindNode("itemBackground")
        accent = selectedCategoryNode.FindNode("itemAccent")
        label = selectedCategoryNode.FindNode("itemLabel")

        selectedCategoryNode.scale = [1.02, 1.02]
        if m.focusColumn = "categories" then
            background.color = "#061F36"
            label.color = "#FFFFFF"
        else
            background.color = "#101A2C"
            label.color = "#B8C3D6"
        end if
        background.opacity = 1.0
        accent.opacity = 1.0
    end if

    ' Keep a single manual highlight: reset every visible item before
    ' applying the selectedIndex state to exactly one realIndex.
    for i = 0 to m.itemNodes.Count() - 1
        realIndex = m.firstVisibleIndex + i
        background = m.itemNodes[i].FindNode("itemBackground")
        accent = m.itemNodes[i].FindNode("itemAccent")
        label = m.itemNodes[i].FindNode("itemLabel")
        logoBackground = m.itemNodes[i].FindNode("logoBackground")

        m.itemNodes[i].scale = [1.0, 1.0]
        background.color = "#111827"
        background.opacity = 0.86
        accent.opacity = 0.0
        label.color = "#F8FAFC"
        if logoBackground <> invalid then logoBackground.color = "#1F2937"

        if realIndex = m.selectedIndex then selectedNode = m.itemNodes[i]
    end for

    if selectedNode <> invalid then
        background = selectedNode.FindNode("itemBackground")
        accent = selectedNode.FindNode("itemAccent")
        label = selectedNode.FindNode("itemLabel")
        logoBackground = selectedNode.FindNode("logoBackground")

        selectedNode.scale = [1.02, 1.02]
        if m.focusColumn = "channels" then
            background.color = "#061F36"
        else
            background.color = "#101A2C"
        end if
        background.opacity = 1.0
        accent.opacity = 1.0
        if m.focusColumn = "channels" then
            label.color = "#FFFFFF"
        else
            label.color = "#B8C3D6"
        end if
        if logoBackground <> invalid then logoBackground.color = "#063B66"
    end if

end sub






sub applySearchFilter()
    query = LCase(m.searchQuery.Trim())
    m.channels = []
    if query = "" then
        for each item in m.allChannel
            m.channels.Push(item)
        end for
    else
        for each item in m.allChannel
            if Instr(1, LCase(getChannelName(item)), query) > 0 then m.channels.Push(item)
        end for
    end if
    resetSelection()
    if m.allChannel.Count() > 0 and m.channels.Count() = 0 then
        m.statusLabel.color = "#FFCC66"
        m.statusLabel.text = "Nenhum resultado encontrado para esta busca."
    else
        m.statusLabel.text = ""
    end if
    updateVisibleWindow()
    renderList()
    updateFocus()
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
